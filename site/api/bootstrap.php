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

function auth_token(): string {
    $hdr = $_SERVER['HTTP_X_AUTH_TOKEN'] ?? '';
    if (is_string($hdr) && $hdr !== '') return $hdr;
    $cookie = $_COOKIE['admin_token'] ?? '';
    return is_string($cookie) ? $cookie : '';
}

function admin_id(): ?int {
    $token = auth_token();
    if (!valid_auth_token($token)) return null;
    $st = db()->prepare('SELECT admin_id, expires_at > NOW() AS live FROM auth_tokens WHERE token = ?');
    $st->execute([$token]);
    $row = $st->fetch();
    if (!$row || !$row['live']) return null;
    return (int)$row['admin_id'];
}

function valid_auth_token(string $token): bool {
    return strlen($token) === 64 && preg_match('/\A[a-f0-9]{64}\z/', $token) === 1;
}

function admin_response_headers(): void {
    header('Cache-Control: no-store, private');
    header('X-Robots-Tag: noindex, nofollow');
}

function csrf_for(string $token): string {
    return hash_hmac('sha256', "admin-csrf\0" . $token, AUTH_PEPPER);
}

function admin_csrf_token(): string {
    admin_response_headers();
    if (admin_id() === null) json_out(['error' => 'forbidden'], 403);
    return csrf_for(auth_token());
}

function require_admin_csrf(string $token): void {
    admin_response_headers();
    if (!valid_auth_token($token) || !hash_equals(admin_csrf_token(), $token)) {
        json_out(['error' => 'forbidden'], 403);
    }
}

final class AdminLoginException extends RuntimeException {}

function admin_credentials($email, $password): ?array {
    if (!is_string($email) || !is_string($password)
        || strlen($email) > 190 || strlen($password) > 4096
        || $password === '' || strpos($password, "\0") !== false) return null;
    $email = trim($email);
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) return null;
    return [$email, $password];
}

function admin_login_attempt(PDO $pdo, string $email): bool {
    // REMOTE_ADDR only: forwarded headers are not a trusted client identity.
    $ip = $_SERVER['REMOTE_ADDR'] ?? '';
    $ip = is_string($ip) && strlen($ip) <= 45 && filter_var($ip, FILTER_VALIDATE_IP)
        ? bin2hex(inet_pton($ip)) : 'unknown';
    $keys = [
        [hash_hmac('sha256', "login-ip\0" . $ip, AUTH_PEPPER), 30],
        [hash_hmac('sha256', "login-account\0" . $ip . "\0" . strtolower($email), AUTH_PEPPER), 5],
    ];
    $pdo->beginTransaction();
    try {
        $reserve = $pdo->prepare('INSERT INTO login_throttles (bucket_key, attempts, window_started)
            VALUES (?, 0, UNIX_TIMESTAMP()) ON DUPLICATE KEY UPDATE
            attempts = IF(window_started <= UNIX_TIMESTAMP() - 900, 0, attempts),
            window_started = IF(window_started <= UNIX_TIMESTAMP() - 900, UNIX_TIMESTAMP(), window_started)');
        $charge = $pdo->prepare('UPDATE login_throttles SET attempts = attempts + 1 WHERE bucket_key = ? AND attempts < ?');
        // Lock the IP first, then its account bucket; reserve before password verification.
        foreach ($keys as [$key, $limit]) {
            $reserve->execute([$key]);
            $charge->execute([$key, $limit]);
            if ($charge->rowCount() !== 1) {
                $pdo->commit();
                return false;
            }
        }
        $pdo->commit();
        return true;
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $e;
    }
}

function admin_login($email, $password): string {
    $invalid = 'Invalid email or password. Try again later.';
    $credentials = admin_credentials($email, $password);
    if ($credentials === null) throw new AdminLoginException($invalid, 401);
    [$email, $password] = $credentials;
    try {
        $pdo = db();
        if (!admin_login_attempt($pdo, $email)) throw new AdminLoginException($invalid, 429);
        $st = $pdo->prepare('SELECT id, password_hash FROM admins WHERE email = ?');
        $st->execute([$email]);
        $admin = $st->fetch();
        if (!$admin || !password_verify($password . AUTH_PEPPER, $admin['password_hash'])) {
            throw new AdminLoginException($invalid, 401);
        }
        $token = bin2hex(random_bytes(32));
        $ins = $pdo->prepare('INSERT INTO auth_tokens (token, admin_id, expires_at) VALUES (?,?, DATE_ADD(NOW(), INTERVAL 7 DAY))');
        $ins->execute([$token, (int)$admin['id']]);
        return $token;
    } catch (AdminLoginException $e) {
        throw $e;
    } catch (Throwable $e) {
        throw new AdminLoginException('Sign-in unavailable. Ask the site administrator to import api/schema.sql and verify database setup.', 503);
    }
}

function is_https(): bool {
    return (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https')
        || (int)($_SERVER['SERVER_PORT'] ?? 0) === 443;
}

function auth_cookie_header(string $token, int $maxAge = 604800): string {
    admin_response_headers();
    return 'admin_token=' . $token . '; path=/; httponly; samesite=lax; max-age=' . $maxAge
        . (is_https() ? '; secure' : '');
}

function clear_auth_cookie_header(): string {
    admin_response_headers();
    return 'admin_token=; path=/; httponly; samesite=lax; max-age=0' . (is_https() ? '; secure' : '');
}

function require_admin(): int {
    admin_response_headers();
    $id = admin_id();
    if ($id === null) { json_out(['error' => 'unauthorized'], 401); }
    return $id;
}
