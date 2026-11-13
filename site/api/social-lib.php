<?php
declare(strict_types=1);

// Pure payload normalization for the social webhook. No database and no
// bootstrap, so scripts/social-normalize-check.php can test the contract.

function social_webhook_secret(string $secretFile = ''): string {
    $secret = '';
    if (defined('SOCIAL_WEBHOOK_SECRET')) $secret = trim((string)SOCIAL_WEBHOOK_SECRET);
    if ($secret === '') {
        if ($secretFile === '') $secretFile = __DIR__ . '/social-secret.php';
        if (!is_file($secretFile)) return '';
        $stored = require $secretFile;
        if (!is_string($stored)) return '';
        $secret = trim($stored);
    }
    if (strlen($secret) < 32 || str_starts_with($secret, 'CHANGE_ME')) return '';
    return $secret;
}

function social_dig(array $data, string $path) {
    $node = $data;
    foreach (explode('.', $path) as $key) {
        if (!is_array($node) || !array_key_exists($key, $node)) return null;
        $node = $node[$key];
    }
    return $node;
}

function social_first_string(array $payload, array $paths): string {
    foreach ($paths as $path) {
        $value = social_dig($payload, $path);
        if (is_string($value) && trim($value) !== '') return trim($value);
        if (is_int($value) || is_float($value)) return (string)$value;
    }
    return '';
}

function social_limit(string $value, int $length): string {
    if (function_exists('mb_substr')) return mb_substr($value, 0, $length, 'UTF-8');
    return substr($value, 0, $length);
}

// Publishing tools differ: some send a string, some an array of blocks.
function social_text(array $payload): string {
    $paths = ['post.content', 'content', 'text', 'body', 'message', 'data.post.content', 'data.content', 'data.text'];
    foreach ($paths as $path) {
        $value = social_dig($payload, $path);
        if (is_string($value) && trim($value) !== '') return trim($value);
        if (!is_array($value)) continue;
        $parts = [];
        foreach ($value as $item) {
            if (is_string($item) && trim($item) !== '') $parts[] = trim($item);
            elseif (is_array($item) && is_string($item['content'] ?? null) && trim($item['content']) !== '') {
                $parts[] = trim($item['content']);
            }
        }
        $joined = trim(implode("\n\n", $parts));
        if ($joined !== '') return $joined;
    }
    return '';
}

function social_url(string $value): string {
    $value = trim($value);
    if ($value === '') return '';
    $parts = parse_url($value);
    if (!is_array($parts) || !isset($parts['scheme'], $parts['host'])) return '';
    if (!in_array(strtolower($parts['scheme']), ['http', 'https'], true)) return '';
    return substr($value, 0, 500);
}

function social_url_value(array $payload): string {
    foreach (['post.releaseURL', 'releaseURL', 'post.url', 'url', 'permalink', 'post.permalink', 'data.url', 'data.permalink'] as $path) {
        $value = social_dig($payload, $path);
        if (!is_string($value)) continue;
        $url = social_url($value);
        if ($url !== '') return $url;
    }
    return '';
}

function social_image_value(array $payload): string {
    foreach (['post.image', 'image', 'media.0.url', 'post.media.0.url', 'data.post.image', 'data.image'] as $path) {
        $value = social_dig($payload, $path);
        if (is_string($value)) {
            $url = social_url($value);
            if ($url !== '') return $url;
        }
        if (!is_array($value)) continue;
        $first = $value[0] ?? null;
        if (is_string($first)) {
            $url = social_url($first);
            if ($url !== '') return $url;
        }
        if (is_array($first) && is_string($first['url'] ?? null)) {
            $url = social_url($first['url']);
            if ($url !== '') return $url;
        }
    }
    return '';
}

function social_external_id(array $payload, string $raw): string {
    $candidate = social_first_string($payload, ['post.id', 'postId', 'id', 'eventId', 'data.post.id', 'data.id']);
    $candidate = preg_replace('/[^A-Za-z0-9._:-]/', '', $candidate) ?? '';
    if ($candidate !== '') return social_limit($candidate, 120);
    return 'hash-' . hash('sha256', $raw);
}

function social_token(string $value, int $length, string $fallback = ''): string {
    $value = strtolower(trim($value));
    $value = preg_replace('/[^a-z0-9._-]/', '', $value) ?? '';
    return $value === '' ? $fallback : social_limit($value, $length);
}

function social_posted_at(array $payload): string {
    $paths = ['post.publishedAt', 'publishedAt', 'post.createdAt', 'createdAt', 'created_at', 'date', 'data.publishedAt', 'data.createdAt'];
    foreach ($paths as $path) {
        $value = social_dig($payload, $path);
        if (is_int($value) || is_float($value)) {
            $ts = (int)$value;
            if ($ts > 9999999999) $ts = (int)($ts / 1000);
            return gmdate('Y-m-d H:i:s', $ts > 0 ? $ts : time());
        }
        if (!is_string($value) || trim($value) === '') continue;
        try {
            return (new DateTimeImmutable(trim($value)))
                ->setTimezone(new DateTimeZone('UTC'))
                ->format('Y-m-d H:i:s');
        } catch (Throwable $e) {
            continue;
        }
    }
    return gmdate('Y-m-d H:i:s');
}

function social_normalize(array $payload, string $raw): array {
    $text = social_limit(social_text($payload), 2000);
    $url = social_url_value($payload);
    $provider = social_first_string($payload, [
        'providerIdentifier', 'integration.providerIdentifier', 'provider',
        'channel.provider', 'data.providerIdentifier',
    ]);
    $channel = social_first_string($payload, [
        'integration.name', 'channel.name', 'account.name', 'data.integration.name',
    ]);
    $kind = social_first_string($payload, ['post.type', 'type', 'kind']);
    return [
        'external_id' => social_external_id($payload, $raw),
        'provider' => social_token($provider, 40, 'social'),
        'channel' => social_limit(trim($channel), 120),
        'kind' => social_token($kind, 24, 'post'),
        'text' => $text,
        'url' => $url,
        'image' => social_image_value($payload),
        'posted_at' => social_posted_at($payload),
        // Nothing empty ever reaches the public feed.
        'published' => ($text !== '' || $url !== '') ? 1 : 0,
    ];
}
