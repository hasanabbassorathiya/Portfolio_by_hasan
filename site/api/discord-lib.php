<?php
declare(strict_types=1);

// Discord mirror: turns a published social post or a site note into a Discord
// webhook message. No database and no bootstrap, so the contract check can run
// it standalone.

const DISCORD_BRAND_COLOR = 0x1D3CFF;
const DISCORD_USERNAME = 'Hasan Abbas Sorathiya';
const DISCORD_TEXT_LIMIT = 2000;

function discord_limit(string $value, int $length): string {
    if (function_exists('mb_substr')) return mb_substr($value, 0, $length, 'UTF-8');
    return substr($value, 0, $length);
}

function discord_provider_label(string $provider): string {
    $provider = strtolower(trim($provider));
    $labels = [
        'linkedin' => 'LinkedIn', 'x' => 'X', 'twitter' => 'X', 'youtube' => 'YouTube',
        'instagram' => 'Instagram', 'facebook' => 'Facebook', 'tiktok' => 'TikTok',
        'threads' => 'Threads', 'medium' => 'Medium', 'reddit' => 'Reddit',
        'devto' => 'DEV', 'dev.to' => 'DEV', 'producthunt' => 'Product Hunt',
        'product-hunt' => 'Product Hunt', 'mastodon' => 'Mastodon', 'bluesky' => 'Bluesky',
        'github' => 'GitHub', 'discord' => 'Discord', 'newsletter' => 'Newsletter',
    ];
    if (isset($labels[$provider])) return $labels[$provider];
    return $provider === '' ? 'Social' : ucfirst($provider);
}

function discord_http_url(string $value): string {
    $value = trim($value);
    if ($value === '') return '';
    $parts = parse_url($value);
    if (!is_array($parts) || !isset($parts['scheme'], $parts['host'])) return '';
    if (!in_array(strtolower($parts['scheme']), ['http', 'https'], true)) return '';
    return $value;
}

function discord_timestamp(string $value): string {
    $value = trim($value);
    if ($value !== '') {
        try {
            $at = new DateTimeImmutable($value, new DateTimeZone('UTC'));
            return $at->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z');
        } catch (Throwable $e) {
            // Fall through to the current time.
        }
    }
    return gmdate('Y-m-d\TH:i:s\Z');
}

function discord_message_payload(array $opts): array {
    $description = discord_limit(trim((string)($opts['description'] ?? '')), DISCORD_TEXT_LIMIT);
    $url = discord_http_url((string)($opts['url'] ?? ''));
    $image = discord_http_url((string)($opts['image'] ?? ''));
    if ($description === '' && $url === '') return [];

    $embed = [];
    $title = trim((string)($opts['title'] ?? ''));
    if ($title !== '') $embed['title'] = discord_limit($title, 256);
    if ($description !== '') $embed['description'] = $description;
    if ($url !== '') $embed['url'] = $url;
    if ($image !== '') $embed['image'] = ['url' => $image];
    $embed['color'] = DISCORD_BRAND_COLOR;
    $footer = trim((string)($opts['footer'] ?? ''));
    if ($footer !== '') $embed['footer'] = ['text' => discord_limit($footer, 2048)];
    $embed['timestamp'] = discord_timestamp((string)($opts['timestamp'] ?? ''));

    return ['username' => DISCORD_USERNAME, 'embeds' => [$embed]];
}

function discord_post_payload(array $row): array {
    if ((int)($row['published'] ?? 0) !== 1) return [];
    $label = discord_provider_label((string)($row['provider'] ?? ''));
    $channel = trim((string)($row['channel'] ?? ''));
    return discord_message_payload([
        'title' => 'New on ' . $label,
        'description' => (string)($row['text'] ?? ''),
        'url' => (string)($row['url'] ?? ''),
        'image' => (string)($row['image'] ?? ''),
        'footer' => $channel !== '' ? $channel : $label,
        'timestamp' => (string)($row['posted_at'] ?? ''),
    ]);
}

function discord_webhook_url(string $secretPath): string {
    if ($secretPath === '' || !is_file($secretPath)) return '';
    $stored = require $secretPath;
    if (is_array($stored)) $stored = (string)($stored['webhook'] ?? '');
    if (!is_string($stored)) return '';
    $url = trim($stored);
    if ($url === '') return '';
    $parts = parse_url($url);
    if (!is_array($parts) || !isset($parts['scheme'], $parts['host'], $parts['path'])) return '';
    if (strtolower($parts['scheme']) !== 'https') return '';
    if (!in_array(strtolower($parts['host']), ['discord.com', 'discordapp.com'], true)) return '';
    if (!str_starts_with($parts['path'], '/api/webhooks/')) return '';
    return $url;
}

function discord_send(string $url, array $payload): bool {
    $url = discord_http_url($url);
    if ($url === '' || $payload === []) return false;
    $json = json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    if (!is_string($json)) return false;

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $json,
        CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 5,
        CURLOPT_CONNECTTIMEOUT => 3,
    ]);
    $resp = curl_exec($ch);
    $code = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    if ($resp === false || $code < 200 || $code >= 300) return false;
    return true;
}

function discord_mirror(array $row, string $secretPath): bool {
    $payload = discord_post_payload($row);
    if ($payload === []) return false;
    $url = discord_webhook_url($secretPath);
    if ($url === '') return false;
    $sent = discord_send($url, $payload);
    if (!$sent) error_log('discord mirror: the announcements channel rejected the post');
    return $sent;
}
