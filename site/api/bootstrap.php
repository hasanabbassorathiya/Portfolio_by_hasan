<?php
declare(strict_types=1);

// Single content bootstrap: DB handle, JSON helpers, auth guard.
// Hostinger: fill credentials in cPanel > MySQL Databases; never commit real values.
require __DIR__ . '/config.php';

function db(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4',
            DB_HOST, DB_NAME);
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }
    return $pdo;
}

function json_out(array $payload, int $status = 200): void {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    exit;
}

function body(): array {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw ?: '[]', true);
    return is_array($data) ? $data : [];
}

function admin_id(): ?int {
    $hdr = $_SERVER['HTTP_X_AUTH_TOKEN'] ?? '';
    if ($hdr === '' || !preg_match('/^[a-f0-9]{64}$/', $hdr)) return null;
    $st = db()->prepare('SELECT admin_id, expires_at > NOW() AS live FROM auth_tokens WHERE token = ?');
    $st->execute([$hdr]);
    $row = $st->fetch();
    if (!$row || !$row['live']) return null;
    return (int)$row['admin_id'];
}

function require_admin(): int {
    $id = admin_id();
    if ($id === null) { json_out(['error' => 'unauthorized'], 401); }
    return $id;
}
