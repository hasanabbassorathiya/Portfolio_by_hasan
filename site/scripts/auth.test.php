<?php
declare(strict_types=1);
namespace AuthHarness;
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
use PDO;
use RuntimeException;
use Throwable;

// Run: php site/scripts/auth.test.php. Requires local MariaDB binaries; never loads site config.
function check(bool $ok, string $message): void {
    if (!$ok) throw new RuntimeException($message);
}

function load_source(string $relative): void {
    $path = dirname(__DIR__) . '/' . $relative;
    check(is_file($path), 'Required implementation missing: ' . $relative);
    $source = file_get_contents($path);
    if ($relative === 'api/bootstrap.php') {
        $source = str_replace("require __DIR__ . '/config.php';", '', $source, $count);
        check($count === 1, 'Refusing to load an unrecognized config boundary');
        $source = str_replace(['function db():', 'function body():'], ['function unused_db():', 'function unused_body():'], $source);
    } else {
        $source = preg_replace("~require __DIR__ \\. '(?:/bootstrap\\.php|/\\.\\./api/bootstrap\\.php|/guard\\.php)';~", '', $source);
    }
    // Transport/config are isolated in memory; SQL and application behavior remain real.
    $source = str_replace('declare(strict_types=1);', 'declare(strict_types=1); namespace AuthHarness; use PDO; use Throwable; use RuntimeException; use Exception;', $source);
    $argv = ['create-admin.php'];
    eval('?>' . $source);
}

function db(): PDO {
    if (!empty($GLOBALS['request']['no_db'])) throw new RuntimeException('Unexpected database access');
    static $pdo;
    return $pdo ??= new PDO('mysql:unix_socket=' . getenv('AUTH_TEST_SOCKET') . ';dbname=auth_test;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
}
function body(): array { return $GLOBALS['request']['data'] ?? []; }
function header(string $value, bool $replace = true, int $response_code = 0): void {
    $GLOBALS['response_headers'][] = $value;
    if ($response_code) http_response_code($response_code);
    elseif (str_starts_with($value, 'Location:')) http_response_code(302);
}

if (($argv[1] ?? '') === '--child') {
    $GLOBALS['request'] = $r = json_decode(fgets(STDIN), true, 512, JSON_THROW_ON_ERROR);
    define(__NAMESPACE__ . '\\PHP_SAPI', !empty($r['web']) ? 'cgi-fcgi' : 'cli');
    define('AUTH_PEPPER', $r['pepper'] ?? 'disposable-test-pepper');
    $_SERVER = ['REQUEST_METHOD' => $r['method'] ?? 'POST', 'REMOTE_ADDR' => $r['ip'] ?? '192.0.2.1', 'HTTPS' => 'on'];
    if (isset($r['header_token'])) $_SERVER['HTTP_X_AUTH_TOKEN'] = $r['header_token'];
    if (isset($r['forwarded_ip'])) $_SERVER['HTTP_X_FORWARDED_FOR'] = $r['forwarded_ip'];
    $_COOKIE = isset($r['token']) ? ['admin_token' => $r['token']] : [];
    $_POST = $r['data'] ?? [];
    $_GET = $r['query'] ?? [];
    $GLOBALS['response_headers'] = [];
    http_response_code(200);
    ob_start();
    register_shutdown_function(static function (): void {
        $output = ob_get_clean();
        echo json_encode(['status' => http_response_code(), 'headers' => $GLOBALS['response_headers'], 'body' => $output, 'error' => $GLOBALS['test_error'] ?? null]);
    });
    set_error_handler(static function (int $severity, string $message): never { throw new RuntimeException($message); });
    try {
        load_source('api/bootstrap.php');
        switch ($r['route']) {
            case 'json': load_source('api/auth.php'); break;
            case 'html': load_source('admin/index.php'); break;
            case 'guard': load_source('admin/guard.php'); break;
            case 'logout': load_source('admin/logout.php'); break;
            case 'subscribers': load_source('admin/guard.php'); load_source('admin/subscribers.php'); break;
            case 'csrf':
                check(function_exists(__NAMESPACE__ . '\\admin_csrf_token'), 'CSRF helper missing');
                echo admin_csrf_token();
                break;
            case 'csrf-check':
                check(function_exists(__NAMESPACE__ . '\\require_admin_csrf'), 'CSRF guard missing');
                require_admin_csrf($r['csrf']);
                break;
            case 'provision': load_source('scripts/create-admin.php'); break;
        }
    } catch (Throwable $e) { $GLOBALS['test_error'] = $e->getMessage(); }
    exit;
}

function start_request(array $request, string $input = ''): array {
    $process = proc_open([PHP_BINARY, __FILE__, '--child'], [['pipe', 'r'], ['pipe', 'w'], ['pipe', 'w']], $pipes);
    check(is_resource($process), 'Cannot start isolated PHP request');
    fwrite($pipes[0], json_encode($request) . "\n" . $input);
    fclose($pipes[0]);
    return [$process, $pipes];
}
function finish_request(array $job): array {
    [$process, $pipes] = $job;
    $result = stream_get_contents($pipes[1]);
    $stderr = stream_get_contents($pipes[2]);
    fclose($pipes[1]); fclose($pipes[2]);
    $exitCode = proc_close($process);
    $r = json_decode($result, true);
    check(is_array($r), 'Invalid test response: ' . $stderr);
    check($r['error'] === null, $r['error'] ?? '');
    $r['stderr'] = $stderr;
    $r['exit_code'] = $exitCode;
    return $r;
}
function request(string $route, array $data = [], array $extra = []): array {
    return finish_request(start_request(['route' => $route, 'data' => $data] + $extra));
}
function reset_attempts(): void { db()->exec('DELETE FROM login_throttles'); }
function credentials(string $password = 'existing-test-password'): array {
    return ['email' => 'existing@example.test', 'password' => $password];
}
function token(): string {
    $token = bin2hex(random_bytes(32));
    db()->prepare('INSERT INTO auth_tokens (token, admin_id, expires_at) VALUES (?, 1, DATE_ADD(NOW(), INTERVAL 7 DAY))')->execute([$token]);
    return $token;
}
function private_headers(array $r): void {
    check((bool)array_filter($r['headers'], static fn($h) => stripos($h, 'Cache-Control:') === 0 && stripos($h, 'no-store') !== false), 'Missing no-store header');
    check((bool)array_filter($r['headers'], static fn($h) => stripos($h, 'X-Robots-Tag:') === 0 && stripos($h, 'noindex') !== false), 'Missing noindex header');
}
function remove_tree(string $dir): void {
    foreach (scandir($dir) as $name) {
        if ($name === '.' || $name === '..') continue;
        $path = $dir . '/' . $name;
        if (is_dir($path) && !is_link($path)) remove_tree($path); else unlink($path);
    }
    rmdir($dir);
}

$dir = '/tmp/portfolio-auth-' . bin2hex(random_bytes(6));
mkdir($dir);
$server = null;
$failures = 0;
try {
    $init = proc_open(['mariadb-install-db', '--no-defaults', '--datadir=' . $dir . '/data', '--auth-root-authentication-method=normal', '--skip-test-db'], [0 => ['file', '/dev/null', 'r'], 1 => ['file', $dir . '/init.log', 'w'], 2 => ['file', $dir . '/init.log', 'a']], $pipes);
    check(is_resource($init) && proc_close($init) === 0, 'Disposable MariaDB initialization unavailable; integration unverified');
    $socket = $dir . '/db.sock';
    $server = proc_open(['mariadbd', '--no-defaults', '--datadir=' . $dir . '/data', '--socket=' . $socket, '--pid-file=' . $dir . '/db.pid', '--log-error=' . $dir . '/db.log', '--skip-networking', '--innodb-buffer-pool-size=32M'], [0 => ['file', '/dev/null', 'r'], 1 => ['file', '/dev/null', 'w'], 2 => ['file', '/dev/null', 'w']], $pipes);
    check(is_resource($server), 'Cannot start disposable MariaDB; integration unverified');
    $setup = null;
    for ($i = 0; $i < 100; $i++) {
        try { $setup = new PDO('mysql:unix_socket=' . $socket, 'root', ''); break; }
        catch (Throwable $e) { usleep(100000); }
    }
    check($setup !== null, 'Disposable MariaDB did not become ready; integration unverified');
    $setup->exec('CREATE DATABASE auth_test');
    putenv('AUTH_TEST_SOCKET=' . $socket);
    db()->exec(file_get_contents(dirname(__DIR__) . '/api/schema.sql'));
    $existingHash = password_hash('existing-test-password' . 'disposable-test-pepper', PASSWORD_ARGON2ID);
    db()->prepare('INSERT INTO admins (email, password_hash) VALUES (?, ?)')->execute(['existing@example.test', $existingHash]);
    $tests = [
        'register is forbidden without database access' => static function (): void {
            $r = request('json', credentials(), ['query' => ['action' => 'register'], 'no_db' => true]);
            check($r['status'] === 403, 'Public registration must be disabled');
        },
        'raw malformed tokens never reach the database' => static function (): void {
            foreach (['bad', str_repeat('a', 64) . "\n", str_repeat('a', 65), ['x']] as $bad) {
                $r = request('guard', [], ['token' => $bad, 'no_db' => true]);
                check($r['status'] === 302, 'Malformed token must redirect');
                $r = request('html', [], ['method' => 'GET', 'token' => $bad, 'no_db' => true]);
                check($r['status'] === 200, 'Malformed token must not bypass login');
            }
        },
        'malformed and oversized credentials are rejected by both paths' => static function (): void {
            foreach (['json', 'html'] as $route) {
                foreach ([['email' => ['x'], 'password' => 'x'], ['email' => 'x@example.test', 'password' => ['x']], ['email' => str_repeat('x', 191), 'password' => 'x'], credentials(str_repeat('x', 4097)), credentials("bad\0password"), []] as $data) {
                    $r = request($route, $data, ['no_db' => true]);
                    check($r['status'] === 401, 'Bad credentials must get a generic 401');
                }
            }
        },
        'five account attempts are shared across HTML and JSON' => static function (): void {
            reset_attempts();
            for ($i = 0; $i < 5; $i++) {
                $data = credentials('wrong');
                $data['email'] = $i % 2 ? ' Existing@Example.Test ' : 'existing@example.test';
                check(request($i % 2 ? 'html' : 'json', $data)['status'] === 401, 'Wrong password accepted');
            }
            foreach (['html', 'json'] as $route) check(request($route, credentials())['status'] === 429, 'Shared account throttle bypassed');
            check(request('json', credentials(), ['ip' => '192.0.2.2'])['status'] === 200, 'Unrelated IP blocked');
            db()->exec('UPDATE login_throttles SET window_started = UNIX_TIMESTAMP() - 901');
            check(request('json', credentials())['status'] === 200, 'Expired window did not recover');
        },
        'thirty IP attempts cannot be bypassed by account or forwarded headers' => static function (): void {
            reset_attempts();
            for ($i = 0; $i < 30; $i++) request($i % 2 ? 'html' : 'json', ['email' => 'missing' . $i . '@example.test', 'password' => 'wrong']);
            check(request('json', credentials(), ['forwarded_ip' => '192.0.2.99'])['status'] === 429, 'IP budget bypassed');
            $keys = db()->query('SELECT bucket_key FROM login_throttles')->fetchAll(PDO::FETCH_COLUMN);
            foreach ($keys as $key) check((bool)preg_match('/\A[a-f0-9]{64}\z/', $key), 'Throttle keys expose raw identifiers');
        },
        'concurrent requests cannot exceed the account budget' => static function (): void {
            reset_attempts();
            $jobs = [];
            for ($i = 0; $i < 12; $i++) $jobs[] = start_request(['route' => $i % 2 ? 'html' : 'json', 'data' => credentials()]);
            $accepted = 0;
            foreach ($jobs as $job) {
                $r = finish_request($job);
                if (in_array($r['status'], [200, 302], true)) $accepted++;
                else check($r['status'] === 429, 'Unexpected concurrent response');
            }
            check($accepted === 5, 'Atomic throttle admitted ' . $accepted . ' requests');
        },
        'missing throttle schema fails closed with setup guidance' => static function (): void {
            db()->exec('RENAME TABLE login_throttles TO held_throttles');
            try {
                foreach (['json', 'html'] as $route) {
                    $r = request($route, credentials());
                    check($r['status'] === 503 && str_contains($r['body'], 'schema.sql'), 'Missing schema did not fail closed with guidance');
                    check(!str_contains($r['body'], 'SQLSTATE'), 'Database exception leaked');
                }
            } finally { db()->exec('RENAME TABLE held_throttles TO login_throttles'); }
        },
        'existing account login, cookie, guard and logout still work' => static function () use ($existingHash): void {
            reset_attempts();
            $r = request('json', credentials()); private_headers($r);
            $json = json_decode($r['body'], true);
            check($r['status'] === 200 && strlen($json['token'] ?? '') === 64 && $json['expires_in'] === 604800, 'JSON login failed');
            check((bool)array_filter($r['headers'], static fn($h) => str_contains($h, 'httponly; samesite=lax') && str_contains($h, '; secure')), 'Session cookie flags changed');
            $guard = request('guard', [], ['token' => $json['token']]); private_headers($guard);
            check($guard['status'] === 200, 'Live session rejected');
            $logout = request('logout', [], ['token' => $json['token']]); private_headers($logout);
            check($logout['status'] === 302 && str_contains(implode(';', $logout['headers']), 'max-age=0'), 'Logout did not clear cookie');
            check(request('guard', [], ['token' => $json['token']])['status'] === 302, 'Revoked token accepted');
            $html = request('html', credentials()); private_headers($html);
            check($html['status'] === 302 && in_array('Location: dashboard.php', $html['headers'], true), 'HTML login failed');
            check(db()->query('SELECT password_hash FROM admins WHERE id = 1')->fetchColumn() === $existingHash, 'Existing password changed');
        },
        'CSRF is session-bound and subscriber deletion requires it' => static function (): void {
            $a = token(); $b = token();
            $csrf = request('csrf', [], ['token' => $a])['body'];
            check(strlen($csrf) === 64 && $csrf !== $a, 'Invalid CSRF token');
            check(request('csrf', [], ['header_token' => $a])['body'] === $csrf, 'Header auth CSRF differs');
            check(request('csrf', [], ['token' => $a, 'pepper' => 'different-test-pepper'])['body'] !== $csrf, 'CSRF is not pepper-bound');
            check(request('csrf-check', [], ['token' => $a, 'csrf' => $csrf])['status'] === 200, 'Valid CSRF rejected');
            check(request('csrf-check', [], ['csrf' => $csrf])['status'] === 403, 'Unauthenticated CSRF accepted');
            foreach (['', str_repeat('0', 64), $csrf . "\n"] as $bad) check(request('csrf-check', [], ['token' => $a, 'csrf' => $bad])['status'] === 403, 'Bad CSRF accepted');
            check(request('csrf-check', [], ['token' => $b, 'csrf' => $csrf])['status'] === 403, 'Cross-session CSRF accepted');
            db()->exec("INSERT INTO subscribers (email, unsub_token) VALUES ('reader@example.test', 'test-token')");
            $id = (int)db()->lastInsertId();
            $page = request('subscribers', [], ['method' => 'GET', 'token' => $a]); private_headers($page);
            check(str_contains($page['body'], 'name="csrf_token"') && str_contains($page['body'], $csrf), 'Delete form lacks CSRF');
            foreach ([[], ['csrf_token' => 'bad'], ['csrf_token' => ['bad']], ['csrf_token' => request('csrf', [], ['token' => $b])['body']]] as $fields) {
                check(request('subscribers', ['delete' => $id] + $fields, ['token' => $a])['status'] === 403, 'Unprotected deletion accepted');
                check((int)db()->query('SELECT COUNT(*) FROM subscribers')->fetchColumn() === 1, 'Subscriber deleted without CSRF');
            }
            check(request('subscribers', ['delete' => $id, 'csrf_token' => $csrf], ['token' => $a])['status'] === 302, 'Valid deletion failed');
            check((int)db()->query('SELECT COUNT(*) FROM subscribers')->fetchColumn() === 0, 'Valid deletion had no effect');
            db()->prepare('UPDATE auth_tokens SET expires_at = DATE_SUB(NOW(), INTERVAL 1 DAY) WHERE token = ?')->execute([$a]);
            check(request('csrf-check', [], ['token' => $a, 'csrf' => $csrf])['status'] === 403, 'Expired session CSRF accepted');
        },
        'CLI provisioning is web-disabled and serializes first admin creation' => static function () use ($existingHash): void {
            check(request('provision', [], ['web' => true, 'no_db' => true])['status'] === 403, 'Provisioning allowed over HTTP');
            $refused = finish_request(start_request(['route' => 'provision'], "other@example.test\nnew-test-password\n"));
            check($refused['exit_code'] === 1, 'Provisioning did not refuse an existing admin');
            check(db()->query('SELECT password_hash FROM admins WHERE id = 1')->fetchColumn() === $existingHash, 'Provisioning altered an existing account');
            db()->exec('DELETE FROM auth_tokens'); db()->exec('DELETE FROM admins');
            foreach (["bad-address\nnew-test-password\n", "first@example.test\nshort\n", "first@example.test\n" . str_repeat('x', 4097) . "\n"] as $input) {
                $bad = finish_request(start_request(['route' => 'provision', 'no_db' => true], $input));
                check($bad['exit_code'] === 1, 'Malformed provisioning input accepted');
            }
            $jobs = [];
            for ($i = 0; $i < 4; $i++) $jobs[] = start_request(['route' => 'provision'], 'first' . $i . "@example.test\nnew-test-password\n");
            $created = 0;
            foreach ($jobs as $job) {
                $r = finish_request($job);
                if ($r['exit_code'] === 0) $created++;
                check(!str_contains($r['body'] . $r['stderr'], 'new-test-password'), 'Provisioning logged a password');
            }
            check($created === 1 && (int)db()->query('SELECT COUNT(*) FROM admins')->fetchColumn() === 1, 'First-admin provisioning raced');
            $admin = db()->query('SELECT email, password_hash FROM admins')->fetch();
            check(password_verify('new-test-password' . 'disposable-test-pepper', $admin['password_hash']), 'Provisioned hash is incompatible');
            reset_attempts();
            check(request('json', ['email' => $admin['email'], 'password' => 'new-test-password'])['status'] === 200, 'Provisioned admin cannot sign in');
        },
    ];
    foreach ($tests as $name => $test) {
        try { $test(); echo 'PASS ' . $name . "\n"; }
        catch (Throwable $e) { $failures++; echo 'FAIL ' . $name . ': ' . $e->getMessage() . "\n"; }
    }
    echo count($tests) . ' tests; ' . $failures . " failures\n";
} catch (Throwable $e) {
    $failures++;
    fwrite(STDERR, $e->getMessage() . "\n");
} finally {
    if (is_resource($server)) { proc_terminate($server); proc_close($server); }
    remove_tree($dir);
}
exit($failures ? 1 : 0);
