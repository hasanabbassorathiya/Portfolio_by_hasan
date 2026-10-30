<?php
declare(strict_types=1);
require __DIR__ . '/guard.php';

function h($value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

$days = (int)($_GET['days'] ?? 30);
if (!in_array($days, [7, 30, 90], true)) $days = 30;
$since = date('Y-m-d', strtotime('-' . ($days - 1) . ' days'));

$pdo = db();
$ready = true;
$empty = [
    'visitors' => 0, 'views' => 0, 'sessions' => 0, 'stores' => 0,
    'enquiries' => 0, 'signups' => 0, 'appViews' => 0, 'storeVisitors' => 0,
];
$summary = $empty;
$daily = [];
$topPages = $referrers = $campaigns = $devices = $browsers = $countries = $recent = $apps = $clicks = [];
$error = '';

try {
    $row = $pdo->prepare("SELECT
        COUNT(DISTINCT visitor) visitors,
        COUNT(DISTINCT session) sessions,
        SUM(event = 'page_view') views,
        SUM(event = 'store_click') stores,
        SUM(event = 'enquiry_submit') enquiries,
        SUM(event = 'newsletter_signup') signups,
        COUNT(DISTINCT IF(event = 'page_view' AND path LIKE '/apps/%', visitor, NULL)) appViews,
        COUNT(DISTINCT IF(event = 'store_click', visitor, NULL)) storeVisitors
        FROM analytics_events WHERE day >= ?");
    $row->execute([$since]);
    $summary = array_merge($empty, array_map('intval', $row->fetch() ?: []));

    $stmt = $pdo->prepare("SELECT day, COUNT(DISTINCT visitor) visitors, SUM(event = 'page_view') views
        FROM analytics_events WHERE day >= ? GROUP BY day ORDER BY day");
    $stmt->execute([$since]);
    $byDay = [];
    foreach ($stmt->fetchAll() as $entry) $byDay[$entry['day']] = $entry;
    for ($i = $days - 1; $i >= 0; $i--) {
        $day = date('Y-m-d', strtotime("-$i days"));
        $daily[] = [
            'day' => $day,
            'visitors' => (int)($byDay[$day]['visitors'] ?? 0),
            'views' => (int)($byDay[$day]['views'] ?? 0),
        ];
    }

    $stmt = $pdo->prepare("SELECT path, COUNT(*) views, COUNT(DISTINCT visitor) visitors
        FROM analytics_events WHERE day >= ? AND event = 'page_view'
        GROUP BY path ORDER BY views DESC LIMIT 10");
    $stmt->execute([$since]);
    $topPages = $stmt->fetchAll();

    $stmt = $pdo->prepare("SELECT referrer_host, COUNT(*) hits, COUNT(DISTINCT visitor) visitors
        FROM analytics_events WHERE day >= ? AND event = 'page_view'
        GROUP BY referrer_host ORDER BY hits DESC LIMIT 10");
    $stmt->execute([$since]);
    $referrers = $stmt->fetchAll();

    $stmt = $pdo->prepare("SELECT
        COALESCE(JSON_UNQUOTE(JSON_EXTRACT(utm, '$.source')), '') source,
        COALESCE(JSON_UNQUOTE(JSON_EXTRACT(utm, '$.campaign')), '') campaign,
        COUNT(*) hits, COUNT(DISTINCT visitor) visitors
        FROM analytics_events WHERE day >= ? AND event = 'page_view' AND utm IS NOT NULL
        GROUP BY source, campaign ORDER BY hits DESC LIMIT 10");
    $stmt->execute([$since]);
    $campaigns = $stmt->fetchAll();

    $stmt = $pdo->prepare("SELECT device, COUNT(DISTINCT visitor) visitors, COUNT(*) events
        FROM analytics_events WHERE day >= ? GROUP BY device ORDER BY events DESC");
    $stmt->execute([$since]);
    $devices = $stmt->fetchAll();

    $stmt = $pdo->prepare("SELECT browser, COUNT(DISTINCT visitor) visitors, COUNT(*) events
        FROM analytics_events WHERE day >= ? GROUP BY browser ORDER BY events DESC");
    $stmt->execute([$since]);
    $browsers = $stmt->fetchAll();

    $stmt = $pdo->prepare("SELECT country, COUNT(DISTINCT visitor) visitors, COUNT(*) events
        FROM analytics_events WHERE day >= ? AND country <> '' GROUP BY country ORDER BY events DESC LIMIT 12");
    $stmt->execute([$since]);
    $countries = $stmt->fetchAll();

    $stmt = $pdo->prepare("SELECT ts, event, path, device, referrer_host, props
        FROM analytics_events WHERE day >= ? ORDER BY id DESC LIMIT 25");
    $stmt->execute([$since]);
    $recent = $stmt->fetchAll();

    $stmt = $pdo->prepare("SELECT path, COUNT(DISTINCT visitor) visitors
        FROM analytics_events WHERE day >= ? AND event = 'page_view' AND path LIKE '/apps/%'
        GROUP BY path ORDER BY visitors DESC LIMIT 12");
    $stmt->execute([$since]);
    $apps = $stmt->fetchAll();

    $stmt = $pdo->prepare("SELECT COALESCE(JSON_UNQUOTE(JSON_EXTRACT(props, '$.app')), '') app,
        COUNT(*) clicks, COUNT(DISTINCT visitor) visitors
        FROM analytics_events WHERE day >= ? AND event = 'store_click'
        GROUP BY app ORDER BY clicks DESC LIMIT 12");
    $stmt->execute([$since]);
    foreach ($stmt->fetchAll() as $entry) $clicks[$entry['app']] = $entry;
} catch (Throwable $e) {
    $ready = false;
    $error = $e->getMessage();
}

$peak = max(1, ...array_map(fn($d) => max($d['visitors'], $d['views']), $daily ?: [['visitors' => 1, 'views' => 1]]));
$points = function (string $key) use ($daily, $peak): string {
    $count = max(1, count($daily) - 1);
    return implode(' ', array_map(
        fn($i, $d) => sprintf('%s,%.1f', round($i * 300 / $count, 1), 58 - ($d[$key] / $peak) * 52),
        array_keys($daily),
        $daily,
    ));
};
$visitorLine = $points('visitors');
$viewLine = $points('views');
$topPage = $topPages[0]['path'] ?? '—';
?><!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<title>Analytics — Portfolio CMS</title>
<link rel="stylesheet" href="admin.css">
</head>
<body>
<nav class="topbar">
  <span class="logo">Portfolio CMS</span>
  <div class="entity-tabs">
    <a href="dashboard.php">Dashboard</a>
    <a href="edit.php?entity=apps">Apps</a>
    <a href="edit.php?entity=posts">Posts</a>
    <a href="analytics.php" class="active">Analytics</a>
    <a href="settings.php">Settings</a>
  </div>
  <div class="topbar-links">
    <a href="../" target="_blank" rel="noreferrer" class="logout">View site ↗</a>
    <a href="logout.php" class="logout">Sign out</a>
  </div>
</nav>
<main>
  <header class="page-head">
    <div>
      <h1>Analytics</h1>
      <p class="meta">First-party traffic from this site only. Visitors are a salted daily hash — no cookies, no raw IPs, no cross-site tracking.</p>
    </div>
    <div class="entity-tabs">
      <?php foreach ([7, 30, 90] as $range): ?>
        <a href="?days=<?=$range?>" class="<?=$range === $days ? 'active' : ''?>"><?=$range?>d</a>
      <?php endforeach; ?>
    </div>
  </header>

  <?php if (!$ready): ?>
    <section class="panel">
      <h2>Analytics tables are not installed</h2>
      <p class="meta">Run <code>api/v2-schema.sql</code> in phpMyAdmin, then reload this page.</p>
      <p class="form-error"><?=h($error)?></p>
    </section>
  <?php else: ?>

  <nav class="entity-nav">
    <div class="entity-card"><h2>Visitors</h2><p class="count"><?=number_format($summary['visitors'])?></p><p class="muted"><?=number_format($summary['sessions'])?> sessions · <?=$days?> days</p></div>
    <div class="entity-card"><h2>Pageviews</h2><p class="count"><?=number_format($summary['views'])?></p><p class="muted">top page <?=h($topPage)?></p></div>
    <div class="entity-card"><h2>Store clicks</h2><p class="count"><?=number_format($summary['stores'])?></p><p class="muted"><?=number_format($summary['storeVisitors'])?> visitors tapped a store link</p></div>
    <div class="entity-card"><h2>Enquiries</h2><p class="count"><?=number_format($summary['enquiries'])?></p><p class="muted"><?=number_format($summary['signups'])?> newsletter signups</p></div>
  </nav>

  <section class="panel" style="margin-bottom:1.5rem">
    <div class="panel-head">
      <h2>Traffic</h2>
      <p class="muted" style="margin:0">Visitors <span class="legend legend-visitor"></span> · Pageviews <span class="legend legend-view"></span></p>
    </div>
    <svg viewBox="0 0 300 60" preserveAspectRatio="none" role="img" aria-label="Daily visitors and pageviews for the last <?=$days?> days" style="width:100%;height:120px;margin-top:.75rem">
      <polyline fill="none" stroke="var(--accent)" stroke-width="1.4" points="<?=h($visitorLine)?>" />
      <polyline fill="none" stroke="var(--accent-solid)" stroke-width="1.2" stroke-opacity=".55" points="<?=h($viewLine)?>" />
    </svg>
    <p class="muted">Peak day: <?=number_format($peak)?> visitors or pageviews.</p>
  </section>

  <div class="grid-2">
    <section class="panel">
      <h2>Top pages</h2>
      <table class="data-table compact">
        <thead><tr><th>Path</th><th>Views</th><th>Visitors</th></tr></thead>
        <tbody>
          <?php if (!$topPages): ?><tr><td colspan="3"><em>No pageviews in this range yet.</em></td></tr><?php endif; ?>
          <?php foreach ($topPages as $page): ?>
            <tr><td><?=h($page['path'])?></td><td><?=number_format((int)$page['views'])?></td><td><?=number_format((int)$page['visitors'])?></td></tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </section>

    <section class="panel">
      <h2>Referrers</h2>
      <table class="data-table compact">
        <thead><tr><th>Host</th><th>Visits</th><th>Visitors</th></tr></thead>
        <tbody>
          <?php if (!$referrers): ?><tr><td colspan="3"><em>No referrers recorded yet.</em></td></tr><?php endif; ?>
          <?php foreach ($referrers as $entry): ?>
            <tr><td><?=h($entry['referrer_host'] !== '' ? $entry['referrer_host'] : 'direct')?></td><td><?=number_format((int)$entry['hits'])?></td><td><?=number_format((int)$entry['visitors'])?></td></tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </section>

    <section class="panel">
      <h2>Campaigns</h2>
      <table class="data-table compact">
        <thead><tr><th>Source</th><th>Campaign</th><th>Visits</th></tr></thead>
        <tbody>
          <?php if (!$campaigns): ?><tr><td colspan="3"><em>No UTM-tagged visits yet. Build links in <a href="settings.php#utm">Settings</a>.</em></td></tr><?php endif; ?>
          <?php foreach ($campaigns as $entry): ?>
            <tr><td><?=h($entry['source'] !== '' ? $entry['source'] : '—')?></td><td><?=h($entry['campaign'] !== '' ? $entry['campaign'] : '—')?></td><td><?=number_format((int)$entry['hits'])?></td></tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </section>

    <section class="panel">
      <h2>Devices &amp; browsers</h2>
      <table class="data-table compact">
        <thead><tr><th>Device</th><th>Visitors</th><th>Events</th></tr></thead>
        <tbody>
          <?php if (!$devices): ?><tr><td colspan="3"><em>No events yet.</em></td></tr><?php endif; ?>
          <?php foreach ($devices as $entry): ?>
            <tr><td><?=h($entry['device'])?></td><td><?=number_format((int)$entry['visitors'])?></td><td><?=number_format((int)$entry['events'])?></td></tr>
          <?php endforeach; ?>
        </tbody>
      </table>
      <p class="muted" style="margin-top:.6rem">
        <?php foreach ($browsers as $entry): ?><?=h($entry['browser'])?> <?=number_format((int)$entry['events'])?> · <?php endforeach; ?>
      </p>
    </section>

    <?php if ($countries): ?>
    <section class="panel">
      <h2>Countries</h2>
      <table class="data-table compact">
        <thead><tr><th>Country</th><th>Visitors</th><th>Events</th></tr></thead>
        <tbody>
          <?php foreach ($countries as $entry): ?>
            <tr><td><?=h($entry['country'])?></td><td><?=number_format((int)$entry['visitors'])?></td><td><?=number_format((int)$entry['events'])?></td></tr>
          <?php endforeach; ?>
        </tbody>
      </table>
      <p class="muted" style="margin-top:.6rem">Only shown when the host/CDN supplies a country header.</p>
    </section>
    <?php endif; ?>

    <section class="panel">
      <h2>Funnel · <?=$days?> days</h2>
      <ol class="funnel">
        <li><span>All visitors</span><strong><?=number_format($summary['visitors'])?></strong></li>
        <li><span>Viewed an app</span><strong><?=number_format($summary['appViews'])?></strong></li>
        <li><span>Tapped a store link</span><strong><?=number_format($summary['storeVisitors'])?></strong></li>
        <li><span>Sent an enquiry</span><strong><?=number_format($summary['enquiries'])?></strong></li>
      </ol>
    </section>
  </div>

  <section class="panel" style="margin-top:1.5rem">
    <h2>Apps · views and store clicks</h2>
    <table class="data-table">
      <thead><tr><th>App</th><th>Detail views</th><th>Store clicks</th></tr></thead>
      <tbody>
        <?php if (!$apps): ?><tr><td colspan="3"><em>No app-detail views yet.</em></td></tr><?php endif; ?>
        <?php foreach ($apps as $entry): $slug = basename($entry['path']); ?>
          <tr>
            <td><a href="../apps/<?=h($slug)?>" target="_blank" rel="noreferrer"><?=h($slug)?></a></td>
            <td><?=number_format((int)$entry['visitors'])?></td>
            <td><?=number_format((int)($clicks[$slug]['clicks'] ?? 0))?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </section>

  <section class="panel" style="margin-top:1.5rem">
    <h2>Recent events</h2>
    <table class="data-table">
      <thead><tr><th>Time (UTC+4)</th><th>Event</th><th>Path</th><th>Device</th><th>From</th></tr></thead>
      <tbody>
        <?php if (!$recent): ?><tr><td colspan="5"><em>No events yet. Open the site in a browser to see the first one.</em></td></tr><?php endif; ?>
        <?php foreach ($recent as $entry): ?>
          <tr>
            <td><?=h($entry['ts'])?></td>
            <td><?=h($entry['event'])?><?php $props = json_decode((string)$entry['props'], true); ?>
              <?php if (is_array($props) && $props): ?><span class="muted"><?=h(implode(' · ', array_map(fn($k, $v) => "$k: $v", array_keys($props), $props)))?></span><?php endif; ?>
            </td>
            <td><?=h($entry['path'])?></td>
            <td><?=h($entry['device'])?></td>
            <td><?=h($entry['referrer_host'] !== '' ? $entry['referrer_host'] : 'direct')?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <p class="muted" style="margin-top:.7rem">Raw events are kept for 180 days, then pruned automatically.</p>
  </section>
  <?php endif; ?>
</main>
</body>
</html>
