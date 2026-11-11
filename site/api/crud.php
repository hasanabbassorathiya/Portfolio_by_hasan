<?php
declare(strict_types=1);
// Admin CRUD: GET/POST/PUT/DELETE /api/crud.php?entity=apps&id=<int>
// Field whitelists and validation come from api/entity-schema.php.
require __DIR__ . '/bootstrap.php';
require __DIR__ . '/entity-schema.php';

$method = $_SERVER['REQUEST_METHOD'];
$pdo = db();

require_admin();
if (in_array($method, ['POST', 'PUT', 'DELETE'], true)) {
    require_scope('content:write');
    $csrf = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? ($_POST['csrf_token'] ?? '');
    require_admin_csrf(is_string($csrf) ? $csrf : '');
} else {
    require_scope('content:read');
}

$entity = (string)($_GET['entity'] ?? '');
$resolved = entity_resolve($entity);
if ($resolved === null) json_out(['error' => 'unknown entity'], 400);
[$entity, $cfg] = $resolved;
$table = $cfg['table'];
$isKv = !empty($cfg['kv']);

if (in_array($method, ['POST', 'PUT'], true)
    && stripos((string)($_SERVER['CONTENT_TYPE'] ?? ''), 'application/json') !== 0) {
    json_out(['error' => 'content-type must be application/json'], 415);
}

// ---- Validation helpers ----

function crud_field_map(array $cfg): array
{
    $map = [];
    foreach ($cfg['fields'] as $field) $map[$field['name']] = $field;
    return $map;
}

function crud_json_shape(mixed $value, string $shape): ?string
{
    if ($value === null) return null;
    if (!is_array($value)) return 'must be a JSON array or object';
    $items = array_values($value);
    $isList = array_is_list($value);
    if ($shape === 'list') {
        if (!$isList) return 'must be a JSON array';
        foreach ($items as $item) {
            if (!is_string($item) && !is_int($item) && !is_float($item)) return 'items must be strings';
        }
        return null;
    }
    if ($shape === 'pairs') {
        if (!$isList) return 'must be a JSON array of [label, value] pairs';
        foreach ($items as $item) {
            if (!is_array($item) || count($item) !== 2) return 'each item must be a [label, value] pair';
            foreach ($item as $part) {
                if (!is_string($part) && !is_int($part) && !is_float($part)) return 'pair values must be strings';
            }
        }
        return null;
    }
    if ($shape === 'object') {
        if ($isList && $items !== []) return 'must be a JSON object';
        return null;
    }
    return null;
}

/**
 * VARCHAR widths straight from the database, keyed by column name.
 *
 * entity-schema.php declares an editorial max (default 255 for text); the column is the
 * limit that actually rejects a write — 30 of the editable text fields sit in
 * VARCHAR(20..190) columns. Validating against the schema alone lets a value through
 * that MySQL then refuses, and the admin sees `update failed` with no field named.
 * TEXT-family columns are skipped because character_maximum_length there is a byte
 * ceiling, not a character count. API.md §4.1 lists the widths.
 *
 * @return array<string,int>
 */
function crud_varchar_limits(PDO $pdo, string $table): array
{
    static $cache = [];
    if (isset($cache[$table])) return $cache[$table];
    $limits = [];
    try {
        $st = $pdo->prepare(
            'SELECT column_name, character_maximum_length FROM information_schema.columns
             WHERE table_schema = DATABASE() AND table_name = ?
               AND data_type IN (?, ?)'
        );
        $st->execute([$table, 'varchar', 'char']);
        foreach ($st->fetchAll() as $row) {
            $len = (int)($row['character_maximum_length'] ?? 0);
            if ($len > 0) $limits[strtolower((string)$row['column_name'])] = $len;
        }
    } catch (Throwable $e) {
        // information_schema can be restricted; fall back to the schema-declared max.
    }
    return $cache[$table] = $limits;
}

/** The shorter of the schema's editorial max and the column's real width. */
function crud_max(array $field, ?int $varchar): int
{
    $type = $field['type'] ?? 'text';
    $declared = (int)($field['max'] ?? match ($type) {
        'text', 'image' => 255,
        'textarea' => 20000,
        'markdown' => 200000,
        default => 0,
    });
    if ($varchar === null) return $declared;
    return $declared > 0 ? min($declared, $varchar) : $varchar;
}

/**
 * A rejection the admin can act on. admin/edit.php renders `detail` alone, so the
 * message has to name its own field; the machine-readable key ships alongside it.
 */
function crud_fail(array $field, string $name, string $message): array
{
    return ['field' => $name, 'error' => (string)($field['label'] ?? $name) . ': ' . $message];
}

/**
 * @return array{0: array<string,mixed>, 1: ?array{field:string, error:string}}
 */
function crud_clean(array $body, array $cfg, bool $creating): array
{
    $fields = crud_field_map($cfg);
    $limits = crud_varchar_limits(db(), (string)$cfg['table']);
    $out = [];
    foreach ($fields as $name => $field) {
        if (!array_key_exists($name, $body)) continue;
        $type = $field['type'] ?? 'text';
        $value = $body[$name];
        $max = crud_max($field, $limits[strtolower($name)] ?? null);

        if ($type === 'checkbox') {
            $out[$name] = in_array($value, [1, '1', true, 'true', 'on'], true) ? 1 : 0;
            continue;
        }
        if ($type === 'number') {
            if ($value === '' || $value === null) { $out[$name] = null; continue; }
            if (!is_numeric($value)) return [[], crud_fail($field, $name, 'must be a number')];
            $out[$name] = $value + 0;
            continue;
        }
        if ($type === 'date') {
            if ($value === '' || $value === null) { $out[$name] = null; continue; }
            $date = DateTime::createFromFormat('Y-m-d', (string)$value);
            if (!$date || $date->format('Y-m-d') !== (string)$value) {
                return [[], crud_fail($field, $name, 'must be a date (YYYY-MM-DD)')];
            }
            $out[$name] = (string)$value;
            continue;
        }
        if ($type === 'json') {
            if ($value === '' || $value === null) { $out[$name] = null; continue; }
            if (is_string($value)) {
                $decoded = json_decode($value, true);
                if (json_last_error() !== JSON_ERROR_NONE) {
                    return [[], crud_fail($field, $name, 'invalid JSON')];
                }
                $value = $decoded;
            }
            $problem = crud_json_shape($value, (string)($field['shape'] ?? 'list'));
            if ($problem !== null) return [[], crud_fail($field, $name, $problem)];
            $out[$name] = json_encode($value, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
            continue;
        }

        // text-like
        if (!is_string($value) && !is_int($value) && !is_float($value)) {
            return [[], crud_fail($field, $name, 'must be text')];
        }
        $value = trim((string)$value);
        if ($value === '') {
            $out[$name] = ($field['required'] ?? false) ? '' : null;
            if (($field['required'] ?? false)) {
                return [[], crud_fail($field, $name, 'is required')];
            }
            continue;
        }
        if ($max > 0 && mb_strlen($value) > $max) {
            return [[], crud_fail($field, $name, "too long — {$max} character limit, got " . mb_strlen($value))];
        }
        if ($name === 'slug' && !preg_match('/\A[a-z0-9][a-z0-9-]{0,189}\z/', $value)) {
            return [[], crud_fail($field, $name, 'use lowercase letters, numbers and hyphens')];
        }
        $out[$name] = $value;
    }

    if ($creating) {
        foreach ($fields as $name => $field) {
            if (($field['required'] ?? false) && (!isset($out[$name]) || $out[$name] === '' || $out[$name] === null)) {
                return [[], crud_fail($field, $name, 'is required')];
            }
        }
    }
    return [$out, null];
}

/**
 * The column a rejected write came from, when MySQL says so.
 *
 * Only the column name is read out of the driver message — the rest can carry SQL or the
 * value itself, and `detail` renders straight into the admin page. This is a backstop for
 * hosts where information_schema is restricted and crud_varchar_limits() comes back empty.
 */
function crud_column_error(PDOException $e): ?string
{
    $msg = (string)($e->errorInfo[2] ?? '');
    if (preg_match("/(?:for|in) column '([A-Za-z0-9_]{1,64})'/", $msg, $m)) return $m[1];
    if (preg_match("/Column '([A-Za-z0-9_]{1,64})' cannot be null/", $msg, $m)) return $m[1];
    return null;
}

/**
 * @param array<string,array> $fields
 * @return array<string,string>
 */
function crud_write_failed(array $fields, PDOException $e, string $fallback): array
{
    $col = crud_column_error($e);
    if ($col === null) return ['error' => $fallback];
    $label = (string)($fields[$col]['label'] ?? $col);
    return ['error' => 'validation failed', 'field' => $col,
            'detail' => "{$label}: rejected by the database — check the length and type against that field"];
}

function crud_slug_conflict(PDO $pdo, string $table, string $slug, int $ignoreId = 0): bool
{
    $st = $pdo->prepare("SELECT id FROM `$table` WHERE slug = ? AND id <> ? LIMIT 1");
    $st->execute([$slug, $ignoreId]);
    return (bool)$st->fetchColumn();
}

// ---- Read ----
if ($method === 'GET') {
    if (($_GET['schema'] ?? '') === '1') {
        $fields = $isKv ? profile_fields() : $cfg['fields'];
        json_out(['entity' => $entity, 'kv' => $isKv, 'fields' => $fields]);
    }
    $id = (int)($_GET['id'] ?? 0);
    if ($isKv) {
        $k = trim((string)($_GET['k'] ?? ''));
        if ($k !== '') {
            $st = $pdo->prepare('SELECT k, v FROM profile WHERE k = ?');
            $st->execute([$k]);
            $row = $st->fetch();
            json_out($row ?: ['error' => 'not found'], $row ? 200 : 404);
        }
        json_out(['entity' => $entity, 'data' => $pdo->query('SELECT k, v FROM profile ORDER BY k')->fetchAll()]);
    }
    if ($id) {
        $st = $pdo->prepare("SELECT * FROM `$table` WHERE id = ?");
        $st->execute([$id]);
        $row = $st->fetch();
        json_out($row ?: ['error' => 'not found'], $row ? 200 : 404);
    }
    $order = match (true) {
        isset($cfg['order']) => ' ORDER BY `' . $cfg['order'] . '`, id',
        $table === 'posts' => ' ORDER BY post_date DESC, id DESC',
        default => ' ORDER BY id',
    };
    json_out(['entity' => $entity, 'data' => $pdo->query("SELECT * FROM `$table`" . $order)->fetchAll()]);
}

// ---- Profile (key/value) ----
if ($isKv) {
    if ($method === 'POST' || $method === 'PUT') {
        $b = body();
        $k = trim((string)($b['k'] ?? ''));
        $v = $b['v'] ?? '';
        if (!preg_match('/\A[a-z0-9_]{1,60}\z/', $k)) {
            json_out(['error' => 'invalid key', 'field' => 'k', 'detail' => 'lowercase letters, numbers, underscore'], 422);
        }
        if (!is_string($v)) json_out(['error' => 'v must be text', 'field' => 'v'], 422);
        if ($method === 'PUT') {
            $previous = trim((string)($b['previous_k'] ?? $k));
            if ($previous !== $k) {
                $pdo->prepare('DELETE FROM profile WHERE k = ?')->execute([$previous]);
            }
        }
        $pdo->prepare('REPLACE INTO profile (k, v) VALUES (?,?)')->execute([$k, $v]);
        json_out(['ok' => true], $method === 'POST' ? 201 : 200);
    }
    if ($method === 'DELETE') {
        $k = trim((string)($_GET['k'] ?? ''));
        if (!preg_match('/\A[a-z0-9_]{1,60}\z/', $k)) json_out(['error' => 'k required'], 400);
        $pdo->prepare('DELETE FROM profile WHERE k = ?')->execute([$k]);
        json_out(['ok' => true]);
    }
    json_out(['error' => 'method not allowed'], 405);
}

// ---- Create ----
if ($method === 'POST') {
    [$row, $error] = crud_clean(body(), $cfg, true);
    if ($error !== null) json_out(['error' => 'validation failed', 'field' => $error['field'], 'detail' => $error['error']], 422);
    if (!$row) json_out(['error' => 'no valid fields'], 400);
    if (!empty($cfg['slug']) && crud_slug_conflict($pdo, $table, (string)$row['slug'])) {
        json_out(['error' => 'slug already exists', 'field' => 'slug', 'slug' => $row['slug']], 409);
    }
    $keys = array_keys($row);
    $cols = '`' . implode('`,`', $keys) . '`';
    $ph = rtrim(str_repeat('?,', count($keys)), ',');
    try {
        $pdo->prepare("INSERT INTO `$table` ($cols) VALUES ($ph)")->execute(array_values($row));
    } catch (PDOException $e) {
        if ($e->getCode() === '23000') {
            json_out(['error' => 'slug already exists', 'field' => 'slug'], 409);
        }
        json_out(crud_write_failed(crud_field_map($cfg), $e, 'insert failed'), 422);
    }
    json_out(['id' => (int)$pdo->lastInsertId()], 201);
}

// ---- Update ----
if ($method === 'PUT') {
    $id = (int)($_GET['id'] ?? 0);
    if (!$id) json_out(['error' => 'id required'], 400);
    $exists = $pdo->prepare("SELECT id FROM `$table` WHERE id = ?");
    $exists->execute([$id]);
    if (!$exists->fetchColumn()) json_out(['error' => 'not found'], 404);
    [$row, $error] = crud_clean(body(), $cfg, false);
    if ($error !== null) json_out(['error' => 'validation failed', 'field' => $error['field'], 'detail' => $error['error']], 422);
    if (!$row) json_out(['error' => 'no valid fields'], 400);
    if (!empty($cfg['slug']) && isset($row['slug']) && crud_slug_conflict($pdo, $table, (string)$row['slug'], $id)) {
        json_out(['error' => 'slug already exists', 'field' => 'slug', 'slug' => $row['slug']], 409);
    }
    $sets = implode(',', array_map(fn ($k) => "`$k`=?", array_keys($row)));
    try {
        $st = $pdo->prepare("UPDATE `$table` SET $sets WHERE id = ?");
        $st->execute([...array_values($row), $id]);
    } catch (PDOException $e) {
        if ($e->getCode() === '23000') {
            json_out(['error' => 'slug already exists', 'field' => 'slug'], 409);
        }
        json_out(crud_write_failed(crud_field_map($cfg), $e, 'update failed'), 422);
    }
    json_out(['ok' => true]);
}

// ---- Delete ----
if ($method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    if (!$id) json_out(['error' => 'id required'], 400);
    $st = $pdo->prepare("DELETE FROM `$table` WHERE id = ?");
    $st->execute([$id]);
    if ($st->rowCount() === 0) json_out(['error' => 'not found'], 404);
    json_out(['ok' => true]);
}

json_out(['error' => 'method not allowed'], 405);
