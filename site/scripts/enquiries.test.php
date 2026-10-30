<?php
declare(strict_types=1);
// Safe standalone tests: no bootstrap/config, credentials or outbound mail.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
$store = __DIR__ . '/../api/enquiry-store.php';
if (!is_file($store)) { fwrite(STDERR, "FAIL: enquiry validation/store implementation is missing\n"); exit(1); }
require $store;

$checks = 0;
function check(bool $condition, string $label): void {
    global $checks;
    if (!$condition) throw new RuntimeException('FAIL: ' . $label);
    $checks++;
}
function rejects(callable $fn, int $status, string $label): void {
    try { $fn(); } catch (EnquiryError $e) {
        check($e->httpStatus === $status, $label . ' status');
        return;
    }
    throw new RuntimeException('FAIL: ' . $label . ' was accepted');
}
function fixture(int $n = 1): array {
    return ['name' => 'Test Person', 'email' => 'person@example.test', 'type' => 'App build',
        'message' => 'Please discuss an application build.', 'website' => '', 'consent' => true,
        'requestId' => sprintf('12345678-1234-4234-8234-%012d', $n)];
}
function validated(array $data): array { return enquiry_validate(json_encode($data, JSON_THROW_ON_ERROR)); }
function request_headers(): array {
    return ['REQUEST_METHOD' => 'POST', 'CONTENT_TYPE' => 'application/json; charset=utf-8',
        'HTTP_HOST' => 'portfolio.test', 'HTTPS' => 'on', 'HTTP_ORIGIN' => 'https://portfolio.test'];
}

try {
    check(validated(fixture())['name'] === 'Test Person', 'valid contract accepted');
    foreach (['App build', 'Embedded engineer', 'AI automation / integration', 'Full-stack / MERN', 'UI/UX', 'Advisory / audit', 'Full-time role', 'Something else'] as $type) {
        check(validated(array_replace(fixture(), ['type' => $type]))['type'] === $type, 'allowed type ' . $type);
    }
    foreach (['name', 'email', 'type', 'message', 'website', 'requestId'] as $field) {
        foreach ([[], null, true, 42] as $value) rejects(fn() => validated(array_replace(fixture(), [$field => $value])), 422, $field . ' scalar type');
        $missing = fixture(); unset($missing[$field]);
        rejects(fn() => validated($missing), 422, $field . ' required');
    }
    foreach ([false, 'true', 1, null, []] as $consent) rejects(fn() => validated(array_replace(fixture(), ['consent' => $consent])), 422, 'explicit consent');
    foreach ([['name', ''], ['name', str_repeat('n', 121)], ['email', 'invalid'], ['email', "x@example.test\r\nBcc: x@example.test"], ['email', str_repeat('a', 180) . '@example.test'], ['message', str_repeat('x', 19)], ['message', str_repeat('x', 10001)], ['type', 'other'], ['requestId', 'not-a-uuid'], ['name', "A\0B"]] as [$field, $value]) {
        rejects(fn() => validated(array_replace(fixture(), [$field => $value])), 422, $field . ' invalid boundary');
    }
    check(strlen(validated(array_replace(fixture(), ['message' => str_repeat('x', 10000)]))['message']) === 10000, 'message upper boundary');
    check(validated(array_replace(fixture(), ['name' => str_repeat('é', 120)]))['name'] === str_repeat('é', 120), 'unicode character length');
    rejects(fn() => validated(array_replace(fixture(), ['website' => 'https://spam.test'])), 422, 'honeypot is not fake success');
    rejects(fn() => validated(array_replace(fixture(), ['email' => '"quoted"@example.test'])), 422, 'intake requires a transport-safe email');
    rejects(fn() => enquiry_validate('{'), 400, 'malformed JSON');
    rejects(fn() => enquiry_validate('[]'), 400, 'JSON object required');
    rejects(fn() => enquiry_validate(str_repeat(' ', 20481)), 413, '20KiB limit');
    enquiry_check_request(request_headers());
    check(true, 'same origin JSON request');
    foreach ([['REQUEST_METHOD', 'GET', 405], ['CONTENT_TYPE', 'text/plain', 415], ['HTTP_ORIGIN', 'https://evil.test', 403], ['HTTP_ORIGIN', 'https://portfolio.test.evil.test', 403], ['HTTP_ORIGIN', '', 403], ['HTTP_ORIGIN', 'null', 403], ['HTTP_ORIGIN', 'http://portfolio.test', 403], ['HTTP_ORIGIN', 'https://portfolio.test/path', 403], ['HTTP_SEC_FETCH_SITE', 'cross-site', 403], ['CONTENT_LENGTH', '20481', 413]] as [$field, $value, $status]) {
        rejects(fn() => enquiry_check_request(array_replace(request_headers(), [$field => $value])), $status, 'request ' . $field . ' guard');
    }
    $edit = ['status' => 'contacted', 'notes' => 'Private note', 'next_action' => 'Arrange call', 'follow_up_date' => '2028-02-29'];
    check(enquiry_validate_update($edit)['follow_up_date'] === '2028-02-29', 'valid leap date');
    foreach ([['status', 'deleted'], ['notes', str_repeat('x', 10001)], ['notes', []], ['next_action', str_repeat('x', 256)], ['follow_up_date', '2027-02-29'], ['follow_up_date', 'tomorrow']] as [$field, $value]) {
        rejects(fn() => enquiry_validate_update(array_replace($edit, [$field => $value])), 422, 'admin ' . $field);
    }
    check(enquiry_validate_update(array_replace($edit, ['follow_up_date' => '']))['follow_up_date'] === null, 'clear follow up');
    check(enquiry_escape('<script>"&') === '&lt;script&gt;&quot;&amp;', 'HTML escaping');
    check(enquiry_ip_hash('127.0.0.1', 'test-pepper') !== hash('sha256', '127.0.0.1'), 'keyed IP hash');
    check(enquiry_ip_hash('::1', 'test-pepper') === enquiry_ip_hash('0:0:0:0:0:0:0:1', 'test-pepper'), 'IP canonicalization');
    foreach (["a@example.test\r\nBcc:b@example.test", 'Name <a@example.test>', 'not-email'] as $email) {
        rejects(fn() => enquiry_mail_settings($email, 'from@example.test'), 503, 'mail header validation');
    }
    $mail = enquiry_mail_message(['id' => 1, 'reference' => str_repeat('a', 32), 'email' => 'person@example.test', 'name' => 'BADNAME', 'message' => 'BADMESSAGE https://evil.test'], 'ack', enquiry_mail_settings('owner@example.test', 'from@example.test'));
    check(!str_contains($mail['body'], 'BAD') && !str_contains($mail['body'], 'https://'), 'ack never echoes contact text or URLs');
    check($mail['to'] === 'person@example.test', 'ack recipient');

    if (getenv('ENQUIRY_TEST_SOCKET')) {
        require __DIR__ . '/enquiries-test-helper.php';
        run_enquiry_database_tests();
    } else {
        print "SKIP: real MySQL/HTTP tests (set ENQUIRY_TEST_SOCKET to a disposable local socket)\n";
    }
    print "PASS: {$checks} enquiry checks; no real mail sent\n";
} catch (Throwable $e) {
    fwrite(STDERR, $e->getMessage() . "\n");
    exit(1);
}
