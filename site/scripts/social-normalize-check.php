<?php
declare(strict_types=1);
// Database-free contract check for the Postiz payload normalizer.
require __DIR__ . '/../api/social-lib.php';

$failures = 0;
function check(string $label, bool $condition): void {
    global $failures;
    if ($condition) return;
    fwrite(STDERR, "FAIL {$label}\n");
    $failures++;
}

$payload = [
    'providerIdentifier' => 'linkedin',
    'integration' => ['name' => 'Hasan on LinkedIn', 'providerIdentifier' => 'linkedin'],
    'post' => [
        'id' => 'post-123',
        'content' => "Line one\nLine two",
        'releaseURL' => 'https://www.linkedin.com/posts/abc',
        'publishedAt' => '2026-10-31T10:30:00.000Z',
        'image' => ['https://cdn.example.com/a.jpg'],
    ],
];
$row = social_normalize($payload, json_encode($payload));
check('external id', $row['external_id'] === 'post-123');
check('provider', $row['provider'] === 'linkedin');
check('channel', $row['channel'] === 'Hasan on LinkedIn');
check('text keeps newlines', str_contains($row['text'], "\nLine two"));
check('url', $row['url'] === 'https://www.linkedin.com/posts/abc');
check('image', $row['image'] === 'https://cdn.example.com/a.jpg');
check('posted_at in UTC', $row['posted_at'] === '2026-10-31 10:30:00');
check('published', $row['published'] === 1);

$blocks = ['content' => [['content' => 'First'], ['content' => 'Second']]];
$row = social_normalize($blocks, json_encode($blocks));
check('block content joins', $row['text'] === "First\n\nSecond");
check('missing id hashes payload', str_starts_with($row['external_id'], 'hash-'));

$empty = social_normalize(['foo' => 'bar'], '{"foo":"bar"}');
check('empty payload stays unpublished', $empty['published'] === 0);
check('provider fallback', $empty['provider'] === 'social');
check('kind fallback', $empty['kind'] === 'post');

$unsafe = social_normalize(['url' => 'javascript:alert(1)', 'content' => 'Hi'], '{}');
check('unsafe url dropped', $unsafe['url'] === '');
check('text alone publishes', $unsafe['published'] === 1);

$badDate = social_normalize(['createdAt' => 'not a date', 'text' => 'x'], '{}');
check('bad date falls back to now', preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/', $badDate['posted_at']) === 1);

$wrapped = ['event' => 'post.published', 'data' => ['post' => ['id' => 'tt-9', 'content' => 'Wrapped']]];
$row = social_normalize($wrapped, json_encode($wrapped));
check('nested data envelope', $row['external_id'] === 'tt-9' && $row['text'] === 'Wrapped');

if ($failures > 0) {
    fwrite(STDERR, "{$failures} check(s) failed\n");
    exit(1);
}
echo "social normalize: all checks passed\n";
