<?php
declare(strict_types=1);
// Public content endpoint: GET /api/index.php?entity=profile|projects|experience|skills|testimonials|clients|apps|posts
// Read-only; the SPA maps these to site sections.
require __DIR__ . '/bootstrap.php';

$allowed = ['profile' => 'profile', 'projects' => 'projects', 'experience' => 'experiences',
            'skills' => 'skills', 'testimonials' => 'testimonials', 'clients' => 'clients',
            'apps' => 'apps', 'posts' => 'posts', 'settings' => 'settings'];

$entity = $_GET['entity'] ?? '';
if (!isset($allowed[$entity])) json_out(['error' => 'unknown entity'], 400);

$table = $allowed[$entity];
$pdo = db();
if ($entity === 'profile') {
    json_out(['entity' => 'profile', 'data' => $pdo->query('SELECT k, v FROM profile')->fetchAll()]);
}
if ($entity === 'settings') {
    $rows = $pdo->query('SELECT k, v FROM settings WHERE is_public = 1 AND v <> \'\'')->fetchAll();
    json_out(['entity' => 'settings', 'data' => array_column($rows, 'v', 'k')]);
}

$where = in_array($entity, ['clients', 'apps', 'posts'], true) ? ' WHERE published = 1' : '';
if ($entity === 'posts') {
    $where .= ' AND post_date <= CURDATE()';
    $order = ' ORDER BY post_date DESC, id DESC';
} else {
    $order = ' ORDER BY sort_order ASC, id ASC';
}
json_out(['entity' => $entity, 'data' => $pdo->query("SELECT * FROM `$table`" . $where . $order)->fetchAll()]);
