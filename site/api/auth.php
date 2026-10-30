<?php
declare(strict_types=1);
// Admin sign-in only. Provision the first admin with scripts/create-admin.php.
require __DIR__ . '/bootstrap.php';
admin_response_headers();

$action = $_GET['action'] ?? 'login';
if ($action === 'register') json_out(['error' => 'registration disabled'], 403);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') json_out(['error' => 'method not allowed'], 405);
if ($action !== 'login') json_out(['error' => 'unknown action'], 400);

$b = body();
try {
    $token = admin_login($b['email'] ?? null, $b['password'] ?? null);
} catch (AdminLoginException $e) {
    json_out(['error' => $e->getMessage()], $e->getCode());
}
$ttl = 7 * 24 * 3600;
header('Set-Cookie: ' . auth_cookie_header($token, $ttl));
// csrf lets header-authenticated API clients (Postman, scripts) perform writes.
json_out(['token' => $token, 'csrf' => csrf_for($token), 'expires_in' => $ttl]);
