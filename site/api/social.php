<?php
declare(strict_types=1);
// Social -> site bridge: POST /api/social.php with a published-post payload.
// Auth is a shared secret (X-Webhook-Secret header, or ?token= for setups that
// cannot send headers). Rows dedupe on external_id, so retries are safe.
require __DIR__ . '/bootstrap.php';
require __DIR__ . '/social-lib.php';

header('Cache-Control: no-store');
header('X-Robots-Tag: noindex, nofollow');

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    header('Allow: POST');
    json_out(['error' => 'method not allowed'], 405);
}

$secret = defined('SOCIAL_WEBHOOK_SECRET') ? (string)SOCIAL_WEBHOOK_SECRET : '';
if ($secret === '') {
    $secretFile = __DIR__ . '/social-secret.php';
    if (is_file($secretFile)) {
        $stored = require $secretFile;
        $secret = is_string($stored) ? trim($stored) : '';
    }
}
if (strlen($secret) < 32 || str_starts_with($secret, 'CHANGE_ME')) {
    json_out([
        'error' => 'webhook not configured',
        'detail' => 'Define SOCIAL_WEBHOOK_SECRET in api/config.php or upload api/social-secret.php.',
    ], 503);
}

$provided = (string)($_SERVER['HTTP_X_WEBHOOK_SECRET'] ?? '');
if ($provided === '') $provided = (string)($_GET['token'] ?? '');
if ($provided === '' || !hash_equals($secret, $provided)) {
    json_out(['error' => 'forbidden'], 403);
}

$raw = file_get_contents('php://input');
if (!is_string($raw) || trim($raw) === '') json_out(['error' => 'empty body'], 400);
if (strlen($raw) > 65536) json_out(['error' => 'payload too large'], 413);

$payload = json_decode($raw, true);
if (!is_array($payload)) json_out(['error' => 'invalid json'], 400);

$row = social_normalize($payload, $raw);

try {
    $st = db()->prepare('INSERT INTO social_posts
        (external_id, provider, channel, kind, text, url, image, posted_at, published, raw_json)
        VALUES (?,?,?,?,?,?,?,?,?,?)
        ON DUPLICATE KEY UPDATE id = id');
    $st->execute([
        $row['external_id'], $row['provider'], $row['channel'], $row['kind'],
        $row['text'], $row['url'], $row['image'], $row['posted_at'],
        $row['published'], $raw,
    ]);
} catch (Throwable $e) {
    json_out([
        'error' => 'store unavailable',
        'detail' => 'Apply api/migrate-2026-11-01-social-posts.sql and check the database.',
    ], 503);
}

$created = $st->rowCount() === 1;
json_out([
    'ok' => true,
    'duplicate' => !$created,
    'published' => $row['published'] === 1,
    'external_id' => $row['external_id'],
], $created ? 201 : 200);
