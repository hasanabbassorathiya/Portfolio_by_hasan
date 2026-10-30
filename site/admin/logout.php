<?php
declare(strict_types=1);
require __DIR__ . '/../api/bootstrap.php';

$token = $_COOKIE['admin_token'] ?? '';
if (is_string($token) && preg_match('/^[a-f0-9]{64}$/', $token)) {
    db()->prepare('DELETE FROM auth_tokens WHERE token = ?')->execute([$token]);
}
header('Set-Cookie: ' . clear_auth_cookie_header());
header('Location: index.php');
echo '<script>location.href="index.php"</script>';
