<?php
declare(strict_types=1);
// Media upload: POST multipart (file, folder) — media:write scope + CSRF required.
require __DIR__ . '/bootstrap.php';
admin_response_headers();
require_admin();
require_scope('media:write');

$csrf = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? ($_POST['csrf_token'] ?? '');
require_admin_csrf(is_string($csrf) ? $csrf : '');

require __DIR__ . '/upload-handler.php';
