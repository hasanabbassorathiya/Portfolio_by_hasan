<?php
declare(strict_types=1);

/**
 * Regenerate postman/portfolio-api.postman_collection.json from api/entity-schema.php.
 *
 * The schema is the same file crud.php validates against, so the requests this emits
 * cannot drift from what the API actually accepts. Run it after editing the schema:
 *
 *   npm run postman        (from site/)
 *
 * Folders 8 and 9 (intake/analytics, SEO tools) are hand-written and carried over
 * verbatim from the existing collection if it is present.
 */

require __DIR__ . '/../api/entity-schema.php';

const OUT = __DIR__ . '/../postman/portfolio-api.postman_collection.json';

const POSTMAN_SCHEMA = 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json';
const COLLECTION_ID  = '6d1f2c4a-2b7e-4b8a-9a51-8f0c3d7e5a10';

/** Entity -> the collection variable that holds a created row's id. */
const ID_VARS = [
    'apps' => 'appId', 'clients' => 'clientId', 'posts' => 'postId',
    'projects' => 'projectId', 'experiences' => 'experienceId',
    'skills' => 'skillId', 'testimonials' => 'testimonialId',
];

/**
 * Every field in the schema, with a value that passes validation.
 * A field that is missing from this map is a hard error, not a silent skip —
 * add an example whenever you add a field to api/entity-schema.php.
 * Deliberately placeholder: nothing here asserts a real metric, testimonial or store link.
 */
const EXAMPLES = [
    // apps
    'slug' => '{{demoSlug}}', 'name' => 'Postman Example', 'tagline' => 'Created by the Postman collection to test the API',
    'role' => 'Design, build, publish', 'year' => '2026', 'genre' => 'Utility',
    'platforms' => ['iOS', 'Android'], 'icon' => '/media/apps/example/icon.webp',
    'screenshots' => ['/media/apps/example/shot1.webp'], 'rating_value' => 4.8, 'rating_count' => 120,
    'stack' => ['Flutter', 'Dart'], 'links' => ['ios' => 'https://example.com/ios', 'android' => 'https://example.com/android'],
    'metrics' => [['placeholder', 'replace with a real, sourced number']],
    'features' => ['Replace this before publishing'],
    'summary' => 'Demo summary — replace before publishing.', 'story' => 'Demo story — replace before publishing.',
    'published' => 0, 'sort_order' => 999, 'is_featured' => 0, 'noindex' => 1,
    // clients
    'kicker' => 'Example kicker', 'type' => 'Contract', 'period' => '2026 — 2026', 'location' => 'Dubai, UAE',
    'website' => 'https://example.com', 'logo' => '/media/clients/example.webp',
    'metric' => 'placeholder', 'metric_label' => 'replace with a sourced number',
    'what_i_did' => ['Replace this before publishing'], 'facts' => [['Role', 'Mobile lead']],
    'challenge' => 'Demo challenge — replace before publishing.', 'outcome' => 'Demo outcome — replace before publishing.',
    'store_url' => 'https://example.com', 'store_urls' => ['ios' => 'https://example.com/ios'],
    // posts
    'title' => 'Postman example', 'dek' => 'Created by the Postman collection to test the API.',
    'post_date' => '2026-01-01', 'category' => 'Example', 'tags' => ['Example'], 'minutes' => 4,
    'body' => "## Demo heading\n\nDemo body. Delete this row before it is ever published.\n",
    // projects / experience / skills / testimonials
    'description' => 'Demo description — replace before publishing.',
    'client' => 'Example Client',
    'company' => 'Example Company', 'position' => 'Example Position',
    'points' => ['Replace this before publishing'], 'highlight' => 'Legacy single-line field',
    'grp' => 'Mobile', 'quote' => 'PLACEHOLDER — never publish a quote that is not real.',
    'author' => 'Example Person', 'note' => 'Role, Company',
    // seo / aso groups
    'seo_title' => 'Postman example', 'seo_description' => 'A demo record created while testing the CMS API.',
    'seo_image' => '/og.png', 'aso_subtitle' => 'Example subtitle', 'aso_keywords' => 'example, flutter',
    'aso_category' => 'Utilities', 'aso_age_rating' => '4+', 'aso_promo_text' => 'Demo record — replace before publishing.',
];

/**
 * Field names preferred by the "Update one field" request, best first.
 * Only text-like fields qualify — the fallback chain covers every entity.
 */
const UPDATE_HINT = ['tagline', 'kicker', 'dek', 'summary', 'role', 'category', 'note', 'metric', 'grp', 'position'];

// 12 characters: narrow enough for the tightest text column in this schema (VARCHAR(20)).
const UPDATE_VALUE = 'Postman edit';

/**
 * The `0 · Start here` description. A top-level nowdoc because PHP's flexible
 * heredoc syntax only tolerates an unindented closing marker inside a call argument.
 */
const START_HERE_MD = <<<'MD'
## Before you send anything

**1. Point `{{baseUrl}}` somewhere you are allowed to write to.**
Every request in folders 3, 5 and 6 writes to whichever database the host resolves to. The default is the live site.
Use the local harness (same PHP, same `.htaccess`, same schema) until you trust the shape of a body:

    baseUrl = http://127.0.0.1:8099/api
    siteUrl = http://127.0.0.1:8099        ← media lives here, not under /api

**2. Run `1 · Auth → Login`.**
It fills `{{token}}` and `{{csrf}}` for every other request and sets an `admin_token` cookie. Both are 64-char
hex and last 7 days (`expires_in: 604800`). There is no refresh and no revoke endpoint — if a token is
compromised, delete its row from `auth_tokens`.

**3. Fill in `{{adminEmail}}` and `{{adminPassword}}`** in the collection's Variables tab. They are deliberately
empty and are never committed. Do not put them in a URL — they would land in shell history and Postman sync.

## The three rules that explain most failures

| Symptom | Cause |
| --- | --- |
| `401 unauthorized` | Missing/expired `X-Auth-Token`. |
| `403 forbidden` | Missing or wrong `X-CSRF-Token`. Only POST/PUT/DELETE check it. |
| `415 content-type must be application/json` | The header is absent or does not *start* with `application/json`. |

## What "editing content" actually costs

- **Editing an existing row** is live on the next page load. The PHP API is authoritative at render time — no rebuild.
- **A brand-new `slug`** needs `npm run build` + a deploy first, because its route shell, OG tags and sitemap entry are prerendered.
- **Media** is a two-step dance: upload to get a URL, then PUT the URL into the field. Media fields store strings, never files.

## Field-by-field contract

Folder `4 · Field reference` has one request per entity whose description is the full field table —
type, required, max length, JSON shape and the exact validation each type performs. That table is generated
from `api/entity-schema.php`, the same file `crud.php` validates against, so it cannot be out of date.

**A `max` in that table is the editorial ceiling, not always the ceiling that rejects you.** Most text
columns in the database are narrower than the 255 the schema promises (`skills.grp` is `VARCHAR(40)`,
`projects.year` is `VARCHAR(20)`). `crud.php` now validates against the smaller of the two, so an
over-long save answers `422` naming the field and its real limit instead of a bare `update failed`.
The measured widths are in `site/API.md` §4.1 and repeat in every field table.

Regenerate it after touching the schema:

    cd site && npm run postman
MD;

// ---------------------------------------------------------------- primitives

function hdr(string $k, string $v, string $d = ''): array
{
    $h = ['key' => $k, 'value' => $v];
    if ($d !== '') $h['description'] = $d;
    return $h;
}

/** Read headers: token only. */
function auth_headers(): array
{
    return [hdr('X-Auth-Token', '{{token}}', '64 hex chars from Login. Falls back to the admin_token cookie. Omit it and you get 401.')];
}

/** Write headers: token + csrf + json content-type (crud.php returns 415 without the last one). */
function write_headers(): array
{
    return [
        hdr('X-Auth-Token', '{{token}}', 'From Login. Omit it and you get 401.'),
        hdr('X-CSRF-Token', '{{csrf}}', 'From Login. Omit it and you get 403.'),
        hdr('Content-Type', 'application/json', 'Must START with application/json or crud.php answers 415.'),
    ];
}

/**
 * Build a Postman url object. $query values are either a plain string or
 * ['value' => …, 'desc' => …, 'disabled' => true]. Disabled params stay in the
 * query editor but leave `raw`, so Postman will not send them.
 */
function url(string $path, array $query = [], string $base = '{{baseUrl}}/'): array
{
    $parts = [];
    foreach ($query as $key => $spec) {
        $entry = ['key' => (string)$key, 'value' => is_array($spec) ? (string)$spec['value'] : (string)$spec];
        if (is_array($spec) && isset($spec['desc'])) $entry['description'] = $spec['desc'];
        if (is_array($spec) && !empty($spec['disabled'])) $entry['disabled'] = true;
        $parts[] = $entry;
    }
    $raw = $base . ltrim($path, '/');
    $enabled = array_values(array_filter($parts, fn ($p) => empty($p['disabled'])));
    if ($enabled) {
        $raw .= '?' . implode('&', array_map(fn ($p) => $p['key'] . '=' . $p['value'], $enabled));
    }
    return ['raw' => $raw, 'query' => $parts];
}

function formdata_body(array $fields): array
{
    return ['mode' => 'formdata', 'formdata' => $fields];
}

function json_body(array $fields): array
{
    return [
        'mode' => 'raw',
        'raw' => json_encode($fields, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE),
        'options' => ['raw' => ['language' => 'json']],
    ];
}

function script(array $lines): array
{
    return ['type' => 'text/javascript', 'exec' => $lines];
}

function req(string $name, string $method, array $url, string $desc, array $headers = [],
             ?array $body = null, array $events = []): array
{
    $request = ['method' => $method, 'header' => $headers, 'url' => $url, 'description' => $desc];
    if ($body !== null) $request['body'] = $body;
    $out = ['name' => $name, 'request' => $request];
    if ($events) $out['event'] = $events;
    return $out;
}

function event(string $listen, array $lines): array
{
    return ['listen' => $listen, 'script' => script($lines)];
}

function folder(string $name, array $items, string $desc = ''): array
{
    $f = ['name' => $name, 'item' => $items];
    if ($desc !== '') $f['description'] = $desc;
    return $f;
}

// ---------------------------------------------------------------- query builders

/** crud.php query string for a row-based entity. */
function crud_query(string $entity, ?string $idVar = null, string $idDesc = ''): array
{
    $q = ['entity' => [
        'value' => $entity,
        'desc'  => 'One of: apps, clients, posts, projects, experiences (alias: experience), skills, testimonials, profile.',
    ]];
    if ($idVar !== null) {
        $q['id'] = ['value' => '{{' . $idVar . '}}', 'desc' => $idDesc ?: 'Numeric id captured by the Create request in this folder.'];
    }
    return $q;
}

function write_warning(string $entity, array $cfg): string
{
    $out = "\n\nThis writes to whichever database `{{baseUrl}}` points at — set it to your local harness before running anything here.";
    if (empty($cfg['published'])) {
        $out .= "\n\n⚠ **`{$entity}` has no `published` column, so a created row is on the live site immediately.** Run Delete as soon as you are done checking.";
    }
    return $out;
}

// ---------------------------------------------------------------- field reference

function field_table(array $cfg): string
{
    $rows = [];
    $rows[] = '| Field | Type | Required | Max | Shape | Notes |';
    $rows[] = '| --- | --- | --- | --- | --- | --- |';
    foreach ($cfg['fields'] as $f) {
        $name  = '`' . $f['name'] . '`';
        $type  = $f['type'] ?? 'text';
        $req   = !empty($f['required']) ? 'yes' : '—';
        $max   = (string)field_max($f);
        $shape = $type === 'json' ? ($f['shape'] ?? 'list') : '—';
        $notes = trim(($f['help'] ?? '') . (isset($f['group']) ? ' _(group: ' . $f['group'] . ')_' : ''));
        $rows[] = "| $name | $type | $req | " . ($max === '0' ? '—' : $max) . " | $shape | $notes |";
    }
    return implode("\n", $rows);
}

function field_max(array $f): int
{
    $type = $f['type'] ?? 'text';
    return (int)($f['max'] ?? match ($type) {
        'text', 'image' => 255,
        'textarea' => 20000,
        'markdown' => 200000,
        default => 0,
    });
}

function type_rules(array $cfg): string
{
    $lines = [];
    foreach ($cfg['fields'] as $f) {
        $type = $f['type'] ?? 'text';
        $max  = field_max($f);
        $note = match ($type) {
            'checkbox' => 'accepts `1`, `"1"`, `true`, `"true"`, `"on"` → stored as 1; **anything else silently becomes 0**, including `null`.',
            'number'   => '`""` or `null` → stored NULL. A non-numeric value → 422 `must be a number`.',
            'date'     => 'must be exactly `YYYY-MM-DD`; `""` or `null` → stored NULL. Anything else → 422.',
            'json'     => 'send a real ' . (($f['shape'] ?? 'list') === 'object' ? 'object' : 'array') . ' (a JSON string also works — it is decoded first). `' . ($f['shape'] ?? 'list') . '` shape.',
            'image'    => 'a path string, not a file. Upload with `5 · Media` first, then PUT the returned `url`.',
            'markdown' => 'plain Markdown text; rendered by the site.',
            default     => $max > 0
                ? "text, ≤ {$max} chars. Accepts a string or a number; `null`, an array or an object → 422 `must be text`."
                : 'text. Accepts a string or a number; `null`, an array or an object → 422 `must be text`.',
        };
        if ($type === 'text' && $f['name'] === 'slug') {
            $note = 'lowercase letters, digits and hyphens, ≤ 190 chars, must not start with a hyphen. A duplicate → 409.';
        }
        if ($type === 'text' && ($f['name'] === 'website' || str_ends_with($f['name'], '_url'))) {
            $note .= ' No URL validation — a typo is stored as-is and rendered as a dead link.';
        }
        $req = !empty($f['required'])
            ? 'Required — `""` or a missing key on create → 422 `is required`.'
            : 'Optional — **`""` or `null` clears the stored value**; omit the key to leave it alone.';
        $lines[] = "- **`{$f['name']}`** ({$type}) — {$note}. {$req}";
    }
    return implode("\n", $lines);
}

// ---------------------------------------------------------------- request builders

function list_request(string $entity, array $cfg): array
{
    $order = isset($cfg['order'])
        ? "ordered by `{$cfg['order']}` then id"
        : ($entity === 'posts' ? 'ordered by `post_date` descending' : 'ordered by id — this entity has no sort column');
    $desc = "All rows including unpublished ones, {$order}."
        . "\n\nNeeds `X-Auth-Token`. The public counterpart filters to `published = 1`"
        . ($entity === 'posts' ? ' and hides future `post_date`' : '')
        . '; it is in `2 · Public content`.';
    return req('List — all rows', 'GET', url('crud.php', crud_query($entity)), $desc, auth_headers(), null, [
        event('test', [
            'pm.test("200 with a data array", () => {',
            '  pm.response.to.have.status(200);',
            '  const body = pm.response.json();',
            '  pm.expect(body.entity).to.eql("' . $entity . '");',
            '  pm.expect(body.data).to.be.an("array");',
            '  console.log(`' . $entity . ': ` + body.data.length + ` rows`);',
            '});',
        ]),
    ]);
}

function get_one_request(string $entity, string $idVar): array
{
    $desc = "One row by id. Set `{$idVar}` by running **Create — every field** first, or copy an id from **List — all rows**.\n\n"
        . "An unknown id answers **404** `{\"error\":\"not found\"}`, not an empty object.";
    return req('Get one', 'GET', url('crud.php', crud_query($entity, $idVar)), $desc, auth_headers(), null, [
        event('test', ['pm.test("200 or 404", () => pm.expect([200, 404]).to.include(pm.response.code));']),
    ]);
}

function create_request(string $entity, array $cfg, string $idVar): array
{
    $fields = [];
    $missing = [];
    foreach ($cfg['fields'] as $f) {
        $name = $f['name'];
        if (!array_key_exists($name, EXAMPLES)) {
            $missing[] = "{$entity}.{$name}";
            continue;
        }
        $fields[$name] = EXAMPLES[$name];
    }
    if ($missing) {
        fwrite(STDERR, "gen-postman: no example value for " . implode(', ', $missing)
            . "\nAdd it to the EXAMPLES map so the collection keeps covering every field.\n");
        exit(1);
    }
    $hasSlug = !empty($cfg['slug']);
    $events = [];
    if ($hasSlug) {
        $events[] = event('prerequest', [
            '// A fresh slug every run, so repeated creates never collide with 409.',
            "pm.variables.set('demoSlug', 'postman-demo-' + Date.now());",
        ]);
    }
    $events[] = event('test', [
        'const json = pm.response.json();',
        'pm.test("201 with a numeric id", () => {',
        '  pm.response.to.have.status(201);',
        '  pm.expect(json.id).to.be.a("number");',
        "  pm.collectionVariables.set(\"{$idVar}\", json.id);",
        "  console.log(\"created {$entity} #\" + json.id + \" — remember to DELETE it\");",
        '});',
    ]);

    $desc = "Creates a row carrying **every field the schema accepts**, each with a value that passes validation. "
        . "The response is `201 {\"id\": <n>}` and the test stores it in `{{{$idVar}}}` for the other requests in this folder."
        . ($hasSlug ? "\n\nA pre-request script gives `slug` a timestamped value, so running this twice never hits `409 slug already exists`." : '')
        . write_warning($entity, $cfg);

    return req('Create — every field', 'POST', url('crud.php', crud_query($entity)), $desc, write_headers(), json_body($fields), $events);
}

/**
 * Choose one text-like field for the partial-update request, so every entity gets a
 * PUT that actually validates. Sending a field the entity does not have would be
 * dropped silently and answered 400 `no valid fields`.
 *
 * @return array{0:string,1:mixed}
 */
function update_pair(array $cfg): array
{
    $byName = [];
    foreach ($cfg['fields'] as $f) $byName[$f['name']] = $f;
    $isText = fn (array $f) => in_array($f['type'] ?? 'text', ['text', 'textarea', 'markdown'], true);

    foreach (UPDATE_HINT as $hint) {
        if (isset($byName[$hint]) && $isText($byName[$hint])) return [$hint, UPDATE_VALUE];
    }
    foreach ($cfg['fields'] as $f) {
        if ($f['name'] === 'slug' || !empty($f['required'])) continue;
        if ($isText($f)) return [$f['name'], UPDATE_VALUE];
    }
    if (isset($byName['sort_order'])) return ['sort_order', 999];
    return ['published', 1];
}

function update_one_request(string $entity, string $idVar, array $cfg): array
{
    [$field, $value] = update_pair($cfg);
    $desc = "PUT is a **partial** update: only the keys you send are written, everything else keeps its value. "
        . "This one writes `{$field}` — swap it for any field name from the reference folder.\n\n"
        . "The example value is 12 characters on purpose. Some text columns here are only 20 wide "
        . "(`projects.year`, `aso_age_rating`), so a longer placeholder would fail on the fields this request "
        . "falls back to. Over-long writes answer 422 naming the field and its real limit.\n\n"
        . "An empty body (or one containing only unknown field names) answers **400 `no valid fields`** — "
        . "unknown keys are dropped silently, they are not an error, so a typo costs you the write without telling you."
        . "\n\nResponse: `200 {\"ok\": true}`. It does not echo the row — GET it again to confirm.";
    return req('Update one field', 'PUT', url('crud.php', crud_query($entity, $idVar)), $desc, write_headers(),
        json_body([$field => $value]), [
        event('test', ['pm.test("200 ok", () => { pm.response.to.have.status(200); pm.expect(pm.response.json().ok).to.eql(true); });']),
    ]);
}

function publish_request(string $entity, string $idVar): array
{
    $desc = "Flip `published`. `1` puts the row on the public site on the next page load — **no rebuild needed** for an "
        . "existing row, because the PHP API is authoritative at render time.\n\n"
        . "A brand-new `slug` is different: its route shell, OG tags and sitemap entry are prerendered, so the site needs "
        . "`npm run build` + a deploy before `/…/<slug>` resolves.\n\n"
        . "Anything truthy in `1`, `\"1\"`, `true`, `\"true\"`, `\"on\"` becomes 1; every other value, including `null`, becomes 0.";
    return req('Publish / unpublish', 'PUT', url('crud.php', crud_query($entity, $idVar)), $desc, write_headers(),
        json_body(['published' => 1]), [
        event('test', ['pm.test("200 ok", () => pm.response.to.have.status(200));']),
    ]);
}

function media_request(string $entity, array $cfg, string $idVar): array
{
    $imageFields = [];
    $jsonListFields = [];
    foreach ($cfg['fields'] as $f) {
        if (($f['type'] ?? '') === 'image') $imageFields[] = $f['name'];
        if (($f['type'] ?? '') === 'json' && ($f['shape'] ?? '') === 'list' && in_array($f['name'], ['screenshots'], true)) {
            $jsonListFields[] = $f['name'];
        }
    }
    $fields = [];
    foreach ($imageFields as $n) $fields[$n] = EXAMPLES[$n] ?? '/media/uploads/example.webp';
    foreach ($jsonListFields as $n) $fields[$n] = EXAMPLES[$n];

    $desc = "Media fields hold **paths as strings**, not files. The order of the flow is:\n\n"
        . "1. `6 · Media → Upload image` (multipart, field `folder`) → response `{\"url\": \"/media/uploads/<folder>/<name>.webp\", …}`.\n"
        . "2. Copy that `url` into the body below and PUT it.\n"
        . "3. Reload the page — the file is served straight from disk, no rebuild.\n\n"
        . "Two limits worth knowing: the uploader caps at **8 MB** and only accepts jpeg/png/webp/avif/gif; anything above "
        . "2400 px on a side is downscaled with GD on the way in. It can only write inside `/media/uploads/` — see the note there."
        . "\n\nFields set here: `" . implode('`, `', array_keys($fields)) . '`.';
    return req('Set media fields', 'PUT', url('crud.php', crud_query($entity, $idVar)), $desc, write_headers(),
        json_body($fields), [
        event('test', ['pm.test("200 ok", () => pm.response.to.have.status(200));']),
    ]);
}

function delete_request(string $entity, string $idVar): array
{
    $desc = "Hard delete by id — there is no soft delete and no undo. **Run this when you are done with the demo row you created.**\n\n"
        . "Needs both tokens. `200 {\"ok\": true}` when a row went away, `404` when the id was already gone. "
        . "Deleting a row whose slug owns prerendered files leaves those files behind; the build cleans them on the next run.";
    return req('Delete', 'DELETE', url('crud.php', crud_query($entity, $idVar)), $desc, write_headers(), null, [
        event('test', ['pm.test("200 or 404", () => pm.expect([200, 404]).to.include(pm.response.code));']),
    ]);
}

// ---------------------------------------------------------------- profile (key/value)

function profile_folder(): array
{
    $list = req('List every key', 'GET', url('crud.php', ['entity' => [
        'value' => 'profile',
        'desc'  => 'Profile is key/value, not a row table. There is no id and no update-in-place.',
    ]]), 'All `k`/`v` pairs. The public endpoint returns the same rows; the site maps each key to a section.',
        auth_headers(), null, [
        event('test', ['pm.test("200 with a data array", () => pm.expect(pm.response.json().data).to.be.an("array"));']),
    ]);

    $get = req('Get one key', 'GET', url('crud.php', [
        'entity' => ['value' => 'profile', 'desc' => ''],
        'k'      => ['value' => 'postman_demo', 'desc' => 'Lowercase letters, digits and underscore, ≤ 60 chars.'],
    ]), 'One pair by key. Unknown key → 404 `{"error":"not found"}`.', auth_headers());

    $set = req('Set a key (create or overwrite)', 'POST', url('crud.php', [
        'entity' => ['value' => 'profile', 'desc' => ''],
    ]), "Profile writes are a `REPLACE INTO`, so **POST creates and updates with the same call** — there is no separate create path.\n\n"
        . "`k` must match `[a-z0-9_]{1,60}` or you get 422 `invalid key`. `v` must be a string; `null` gives 422 `v must be text`. "
        . "Sending a number, array or object is rejected even though JSON would coerce it.\n\n"
        . "Response: 201 on POST, 200 on PUT, both `{\"ok\": true}`."
        . write_warning('profile', []),
        write_headers(), json_body(['k' => 'postman_demo', 'v' => 'created by the Postman collection']), [
        event('test', ['pm.test("200 or 201", () => pm.expect([200, 201]).to.include(pm.response.code));']),
    ]);

    $rename = req('Rename a key', 'PUT', url('crud.php', [
        'entity' => ['value' => 'profile', 'desc' => ''],
    ]), "PUT is the only place `previous_k` matters. Send the new `k` **and** the old one; the API deletes `previous_k` and replaces `k`. "
        . "Omit `previous_k` and it defaults to `k`, so the row is overwritten in place rather than renamed.\n\n"
        . "**This is how you avoid orphans:** renaming without `previous_k` leaves the old key live, and the site keeps reading it.",
        write_headers(), json_body(['k' => 'postman_demo_v2', 'v' => 'renamed', 'previous_k' => 'postman_demo']), [
        event('test', ['pm.test("200 ok", () => pm.response.to.have.status(200));']),
    ]);

    $del = req('Delete a key', 'DELETE', url('crud.php', [
        'entity' => ['value' => 'profile', 'desc' => ''],
        'k'      => ['value' => 'postman_demo_v2', 'desc' => 'The key to remove. Must match [a-z0-9_]{1,60}.'],
    ]), "The key goes in the **query string** here, not the body — `?entity=profile&k=…`. A malformed or missing `k` is 400, not 422.\n\n"
        . "**Run this when you are done** so the demo key does not linger in the profile the site reads.",
        write_headers(), null, [
        event('test', ['pm.test("200 ok", () => pm.response.to.have.status(200));']),
    ]);

    return folder('3 · Profile (key/value)', [$list, $get, $set, $rename, $del],
        "`profile` is not a row table. It has no id, no `published`, no slug and no partial update — every write is a "
        . "`REPLACE INTO` keyed on `k`. The site reads it as a flat map of profile facts (name, title, email, links, …).");
}

// ---------------------------------------------------------------- top-level folders

function start_here_folder(): array
{
    $readme = req('Read me first', 'GET', url('index.php', [
        'entity' => ['value' => 'apps', 'desc' => 'Any public entity — this request exists to be read, not run.'],
    ]), START_HERE_MD);
    return folder('0 · Start here', [$readme]);
}

function auth_folder(): array
{
    $login = req('Login', 'POST', url('auth.php', [
        'action' => ['value' => 'login', 'desc' => 'The only supported action on this endpoint.'],
    ]), "Exchanges an email + password for `{token, csrf, expires_in: 604800}` and sets an `admin_token` cookie.\n\n"
        . "POST only — a GET is 405. Credentials longer than 190 (email) / 4096 (password) bytes, an empty password, "
        . "or a NUL byte in either field are refused before the database is touched.\n\n"
        . "There is **no refresh and no revoke endpoint.** Tokens live 7 days; to kill one, delete its row from `auth_tokens`.",
        [hdr('Content-Type', 'application/json', 'crud.php demands it; auth.php does not, but send it anyway.')],
        json_body(['email' => '{{adminEmail}}', 'password' => '{{adminPassword}}']), [
        event('test', [
            'pm.test("200 with token and csrf", () => {',
            '  pm.response.to.have.status(200);',
            '  const body = pm.response.json();',
            '  pm.expect(body.token).to.match(/^[a-f0-9]{64}$/);',
            '  pm.expect(body.csrf).to.match(/^[a-f0-9]{64}$/);',
            '  pm.collectionVariables.set("token", body.token);',
            '  pm.collectionVariables.set("csrf", body.csrf);',
            '});',
        ]),
    ]);

    $whoami = req('Who am I (cookie session)', 'GET', url('crud.php', [
        'entity' => ['value' => 'apps', 'desc' => 'Any entity — this request only proves the cookie path works.'],
    ]), "Deliberately sent **without** `X-Auth-Token`. `auth_token()` falls back to the `admin_token` cookie that Login set, "
        . "so a 200 here means the cookie session is working; a 401 means it is not and you need the header.");
    return folder('1 · Auth', [$login, $whoami],
        'One login, two ways to be recognised: the `X-Auth-Token` header (every other request in this collection) or the '
        . '`admin_token` cookie Postman keeps for you.');
}

function public_folder(): array
{
    $entities = [
        'profile'     => 'Key/value rows as `[{k, v}, …]`. The site maps each key to a section.',
        'projects'    => 'All rows, `sort_order` then id. No published filter — every project is public.',
        'experience'  => 'All rows, `sort_order` then id. Note the singular alias: `experience` resolves to the `experiences` table.',
        'skills'      => 'All rows, `sort_order` then id. Grouped on the client by the `grp` column.',
        'testimonials' => 'All rows, `sort_order` then id. **No published filter — a testimonial is live the moment it exists.**',
        'clients'     => 'Only `published = 1`, ordered by `sort_order`.',
        'apps'        => 'Only `published = 1`, ordered by `sort_order`. This is what `/apps` renders.',
        'posts'       => 'Only `published = 1` **and** `post_date <= CURDATE()`, newest first — a future date schedules the post.',
        'settings'    => 'A flat `{key: value}` object (not an array) of rows where `is_public = 1` and the value is not empty.',
        'activity'    => 'The last 50 published `social_posts`, newest first. A missing table returns an empty feed rather than a 500.',
    ];
    $items = [];
    foreach ($entities as $entity => $note) {
        $items[] = req("GET {$entity}", 'GET', url('index.php', [
            'entity' => ['value' => $entity, 'desc' => $note],
        ]), $note . "\n\nNo token, no CSRF — this endpoint is read-only and public. An entity outside the allow-list is "
            . "**400 `unknown entity`**, and the admin-only names (`settings` writes, `social_posts`) are not in it.");
    }
    return folder('2 · Public content', $items,
        'Read-only, unauthenticated, and the fastest way to see what the site will actually render. '
        . 'Compare any of these against the admin list in folder 5 — the difference is the published filter.');
}

function reference_folder(array $schema): array
{
    $items = [];
    foreach ($schema as $entity => $cfg) {
        if (!empty($cfg['kv'])) {
            $items[] = req('profile — key/value', 'GET', url('crud.php', ['entity' => ['value' => 'profile', 'desc' => '']]),
                "Not a row table. `k` matches `[a-z0-9_]{1,60}`; `v` must be a string (`null` → 422). "
                . "Writes are `REPLACE INTO`, so POST both creates and updates. See folder `3 · Profile (key/value)`.",
                auth_headers());
            $items[] = req('profile — typed field schema', 'GET', url('crud.php', [
                'entity' => ['value' => 'profile', 'desc' => ''],
                'schema' => ['value' => '1', 'desc' => 'Return field definitions instead of rows.'],
            ]),
                "`?schema=1` returns `{entity, kv, fields:[{name,label,type,group,help,max,shape}]}` — the typed definitions "
                . "for the keys the site hydrates (`sub` is the hero sub-copy, `experience_years` is numeric). The panel, MCP "
                . "tools and Postman use this to render typed controls instead of a free-text key box.\n\n"
                . "Every entity supports `&schema=1`; for row tables it returns the same field whitelist `crud.php` validates against.",
                auth_headers(), null, [
                event('test', [
                    'pm.test("200 with typed fields", () => {',
                    '  pm.response.to.have.status(200);',
                    '  const b = pm.response.json();',
                    '  pm.expect(b.fields).to.be.an("array");',
                    '  const years = b.fields.find((f) => f.name === "experience_years");',
                    '  pm.expect(years.type).to.eql("number");',
                    '});',
                ]),
            ]);
            continue;
        }
        $desc = "**`{$cfg['label']}`** — table `{$cfg['table']}`"
            . (isset($cfg['order']) ? ", ordered by `{$cfg['order']}`" : ', ordered by id')
            . (!empty($cfg['slug']) ? ', has a unique `slug`' : '')
            . (!empty($cfg['published']) ? ', has a `published` flag' : ', **no `published` flag — rows are live immediately**')
            . ".\n\n## Fields\n\n" . field_table($cfg)
            . "\n\nThe **Max** column is the editorial ceiling declared in `api/entity-schema.php`. "
            . "Many columns are physically narrower — `grp` says 255 and the column is `VARCHAR(40)`. "
            . "`crud.php` enforces whichever is smaller and names the field in the 422, so a rejected save "
            . "tells you the real number. Measured widths for every entity: `site/API.md` §4.1.\n\n"
            . "## What each type does on the way in\n\n" . type_rules($cfg);
        $items[] = req($cfg['label'], 'GET', url('crud.php', crud_query($entity)), $desc, auth_headers());
    }
    return folder('4 · Field reference', $items,
        'One entry per entity. Run it to fetch live rows; read its description for the contract. '
        . 'Generated from `api/entity-schema.php` — the same file `crud.php` validates against.');
}

function crud_folder(array $schema): array
{
    $folders = [];
    foreach ($schema as $entity => $cfg) {
        if (!empty($cfg['kv'])) continue;
        $idVar = ID_VARS[$entity];
        // Create comes before Get one: it is the request that fills the id variable, and
        // every request after it reads that variable.
        $items = [list_request($entity, $cfg), create_request($entity, $cfg, $idVar), get_one_request($entity, $idVar)];
        $items[] = update_one_request($entity, $idVar, $cfg);
        $mediaFields = array_filter($cfg['fields'], fn ($f) => ($f['type'] ?? '') === 'image' || $f['name'] === 'screenshots');
        if ($mediaFields) $items[] = media_request($entity, $cfg, $idVar);
        if (!empty($cfg['published'])) $items[] = publish_request($entity, $idVar);
        $items[] = delete_request($entity, $idVar);
        $folders[] = folder($cfg['label'], $items,
            "Table `{$cfg['table']}`. The id variable is `{{$idVar}}` — Create writes it, every other request reads it.");
    }
    return folder('5 · Admin CRUD', $folders,
        'Per entity: List → **Create** (which captures the id) → Get one → Update → Set media → Publish → **Delete**. '
        . 'Run them top to bottom and the folder is self-cleaning: it leaves no row behind. '
        . 'Writes need `X-Auth-Token` **and** `X-CSRF-Token` **and** a `Content-Type` starting with `application/json`.');
}

function media_folder(): array
{
    $upload = req('Upload image', 'POST', url('upload.php'),
        "Multipart form. Field **`file`** carries the image; field **`folder`** (default `uploads`) picks the sub-directory.\n\n"
        . "**Do not copy the JSON `Content-Type` header onto this request** — Postman sets `multipart/form-data` and its "
        . "boundary for you, and a hand-written header without a boundary makes PHP see zero files, which answers 400 "
        . "`no file uploaded` rather than anything about content-type.\n\n"
        . "## Limits, and the status each one returns\n\n"
        . "| Condition | Code | Body |\n| --- | --- | --- |\n"
        . "| Missing/unreadable `file` | 400 | `no file uploaded` |\n"
        . "| `folder` outside `[a-z0-9][a-z0-9-]{0,59}` | 400 | `invalid folder` |\n"
        . "| 0 bytes or over **8 MB** | **413** | `file must be between 1 byte and 8 MB` |\n"
        . "| mime outside jpeg/png/webp/avif/gif | **415** | `only JPEG, PNG, WebP, AVIF or GIF images are allowed` |\n"
        . "| Bytes pass the mime test but are not a decodable image | 415 | `file is not a readable image` |\n"
        . "| Directory or `move_uploaded_file` fails on the host | 500 | `could not store the upload` |\n\n"
        . "The mime check uses `finfo` on the bytes, not the filename — renaming a `.php` to `.webp` does not get it in. "
        . "An SVG is rejected outright, which is deliberate: an SVG can carry script and would execute on your own origin.\n\n"
        . "## What you get back\n\n"
        . "`201 {path, url, mime, bytes, width, height}` where `url === path`, shaped "
        . "`/media/uploads/<folder>/<folder>-<8 hex>.<ext>`. Anything over 2400 px on a long edge is resampled with GD "
        . "first, so the returned `width`/`height` may be smaller than what you sent. The random 8-hex name means the same "
        . "file uploaded twice produces two distinct paths — there is no dedupe and no overwrite.\n\n"
        . "A `media` library row is inserted best-effort: if `api/v2-schema.sql` has not been imported the insert fails "
        . "silently and the upload still succeeds. Never treat the media library as the source of truth; the file on disk is.\n\n"
        . "**The limitation that matters for app screenshots:** this writes only inside `/media/uploads/`. The site's app "
        . "icons and screenshots live at `/media/apps/<slug>/`, which this endpoint cannot reach — placing a file there is "
        . "a filesystem operation, not an API call.",
        [
            hdr('X-Auth-Token', '{{token}}', 'Required.'),
            hdr('X-CSRF-Token', '{{csrf}}', 'Required. Can be sent as a `csrf_token` form field instead — one is included below.'),
        ],
        formdata_body([
            ['key' => 'file', 'type' => 'file', 'src' => [], 'description' => 'Click Select File. jpeg/png/webp/avif/gif, ≤ 8 MB.'],
            ['key' => 'folder', 'type' => 'text', 'value' => 'apps', 'description' => 'Sub-directory inside /media/uploads/. Lowercase letters, digits, hyphens; must not start with a hyphen; ≤ 60 chars.'],
            ['key' => 'csrf_token', 'type' => 'text', 'value' => '{{csrf}}', 'description' => 'Belt-and-braces: the header above already satisfies the check.'],
        ]), [
        event('test', [
            'const json = pm.response.json();',
            'pm.test("201 with a usable url", () => {',
            '  pm.response.to.have.status(201);',
            '  pm.expect(json.url).to.match(/^\\/media\\/uploads\\/([a-z0-9-]+)\\/\\1-[0-9a-f]{8}\\.(jpg|png|webp|avif|gif)$/);',
            '  pm.collectionVariables.set("mediaPath", json.url);',
            '  console.log(`uploaded ` + json.width + `x` + json.height + ` (` + json.mime + `) -> ` + json.url);',
            '});',
        ]),
    ]);

    $show = req('GET the uploaded file', 'GET', url('{{siteUrl}}{{mediaPath}}', [], ''),
        "Static file — served straight from disk, no PHP, no token, no CSRF. If this 404s, the upload wrote a path the web "
        . "server cannot see (a docroot mismatch); if it 200s, the URL is safe to PUT into an `image` field.\n\n"
        . "Note the base: media lives at the **site root**, not under `/api`, which is why this uses `{{siteUrl}}` where every "
        . "other request uses `{{baseUrl}}`.");

    $recipe = req('Recipe: upload → attach to an app', 'PUT', url('crud.php', crud_query('apps', 'mediaRecipeId',
            'Throwaway row the pre-request script creates and the test script deletes.')),
        "Self-contained: the pre-request script creates a `published: 0` apps row, this request attaches `{{mediaPath}}` "
        . "to **that** row, and the test script deletes it. Run **Upload image** first — its test puts the URL into "
        . "`{{mediaPath}}`; with it empty this writes an empty icon and still proves the round trip.\n\n"
        . "`icon` and `screenshots` are *strings*. `screenshots` is a JSON array of strings and the site renders them in "
        . "the order given, so the array **is** the ordering control — reorder it by PUTting a new array, there is no "
        . "separate sort field.\n\n"
        . "A path that does not resolve still saves cleanly and renders as a broken image. Nothing here checks that the "
        . "file exists, so GET the file before you attach it.\n\n"
        . "To do this to a real app instead, use `5 · Admin CRUD → Apps → Set media fields` with `{{appId}}` set to that "
        . "row's id — nothing in this recipe touches existing content.",
        write_headers(), json_body([
            'icon' => '{{mediaPath}}',
            'screenshots' => ['{{mediaPath}}'],
        ]), [
        event('prerequest', [
            "const token = pm.collectionVariables.get('token');",
            "if (!token) {",
            "  console.log('no {{token}} — run 1 · Auth → Login first');",
            '} else {',
            "  pm.sendRequest({",
            "    url: pm.collectionVariables.get('baseUrl') + '/crud.php?entity=apps',",
            "    method: 'POST',",
            '    header: [',
            "      { key: 'Content-Type', value: 'application/json' },",
            "      { key: 'X-Auth-Token', value: token },",
            "      { key: 'X-CSRF-Token', value: pm.collectionVariables.get('csrf') },",
            '    ],',
            "    body: { mode: 'raw', raw: JSON.stringify({",
            "      slug: 'postman-recipe-' + Date.now(), name: 'Postman recipe row',",
            "      tagline: 'Throwaway — deleted by this recipe', published: 0,",
            '    }) },',
            '  }, function (err, res) {',
            "    if (err) { console.log('recipe row create failed: ' + err); return; }",
            "    if (res.code !== 201) { console.log('recipe row create got HTTP ' + res.code + ': ' + res.text()); return; }",
            "    pm.collectionVariables.set('mediaRecipeId', res.json().id);",
            "    console.log('created throwaway apps row #' + res.json().id);",
            '  });',
            '}',
        ]),
        event('test', [
            'pm.test("200 ok", () => { pm.response.to.have.status(200); pm.expect(pm.response.json().ok).to.eql(true); });',
            "const id = pm.collectionVariables.get('mediaRecipeId');",
            'if (id) {',
            '  pm.sendRequest({',
            "    url: pm.collectionVariables.get('baseUrl') + '/crud.php?entity=apps&id=' + id,",
            "    method: 'DELETE',",
            '    header: [',
            "      { key: 'X-Auth-Token', value: pm.collectionVariables.get('token') },",
            "      { key: 'X-CSRF-Token', value: pm.collectionVariables.get('csrf') },",
            '    ],',
            '  }, function (err, res) {',
            "    if (err) { console.log('cleanup failed for throwaway row #' + id + ': ' + err); return; }",
            "    pm.collectionVariables.unset('mediaRecipeId');",
            "    console.log('deleted throwaway apps row #' + id + ' (HTTP ' + res.code + ')');",
            '  });',
            '}',
        ]),
    ]);

    $libList = req('List the media library', 'GET', url('media.php', [
        'folder' => ['value' => '', 'desc' => 'Optional folder filter, [a-z0-9][a-z0-9-]{0,59}.', 'disabled' => true],
        'page' => ['value' => '1', 'desc' => '50 rows per page.'],
    ]),
        "`api/media.php` is the queryable library backed by the `media` table: `{rows:[{id,path,folder,mime,bytes,width,height,created_at}], page, has_more}`. "
        . "Add `&folder=<name>` to filter. Requires `media:read` (a session token works too).\n\n"
        . "The file on disk is still the source of truth — a row can exist for a file that was removed by hand, and an upload "
        . "whose `media` insert failed (pre-v2 schema) is served from disk without a row.",
        auth_headers(), null, [
        event('test', [
            'pm.test("200 with rows array", () => { pm.response.to.have.status(200); pm.expect(pm.response.json().rows).to.be.an("array"); });',
        ]),
    ]);

    $libUpload = req('Upload into the library', 'POST', url('media.php'),
        "Same upload core as `upload.php` (multipart `file` + `folder`), but scoped: needs `media:write` + CSRF. "
        . "`201 {path,url,mime,bytes,width,height}` and a `media` row. This request captures `{{mediaId}}` for the Delete below. "
        . "Do not hand-write a `Content-Type` header — Postman sets the multipart boundary.",
        [
            hdr('X-Auth-Token', '{{token}}', 'Session token, or a scoped token with media:write.'),
            hdr('X-CSRF-Token', '{{csrf}}', 'Required for the write.'),
        ],
        formdata_body([
            ['key' => 'file', 'type' => 'file', 'src' => [], 'description' => 'jpeg/png/webp/avif/gif, ≤ 8 MB.'],
            ['key' => 'folder', 'type' => 'text', 'value' => 'postman', 'description' => 'Sub-directory inside /media/uploads/.'],
            ['key' => 'csrf_token', 'type' => 'text', 'value' => '{{csrf}}', 'description' => 'Form-field alternative to the header.'],
        ]), [
        event('test', [
            'pm.test("201 and capture the library id", () => {',
            '  pm.response.to.have.status(201);',
            '  const b = pm.response.json();',
            '  pm.expect(b.url).to.match(/^\\/media\\/uploads\\//);',
            '});',
            // The upload response carries no id; read it back from the library by path.
            "pm.sendRequest({",
            "  url: pm.collectionVariables.get('baseUrl') + '/media.php?folder=postman',",
            "  method: 'GET',",
            "  header: [{ key: 'X-Auth-Token', value: pm.collectionVariables.get('token') }],",
            '}, function (err, res) {',
            "  if (err || res.code !== 200) { console.log('media id lookup failed'); return; }",
            "  const path = pm.response.json().url;",
            "  const row = res.json().rows.find((r) => r.path === path);",
            "  if (row) { pm.collectionVariables.set('mediaId', row.id); console.log('library row #' + row.id); }",
            '});',
        ]),
    ]);

    $libDelete = req('Delete from the library', 'DELETE', url('media.php', [
        'id' => ['value' => '{{mediaId}}', 'desc' => 'Captured by Upload into the library.'],
    ]),
        "Removes the `media` row **and** unlinks the file from disk. `200 {ok:true}`, or `404 not found`. "
        . "Needs `media:write` + CSRF. Run after the library upload to leave no demo file behind.",
        [
            hdr('X-Auth-Token', '{{token}}', 'Session token, or a scoped token with media:write.'),
            hdr('X-CSRF-Token', '{{csrf}}', 'Required for the write.'),
        ], null, [
        event('test', [
            'pm.test("200 deleted", () => { pm.response.to.have.status(200); pm.expect(pm.response.json().ok).to.eql(true); });',
        ]),
    ]);

    return folder('6 · Media', [$upload, $show, $recipe, $libList, $libUpload, $libDelete],
        'Upload returns a URL; content fields store that URL. They are never the same request, and the gap between them '
        . 'is the single most common reason a media edit "did not work". `media.php` adds a queryable library '
        . '(list/filter/upload/delete) on top of the original `upload.php`.');
}

function recipes_folder(): array
{
    $items = [
        req('Recipe: full round-trip on one app', 'GET', url('index.php', ['entity' => ['value' => 'apps', 'desc' => '']]),
            "Run these in order and watch the site between steps — this is the whole content model in five calls:\n\n"
            . "1. `1 · Auth → Login`\n"
            . "2. `5 · Admin CRUD → Apps → Create — every field` (captures `{{appId}}`, `published: 0` so nothing is visible)\n"
            . "3. `6 · Media → Upload image`, then `Recipe: upload → attach to an app`\n"
            . "4. `5 · Admin CRUD → Apps → Publish / unpublish` — reload `/apps`, the card appears with no rebuild\n"
            . "5. `5 · Admin CRUD → Apps → Delete` — the card disappears\n\n"
            . "If step 4 shows nothing, the public list is cached or the row's `sort_order` pushed it off the first screen; "
            . "this request answers 200 with only `published = 1` rows, so compare its count against the admin list."),
        req('Recipe: find the row you want by slug', 'GET', url('crud.php', [
            'entity' => ['value' => 'apps', 'desc' => ''],
        ]), "There is **no `?slug=` filter** on `crud.php` — it takes `id` or nothing. So: run this, then in the response "
            . "body use Postman's find (⌘F) for the slug, and read that row's `id` into `{{appId}}`.\n\n"
            . "The JSON fields (`platforms`, `stack`, `links`, `metrics`, `features`, `screenshots`) come back as **encoded "
            . "strings**, not arrays — the API stores JSON text and does not decode it on read. Parse them client-side."),
        req('Recipe: what the site will render vs what the DB holds', 'GET', url('index.php', ['entity' => ['value' => 'apps', 'desc' => '']]),
            "Pair this with `5 · Admin CRUD → Apps → List — all rows`. The two counts differ by exactly the unpublished rows. "
            . "Same trick for `posts`, where the public list also hides anything dated in the future.\n\n"
            . "This is the check that answers \"why isn't my edit on the site\": if the row is here, the site will show it; "
            . "if it is missing here but present in the admin list, it is unpublished."),
        req('Recipe: reject a bad body on purpose', 'POST', url('crud.php', crud_query('apps')),
            "A known-bad payload, sent so the error shapes are visible without guessing. Expect **422** with "
            . "`{\"error\":\"validation failed\",\"field\":\"…\",\"detail\":\"…\"}` — one field per response, the first one that failed.\n\n"
            . "Each key below trips a different rule:\n"
            . "- `slug` — uppercase and a leading digit break `[a-z0-9][a-z0-9-]{0,189}`\n"
            . "- `rating_value` — a word where a number is required\n"
            . "- `post_date`-style format errors are the same shape\n"
            . "- `platforms` — a list where an object was expected (or vice versa)\n\n"
            . "Also worth trying by hand: drop `Content-Type` → **415**; drop `X-CSRF-Token` → **403**; drop `X-Auth-Token` → **401**.",
            write_headers(), json_body([
                'slug' => 'Not A Valid Slug',
                'name' => 'Rejected on purpose',
                'tagline' => 'This request is expected to fail validation',
                'rating_value' => 'four point eight',
                'platforms' => ['iOS' => 'should be a plain array'],
                'published' => 0,
            ]), [
            event('test', [
                'pm.test("422 naming the offending field", () => {',
                '  pm.response.to.have.status(422);',
                '  const b = pm.response.json();',
                '  pm.expect(b.error).to.eql("validation failed");',
                '  pm.expect(b.field).to.be.a("string");',
                '  console.log("rejected at field: " + b.field + " — " + b.detail);',
                '});',
            ]),
        ]),
    ];
    return folder('7 · Recipes', $items,
        'Multi-step flows assembled from the other folders. Read the description — the steps are in it.');
}

// ---------------------------------------------------------------- scoped tokens & CRM

function tokens_folder(): array
{
    $list = req('List scoped tokens', 'GET', url('tokens.php'),
        "Scoped, revocable API tokens for Postman/MCP/automation — distinct from the 7-day **session** token Login returns.\n\n"
        . "`GET` answers `{tokens:[{id,label,scopes,expires_at,revoked_at,created_at,active}], allowed_scopes:[…]}`. "
        . "The raw token value is **never** returned here — it is shown once, at creation. `active` is false once revoked or expired.\n\n"
        . "**Session only:** a scoped token cannot list, create or revoke tokens. Calling this with a scoped token answers 403 `session token required`.",
        auth_headers(), null, [
        event('test', [
            'pm.test("200 with tokens and allowed_scopes", () => {',
            '  pm.response.to.have.status(200);',
            '  const b = pm.response.json();',
            '  pm.expect(b.tokens).to.be.an("array");',
            '  pm.expect(b.allowed_scopes).to.be.an("array");',
            '});',
        ]),
    ]);

    $create = req('Create a scoped token', 'POST', url('tokens.php'),
        "Body: `{label, scopes[], days?}`. `label` ≤ 120 chars; `scopes` is a non-empty subset of "
        . "`content:read, content:write, media:read, media:write, crm:read, crm:write`; `days` is 1–365 (default 90).\n\n"
        . "`201 {id, token, csrf, scopes, expires_in}` — **copy `token` and `csrf` now**, neither is retrievable later. "
        . "Send the token as `X-Auth-Token` on the endpoints its scopes cover; a missing scope answers 403 `insufficient scope`. "
        . "Writes also need `X-CSRF-Token` set to the returned `csrf` (it is pepper-derived, so a scoped client cannot compute it itself).\n\n"
        . "This request captures `{{scopedTokenId}}` so the Revoke request below can revoke it. Uses the session token + CSRF.",
        write_headers(), json_body(['label' => 'Postman demo token', 'scopes' => ['content:read'], 'days' => 7]), [
        event('test', [
            'pm.test("201 with a 64-hex token and csrf pair", () => {',
            '  pm.response.to.have.status(201);',
            '  const b = pm.response.json();',
            '  pm.expect(b.token).to.match(/^[0-9a-f]{64}$/);',
            '  pm.expect(b.csrf).to.match(/^[0-9a-f]{64}$/);',
            '  pm.expect(b.scopes).to.be.an("array");',
            '  pm.collectionVariables.set("scopedTokenId", b.id);',
            '  pm.collectionVariables.set("scopedToken", b.token);',
            '  pm.collectionVariables.set("scopedCsrf", b.csrf);',
            '});',
        ]),
    ]);

    $revoke = req('Revoke the scoped token', 'DELETE', url('tokens.php', [
        'id' => ['value' => '{{scopedTokenId}}', 'desc' => 'Captured by Create a scoped token.'],
    ]),
        "Soft-revokes: sets `revoked_at = NOW()`. The token stops authenticating immediately; the row stays for audit. "
        . "`200 {ok:true}`, or `404 not found or already revoked` if the id is wrong or already revoked.\n\n"
        . "Run after Create to leave no active demo token behind. Session token + CSRF required.",
        write_headers(), null, [
        event('test', [
            'pm.test("200 revoked", () => { pm.response.to.have.status(200); pm.expect(pm.response.json().ok).to.eql(true); });',
        ]),
    ]);

    return folder('8 · Scoped API tokens', [$list, $create, $revoke],
        'Create → use → revoke. Scoped tokens carry only the permissions you grant and can be revoked individually, '
        . 'unlike the all-powerful session token. Folder is self-cleaning: Create then Revoke leaves no active token.');
}

function crm_folder(): array
{
    $enquiries = req('List enquiries', 'GET', url('crm.php', [
        'resource' => ['value' => 'enquiries', 'desc' => 'enquiries | subscribers | settings'],
        'page' => ['value' => '1', 'desc' => '1-based page.'],
        'status' => ['value' => '', 'desc' => 'Optional status filter.', 'disabled' => true],
    ]),
        "Dedicated CRM read — not unrestricted table CRUD. `GET ?resource=enquiries` lists intake rows; add `&id=<n>` for one "
        . "row's full detail. `PUT ?resource=enquiries&id=<n>` updates status/follow-up with a `version` for optimistic locking "
        . "(a stale version answers 409). Requires `crm:read` (or `crm:write` for PUT).",
        auth_headers(), null, [
        event('test', ['pm.test("200", () => pm.response.to.have.status(200));']),
    ]);

    $subscribers = req('List subscribers', 'GET', url('crm.php', [
        'resource' => ['value' => 'subscribers', 'desc' => ''],
        'page' => ['value' => '1', 'desc' => '50 rows per page.'],
    ]),
        "`{rows:[{id,email,source,created_at}], page, has_more}`. `DELETE ?resource=subscribers&id=<n>` removes one "
        . "(needs `crm:write` + CSRF). Requires `crm:read`.",
        auth_headers(), null, [
        event('test', [
            'pm.test("200 with rows array", () => { pm.response.to.have.status(200); pm.expect(pm.response.json().rows).to.be.an("array"); });',
        ]),
    ]);

    $settingsGet = req('Get settings', 'GET', url('crm.php', ['resource' => ['value' => 'settings', 'desc' => '']]),
        "Returns the settings key/value map (ga4_id, gsc_verification, indexnow_key, community_enabled, contact_email, …). "
        . "Requires `crm:read`.",
        auth_headers(), null, [
        event('test', ['pm.test("200 object", () => { pm.response.to.have.status(200); pm.expect(pm.response.json()).to.be.an("object"); });']),
    ]);

    $settingsPut = req('Update a setting (idempotent demo)', 'PUT', url('crm.php', ['resource' => ['value' => 'settings', 'desc' => '']]),
        "Validated write — `settings-validate.php` rejects a bad shape with 422 (e.g. `ga4_id` must match `G-XXXXXXXXXX`). "
        . "Unknown keys are dropped; a body with no valid field answers 400.\n\n"
        . "**Safe by construction:** the pre-request reads the current `community_enabled` and this writes the *same* value back "
        . "(defaulting to `0` when unset), so it proves the PUT path without changing what the site does. To set a real value, "
        . "replace the body, e.g. `{\"ga4_id\":\"G-XXXXXXXXXX\"}`. Requires `crm:write` + CSRF.",
        write_headers(), json_body(['community_enabled' => '{{crmCommunity}}']), [
        event('prerequest', [
            "pm.sendRequest({",
            "  url: pm.collectionVariables.get('baseUrl') + '/crm.php?resource=settings',",
            "  method: 'GET',",
            "  header: [{ key: 'X-Auth-Token', value: pm.collectionVariables.get('token') }],",
            '}, function (err, res) {',
            "  let value = '0';",
            "  if (!err && res.code === 200) { const v = res.json().community_enabled; if (v === '1' || v === '0') value = v; }",
            "  pm.collectionVariables.set('crmCommunity', value);",
            '});',
        ]),
        event('test', [
            'pm.test("200 and updated key", () => {',
            '  pm.response.to.have.status(200);',
            '  const b = pm.response.json();',
            '  pm.expect(b.ok).to.eql(true);',
            '  pm.expect(b.updated).to.include("community_enabled");',
            '});',
        ]),
    ]);

    return folder('9 · CRM', [$enquiries, $subscribers, $settingsGet, $settingsPut],
        'Enquiries, subscribers and settings through one scoped endpoint (`api/crm.php?resource=…`). '
        . 'Reads need crm:read; writes need crm:write + CSRF. The settings write is idempotent so the folder is safe to run as-is.');
}

// ---------------------------------------------------------------- carry-over

function carried_folders(): array
{
    if (!is_file(OUT)) return [];
    $old = json_decode((string)file_get_contents(OUT), true);
    if (!is_array($old) || empty($old['item'])) return [];
    $keep = ['Intake & analytics', 'SEO tools'];
    $out = [];
    foreach ($old['item'] as $f) {
        $name = (string)($f['name'] ?? '');
        foreach ($keep as $needle) {
            if (str_ends_with($name, $needle)) $out[] = repair_carried($f);
        }
    }
    return $out;
}

/**
 * `enquiries.php` answers 403 unless Origin equals the request host, and Postman does not
 * send Origin — so the carried-over intake request needs one before it can ever pass.
 */
function repair_carried(array $folder): array
{
    foreach ($folder['item'] as &$item) {
        $url = (string)($item['request']['url'] ?? '');
        if (!str_contains($url, 'enquiries.php')) continue;
        $headers = $item['request']['header'] ?? [];
        $has = false;
        foreach ($headers as $h) if (strcasecmp((string)($h['key'] ?? ''), 'Origin') === 0) $has = true;
        if (!$has) {
            array_unshift($headers, hdr('Origin', '{{siteUrl}}',
                'Required. api/enquiry-store.php rejects the POST with 403 origin_not_allowed unless Origin matches '
                . 'the Host exactly, and Postman does not add Origin the way a browser does. Keep it equal to the site '
                . 'root — if you change {{baseUrl}}, change this too.'));
            $item['request']['header'] = $headers;
        }
        $item['request']['description'] = preg_replace(
            '/Origin must equal the host when sent from a browser\./',
            'Origin **must** equal the host: `{{siteUrl}}` is sent as a header because Postman, unlike a browser, '
            . 'sends none. A mismatch is 403 `origin_not_allowed`, not a token problem.',
            (string)($item['request']['description'] ?? '')
        );
    }
    unset($item);
    return $folder;
}

function renumber_carried(array $folders, int $from): array
{
    $n = $from;
    foreach ($folders as &$f) {
        $f['name'] = preg_replace('/^\d+\s·\s*/', $n . ' · ', (string)$f['name']);
        $n++;
    }
    return $folders;
}

// ---------------------------------------------------------------- assemble

$schema = entity_schema();

$folders = array_merge(
    [start_here_folder(), auth_folder(), public_folder(), profile_folder(), reference_folder($schema),
     crud_folder($schema), media_folder(), recipes_folder(), tokens_folder(), crm_folder()],
    renumber_carried(carried_folders(), 10)
);

// every {{var}} used anywhere must exist in the variable list, or Postman shows it greyed
$live = 'https://hasanabbassorathiya.tech';
$vars = [
    'baseUrl' => getenv('BASE_URL') ?: $live . '/api',
    'siteUrl' => getenv('SITE_URL') ?: $live,
    'adminEmail' => '', 'adminPassword' => '',
    'token' => '', 'csrf' => '',
    'mediaPath' => '', 'demoSlug' => '', 'mediaRecipeId' => '',
    'mediaId' => '', 'scopedTokenId' => '', 'scopedToken' => '', 'scopedCsrf' => '', 'crmCommunity' => '',
];
foreach (ID_VARS as $v) $vars[$v] = '';
$vars['enquiryReference'] = '';

$collection = [
    'info' => [
        '_postman_id' => COLLECTION_ID,
        'name' => 'Portfolio API — Hasan Abbas Sorathiya',
        'description' => "Complete collection for the portfolio CMS: public content, profile key/values, admin CRUD for "
            . "every entity, media uploads and recipes. Folders 4 and 5 are generated from `api/entity-schema.php` — "
            . "regenerate with `cd site && npm run postman`. See site/API.md for the prose guide.",
        'schema' => POSTMAN_SCHEMA,
    ],
    'item' => $folders,
    'variable' => array_map(fn ($k, $v) => ['key' => $k, 'value' => (string)$v], array_keys($vars), $vars),
];

$json = json_encode($collection, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
if ($json === false) {
    fwrite(STDERR, 'gen-postman: ' . json_last_error_msg() . "\n");
    exit(1);
}

// A {{var}} with no entry renders greyed and silently sends the literal text, so fail the build instead.
preg_match_all('/\{\{([A-Za-z][A-Za-z0-9_]*)\}\}/', $json, $used);
$undeclared = array_values(array_unique(array_diff($used[1], array_keys($vars))));
if ($undeclared) {
    fwrite(STDERR, 'gen-postman: referenced but not declared in the variable list: ' . implode(', ', $undeclared) . "\n");
    exit(1);
}

file_put_contents(OUT, $json . "\n");

$counts = [];
foreach ($folders as $f) {
    $n = 0;
    foreach ($f['item'] as $i) $n += isset($i['item']) ? count($i['item']) : 1;
    $counts[] = $f['name'] . ' (' . $n . ')';
}
printf("wrote %s\n%s\n", OUT, '  ' . implode("\n  ", $counts));
