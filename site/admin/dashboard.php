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

// Load scheduled posts for content planner
$scheduledPosts = [];
try {
    $stmt = db()->query("SELECT id, title, post_date, published FROM posts WHERE post_date >= CURDATE() - INTERVAL 7 DAY AND published = 1 ORDER BY post_date ASC LIMIT 20");
    $scheduledPosts = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {}
?><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="robots" content="noindex,nofollow">
    <title>Dashboard — Portfolio CMS</title>
    <link rel="stylesheet" href="admin.css">
</head>
<body>
<nav class="topbar">
    <a href="index.php" class="logo">Portfolio CMS</a>
    <div class="entity-tabs">
        <a href="dashboard.php" class="active" aria-current="page">Dashboard</a>
        <a href="edit.php?entity=apps">Apps</a>
        <a href="edit.php?entity=posts">Posts</a>
        <a href="enquiries.php">Enquiries</a>
        <a href="subscribers.php">Subscribers</a>
        <a href="analytics.php">Analytics</a>
        <a href="settings.php">Settings</a>
    </div>
    <div class="topbar-links">
        <a href="../" target="_blank" rel="noreferrer" class="logout">View site ↗</a>
        <a href="logout.php" class="btn btn-sm">Sign out</a>
    </div>
</nav>
<main>
    <header class="page-head container">
        <div>
            <h1>Dashboard</h1>
            <p class="meta">Content management and analytics for your portfolio site.</p>
        </div>
    </header>

    <section class="container">
        <h2 class="sr-only">Stats cards</h2>
        <nav class="entity-nav">
            <a href="edit.php?entity=apps" class="entity-card" aria-labelledby="apps-title apps-count apps-meta">
                <h2 id="apps-title">Apps</h2>
                <p id="apps-count" class="count"><?= $counts['apps'] === null ? '—' : $counts['apps']['published'] ?></p>
                <p id="apps-meta" class="muted"><?= $counts['apps'] === null ? 'table missing' : $counts['apps']['total'] . ' total · ' . $counts['apps']['published'] . ' live' ?></p>
            </a>
            <a href="edit.php?entity=clients" class="entity-card" aria-labelledby="clients-title clients-count clients-meta">
                <h2 id="clients-title">Clients</h2>
                <p id="clients-count" class="count"><?= $counts['clients'] === null ? '—' : $counts['clients']['published'] ?></p>
                <p id="clients-meta" class="muted"><?= $counts['clients'] === null ? 'table missing' : $counts['clients']['total'] . ' total · ' . $counts['clients']['published'] . ' live' ?></p>
            </a>
            <a href="edit.php?entity=posts" class="entity-card" aria-labelledby="posts-title posts-count posts-meta">
                <h2 id="posts-title">Posts</h2>
                <p id="posts-count" class="count"><?= $counts['posts'] === null ? '—' : $counts['posts']['published'] ?></p>
                <p id="posts-meta" class="muted"><?= $counts['posts'] === null ? 'table missing' : $counts['posts']['total'] . ' total · ' . $counts['posts']['published'] . ' published' ?></p>
            </a>
            <a href="enquiries.php" class="entity-card" aria-labelledby="enquiries-title enquiries-count enquiries-meta">
                <h2 id="enquiries-title">Enquiries</h2>
                <p id="enquiries-count" class="count"><?= $enquiryNew === null ? '—' : $enquiryNew ?></p>
                <p id="enquiries-meta" class="muted"><?= $enquiryNew === null ? 'table missing' : $enquiryOpen . ' open · ' . $enquiryNew . ' new' ?></p>
            </a>
            <a href="subscribers.php" class="entity-card" aria-labelledby="subscribers-title subscribers-count subscribers-meta">
                <h2 id="subscribers-title">Subscribers</h2>
                <p id="subscribers-count" class="count"><?= $subCount === null ? '—' : number_format($subCount) ?></p>
                <p id="subscribers-meta" class="muted"><?= $subCount === null ? 'table missing' : '+' . $subWeek . ' this week' ?></p>
            </a>
            <a href="analytics.php" class="entity-card" aria-labelledby="analytics-title analytics-count analytics-meta">
                <h2 id="analytics-title">Analytics</h2>
                <p id="analytics-count" class="count"><?= $visitors30 === null ? '—' : number_format($visitors30) ?></p>
                <p id="analytics-meta" class="muted"><?= $visitors30 === null ? 'run v2-schema.sql' : 'visitors in the last 30 days' ?></p>
            </a>
            <a href="settings.php" class="entity-card" aria-labelledby="settings-title settings-count settings-meta">
                <h2 id="settings-title">Settings</h2>
                <p id="settings-count" class="count"><?= $settingsCount === null ? '—' : $settingsCount ?></p>
                <p id="settings-meta" class="muted"><?= $settingsCount === null ? 'run v2-schema.sql' : 'platform IDs configured' ?></p>
            </a>
        </nav>
    </section>

    <section class="panel container">
        <h2>How publishing works</h2>
        <ol class="steps">
            <li><strong>Edit</strong> a record and save. Changes are written to MySQL immediately.</li>
            <li><strong>Published</strong> must stay checked for the item to appear on the public site.</li>
            <li><strong>The live site</strong> loads apps, clients, and essays from <code>api/index.php</code> on every visit — visitors see changes immediately.</li>
            <li><strong>Order</strong> follows <em>sort order</em> (ascending), then id.</li>
        </ol>
    </section>

    <section class="content-planner container">
        <div class="planner-header">
            <div>
                <h2>Content Planner</h2>
                <p class="meta">Schedule and track your content. Published items appear on the live site immediately.</p>
            </div>
            <div class="planner-controls">
                <a href="edit.php?entity=posts" class="btn btn-sm btn-primary">+ New Post</a>
            </div>
        </div>
        
        <div class="calendar" role="grid" aria-label="Content calendar for next 7 days">
            <div class="calendar-header" role="row">
                <div role="columnheader">Sun</div>
                <div role="columnheader">Mon</div>
                <div role="columnheader">Tue</div>
                <div role="columnheader">Wed</div>
                <div role="columnheader">Thu</div>
                <div role="columnheader">Fri</div>
                <div role="columnheader">Sat</div>
            </div>
            <div class="calendar-days" role="rowgroup">
                <?php 
                $startOfWeek = strtotime('last sunday');
                for ($week = 0; $week < 2; $week++) {
                    for ($day = 0; $day < 7; $day++) {
                        $date = strtotime("+$day days + $week weeks", $startOfWeek);
                        $dateStr = date('Y-m-d', $date);
                        $dayPosts = array_filter($scheduledPosts, fn($p) => substr($p['post_date'], 0, 10) === $dateStr);
                        ?>
                        <div class="calendar-day" role="row" aria-label="<?= date('l, M j', $date) ?>">
                            <div class="calendar-day-header" role="columnheader"><span><?= date('j', $date) ?></span></div>
                            <div class="calendar-day-content" role="gridcell">
                                <?php if (count($dayPosts) === 0): ?>
                                    <div class="planner-empty">No content scheduled</div>
                                <?php else: ?>
                                    <?php foreach ($dayPosts as $post): ?>
                                        <div class="planned-item published" title="<?= htmlspecialchars($post['title']) ?>">
                                            <div class="planned-item-title"><?= htmlspecialchars(mb_strimwidth($post['title'], 0, 30, '...')) ?></div>
                                            <div class="planned-item-time"><?= date('g:i A', strtotime($post['id'] . ' min')) ?> UTC</div>
                                        </div>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </div>
                        </div>
                    <?php }
                }
                ?>
            </div>
        </div>
    </section>

    <section class="panel container" style="margin-top: 1.5rem">
        <h2>Quick Actions</h2>
        <div class="grid-2">
            <div class="panel">
                <h3>Quick Links</h3>
                <ul class="field-help" style="margin-left: 1.5rem; list-style: none; padding: 0;">
                    <li><a href="edit.php?entity=apps">Manage Apps</a></li>
                    <li><a href="edit.php?entity=posts">Manage Posts</a></li>
                    <li><a href="settings.php">Site Settings</a></li>
                    <li><a href="analytics.php">Analytics Dashboard</a></li>
                </ul>
            </div>
            <div class="panel">
                <h3>Recent Activity</h3>
                <p class="meta">Last 7 days</p>
                <?php if ($scheduledPosts): ?>
                    <ul class="field-help" style="margin-left: 1.5rem; list-style: none; padding: 0;">
                        <?php foreach (array_slice($scheduledPosts, 0, 5) as $post): ?>
                            <li><a href="edit.php?entity=posts" class="planned-item">Updated: <?= htmlspecialchars(mb_strimwidth($post['title'], 0, 40, '...')) ?></a></li>
                        <?php endforeach; ?>
                    </ul>
                <?php else: ?>
                    <p class="muted">No recent content updates.</p>
                <?php endif; ?>
            </div>
        </div>
    </section>
</main>
</body>
</html>
