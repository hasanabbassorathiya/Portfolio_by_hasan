<?php
declare(strict_types=1);
require __DIR__ . '/guard.php';
require __DIR__ . '/../api/entity-schema.php';

$schema = entity_schema();
$entity = (string)($_GET['entity'] ?? 'apps');
if (isset($_GET['entity']) === false && isset($schema['apps'])) $entity = 'apps';
if (!isset($schema[$entity])) {
    http_response_code(404);
    echo 'Unknown entity.';
    exit;
}
$cfg = $schema[$entity];
$table = $cfg['table'];
$isKv = !empty($cfg['kv']);
$hasPublished = !empty($cfg['published']);
$hasOrder = !empty($cfg['order']);
$hasSlug = !empty($cfg['slug']);
$pdo = db();
$csrf = admin_csrf_token();

// ---- Quick actions (plain POST form + redirect), all CSRF-guarded ----
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $posted = $_POST['csrf_token'] ?? '';
    if (!is_string($posted) || !hash_equals($csrf, $posted)) {
        http_response_code(403);
        echo 'Security check failed. Reload the page and try again.';
        exit;
    }
    $action = (string)($_POST['action'] ?? '');
    $id = (int)($_POST['id'] ?? 0);
    $key = (string)($_POST['k'] ?? '');
    $back = 'edit.php?entity=' . urlencode($entity);

    if ($isKv) {
        if ($action === 'delete' && preg_match('/\A[a-z0-9_]{1,60}\z/', $key)) {
            $pdo->prepare('DELETE FROM profile WHERE k = ?')->execute([$key]);
        }
    } elseif ($id > 0) {
        if ($action === 'toggle' && $hasPublished) {
            $pdo->prepare("UPDATE `$table` SET published = IF(published = 1, 0, 1) WHERE id = ?")->execute([$id]);
        } elseif ($action === 'delete') {
            $pdo->prepare("DELETE FROM `$table` WHERE id = ?")->execute([$id]);
        } elseif ($action === 'move' && $hasOrder) {
            $orderCol = $cfg['order'];
            $order = $pdo->query("SELECT id FROM `$table` ORDER BY `$orderCol`, id")->fetchAll(PDO::FETCH_COLUMN);
            $ids = array_map('intval', $order);
            $position = array_search($id, $ids, true);
            $target = ($_POST['dir'] ?? 'up') === 'up' ? $position - 1 : $position + 1;
            if ($position !== false && $target >= 0 && $target < count($ids)) {
                [$ids[$position], $ids[$target]] = [$ids[$target], $ids[$position]];
                $update = $pdo->prepare("UPDATE `$table` SET `$orderCol` = ? WHERE id = ?");
                foreach ($ids as $index => $rowId) $update->execute([$index + 1, $rowId]);
            }
        }
    }
    header('Location: ' . $back);
    exit;
}

// ---- Load rows ----
if ($isKv) {
    $rows = $pdo->query('SELECT k, v FROM profile ORDER BY k')->fetchAll();
} else {
    $order = $hasOrder
        ? ' ORDER BY `' . $cfg['order'] . '`, id'
        : ($table === 'posts' ? ' ORDER BY post_date DESC, id DESC' : ' ORDER BY id');
    $rows = $pdo->query('SELECT * FROM `' . $table . '`' . $order)->fetchAll();
}

$fieldLabels = [];
foreach ($cfg['fields'] as $field) $fieldLabels[$field['name']] = $field['label'];
if ($isKv) $fieldLabels = ['k' => 'Key', 'v' => 'Value'];

$groups = [];
foreach ($cfg['fields'] as $field) {
    $groups[$field['group'] ?? 'Content'][] = $field;
}
if ($isKv) {
    $groups = ['Field' => [
        ['name' => 'k', 'label' => 'Key', 'type' => 'text', 'required' => true,
         'help' => 'lowercase_with_underscores — e.g. sub, availability, email'],
        ['name' => 'v', 'label' => 'Value', 'type' => 'textarea', 'required' => true,
         'help' => 'Tokens resolve from live data: {{years}}, {{apps}}, {{clients}}, {{users}}, {{platforms}}, {{client_metric:client-slug}}. Use them in the sub value or any text shown on the site.'],
    ]];
}
?><!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<title><?=htmlspecialchars($cfg['label'])?> — Portfolio CMS</title>
<link rel="stylesheet" href="admin.css">
</head>
<body>
<nav class="topbar">
  <a href="dashboard.php" class="back">&larr; Dashboard</a>
  <div class="entity-tabs">
    <?php foreach ($schema as $key => $item): ?>
      <a href="edit.php?entity=<?=$key?>" class="<?=$key === $entity ? 'active' : ''?>"><?=htmlspecialchars($item['label'])?></a>
    <?php endforeach; ?>
    <a href="analytics.php">Analytics</a>
    <a href="settings.php">Settings</a>
  </div>
  <div class="topbar-links">
    <a href="../" target="_blank" rel="noreferrer" class="logout">View site ↗</a>
    <a href="logout.php" class="logout">Sign out</a>
  </div>
</nav>
<main>
  <header class="page-head">
    <div>
      <h1><?=htmlspecialchars($cfg['label'])?></h1>
      <p class="meta"><?=count($rows)?> record<?=count($rows) === 1 ? '' : 's'?> · changes appear on the live site on the next page load. SEO snippets are baked into the prerendered HTML at the next deploy.</p>
    </div>
    <button class="btn-primary" type="button" onclick="openEditor()">+ New <?=htmlspecialchars($cfg['singular'])?></button>
  </header>

  <p id="page-status" role="status" class="save-notice"></p>
  <section class="editor" id="editor" hidden>
    <div class="editor-head">
      <h2 id="editor-title">New record</h2>
      <button class="btn-sm" type="button" onclick="closeEditor()">Close</button>
    </div>
    <form id="editor-form">
      <?php foreach ($groups as $groupName => $fields): ?>
        <fieldset class="field-group">
          <?php if (count($groups) > 1): ?><legend><?=htmlspecialchars($groupName)?></legend><?php endif; ?>
          <div class="editor-grid">
            <?php foreach ($fields as $field): ?>
              <?php
                $name = $field['name'];
                $label = $field['label'];
                $type = $field['type'] ?? 'text';
                $required = !empty($field['required']);
                $help = $field['help'] ?? '';
                $requiredAttr = $required ? 'required' : '';
                $helpHtml = $help !== '' ? '<small class="field-help">' . htmlspecialchars($help) . '</small>' : '';
              ?>
              <?php if ($type === 'checkbox'): ?>
                <label class="field field-check">
                  <input type="checkbox" name="<?=$name?>" value="1">
                  <span><?=htmlspecialchars($label)?></span>
                </label>
              <?php elseif ($type === 'json'): ?>
                <div class="field field-wide" role="group" aria-label="<?=htmlspecialchars($label)?>" data-structured="<?=$name?>" data-shape="<?=htmlspecialchars($field['shape'] ?? 'list')?>" data-images="<?=$name === 'screenshots' ? '1' : '0'?>">
                  <span><?=htmlspecialchars($label)?></span>
                  <input type="hidden" name="<?=$name?>" data-json="1">
                  <div data-items></div>
                  <div class="structured-actions">
                    <button class="btn-sm" type="button" data-add>Add item</button>
                    <?php if ($name === 'screenshots'): ?>
                      <button class="btn-sm" type="button" data-upload="<?=$name?>">Upload images</button>
                      <input type="file" accept="image/png,image/jpeg,image/webp,image/avif,image/gif" multiple hidden data-file="<?=$name?>">
                    <?php endif; ?>
                  </div>
                  <small class="field-help"><?=$name === 'screenshots' ? 'Upload images or add an existing image path. Move items to set their display order. Removing an item does not delete its file.' : (($field['shape'] ?? 'list') === 'object' ? 'One key and value per row. Keys must be unique.' : 'Add one item per row. Move items to set their display order.')?></small>
                </div>
              <?php elseif ($type === 'textarea' || $type === 'markdown'): ?>
                <label class="field field-wide">
                  <span><?=htmlspecialchars($label)?></span>
                  <textarea name="<?=$name?>" rows="<?=$type === 'markdown' ? 16 : 5?>" <?=$requiredAttr?>></textarea>
                  <?=$helpHtml?>
                </label>
              <?php elseif ($type === 'image'): ?>
                <div class="field field-wide">
                  <span><?=htmlspecialchars($label)?></span>
                  <div class="media-row">
                    <input type="text" name="<?=$name?>" data-image="1" placeholder="/media/…">
                    <button class="btn-sm" type="button" data-upload="<?=$name?>">Upload</button>
                    <input type="file" accept="image/png,image/jpeg,image/webp,image/avif,image/gif" hidden data-file="<?=$name?>">
                  </div>
                  <img class="img-preview" data-preview="<?=$name?>" alt="" hidden>
                  <?=$helpHtml?>
                </div>
              <?php elseif ($type === 'select'): ?>
                <label class="field">
                  <span><?=htmlspecialchars($label)?></span>
                  <select name="<?=$name?>">
                    <?php foreach (($field['options'] ?? []) as $option): ?>
                      <option value="<?=htmlspecialchars($option)?>"><?=htmlspecialchars($option)?></option>
                    <?php endforeach; ?>
                  </select>
                </label>
              <?php else: ?>
                <label class="field">
                  <span><?=htmlspecialchars($label)?></span>
                  <input type="<?=$type === 'number' ? 'number' : ($type === 'date' ? 'date' : 'text')?>" name="<?=$name?>" <?=$requiredAttr?> <?=$type === 'number' ? 'step="any"' : ''?>>
                  <?=$helpHtml?>
                </label>
              <?php endif; ?>
            <?php endforeach; ?>
          </div>
        </fieldset>
      <?php endforeach; ?>
      <div class="editor-actions">
        <button class="btn-primary" type="submit" id="save-btn">Save</button>
        <button class="btn-sm" type="button" onclick="closeEditor()">Cancel</button>
        <span class="form-error" id="form-error" role="alert"></span>
        <span class="field-help" id="editor-status" role="status"></span>
      </div>
    </form>
  </section>

  <div class="table-wrap">
    <table class="data-table">
      <thead><tr>
        <?php foreach ($cfg['list'] as $col): ?>
          <th><?=htmlspecialchars($fieldLabels[$col] ?? ucfirst($col))?></th>
        <?php endforeach; ?>
        <th>Actions</th>
      </tr></thead>
      <tbody>
        <?php if (!$rows): ?><tr><td colspan="<?=count($cfg['list']) + 1?>"><em>No records yet. Create the first one.</em></td></tr><?php endif; ?>
        <?php foreach ($rows as $index => $row): ?>
          <?php
            $id = (int)($row['id'] ?? 0);
            $editArg = $isKv ? json_encode($row['k']) : (string)$id;
          ?>
          <tr>
            <?php foreach ($cfg['list'] as $col): ?>
              <?php $value = $row[$col] ?? ''; $type = 'text'; ?>
              <?php foreach ($cfg['fields'] as $f) { if ($f['name'] === $col) { $type = $f['type'] ?? 'text'; break; } } ?>
              <td>
                <?php if ($type === 'checkbox' || $col === 'published'): ?>
                  <span class="pill <?= (int)$value === 1 ? 'pill-live' : 'pill-draft' ?>"><?= (int)$value === 1 ? 'Yes' : 'No' ?></span>
                <?php elseif ($type === 'image' && is_string($value) && str_starts_with($value, '/')): ?>
                  <img class="thumb" src="<?=htmlspecialchars($value)?>" alt="" loading="lazy">
                <?php elseif ($col === 'rating_value'): ?>
                  <?= $value !== null && $value !== '' ? '★ ' . htmlspecialchars((string)$value) : '—' ?>
                <?php else: ?>
                  <?= htmlspecialchars(mb_strimwidth((string)$value, 0, 80, '…')) ?>
                <?php endif; ?>
              </td>
            <?php endforeach; ?>
            <td class="row-actions">
              <button class="btn-sm" type="button" onclick="openEditor(<?=htmlspecialchars($editArg, ENT_QUOTES, 'UTF-8')?>)">Edit</button>
              <?php if (!empty($cfg['view']) && $hasSlug && !empty($row['slug'])): ?>
                <button class="btn-sm" type="button" onclick="window.open('<?=htmlspecialchars(sprintf($cfg['view'], rawurlencode((string)$row['slug'])))?>', '_blank')" title="Open on the public site">↗</button>
              <?php endif; ?>
              <form method="post">
                <input type="hidden" name="csrf_token" value="<?=htmlspecialchars($csrf)?>">
                <?php if ($isKv): ?>
                  <input type="hidden" name="k" value="<?=htmlspecialchars((string)$row['k'])?>">
                  <input type="hidden" name="action" value="delete">
                  <button class="btn-sm btn-danger" type="submit" onclick="return confirm('Delete this profile field?')">Delete</button>
                <?php else: ?>
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="toggle">
                  <button class="btn-sm" type="submit" title="Toggle published" <?=$hasPublished ? '' : 'hidden'?>><?= (int)($row['published'] ?? 0) === 1 ? 'Unpublish' : 'Publish' ?></button>
                <?php endif; ?>
              </form>
              <?php if (!$isKv && $hasOrder): ?>
                <form method="post">
                  <input type="hidden" name="csrf_token" value="<?=htmlspecialchars($csrf)?>">
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="move">
                  <input type="hidden" name="dir" value="up">
                  <button class="btn-sm" type="submit" title="Move up" <?=$index === 0 ? 'disabled' : ''?>>↑</button>
                </form>
                <form method="post">
                  <input type="hidden" name="csrf_token" value="<?=htmlspecialchars($csrf)?>">
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="move">
                  <input type="hidden" name="dir" value="down">
                  <button class="btn-sm" type="submit" title="Move down" <?=$index === count($rows) - 1 ? 'disabled' : ''?>>↓</button>
                </form>
              <?php endif; ?>
              <?php if (!$isKv): ?>
                <form method="post" onsubmit="return confirm('Delete this record? This cannot be undone.')">
                  <input type="hidden" name="csrf_token" value="<?=htmlspecialchars($csrf)?>">
                  <input type="hidden" name="id" value="<?=$id?>">
                  <input type="hidden" name="action" value="delete">
                  <button class="btn-sm btn-danger" type="submit">Delete</button>
                </form>
              <?php endif; ?>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</main>
<script>
const ENTITY = <?=json_encode($entity)?>;
const CSRF = <?=json_encode($csrf)?>;
const IS_KV = <?=$isKv ? 'true' : 'false'?>;
</script>
<script src="structured-fields.js"></script>
<script src="editor.js"></script>
</body>
</html>
