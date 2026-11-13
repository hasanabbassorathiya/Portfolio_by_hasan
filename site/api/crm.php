<?php
declare(strict_types=1);
// Dedicated CRM operations: enquiries, subscribers, settings.
// Not unrestricted table CRUD — each resource has its own validation and shape.
require __DIR__ . '/bootstrap.php';
require __DIR__ . '/enquiry-store.php';
require __DIR__ . '/settings-validate.php';

$method = $_SERVER['REQUEST_METHOD'];
$resource = (string)($_GET['resource'] ?? '');
$pdo = db();

if (!in_array($resource, ['enquiries', 'subscribers', 'settings'], true)) {
    json_out(['error' => 'resource must be enquiries, subscribers, or settings'], 400);
}

$adminId = require_admin();
if (in_array($method, ['POST', 'PUT', 'DELETE'], true)) {
    require_scope('crm:write');
    $csrf = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    require_admin_csrf(is_string($csrf) ? $csrf : '');
} else {
    require_scope('crm:read');
}

if (in_array($method, ['POST', 'PUT'], true)
    && stripos((string)($_SERVER['CONTENT_TYPE'] ?? ''), 'application/json') !== 0) {
    json_out(['error' => 'content-type must be application/json'], 415);
}

$id = (int)($_GET['id'] ?? 0);

// ---- Enquiries ----
if ($resource === 'enquiries') {
    if ($method === 'GET') {
        if ($id > 0) {
            $row = enquiry_detail($pdo, $id);
            if ($row === null) json_out(['error' => 'not found'], 404);
            json_out($row);
        }
        $page = max(1, (int)($_GET['page'] ?? 1));
        $status = (string)($_GET['status'] ?? '');
        try {
            json_out(enquiry_list($pdo, $page, $status));
        } catch (EnquiryError $e) {
            json_out(['error' => $e->errorCode], $e->httpStatus);
        }
    }
    if ($method === 'PUT') {
        if ($id < 1) json_out(['error' => 'id required'], 422);
        $b = body();
        $version = (int)($b['version'] ?? 0);
        if ($version < 1) json_out(['error' => 'version required for optimistic locking'], 422);
        try {
            enquiry_update($pdo, $id, $version, $b, $adminId);
        } catch (EnquiryError $e) {
            json_out(['error' => $e->errorCode], $e->httpStatus);
        }
        json_out(['ok' => true]);
    }
    json_out(['error' => 'method not allowed'], 405);
}

// ---- Subscribers ----
if ($resource === 'subscribers') {
    if ($method === 'GET') {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $offset = ($page - 1) * 50;
        $st = $pdo->prepare('SELECT id, email, name, whatsapp, source, consent_at, created_at FROM subscribers ORDER BY created_at DESC, id DESC LIMIT 51 OFFSET ?');
        $st->bindValue(1, $offset, PDO::PARAM_INT);
        $st->execute();
        $rows = $st->fetchAll();
        json_out(['rows' => array_slice($rows, 0, 50), 'page' => $page, 'has_more' => count($rows) > 50]);
    }
    if ($method === 'DELETE') {
        if ($id < 1) json_out(['error' => 'id required'], 422);
        $st = $pdo->prepare('DELETE FROM subscribers WHERE id = ?');
        $st->execute([$id]);
        if ($st->rowCount() !== 1) json_out(['error' => 'not found'], 404);
        json_out(['ok' => true]);
    }
    json_out(['error' => 'method not allowed'], 405);
}

// ---- Settings ----
if ($resource === 'settings') {
    if ($method === 'GET') {
        $rows = $pdo->query('SELECT k, v FROM settings ORDER BY k')->fetchAll();
        json_out(array_column($rows, 'v', 'k'));
    }
    if ($method === 'PUT') {
        $b = body();
        [$updates, $problems] = settings_validate($b);
        if ($problems) json_out(['error' => implode(' ', $problems)], 422);
        if (!$updates) json_out(['error' => 'no valid fields'], 400);
        $stmt = $pdo->prepare('INSERT INTO settings (k, v, is_public) VALUES (?, ?, 1) ON DUPLICATE KEY UPDATE v = VALUES(v)');
        foreach ($updates as $key => $value) $stmt->execute([$key, $value]);
        json_out(['ok' => true, 'updated' => array_keys($updates)]);
    }
    json_out(['error' => 'method not allowed'], 405);
}