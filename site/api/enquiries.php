<?php
declare(strict_types=1);
// Public, write-only intake. No enquiry lookup, email sending, or runtime migration here.
require __DIR__ . '/enquiry-store.php';
header('Cache-Control: no-store');
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('X-Robots-Tag: noindex, nofollow');

try {
    enquiry_check_request($_SERVER);
    // body() is intentionally not used: bound memory even without Content-Length.
    $raw = file_get_contents('php://input', false, null, 0, ENQUIRY_MAX_BODY + 1);
    if ($raw === false) throw new EnquiryError(400, 'invalid_body');
    $data = enquiry_validate($raw);
    require __DIR__ . '/bootstrap.php';
    $ipHash = enquiry_ip_hash($_SERVER['REMOTE_ADDR'] ?? '', defined('AUTH_PEPPER') ? (string)AUTH_PEPPER : '');
    $reference = enquiry_submit(db(), $data, $ipHash);
    json_out(['ok' => true, 'reference' => $reference], 201);
} catch (Throwable $e) {
    $status = $e instanceof EnquiryError ? $e->httpStatus : 503;
    $code = $e instanceof EnquiryError ? $e->errorCode : 'enquiry_unavailable';
    if ($status === 405) header('Allow: POST');
    if ($status === 429) header('Retry-After: 3600');
    if ($status === 503) {
        header('Retry-After: 60');
        // No payload, address, IP, SQL diagnostics, or exception text in application logs.
        error_log('enquiry_intake status=unavailable');
    }
    http_response_code($status);
    echo json_encode(['ok' => false, 'error' => $code], JSON_UNESCAPED_SLASHES);
}
