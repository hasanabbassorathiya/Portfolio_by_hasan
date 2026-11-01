<?php
declare(strict_types=1);
// Copy to config.php and fill in real values (config.php is gitignored).
define('DB_HOST', 'localhost');
define('DB_NAME', 'u123456789_portfolio');
define('DB_USER', 'u123456789_admin');
define('DB_PASS', 'CHANGE_ME');
// 32-byte hex secret; generate with: php -r "echo bin2hex(random_bytes(32));"
define('AUTH_PEPPER', 'CHANGE_ME');
// Postiz webhook shared secret (32+ chars). Leave the placeholder to keep /api/social.php disabled.
define('SOCIAL_WEBHOOK_SECRET', 'CHANGE_ME_32_PLUS_CHARS');
