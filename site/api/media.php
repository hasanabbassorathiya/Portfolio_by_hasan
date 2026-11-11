<?php
declare(strict_types=1);
// Media library: GET list/filter, POST upload (delegates to upload logic).
require __DIR__ . '/bootstrap.php';

$method = $_SERVER['REQUEST_METHOD'];
$pdo = db();

require_admin();
if ($method === 'GET') {
    require_scope('media:read');
    $folder = (string)($_GET['folder'] ?? '');
    $page = max(1, (int)($_GET['page'] ?? 1));
    $offset = ($page - 1) * 50;
    if ($folder !== '' && !preg_match('/\A[a-z0-9][a-z0-9-]{0,59}\z/', $folder)) {
        json_out(['error' => 'invalid folder'], 400);
    }
    $where = $folder !== '' ? ' WHERE folder = ?' : '';
    $sql = 'SELECT id, path, folder, mime, bytes, width, height, created_at FROM media' . $where . ' ORDER BY created_at DESC, id DESC LIMIT 51 OFFSET ?';
    $st = $pdo->prepare($sql);
    $i = 1;
    if ($folder !== '') $st->bindValue($i++, $folder, PDO::PARAM_STR);
    $st->bindValue($i, $offset, PDO::PARAM_INT);
    $st->execute();
    $rows = $st->fetchAll();
    foreach ($rows as &$row) {
        $row['id'] = (int)$row['id'];
        $row['bytes'] = (int)$row['bytes'];
        $row['width'] = (int)$row['width'];
        $row['height'] = (int)$row['height'];
    }
    unset($row);
    json_out(['rows' => array_slice($rows, 0, 50), 'page' => $page, 'has_more' => count($rows) > 50]);
}

if ($method === 'POST') {
    require_scope('media:write');
    $csrf = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? ($_POST['csrf_token'] ?? '');
    require_admin_csrf(is_string($csrf) ? $csrf : '');
    require __DIR__ . '/upload-handler.php';
    exit;
}

if ($method === 'DELETE') {
    require_scope('media:write');
    $csrf = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    require_admin_csrf(is_string($csrf) ? $csrf : '');
    $id = (int)($_GET['id'] ?? 0);
    if ($id < 1) json_out(['error' => 'id required'], 422);
    $st = $pdo->prepare('SELECT path FROM media WHERE id = ?');
    $st->execute([$id]);
    $row = $st->fetch();
    if (!$row) json_out(['error' => 'not found'], 404);
    $pdo->prepare('DELETE FROM media WHERE id = ?')->execute([$id]);
    $file = dirname(__DIR__) . $row['path'];
    if (is_file($file)) @unlink($file);
    json_out(['ok' => true]);
}

json_out(['error' => 'method not allowed'], 405);