<?php
declare(strict_types=1);
// Signup intake: POST {email, source, website, name?, whatsapp?, consent?}.
// Community signups carry name/optional WhatsApp and require consent:true.
// GET ?unsubscribe=<token> deletes the row. No double opt-in: only typed data is stored.
require __DIR__ . '/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $token = strtolower((string)($_GET['unsubscribe'] ?? ''));
    $valid = (bool)preg_match('/^[a-f0-9]{32}$/', $token);
    $removed = false;
    if ($valid) {
        $st = db()->prepare('DELETE FROM subscribers WHERE unsub_token = ?');
        $st->execute([$token]);
        $removed = $st->rowCount() > 0;
    }
    header('Content-Type: text/html; charset=utf-8');
    header('X-Robots-Tag: noindex');
    $title = $removed ? 'You are unsubscribed' : 'Link not recognised';
    $line = $removed
        ? 'That address will not receive any more essay emails. No hard feelings.'
        : 'This unsubscribe link is invalid or was already used.';
    $css = <<<'CSS'
:root{color-scheme:light dark}
body{margin:0;min-height:100vh;display:grid;place-items:center;background:#f3efe6;color:#14110d;
font:16px/1.7 Geist,system-ui,-apple-system,'Segoe UI',sans-serif}
main{max-width:46ch;padding:2rem}
p.k{margin:0;font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:.7rem;letter-spacing:.18em;
text-transform:uppercase;color:#1d3cff}
h1{font-family:'Instrument Serif',Georgia,'Times New Roman',serif;font-weight:400;font-size:1.9rem;
line-height:1.15;margin:.6rem 0 1rem}
a{color:#1d3cff;text-underline-offset:3px}
a:focus-visible{outline:2px solid #1d3cff;outline-offset:3px}
@media (prefers-color-scheme:dark){
body{background:#12100c;color:#f3efe6}
p.k,a{color:#93a4ff}
a:focus-visible{outline-color:#93a4ff}
}
CSS;
    echo '<!doctype html><html lang="en"><head><meta charset="utf-8">'
        . '<meta name="viewport" content="width=device-width,initial-scale=1">'
        . '<meta name="robots" content="noindex"><meta name="color-scheme" content="light dark">'
        . '<title>' . $title . ' — Hasan Abbas Sorathiya</title>'
        . '<style>' . $css . '</style></head><body><main>'
        . '<p class="k">Hasan Abbas Sorathiya</p><h1>' . $title . '</h1><p>' . $line . '</p>'
        . '<p><a href="https://hasanabbassorathiya.tech/">Back to the site</a></p>'
        . '</main></body></html>';
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') json_out(['error' => 'method not allowed'], 405);

$b = body();

// Honeypot: report success so bots do not learn the field is ignored.
if (trim((string)($b['website'] ?? '')) !== '') json_out(['ok' => true]);

$email = strtolower(trim((string)($b['email'] ?? '')));
$source = substr(preg_replace('/[^a-z0-9:-]/', '', strtolower((string)($b['source'] ?? 'site'))) ?: 'site', 0, 40);

$name = trim(preg_replace('/[\x00-\x1F\x7F]/u', '', (string)($b['name'] ?? '')));
if (mb_strlen($name) > 120) json_out(['error' => 'name too long (max 120 characters)'], 422);

$whatsapp = trim((string)($b['whatsapp'] ?? ''));
if ($whatsapp !== '') {
    $whatsapp = preg_replace('/[\s().-]/', '', $whatsapp);
    if (!preg_match('/^\+?[1-9][0-9]{6,14}$/', $whatsapp)) {
        json_out(['error' => 'valid WhatsApp number required (digits, optional leading +)'], 422);
    }
}

$consent = ($b['consent'] ?? null) === true;
if (($name !== '' || $whatsapp !== '') && !$consent) {
    json_out(['error' => 'consent required to store a name or WhatsApp number'], 422);
}

if ($email === '' || strlen($email) > 190 || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    json_out(['error' => 'valid email required'], 422);
}

$pdo = db();
$ipHash = hash('sha256', ($_SERVER['REMOTE_ADDR'] ?? '') . '|' . AUTH_PEPPER);

// Five new addresses per IP per hour, then answer as success — caps abuse without
// telling a script whether it was throttled.
$st = $pdo->prepare('SELECT COUNT(*) FROM subscribers WHERE ip_hash = ? AND created_at > NOW() - INTERVAL 1 HOUR');
$st->execute([$ipHash]);
if ((int)$st->fetchColumn() >= 5) json_out(['ok' => true]);

$pdo->prepare('INSERT INTO subscribers (email, name, whatsapp, source, consent_at, consent_version, ip_hash, unsub_token)
               VALUES (?,?,?,?,?,?,?,?)
               ON DUPLICATE KEY UPDATE
                 source = VALUES(source),
                 name = IF(VALUES(name) = \'\', name, VALUES(name)),
                 whatsapp = IF(VALUES(whatsapp) = \'\', whatsapp, VALUES(whatsapp)),
                 consent_at = COALESCE(VALUES(consent_at), consent_at),
                 consent_version = IF(VALUES(consent_version) = \'\', consent_version, VALUES(consent_version))')
    ->execute([
        $email, $name, $whatsapp, $source,
        $consent ? date('Y-m-d H:i:s') : null,
        $consent ? 'community-v1' : '',
        $ipHash, bin2hex(random_bytes(16)),
    ]);

// Autopilot: mirror the address into the Brevo list when configured. Best-effort —
// the local row is the source of truth and a Brevo outage must not fail the signup.
$mailSecret = __DIR__ . '/mail-secret.php';
if (is_file($mailSecret)) {
    $mail = require $mailSecret;
    if (is_array($mail) && !empty($mail['brevo_key']) && !empty($mail['brevo_list'])) {
        $ch = curl_init('https://api.brevo.com/v3/contacts');
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode([
                'email' => $email,
                'listIds' => [(int)$mail['brevo_list']],
                'updateEnabled' => true,
            ]),
            CURLOPT_HTTPHEADER => ['api-key: ' . $mail['brevo_key'], 'Content-Type: application/json'],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 3,
        ]);
        $resp = curl_exec($ch);
        $code = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        curl_close($ch);
        if ($resp === false || $code >= 400) error_log('subscribe: brevo sync failed (' . $code . ')');
    }
}

json_out(['ok' => true], 201);
