<?php
declare(strict_types=1);
// Scoped token management. Session tokens only — a scoped token cannot create or revoke tokens.
require __DIR__ . '/bootstrap.php';

$adminId = require_session();
$method = $_SERVER['REQUEST_METHOD'];
$pdo = db();

if (in_array($method, ['POST', 'DELETE'], true)) {
    $csrf = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    require_admin_csrf(is_string($csrf) ? $csrf : '');
}

const ALLOWED_SCOPES = ['content:read', 'content:write', 'media:read', 'media:write', 'crm:read', 'crm:write'];

if ($method === 'GET') {
    $st = $pdo->prepare('SELECT id, label, scopes, expires_at, revoked_at, created_at FROM api_tokens WHERE admin_id = ? ORDER BY created_at DESC');
    $st->execute([$adminId]);
    $tokens = [];
    foreach ($st->fetchAll() as $row) {
        $row['id'] = (int)$row['id'];
        $row['scopes'] = json_decode($row['scopes'], true);
        $row['active'] = $row['revoked_at'] === null && strtotime($row['expires_at']) > time();
        $tokens[] = $row;
    }
    json_out(['tokens' => $tokens, 'allowed_scopes' => ALLOWED_SCOPES]);
}

if ($method === 'POST') {
    if (stripos((string)($_SERVER['CONTENT_TYPE'] ?? ''), 'application/json') !== 0) {
        json_out(['error' => 'content-type must be application/json'], 415);
    }
    $b = body();
    $label = trim((string)($b['label'] ?? ''));
    if ($label === '' || mb_strlen($label) > 120) json_out(['error' => 'label required (max 120 chars)'], 422);
    $scopes = $b['scopes'] ?? [];
    if (!is_array($scopes) || $scopes === []) json_out(['error' => 'scopes must be a non-empty array'], 422);
    foreach ($scopes as $s) {
        if (!is_string($s) || !in_array($s, ALLOWED_SCOPES, true)) {
            json_out(['error' => 'unknown scope: ' . (is_string($s) ? $s : '?'), 'allowed' => ALLOWED_SCOPES], 422);
        }
    }
    $scopes = array_values(array_unique($scopes));
    $days = (int)($b['days'] ?? 90);
    if ($days < 1 || $days > 365) json_out(['error' => 'days must be 1–365'], 422);

    $token = bin2hex(random_bytes(32));
    $pdo->prepare('INSERT INTO api_tokens (token, admin_id, label, scopes, expires_at) VALUES (?,?,?,?, DATE_ADD(NOW(), INTERVAL ? DAY))')
        ->execute([$token, $adminId, $label, json_encode($scopes), $days]);
    $id = (int)$pdo->lastInsertId();
    json_out(['id' => $id, 'token' => $token, 'csrf' => csrf_for($token), 'scopes' => $scopes, 'expires_in' => $days * 86400], 201);
}

if ($method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    if ($id < 1) json_out(['error' => 'id required'], 422);
    $st = $pdo->prepare('UPDATE api_tokens SET revoked_at = NOW() WHERE id = ? AND admin_id = ? AND revoked_at IS NULL');
    $st->execute([$id, $adminId]);
    if ($st->rowCount() !== 1) json_out(['error' => 'not found or already revoked'], 404);
    json_out(['ok' => true]);
}

json_out(['error' => 'method not allowed'], 405);