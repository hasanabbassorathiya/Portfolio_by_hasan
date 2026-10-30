<?php
declare(strict_types=1);
// Disposable integration harness only. Never includes the project's config.php.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
function test_connection(string $socket, string $database = ''): PDO {
    return new PDO('mysql:unix_socket=' . $socket . ($database ? ';dbname=' . $database : '') . ';charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
}
function run_enquiry_database_tests(): void {
    $socket = (string)getenv('ENQUIRY_TEST_SOCKET');
    if (!preg_match('~^/(?:private/)?tmp/enquiry-[a-zA-Z0-9./_-]+\.sock$~D', $socket)) throw new RuntimeException('Only an explicit disposable /tmp/enquiry-* socket is allowed');
    $database = 'enquiry_test_' . bin2hex(random_bytes(6));
    $root = test_connection($socket);
    $root->exec('CREATE DATABASE `' . $database . '` CHARACTER SET utf8mb4');
    try {
        $pdo = test_connection($socket, $database);
        $schema = file_get_contents(__DIR__ . '/../api/enquiries-schema.sql');
        check(is_string($schema), 'additive migration exists');
        $pdo->exec($schema);
        $pdo->exec($schema); // The additive import can be safely repeated.
        $hash = enquiry_ip_hash('127.0.0.1', 'test-pepper');
        $one = enquiry_submit($pdo, validated(fixture()), $hash);
        check((bool)preg_match('/^[a-f0-9]{32}$/D', $one), 'opaque reference');
        check((int)$pdo->query('SELECT COUNT(*) FROM enquiries')->fetchColumn() === 1, 'durable enquiry');
        check((int)$pdo->query('SELECT COUNT(*) FROM enquiry_outbox')->fetchColumn() === 2, 'owner and ack persisted');
        check(enquiry_submit($pdo, validated(fixture()), $hash) === $one, 'idempotent same reference');
        rejects(fn() => enquiry_submit($pdo, validated(array_replace(fixture(), ['message' => 'This is a different project message.'])), $hash), 409, 'idempotency conflict');
        rejects(fn() => enquiry_submit($pdo, validated(array_replace(fixture(), ['name' => ' Test Person '])), $hash), 409, 'different raw payload is conflict');
        for ($i = 2; $i <= 5; $i++) enquiry_submit($pdo, validated(fixture($i)), $hash);
        rejects(fn() => enquiry_submit($pdo, validated(fixture(6)), $hash), 429, 'sixth enquiry throttled');
        check(enquiry_submit($pdo, validated(fixture()), $hash) === $one, 'retry succeeds even when throttled');
        check((int)$pdo->query('SELECT COUNT(*) FROM enquiry_outbox')->fetchColumn() === 10, 'retry does not duplicate notifications');
        $pdo->exec("UPDATE enquiries SET created_at = UTC_TIMESTAMP() - INTERVAL 61 MINUTE");
        enquiry_submit($pdo, validated(fixture(6)), $hash);
        check((int)$pdo->query('SELECT COUNT(*) FROM enquiries')->fetchColumn() === 6, 'rolling window expires');
        $pdo->exec("CREATE TRIGGER fail_ack BEFORE INSERT ON enquiry_outbox FOR EACH ROW BEGIN IF NEW.kind = 'ack' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'test rollback'; END IF; END");
        try { enquiry_submit($pdo, validated(fixture(7)), $hash); throw new RuntimeException('FAIL: outbox failure accepted'); }
        catch (PDOException $e) { check(true, 'outbox failure surfaced'); }
        check((int)$pdo->query('SELECT COUNT(*) FROM enquiries')->fetchColumn() === 6, 'outbox failure rolls back enquiry');
        check((int)$pdo->query('SELECT COUNT(*) FROM enquiry_outbox')->fetchColumn() === 12, 'outbox failure rolls back owner row');
        $pdo->exec('DROP TRIGGER fail_ack');
        enquiry_update($pdo, 1, 1, ['status' => 'qualified', 'notes' => '<script>private</script>', 'next_action' => 'Discuss proposal', 'follow_up_date' => '2028-02-29'], 9);
        $detail = enquiry_detail($pdo, 1);
        check($detail['status'] === 'qualified' && $detail['notes'] === '<script>private</script>' && (int)$detail['updated_by'] === 9, 'private update persisted');
        rejects(fn() => enquiry_update($pdo, 1, 1, ['status' => 'closed', 'notes' => '', 'next_action' => '', 'follow_up_date' => ''], 9), 409, 'stale admin edit rejected');
        check(count(enquiry_list($pdo, 1, 'qualified')['rows']) === 1, 'status list filter');
        check(enquiry_detail($pdo, 99999) === null, 'missing private record');

        $settings = enquiry_mail_settings('owner@example.test', 'from@example.test');
        $before = $pdo->query('SELECT * FROM enquiry_outbox ORDER BY id')->fetchAll();
        $events = [];
        $log = static function(int $id, string $status) use (&$events): void { $events[] = [$id, $status]; };
        $never = static function(array $mail): bool { throw new RuntimeException('FAIL: dry-run invoked transport'); };
        enquiry_worker($pdo, false, 2, null, false, $settings, $never, $log);
        check($before === $pdo->query('SELECT * FROM enquiry_outbox ORDER BY id')->fetchAll(), 'dry-run does not mutate any outbox state');
        check(count($events) === 2 && $events[0][1] === 'dry-run', 'bounded dry-run reporting');
        enquiry_worker($pdo, true, 1, null, false, $settings, static fn(array $mail): bool => false, $log);
        $failed = $pdo->query('SELECT * FROM enquiry_outbox WHERE id = 1')->fetch();
        check($failed['status'] === 'failed' && (int)$failed['attempts'] === 1 && $failed['next_attempt_at'] !== null, 'rejected transport schedules backoff');
        $pdo->exec('UPDATE enquiry_outbox SET next_attempt_at = UTC_TIMESTAMP() - INTERVAL 1 SECOND WHERE id = 1');
        enquiry_worker($pdo, true, 1, null, false, $settings, static fn(array $mail): bool => true, $log);
        check($pdo->query('SELECT status FROM enquiry_outbox WHERE id = 1')->fetchColumn() === 'sent', 'fake accepted transport is marked sent');
        $pdo->exec("UPDATE enquiry_outbox SET status='processing', claimed_at=UTC_TIMESTAMP(), claim_token=REPEAT('a',32), attempts=1 WHERE id=2");
        enquiry_worker($pdo, true, 1, null, false, $settings, static fn(array $mail): bool => true, $log);
        $unknown = $pdo->query('SELECT * FROM enquiry_outbox WHERE id=2')->fetch();
        check($unknown['status'] === 'failed' && $unknown['last_error'] === 'acceptance_unknown' && $unknown['next_attempt_at'] === null, 'interrupted claim is never automatically resent');
        rejects(fn() => enquiry_worker($pdo, true, 1, 2, false, $settings, $never, $log), 409, 'ambiguous retry needs duplicate acknowledgement');
        enquiry_worker($pdo, true, 1, 2, true, $settings, static fn(array $mail): bool => true, $log);
        check($pdo->query('SELECT status FROM enquiry_outbox WHERE id=2')->fetchColumn() === 'sent', 'explicit ambiguous retry recovery');
        rejects(fn() => enquiry_worker($pdo, true, 1, 2, true, $settings, $never, $log), 409, 'sent row cannot be replayed');
        $pdo->exec("UPDATE enquiry_outbox SET attempts=4, next_attempt_at=UTC_TIMESTAMP() WHERE id=4");
        enquiry_worker($pdo, true, 1, null, false, $settings, static fn(array $mail): bool => false, $log);
        $exhausted = $pdo->query('SELECT * FROM enquiry_outbox WHERE id=4')->fetch();
        check((int)$exhausted['attempts'] === 5 && $exhausted['next_attempt_at'] === null, 'automatic attempts are bounded');
        enquiry_worker($pdo, true, 1, 4, false, $settings, static function(array $mail): bool { throw new RuntimeException('private transport diagnostic'); }, $log);
        check($pdo->query('SELECT last_error FROM enquiry_outbox WHERE id=4')->fetchColumn() === 'acceptance_unknown', 'transport exception quarantines ambiguous acceptance');
        // A second actual connection cannot acquire the global worker claim.
        $second = test_connection($socket, $database);
        $lock = enquiry_worker_lock_name($pdo);
        $st = $second->prepare('SELECT GET_LOCK(?, 0)'); $st->execute([$lock]);
        $before = $pdo->query('SELECT * FROM enquiry_outbox ORDER BY id')->fetchAll();
        rejects(fn() => enquiry_worker($pdo, true, 1, null, false, $settings, $never, $log), 409, 'concurrent worker excluded');
        check($before === $pdo->query('SELECT * FROM enquiry_outbox ORDER BY id')->fetchAll(), 'busy worker does not mutate claims');
        $st = $second->prepare('SELECT RELEASE_LOCK(?)'); $st->execute([$lock]);
        $pdo->exec("CREATE TRIGGER fail_accept BEFORE UPDATE ON enquiry_outbox FOR EACH ROW BEGIN IF NEW.id=5 AND NEW.status='sent' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='test acceptance write failure'; END IF; END");
        try { enquiry_worker($pdo, true, 1, null, false, $settings, static fn(array $mail): bool => true, $log); throw new RuntimeException('FAIL: acceptance write failure hidden'); }
        catch (PDOException $e) { check(true, 'accepted mail followed by database error surfaces'); }
        check($pdo->query('SELECT status FROM enquiry_outbox WHERE id=5')->fetchColumn() === 'processing', 'acceptance write failure preserves claim');
        $pdo->exec('DROP TRIGGER fail_accept');
        enquiry_worker($pdo, true, 1, null, false, $settings, static fn(array $mail): bool => true, $log);
        check($pdo->query('SELECT last_error FROM enquiry_outbox WHERE id=5')->fetchColumn() === 'acceptance_unknown', 'post-acceptance DB failure quarantines instead of duplicate send');
        run_enquiry_concurrency_tests($pdo, $socket, $database);
        for ($n = 300; $n < 330; $n++) enquiry_submit($pdo, validated(fixture($n)), enquiry_ip_hash('198.51.100.' . ($n - 299), 'test-pepper'));
        $page = enquiry_list($pdo, 1);
        check(count($page['rows']) === 25 && $page['has_more'], 'private page size capped at 25');
        check(count(enquiry_list($pdo, 2)['rows']) === 18, 'private next page has remaining records');
        check(enquiry_list($pdo, 10001)['page'] === 10000, 'store caps pagination depth');
        run_enquiry_http_tests($pdo, $socket, $database);
        print "PASS: real MariaDB persistence, outbox, retry, worker locks, concurrent intake, HTTP/admin/CLI integration\n";
    } finally {
        $root->exec('DROP DATABASE `' . $database . '`');
    }
}

function run_enquiry_concurrency_tests(PDO $pdo, string $socket, string $database): void {
    $code = <<<'PHP'
require $argv[1];
$p = new PDO('mysql:unix_socket=' . $argv[2] . ';dbname=' . $argv[3] . ';charset=utf8mb4', 'root', '', [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
try { print '201:' . enquiry_submit($p, enquiry_validate($argv[4]), enquiry_ip_hash($argv[5], 'test-pepper')); }
catch (EnquiryError $e) { print $e->httpStatus; }
PHP;
    foreach (['throttle', 'idempotency', 'cross-ip-idempotency'] as $scenario) {
        $processes = [];
        for ($i = 0; $i < 8; $i++) {
            $ip = $scenario === 'cross-ip-idempotency' ? '192.0.2.' . ($i + 1) : ($scenario === 'throttle' ? '192.0.2.100' : '192.0.2.101');
            $number = $scenario === 'throttle' ? 100 + $i : ($scenario === 'idempotency' ? 110 : 111);
            $proc = proc_open([PHP_BINARY, '-r', $code, __DIR__ . '/../api/enquiry-store.php', $socket, $database, json_encode(fixture($number)), $ip], [0=>['pipe','r'], 1=>['pipe','w'], 2=>['pipe','w']], $pipes);
            fclose($pipes[0]);
            $processes[] = [$proc, $pipes];
        }
        $outputs = [];
        foreach ($processes as [$proc, $pipes]) {
            $outputs[] = stream_get_contents($pipes[1]);
            $errors = stream_get_contents($pipes[2]);
            fclose($pipes[1]); fclose($pipes[2]);
            check(proc_close($proc) === 0 && $errors === '', 'concurrent child clean exit');
        }
        $created = array_filter($outputs, static fn($output) => str_starts_with($output, '201:'));
        if ($scenario === 'throttle') {
            check(count($created) === 5 && count(array_filter($outputs, static fn($output) => $output === '429')) === 3, 'eight concurrent requests admit exactly five');
        } else {
            check(count($created) === 8 && count(array_unique($created)) === 1, $scenario . ' concurrent retries share one reference');
        }
    }
}

function test_http(string $base, string $path, string $method = 'GET', ?string $body = null, array $headers = []): array {
    $ctx = stream_context_create(['http' => ['method' => $method, 'header' => implode("\r\n", $headers), 'content' => $body ?? '', 'ignore_errors' => true, 'follow_location' => 0, 'timeout' => 10]]);
    $stream = fopen($base . $path, 'r', false, $ctx);
    if (!$stream) throw new RuntimeException('HTTP harness request failed');
    $content = stream_get_contents($stream);
    $responseHeaders = stream_get_meta_data($stream)['wrapper_data'];
    fclose($stream);
    preg_match('/\s(\d{3})\s/', $responseHeaders[0] ?? '', $match);
    return [(int)($match[1] ?? 0), $content, implode("\n", $responseHeaders)];
}

function test_remove_tree(string $dir): void {
    foreach (new FilesystemIterator($dir) as $entry) {
        if ($entry->isDir() && !$entry->isLink()) test_remove_tree($entry->getPathname());
        else unlink($entry->getPathname());
    }
    rmdir($dir);
}

function run_enquiry_http_tests(PDO $pdo, string $socket, string $database): void {
    foreach (['api/enquiries.php', 'admin/enquiries.php', 'scripts/enquiry-worker.php'] as $file) {
        check(is_file(__DIR__ . '/../' . $file), $file . ' implementation exists');
    }
    $tmp = sys_get_temp_dir() . '/enquiry-http-' . bin2hex(random_bytes(6));
    mkdir($tmp, 0700);
    $server = null; $pipes = [];
    try {
        foreach (['api', 'admin', 'scripts'] as $dir) mkdir($tmp . '/' . $dir, 0700);
        foreach (['api/enquiries.php', 'api/enquiry-store.php', 'api/bootstrap.php', 'admin/guard.php', 'admin/enquiries.php', 'scripts/enquiry-worker.php'] as $file) copy(__DIR__ . '/../' . $file, $tmp . '/' . $file);
        $config = "<?php\n";
        foreach (['DB_HOST' => 'localhost;unix_socket=' . $socket, 'DB_NAME' => $database, 'DB_USER' => 'root', 'DB_PASS' => '', 'AUTH_PEPPER' => 'test-pepper'] as $key => $value) $config .= 'define(' . var_export($key, true) . ', ' . var_export($value, true) . ");\n";
        file_put_contents($tmp . '/api/config.php', $config);
        $pdo->exec('CREATE TABLE auth_tokens (token CHAR(64) PRIMARY KEY, admin_id INT NOT NULL, expires_at DATETIME NOT NULL) ENGINE=InnoDB');
        $token = str_repeat('a', 64);
        $pdo->prepare('INSERT INTO auth_tokens VALUES (?,9,NOW() + INTERVAL 1 HOUR)')->execute([$token]);
        $listener = stream_socket_server('tcp://127.0.0.1:0');
        $address = stream_socket_get_name($listener, false); fclose($listener);
        $base = 'http://' . $address;
        $server = proc_open([PHP_BINARY, '-d', 'disable_functions=mail', '-S', $address, '-t', $tmp], [0=>['pipe','r'], 1=>['pipe','w'], 2=>['pipe','w']], $pipes);
        fclose($pipes[0]);
        stream_set_timeout($pipes[2], 10);
        check(str_contains((string)fgets($pipes[2]), 'started'), 'isolated HTTP server started');
        $jsonHeaders = ['Content-Type: application/json', 'Origin: ' . $base];
        $payload = fixture(201); $payload['message'] = '<script>alert(1)</script> project description';
        [$status, $body, $headers] = test_http($base, '/api/enquiries.php', 'POST', json_encode($payload), $jsonHeaders);
        check($status === 201, 'HTTP durable success');
        $result = json_decode($body, true);
        check(array_keys($result) === ['ok', 'reference'] && $result['ok'] === true, 'public success contains only ok and opaque reference');
        check(str_contains($headers, 'no-store'), 'public response is not cached');
        [$status, $retry] = test_http($base, '/api/enquiries.php', 'POST', json_encode($payload), $jsonHeaders);
        check($status === 201 && $retry === $body, 'HTTP retry preserves exact success');
        $payload['name'] = 'Changed';
        check(test_http($base, '/api/enquiries.php', 'POST', json_encode($payload), $jsonHeaders)[0] === 409, 'HTTP payload conflict');
        foreach ([['GET', null, [], 405], ['POST', '{}', ['Content-Type: text/plain', 'Origin: ' . $base], 415], ['POST', '{}', ['Content-Type: application/json', 'Origin: https://evil.test'], 403], ['POST', '{', $jsonHeaders, 400], ['POST', str_repeat('x', 20481), $jsonHeaders, 413]] as [$method, $content, $hdrs, $expected]) {
            [$status, $response] = test_http($base, '/api/enquiries.php', $method, $content, $hdrs);
            check($status === $expected && !str_contains($response, 'Test Person'), 'HTTP rejection without PII ' . $expected);
        }
        $spam = fixture(202); $spam['website'] = 'https://spam.test';
        check(test_http($base, '/api/enquiries.php', 'POST', json_encode($spam), $jsonHeaders)[0] === 422, 'HTTP honeypot rejected honestly');
        for ($n = 203; $n <= 205; $n++) check(test_http($base, '/api/enquiries.php', 'POST', json_encode(fixture($n)), $jsonHeaders)[0] === 201, 'HTTP throttle allows capacity');
        [$status, $response, $headers] = test_http($base, '/api/enquiries.php', 'POST', json_encode(fixture(206)), array_merge($jsonHeaders, ['X-Forwarded-For: 203.0.113.99']));
        check($status === 429 && str_contains($headers, 'Retry-After: 3600'), 'HTTP throttle cannot be bypassed with forwarded IP');
        $payload['name'] = 'Test Person';
        check(test_http($base, '/api/enquiries.php', 'POST', json_encode($payload), $jsonHeaders)[0] === 201, 'HTTP idempotent success still works at limit');
        check(test_http($base, '/api/enquiry-store.php')[0] === 404, 'store is not a public route');
        check(test_http($base, '/scripts/enquiry-worker.php')[0] === 404, 'worker cannot execute over HTTP');
        [$status, $response] = test_http($base, '/admin/enquiries.php');
        check($status === 302 && !str_contains($response, 'Test Person'), 'admin requires session');
        $id = (int)$pdo->query("SELECT id FROM enquiries WHERE request_id='12345678-1234-4234-8234-000000000201'")->fetchColumn();
        $cookie = 'Cookie: admin_token=' . $token;
        [$status, $response, $headers] = test_http($base, '/admin/enquiries.php?id=' . $id, 'GET', null, [$cookie]);
        check($status === 200 && str_contains($response, '&lt;script&gt;alert(1)&lt;/script&gt;') && !str_contains($response, '<script>alert(1)</script>'), 'admin renders escaped contact message');
        check(str_contains($headers, 'no-store'), 'private response cannot be cached');
        preg_match('/name="csrf_token" value="([a-f0-9]+)"/', $response, $match);
        check(isset($match[1]), 'admin CSRF token rendered');
        $form = ['id' => (string)$id, 'version' => '1', 'status' => 'proposal', 'notes' => '<b>private note</b>', 'next_action' => 'Follow up', 'follow_up_date' => '2028-04-03'];
        $formHeaders = [$cookie, 'Content-Type: application/x-www-form-urlencoded'];
        check(test_http($base, '/admin/enquiries.php', 'POST', http_build_query($form), $formHeaders)[0] === 403, 'admin missing CSRF rejected');
        $form['csrf_token'] = str_repeat('b', 64);
        check(test_http($base, '/admin/enquiries.php', 'POST', http_build_query($form), $formHeaders)[0] === 403, 'admin invalid CSRF rejected');
        $form['csrf_token'] = $match[1];
        check(test_http($base, '/admin/enquiries.php', 'POST', http_build_query($form), $formHeaders)[0] === 303, 'admin valid CSRF update redirects');
        check(enquiry_detail($pdo, $id)['notes'] === '<b>private note</b>', 'admin notes persisted through HTTP');
        check(test_http($base, '/admin/enquiries.php', 'POST', http_build_query($form), $formHeaders)[0] === 409, 'HTTP stale edit conflict');
        $form['version'] = '2'; $form['notes'] = str_repeat('x', 10001);
        check(test_http($base, '/admin/enquiries.php', 'POST', http_build_query($form), $formHeaders)[0] === 422, 'HTTP notes length rejected');
        check(test_http($base, '/admin/enquiries.php?id=99999999', 'GET', null, [$cookie])[0] === 404, 'missing admin detail HTTP status');
        $snapshot = $pdo->query('SELECT * FROM enquiry_outbox ORDER BY id')->fetchAll();
        foreach ([[], ['--send']] as $args) {
            $proc = proc_open(array_merge([PHP_BINARY, '-d', 'disable_functions=mail', $tmp . '/scripts/enquiry-worker.php'], $args), [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $cliPipes, $tmp, []);
            fclose($cliPipes[0]); $out = stream_get_contents($cliPipes[1]); $err = stream_get_contents($cliPipes[2]);
            fclose($cliPipes[1]); fclose($cliPipes[2]); $exit = proc_close($proc);
            check($args ? $exit !== 0 : $exit === 0, 'CLI dry-run/default or missing mail configuration');
            check(!str_contains($out . $err, 'person@example.test'), 'CLI logs do not disclose contact data');
        }
        check($snapshot === $pdo->query('SELECT * FROM enquiry_outbox ORDER BY id')->fetchAll(), 'CLI dry-run and invalid send leave outbox unchanged');
        $proc = proc_open([PHP_BINARY, '-d', 'disable_functions=mail', $tmp . '/scripts/enquiry-worker.php', '--send', '--limit=1'], [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $cliPipes, $tmp, ['ENQUIRY_OWNER_EMAIL'=>'owner@example.test', 'ENQUIRY_FROM_EMAIL'=>'from@example.test']);
        fclose($cliPipes[0]); $out = stream_get_contents($cliPipes[1]); $err = stream_get_contents($cliPipes[2]);
        fclose($cliPipes[1]); fclose($cliPipes[2]); proc_close($proc);
        check(str_contains($out, 'failed_transport_unavailable') && $err === '', 'CLI with disabled native mail reports unavailable, not delivered');
        check((int)$pdo->query("SELECT COUNT(*) FROM enquiry_outbox WHERE last_error='transport_unavailable' AND status='failed'")->fetchColumn() === 1, 'unavailable native mail preserves failed outbox');
        check(test_http($base, '/admin/enquiries.php?page=10001', 'GET', null, [$cookie])[0] === 422, 'HTTP admin pagination depth capped');
        $pdo->prepare('UPDATE auth_tokens SET expires_at=NOW() - INTERVAL 1 SECOND WHERE token=?')->execute([$token]);
        check(test_http($base, '/admin/enquiries.php?id=' . $id, 'GET', null, [$cookie])[0] === 302, 'expired session cannot view a lead');
        // Remove one required table in this disposable schema: real endpoint must fail closed.
        $pdo->exec("UPDATE enquiries SET created_at=UTC_TIMESTAMP() - INTERVAL 61 MINUTE");
        $pdo->exec('RENAME TABLE enquiry_outbox TO enquiry_outbox_unavailable');
        [$status, $response] = test_http($base, '/api/enquiries.php', 'POST', json_encode(fixture(202)), $jsonHeaders);
        check($status === 503 && !str_contains($response, 'SQL'), 'HTTP database failure is honest and sanitized');
        check((int)$pdo->query("SELECT COUNT(*) FROM enquiries WHERE request_id='12345678-1234-4234-8234-000000000202'")->fetchColumn() === 0, 'HTTP failure never leaves a partial enquiry');
    } finally {
        if (is_resource($server)) { proc_terminate($server); foreach ([1,2] as $n) if (isset($pipes[$n]) && is_resource($pipes[$n])) fclose($pipes[$n]); proc_close($server); }
        test_remove_tree($tmp);
    }
}
