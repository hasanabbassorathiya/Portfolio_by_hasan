<?php
declare(strict_types=1);
// Guard — validate the raw session token before any database access.
require __DIR__ . '/../api/bootstrap.php';
admin_response_headers();

$token = auth_token();
if (!valid_auth_token($token)) {
    header('Set-Cookie: ' . clear_auth_cookie_header());
    header('Location: index.php');
    echo '<script>location.href="index.php"</script>';
    exit;
}

$st = db()->prepare('SELECT admin_id, expires_at > NOW() AS live FROM auth_tokens WHERE token = ?');
$st->execute([$token]);
$row = $st->fetch();
if (!$row || !$row['live']) {
    header('Set-Cookie: ' . clear_auth_cookie_header());
    header('Location: index.php');
    echo '<script>location.href="index.php"</script>';
    exit;
}

$_admin_id = (int)$row['admin_id'];
