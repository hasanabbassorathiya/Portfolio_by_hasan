<?php
declare(strict_types=1);
// Database-free contract check for the Discord mirror of published social posts.
require __DIR__ . '/../api/discord-lib.php';
require __DIR__ . '/../api/social-lib.php';

$failures = 0;
function check(string $label, bool $condition): void {
    global $failures;
    if ($condition) return;
    fwrite(STDERR, "FAIL {$label}\n");
    $failures++;
}

$row = [
    'external_id' => 'post-123',
    'provider' => 'linkedin',
    'channel' => 'Hasan on LinkedIn',
    'kind' => 'post',
    'text' => "Line one\nLine two",
    'url' => 'https://www.linkedin.com/posts/abc',
    'image' => 'https://cdn.example.com/a.jpg',
    'posted_at' => '2026-10-31 10:30:00',
    'published' => 1,
];

$payload = discord_post_payload($row);
check('payload has a username', ($payload['username'] ?? '') === 'Hasan Abbas Sorathiya');
check('payload has one embed', count($payload['embeds'] ?? []) === 1);
$embed = $payload['embeds'][0] ?? [];
check('embed title', ($embed['title'] ?? '') === 'New on LinkedIn');
check('embed description keeps the text', ($embed['description'] ?? '') === "Line one\nLine two");
check('embed url', ($embed['url'] ?? '') === 'https://www.linkedin.com/posts/abc');
check('embed image', ($embed['image']['url'] ?? '') === 'https://cdn.example.com/a.jpg');
check('embed colour is the brand signal', ($embed['color'] ?? 0) === 0x1D3CFF);
check('embed footer is the channel', ($embed['footer']['text'] ?? '') === 'Hasan on LinkedIn');
check('embed timestamp is UTC', ($embed['timestamp'] ?? '') === '2026-10-31T10:30:00Z');

$noChannel = discord_post_payload(array_merge($row, ['channel' => '']));
check('footer falls back to the provider', ($noChannel['embeds'][0]['footer']['text'] ?? '') === 'LinkedIn');

check('unpublished rows stay silent', discord_post_payload(array_merge($row, ['published' => 0])) === []);
check('empty rows stay silent', discord_post_payload(['published' => 1]) === []);
check('unpublished flag absent is unpublished', discord_post_payload(['text' => 'x']) === []);

$unsafeUrl = discord_post_payload(array_merge($row, ['url' => 'javascript:alert(1)']));
check('unsafe url dropped', isset($unsafeUrl['embeds'][0]['url']) === false);
$unsafeImage = discord_post_payload(array_merge($row, ['image' => 'javascript:alert(1)']));
check('unsafe image dropped', isset($unsafeImage['embeds'][0]['image']) === false);
$noImage = discord_post_payload(array_merge($row, ['image' => '']));
check('empty image omitted', isset($noImage['embeds'][0]['image']) === false);

$long = discord_post_payload(array_merge($row, ['text' => str_repeat('a', 5000)]));
check('long text capped', strlen((string)($long['embeds'][0]['description'] ?? '')) <= 2000);

$badDate = discord_post_payload(array_merge($row, ['posted_at' => 'not a date']));
check('bad timestamp falls back to now', preg_match('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/', (string)($badDate['embeds'][0]['timestamp'] ?? '')) === 1);

check('provider labels', discord_provider_label('linkedin') === 'LinkedIn'
    && discord_provider_label('x') === 'X'
    && discord_provider_label('youtube') === 'YouTube'
    && discord_provider_label('devto') === 'DEV'
    && discord_provider_label('producthunt') === 'Product Hunt'
    && discord_provider_label('unknown') === 'Unknown');

$note = discord_message_payload([
    'title' => 'Community note',
    'description' => 'Bring one problem.',
    'url' => 'https://hasanabbassorathiya.tech/community',
    'footer' => 'hasanabbassorathiya.tech',
]);
check('note payload builds one embed', count($note['embeds'] ?? []) === 1);
check('note description', ($note['embeds'][0]['description'] ?? '') === 'Bring one problem.');
check('note without body stays silent', discord_message_payload(['title' => 'Empty']) === []);

$secretFile = sys_get_temp_dir() . '/discord-secret-' . bin2hex(random_bytes(6)) . '.php';
file_put_contents($secretFile, "<?php return 'https://discord.com/api/webhooks/123/abc';");
check('secret file string form', discord_webhook_url($secretFile) === 'https://discord.com/api/webhooks/123/abc');
file_put_contents($secretFile, "<?php return ['webhook' => 'https://discordapp.com/api/webhooks/9/xyz'];");
check('secret file array form', discord_webhook_url($secretFile) === 'https://discordapp.com/api/webhooks/9/xyz');
file_put_contents($secretFile, "<?php return 'https://evil.example.com/hook';");
check('foreign host rejected', discord_webhook_url($secretFile) === '');
file_put_contents($secretFile, "<?php return 'https://discord.com/api/other/1';");
check('non-webhook path rejected', discord_webhook_url($secretFile) === '');
unlink($secretFile);
check('missing secret file rejected', discord_webhook_url($secretFile) === '');

check('mirror without a secret is a no-op', discord_mirror(['text' => 'hi', 'published' => 1], $secretFile) === false);
check('mirror of an unpublished row is a no-op', discord_mirror(['text' => 'hi', 'published' => 0], $secretFile) === false);

$sharedSecret = sys_get_temp_dir() . '/social-secret-' . bin2hex(random_bytes(6)) . '.php';
file_put_contents($sharedSecret, "<?php return str_repeat('s', 40);");
check('shared webhook secret from file', social_webhook_secret($sharedSecret) === str_repeat('s', 40));
file_put_contents($sharedSecret, "<?php return 'short';");
check('short shared secret rejected', social_webhook_secret($sharedSecret) === '');
unlink($sharedSecret);

if ($failures > 0) {
    fwrite(STDERR, "{$failures} check(s) failed\n");
    exit(1);
}
echo "discord mirror: all checks passed\n";
