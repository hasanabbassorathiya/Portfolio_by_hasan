<?php
declare(strict_types=1);

// Admin-triggered IndexNow submission: serves /<key>.txt and pushes the sitemap
// URL list to api.indexnow.org (Bing, Yandex, Seznam).
require __DIR__ . '/bootstrap.php';

require_admin();
admin_response_headers();
if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') json_out(['error' => 'method not allowed'], 405);
require_admin_csrf((string)($_SERVER['HTTP_X_CSRF_TOKEN'] ?? ''));

$key = '';
try {
    $st = db()->prepare("SELECT v FROM settings WHERE k = 'indexnow_key'");
    $st->execute();
    $key = trim((string)$st->fetchColumn());
} catch (Throwable $e) {
    json_out(['error' => 'settings unavailable', 'detail' => 'Run api/v2-schema.sql first.'], 503);
}
if (preg_match('/\A[a-f0-9]{8,128}\z/', $key) !== 1) {
    json_out(['error' => 'invalid key', 'detail' => 'Set a lowercase hex IndexNow key in Settings first.'], 422);
}

$root = dirname(__DIR__);
$keyFile = $key . '.txt';
if (file_put_contents($root . '/' . $keyFile, $key) === false) {
    json_out(['error' => 'key file not writable', 'detail' => 'Check write permissions on the site root.'], 500);
}
@chmod($root . '/' . $keyFile, 0644);

$urls = [];
$sitemapPath = $root . '/sitemap.xml';
if (is_file($sitemapPath)) {
    $xml = @simplexml_load_file($sitemapPath);
    if ($xml !== false) {
        foreach ($xml->xpath('//*[local-name()="url"]/*[local-name()="loc"]') ?: [] as $loc) {
            $url = trim((string)$loc);
            if (str_starts_with($url, 'https://')) $urls[] = $url;
        }
    }
}
$urls = array_slice(array_values(array_unique($urls)), 0, 10000);
if (!$urls) json_out(['error' => 'no urls', 'detail' => 'Build the site so sitemap.xml exists.'], 422);

$host = (string)($_SERVER['HTTP_HOST'] ?? '');
$host = explode(':', $host)[0];
if ($host === '' || !str_contains($host, '.')) {
    json_out(['error' => 'unknown host', 'detail' => 'Open Settings on the live domain before submitting.'], 422);
}

$payload = json_encode([
    'host' => $host,
    'key' => $key,
    'keyLocation' => 'https://' . $host . '/' . $keyFile,
    'urlList' => $urls,
], JSON_UNESCAPED_SLASHES);

$status = 0;
if (function_exists('curl_init')) {
    $curl = curl_init('https://api.indexnow.org/indexnow');
    curl_setopt_array($curl, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $payload,
        CURLOPT_HTTPHEADER => ['Content-Type: application/json; charset=utf-8'],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 15,
    ]);
    curl_exec($curl);
    $status = (int)curl_getinfo($curl, CURLINFO_RESPONSE_CODE);
    curl_close($curl);
} else {
    $context = stream_context_create(['http' => [
        'method' => 'POST',
        'header' => "Content-Type: application/json\r\n",
        'content' => $payload,
        'timeout' => 15,
        'ignore_errors' => true,
    ]]);
    @file_get_contents('https://api.indexnow.org/indexnow', false, $context);
    if (preg_match('#\s(\d{3})\s#', ' ' . ($http_response_header[0] ?? '') . ' ', $match)) {
        $status = (int)$match[1];
    }
}

json_out([
    'ok' => $status >= 200 && $status < 300,
    'submitted' => count($urls),
    'status' => $status,
    'keyFile' => '/' . $keyFile,
]);
