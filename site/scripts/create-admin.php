<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit('Forbidden');
}
if (in_array('--help', $argv, true)) {
    echo "Usage: php site/scripts/create-admin.php\n"
        . "Interactive: email prompt, then a hidden password prompt.\n"
        . "Noninteractive stdin: exactly two lines, email then password (8–4096 bytes).\n"
        . "Pipe from a secret manager; never put passwords in command arguments or shell history.\n"
        . "Creates only the first admin; existing accounts are never changed.\n";
    exit(0);
}
if (count($argv) !== 1) {
    fwrite(STDERR, "No credential arguments accepted. Use --help for stdin input.\n");
    exit(1);
}

require __DIR__ . '/../api/bootstrap.php';

function provisioning_line(int $maxBytes): string {
    $line = fgets(STDIN, $maxBytes + 3);
    if ($line === false) throw new RuntimeException('Missing input.');
    $line = rtrim($line, "\r\n");
    if (strlen($line) > $maxBytes) throw new RuntimeException('Input too long.');
    return $line;
}

$terminalState = null;
$restoreTerminal = static function () use (&$terminalState): void {
    if ($terminalState !== null) {
        exec('stty ' . escapeshellarg($terminalState));
        $terminalState = null;
    }
};
register_shutdown_function($restoreTerminal);

try {
    $interactive = stream_isatty(STDIN);
    if ($interactive) fwrite(STDERR, 'Email: ');
    $email = provisioning_line(190);
    try {
        if ($interactive) {
            exec('stty -g', $state, $status);
            if ($status !== 0 || empty($state[0])) throw new RuntimeException('Cannot hide input.');
            $terminalState = $state[0];
            exec('stty -echo', $unused, $status);
            if ($status !== 0) throw new RuntimeException('Cannot hide input.');
            fwrite(STDERR, 'Password: ');
        }
        $password = provisioning_line(4096);
    } finally {
        $restoreTerminal();
        if ($interactive) fwrite(STDERR, "\n");
    }
    $credentials = admin_credentials($email, $password);
    if ($credentials === null || strlen($password) < 8) throw new RuntimeException('Invalid input.');
    [$email, $password] = $credentials;
    $hash = password_hash($password . AUTH_PEPPER, PASSWORD_ARGON2ID);
    unset($password, $credentials);
    $pdo = db();
    if ((int)$pdo->query("SELECT GET_LOCK('portfolio_create_first_admin', 10)")->fetchColumn() !== 1) {
        throw new RuntimeException('Provisioning is busy.');
    }
    $created = false;
    try {
        if ((int)$pdo->query('SELECT COUNT(*) FROM admins')->fetchColumn() === 0) {
            $pdo->prepare('INSERT INTO admins (email, password_hash) VALUES (?, ?)')->execute([$email, $hash]);
            $created = true;
        }
    } finally {
        $pdo->query("SELECT RELEASE_LOCK('portfolio_create_first_admin')");
    }
    echo $created ? "Admin created.\n" : "Admin already exists; no changes made.\n";
    exit($created ? 0 : 1);
} catch (Throwable $e) {
    fwrite(STDERR, "Admin not created. Check stdin email/password, import api/schema.sql, and verify database setup.\n");
    exit(1);
}
