<?php
declare(strict_types=1);
// Copy to config.php and fill in real values (config.php is gitignored).
define('DB_HOST', 'localhost');
define('DB_NAME', 'u123456789_portfolio');
define('DB_USER', 'u123456789_admin');
define('DB_PASS', 'CHANGE_ME');
// 32-byte hex secret; generate with: php -r "echo bin2hex(random_bytes(32));"
define('AUTH_PEPPER', 'CHANGE_ME');
