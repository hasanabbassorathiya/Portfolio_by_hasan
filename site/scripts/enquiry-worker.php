<?php
declare(strict_types=1);
// Run from CLI/cron only. No transport is invoked without an explicit --send.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../api/enquiry-store.php';

$send = false;
$limit = 25;
$retry = null;
$acceptDuplicate = false;
try {
    foreach (array_slice($argv, 1) as $arg) {
        if ($arg === '--help') {
            print "Usage: php site/scripts/enquiry-worker.php [--send] [--limit=1..100] [--retry=OUTBOX_ID] [--accept-duplicate-risk]\n"
                . "Default: read-only dry-run. --send requires ENQUIRY_OWNER_EMAIL and ENQUIRY_FROM_EMAIL.\n"
                . "Failed rows retry automatically up to five attempts (60/120/240/480 second backoff).\n"
                . "--send --retry=ID resets the bounded retry cycle for one failed row; lifetime attempts remain.\n"
                . "An interrupted/ambiguous send requires --accept-duplicate-risk to retry. Inspect transport logs first.\n"
                . "Sent means transport accepted, not inbox delivery. Dry-run never retries or recovers claims.\n";
            exit(0);
        } elseif ($arg === '--send') { $send = true; }
        elseif ($arg === '--accept-duplicate-risk') { $acceptDuplicate = true; }
        elseif (preg_match('/^--limit=([0-9]{1,3})$/D', $arg, $match) && (int)$match[1] >= 1 && (int)$match[1] <= 100) { $limit = (int)$match[1]; }
        elseif (preg_match('/^--retry=([1-9][0-9]{0,17})$/D', $arg, $match)) { $retry = (int)$match[1]; }
        else { throw new EnquiryError(422, 'invalid_worker_arguments_use_help'); }
    }
    if ($acceptDuplicate && (!$send || $retry === null)) throw new EnquiryError(422, 'duplicate_ack_requires_send_and_retry');
    // Read only the two explicitly required settings, never load or inspect an .env file.
    $settings = $send ? enquiry_mail_settings((string)getenv('ENQUIRY_OWNER_EMAIL'), (string)getenv('ENQUIRY_FROM_EMAIL')) : [];
    require __DIR__ . '/../api/bootstrap.php';
    $pdo = db();
    $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    $log = static function(int $id, string $status): void { print 'outbox_id=' . $id . ' status=' . $status . "\n"; };
    enquiry_worker($pdo, $send, $limit, $retry, $acceptDuplicate, $settings, 'enquiry_native_mail', $log);
    print 'status=' . ($send ? 'worker_complete' : 'dry_run_complete') . "\n";
} catch (Throwable $e) {
    // Controlled status codes only: PDO/mail diagnostics can contain addresses or secrets.
    $status = $e instanceof EnquiryError ? $e->errorCode : 'worker_unavailable';
    fwrite(STDERR, 'status=' . $status . "\n");
    exit(1);
}
