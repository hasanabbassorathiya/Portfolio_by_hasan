<?php
declare(strict_types=1);
require __DIR__ . '/../api/bootstrap.php';
admin_response_headers();

// A cookie token is enough to skip the form; admin_id() reads the admin_token cookie.
if (admin_id()) {
    header('Location: dashboard.php');
    echo '<script>location.href="dashboard.php"</script>';
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $token = admin_login($_POST['email'] ?? null, $_POST['password'] ?? null);
        header('Set-Cookie: ' . auth_cookie_header($token));
        header('Location: dashboard.php');
        echo '<script>location.href="dashboard.php"</script>';
        exit;
    } catch (AdminLoginException $e) {
        http_response_code($e->getCode());
        $error = $e->getMessage();
    }
}
?><!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<title>Sign in — Portfolio CMS</title>
<link rel="stylesheet" href="admin.css">
</head>
<body class="login-page">
<div class="login-card">
  <h1>Portfolio CMS</h1>
  <?php if ($error !== ''): ?><p class="error"><?=htmlspecialchars($error)?></p><?php endif; ?>
  <form method="post" autocomplete="off">
    <label>Email <input type="email" name="email" required autocomplete="username" autofocus></label>
    <label>Password <input type="password" name="password" required autocomplete="current-password"></label>
    <button type="submit" class="btn-primary">Sign in</button>
  </form>
  <p class="hint">Sessions last 7 days. Use <a href="../">the site</a> to check how your content reads in public.</p>
</div>
</body>
</html>
