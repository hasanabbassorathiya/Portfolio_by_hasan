<?php
declare(strict_types=1);
// Site -> Discord: POST a community note to the announcements channel.
// Auth is the same shared secret the social webhook uses.
require __DIR__ . '/bootstrap.php';
require __DIR__ . '/social-lib.php';
require __DIR__ . '/discord-lib.php';

header('Cache-Control: no-store');
header('X-Robots-Tag: noindex, nofollow');

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    header('Allow: POST');
    json_out(['error' => 'method not allowed'], 405);
}

$secret = social_webhook_secret();
if ($secret === '') {
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

$b = body();
$text = trim((string)($b['text'] ?? ''));
$title = trim((string)($b['title'] ?? ''));
$url = trim((string)($b['url'] ?? ''));
$image = trim((string)($b['image'] ?? ''));

$payload = discord_message_payload([
    'title' => $title !== '' ? $title : 'Community note',
    'description' => $text,
    'url' => $url,
    'image' => $image,
    'footer' => 'hasanabbassorathiya.tech',
]);
if ($payload === []) json_out(['error' => 'text or url required'], 422);

$webhook = discord_webhook_url(__DIR__ . '/discord-secret.php');
if ($webhook === '') {
    json_out([
        'error' => 'discord not configured',
        'detail' => 'Upload api/discord-secret.php with the announcements webhook URL.',
    ], 503);
}

if (!discord_send($webhook, $payload)) {
    error_log('discord publish: the announcements channel rejected the note');
    json_out(['error' => 'discord rejected the note'], 502);
}

json_out(['ok' => true]);
