<?php
declare(strict_types=1);

// First-party analytics beacon. Public, unauthenticated, always 204 — the
// client must never be able to probe internals through this endpoint.
require __DIR__ . '/bootstrap.php';

http_response_code(204);
header('Cache-Control: no-store');

function track_drop(): void {
    http_response_code(204);
    exit;
}

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') track_drop();
if (stripos($_SERVER['CONTENT_TYPE'] ?? '', 'application/json') === false) track_drop();

// Same-origin only: an Origin we do not own is a cross-site write attempt.
$origin = (string)($_SERVER['HTTP_ORIGIN'] ?? '');
$host = (string)($_SERVER['HTTP_HOST'] ?? '');
if ($origin !== '') {
    $originHost = parse_url($origin, PHP_URL_HOST);
    $hostOnly = explode(':', $host)[0];
    if (!is_string($originHost) || strcasecmp($originHost, $hostOnly) !== 0) track_drop();
} elseif (($_SERVER['HTTP_SEC_FETCH_SITE'] ?? '') === 'cross-site') {
    track_drop();
}

try {
    // Signed-in admins browsing the site are not visitors.
    if (admin_id() !== null) track_drop();

    $payload = body();
    $ua = substr((string)($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 512);

    if ($ua === '' || preg_match('/bot|crawl|spider|slurp|headless|phantom|puppeteer|playwright|lighthouse|pingdom|uptime|monitor|preview|curl|wget|python-requests|go-http-client|node-fetch|axios|facebookexternalhit|scrapy/i', $ua)) {
        track_drop();
    }

    $events = [
        'page_view', 'page_leave', 'cta_click', 'store_click', 'app_open', 'section_view',
        'outbound_click', 'resume_open', 'newsletter_signup', 'enquiry_submit', 'project_open',
        'community_join',
    ];
    $propsWhitelist = [
        'page_view' => ['title'],
        'page_leave' => ['dwell_ms'],
        'cta_click' => ['kind', 'meta'],
        'store_click' => ['app', 'platform'],
        'app_open' => ['app', 'slug'],
        'section_view' => ['section'],
        'outbound_click' => ['label', 'href'],
        'resume_open' => ['location'],
        'newsletter_signup' => ['source'],
        'enquiry_submit' => ['type', 'category'],
        'project_open' => ['entity'],
        'community_join' => ['target'],
    ];
    $event = is_string($payload['event'] ?? null) ? $payload['event'] : '';
    if (!isset($propsWhitelist[$event])) track_drop();

    $rawPath = is_string($payload['path'] ?? null) ? $payload['path'] : '';
    $path = parse_url($rawPath, PHP_URL_PATH);
    $path = is_string($path) ? substr($path, 0, 255) : '';
    if ($path === '' || $path[0] !== '/' || preg_match('#\A/[A-Za-z0-9._~\-/]*\z#', $path) !== 1) track_drop();
    if ($path === '/admin' || str_starts_with($path, '/admin/')) track_drop();

    $session = is_string($payload['session'] ?? null) ? $payload['session'] : '';
    if (preg_match('/\A[a-f0-9]{32}\z/', $session) !== 1) track_drop();

    $props = [];
    $incoming = is_array($payload['props'] ?? null) ? $payload['props'] : [];
    foreach ($propsWhitelist[$event] as $key) {
        if (!array_key_exists($key, $incoming)) continue;
        $value = $incoming[$key];
        if ($event === 'page_leave' && $key === 'dwell_ms') {
            $ms = (int)$value;
            $props[$key] = max(0, min($ms, 1800000));
            continue;
        }
        if (!is_string($value)) continue;
        $value = trim($value);
        if ($value !== '') $props[$key] = substr($value, 0, 120);
    }

    $utmIn = is_array($payload['utm'] ?? null) ? $payload['utm'] : [];
    $utm = [];
    foreach (['source', 'medium', 'campaign', 'term', 'content'] as $key) {
        $value = is_string($utmIn[$key] ?? null) ? trim($utmIn[$key]) : '';
        if ($value !== '') $utm[$key] = substr($value, 0, 80);
    }

    $referrer = is_string($payload['referrer'] ?? null) ? strtolower(trim($payload['referrer'])) : '';
    if (preg_match('/\A[a-z0-9]([a-z0-9.\-]{0,118}[a-z0-9])?\z/', $referrer) !== 1) $referrer = '';
    if ($referrer !== '' && strcasecmp($referrer, explode(':', $host)[0]) === 0) $referrer = '';

    $ip = (string)($_SERVER['REMOTE_ADDR'] ?? '');
    $salt = defined('ANALYTICS_SALT') && ANALYTICS_SALT !== '' ? ANALYTICS_SALT : AUTH_PEPPER;
    $day = gmdate('Y-m-d');
    $visitor = substr(hash_hmac('sha256', $day . '|' . $ip . '|' . $ua, $salt), 0, 32);

    $pdo = db();

    // 120 events/minute per visitor hash; silent drop beyond that.
    $rate = $pdo->prepare('SELECT COUNT(*) FROM analytics_events WHERE visitor = ? AND ts > NOW() - INTERVAL 1 MINUTE');
    $rate->execute([$visitor]);
    if ((int)$rate->fetchColumn() > 120) track_drop();

    [$device, $browser, $os] = track_client_profile($ua);
    $country = strtoupper(substr((string)($_SERVER['HTTP_CF_IPCOUNTRY'] ?? $_SERVER['HTTP_X_COUNTRY_CODE'] ?? ''), 0, 2));
    if (preg_match('/\A[A-Z]{2}\z/', $country) !== 1) $country = '';

    $insert = $pdo->prepare('INSERT INTO analytics_events
        (ts, day, visitor, session, path, event, referrer_host, utm, device, browser, os, country, props)
        VALUES (NOW(3), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $insert->execute([
        $day, $visitor, $session, $path, $event, $referrer,
        $utm ? json_encode($utm, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) : null,
        $device, $browser, $os, $country,
        $props ? json_encode($props, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) : null,
    ]);

    $daily = $pdo->prepare('INSERT INTO analytics_daily (day, path, event, device, events)
        VALUES (?, ?, ?, ?, 1) ON DUPLICATE KEY UPDATE events = events + 1');
    $daily->execute([$day, substr($path, 0, 180), $event, $device]);

    if (random_int(1, 200) === 1) {
        $pdo->exec('DELETE FROM analytics_events WHERE ts < NOW() - INTERVAL 180 DAY LIMIT 5000');
    }
} catch (Throwable $e) {
    // Never disclose why a beacon was dropped.
}

track_drop();

function track_client_profile(string $ua): array {
    $device = 'desktop';
    if (preg_match('/iPad|Tablet|PlayBook|Silk/i', $ua)) $device = 'tablet';
    elseif (preg_match('/Mobi|iPhone|iPod|Android.*Mobile|Windows Phone/i', $ua)) $device = 'mobile';

    $browser = 'other';
    if (preg_match('/Edg\//i', $ua)) $browser = 'edge';
    elseif (preg_match('/OPR\/|Opera/i', $ua)) $browser = 'opera';
    elseif (preg_match('/SamsungBrowser/i', $ua)) $browser = 'samsung';
    elseif (preg_match('/Firefox|FxiOS/i', $ua)) $browser = 'firefox';
    elseif (preg_match('/Chrome|CriOS/i', $ua)) $browser = 'chrome';
    elseif (preg_match('/Safari/i', $ua)) $browser = 'safari';

    $os = 'other';
    if (preg_match('/iPhone|iPad|iPod/i', $ua)) $os = 'ios';
    elseif (preg_match('/Android/i', $ua)) $os = 'android';
    elseif (preg_match('/Mac OS X|Macintosh/i', $ua)) $os = 'macos';
    elseif (preg_match('/Windows/i', $ua)) $os = 'windows';
    elseif (preg_match('/Linux|CrOS/i', $ua)) $os = 'linux';

    return [$device, $browser, $os];
}
