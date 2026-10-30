<?php
declare(strict_types=1);
require __DIR__ . '/guard.php';

$counts = [];
foreach (['apps', 'clients', 'posts'] as $table) {
    try {
        $total = (int) db()->query("SELECT COUNT(*) FROM `$table`")->fetchColumn();
        $published = (int) db()->query("SELECT COUNT(*) FROM `$table` WHERE published = 1")->fetchColumn();
        $counts[$table] = ['total' => $total, 'published' => $published];
    } catch (Throwable $e) {
        $counts[$table] = null;
    }
}
try {
    $subCount = (int) db()->query('SELECT COUNT(*) FROM subscribers')->fetchColumn();
    $subWeek = (int) db()->query('SELECT COUNT(*) FROM subscribers WHERE created_at > NOW() - INTERVAL 7 DAY')->fetchColumn();
} catch (Throwable $e) {
    $subCount = null;
    $subWeek = 0;
}
try {
    $enquiryNew = (int) db()->query("SELECT COUNT(*) FROM enquiries WHERE status = 'new'")->fetchColumn();
    $enquiryOpen = (int) db()->query("SELECT COUNT(*) FROM enquiries WHERE status IN ('new','contacted','qualified','proposal')")->fetchColumn();
} catch (Throwable $e) {
    $enquiryNew = null;
    $enquiryOpen = 0;
}
$labels = ['apps' => 'Apps', 'clients' => 'Clients', 'posts' => 'Posts'];

try {
    $visitors30 = (int) db()->query('SELECT COUNT(DISTINCT visitor) FROM analytics_events WHERE day >= CURDATE() - INTERVAL 29 DAY')->fetchColumn();
} catch (Throwable $e) {
    $visitors30 = null;
}
try {
    $settingsCount = (int) db()->query("SELECT COUNT(*) FROM settings WHERE v <> ''")->fetchColumn();
} catch (Throwable $e) {
    $settingsCount = null;
}
?><!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<title>Dashboard — Portfolio CMS</title>
<link rel="stylesheet" href="admin.css">
</head>
<body>
<nav class="topbar">
  <span class="logo">Portfolio CMS</span>
  <div class="entity-tabs">
    <a href="dashboard.php" class="active">Dashboard</a>
    <a href="edit.php?entity=apps">Apps</a>
    <a href="edit.php?entity=posts">Posts</a>
    <a href="analytics.php">Analytics</a>
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
      <h1>Dashboard</h1>
      <p class="meta">Apps, client case studies, and essays are stored in MySQL and rendered on the public site.</p>
    </div>
  </header>

  <nav class="entity-nav">
    <?php foreach (['apps', 'clients', 'posts'] as $entity): ?>
      <?php $c = $counts[$entity]; ?>
      <a href="edit.php?entity=<?=$entity?>" class="entity-card">
        <h2><?=$labels[$entity]?></h2>
        <p class="count"><?= $c === null ? '—' : $c['published'] ?></p>
        <p class="muted"><?= $c === null ? 'table missing' : $c['total'] . ' total · ' . $c['published'] . ' live' ?></p>
      </a>
    <?php endforeach; ?>
    <a href="enquiries.php" class="entity-card">
      <h2>Enquiries</h2>
      <p class="count"><?= $enquiryNew === null ? '—' : $enquiryNew ?></p>
      <p class="muted"><?= $enquiryNew === null ? 'table missing' : $enquiryOpen . ' open · ' . $enquiryNew . ' new' ?></p>
    </a>
    <a href="subscribers.php" class="entity-card">
      <h2>Subscribers</h2>
      <p class="count"><?= $subCount === null ? '—' : $subCount ?></p>
      <p class="muted"><?= $subCount === null ? 'table missing' : '+' . $subWeek . ' this week' ?></p>
    </a>
    <a href="analytics.php" class="entity-card">
      <h2>Analytics</h2>
      <p class="count"><?=$visitors30 === null ? '—' : number_format($visitors30)?></p>
      <p class="muted"><?=$visitors30 === null ? 'run v2-schema.sql' : 'visitors in the last 30 days' ?></p>
    </a>
    <a href="settings.php" class="entity-card">
      <h2>Settings</h2>
      <p class="count"><?=$settingsCount === null ? '—' : $settingsCount ?></p>
      <p class="muted"><?=$settingsCount === null ? 'run v2-schema.sql' : 'platform IDs and links configured' ?></p>
    </a>
  </nav>

  <section class="panel">
    <h2>How publishing works</h2>
    <ol class="steps">
      <li><strong>Edit</strong> a record and save. Changes are written to MySQL immediately.</li>
      <li><strong>Published</strong> must stay checked for the item to appear on the public site.</li>
      <li><strong>The live site</strong> loads apps, clients, and essays from <code>api/index.php</code> on every visit — visitors see changes immediately. Re-run the site build after major copy edits so pre-rendered pages and metadata match.</li>
      <li><strong>Order</strong> follows <em>sort order</em> (ascending), then id.</li>
    </ol>
  </section>
</main>
</body>
</html>
