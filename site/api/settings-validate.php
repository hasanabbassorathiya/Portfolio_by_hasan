<?php
declare(strict_types=1);

function settings_fields(): array
{
    return [
        'ga4_id' => ['type' => 'text', 'pattern' => '/\AG-[A-Z0-9]{4,20}\z/', 'error' => 'GA4 measurement ID must look like G-XXXXXXXXXX.'],
        'gsc_verification' => ['type' => 'text', 'pattern' => '/\A[A-Za-z0-9_\-]{10,120}\z/', 'error' => 'Search Console token contains unexpected characters.'],
        'indexnow_key' => ['type' => 'text', 'pattern' => '/\A[a-f0-9]{8,128}\z/', 'error' => 'IndexNow key must be 8–128 lowercase hex characters.'],
        'calcom_url' => ['type' => 'url'],
        'discord_invite' => ['type' => 'url'],
        'community_enabled' => ['type' => 'select', 'options' => ['1', '0']],
        'announcement' => ['type' => 'text'],
        'default_og_image' => ['type' => 'text'],
        'contact_email' => ['type' => 'email'],
        'linkedin_url' => ['type' => 'url'],
        'github_url' => ['type' => 'url'],
        'x_url' => ['type' => 'url'],
        'instagram_url' => ['type' => 'url'],
        'play_dev_url' => ['type' => 'url'],
        'appstore_dev_url' => ['type' => 'url'],
    ];
}

function settings_validate(array $input): array
{
    $fields = settings_fields();
    $updates = [];
    $problems = [];
    foreach ($input as $key => $raw) {
        if (!isset($fields[$key])) continue;
        $value = trim((string)$raw);
        if (strlen($value) > 600) { $problems[] = "$key is too long."; continue; }
        $cfg = $fields[$key];
        if ($cfg['type'] === 'select') {
            if (!in_array($value, $cfg['options'], true)) continue;
        } elseif ($cfg['type'] === 'url') {
            if ($value !== '' && (filter_var($value, FILTER_VALIDATE_URL) === false || !str_starts_with($value, 'https://'))) {
                $problems[] = "$key must be an https:// URL."; continue;
            }
        } elseif ($cfg['type'] === 'email') {
            if ($value !== '' && filter_var($value, FILTER_VALIDATE_EMAIL) === false) {
                $problems[] = "$key is not a valid email address."; continue;
            }
        } elseif (isset($cfg['pattern'])) {
            if ($value !== '' && preg_match($cfg['pattern'], $value) !== 1) {
                $problems[] = $cfg['error']; continue;
            }
        }
        $updates[$key] = $value;
    }
    return [$updates, $problems];
}