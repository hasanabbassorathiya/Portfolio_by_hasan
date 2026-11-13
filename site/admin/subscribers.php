<?php
declare(strict_types=1);
require __DIR__ . '/guard.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require_admin_csrf(is_string($_POST['csrf_token'] ?? null) ? $_POST['csrf_token'] : '');
}
$csrfToken = admin_csrf_token();
$error = null;
$rows = [];
$week = 0;

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete'])) {
        db()->prepare('DELETE FROM subscribers WHERE id = ?')->execute([(int)$_POST['delete']]);
        header('Location: subscribers.php?deleted=1');
        exit;
    }
    $rows = db()->query('SELECT id, email, name, whatsapp, source, consent_at, created_at, unsub_token FROM subscribers ORDER BY created_at DESC, id DESC')->fetchAll();
    $week = (int) db()->query('SELECT COUNT(*) FROM subscribers WHERE created_at > NOW() - INTERVAL 7 DAY')->fetchColumn();
} catch (Throwable $e) {
    $error = 'The subscribers table is missing. Import api/schema.sql in phpMyAdmin, then reload.';
}

$proto = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = preg_replace('/[^a-z0-9.\-:]/i', '', $_SERVER['HTTP_HOST'] ?? '') ?: 'hasanabbassorathiya.tech';
$base = $proto . '://' . $host;
?><!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Subscribers — Portfolio CMS</title>
<link rel="stylesheet" href="admin.css">
</head>
<body>
<nav class="topbar"><a href="dashboard.php" class="back">&larr; Dashboard</a><span class="logo">Subscribers</span></nav>
<main>
  <h1>Subscribers</h1>
  <?php if (isset($_GET['deleted'])): ?><p class="notice">Removed.</p><?php endif; ?>
  <?php if ($error): ?>
    <p class="error"><?= htmlspecialchars($error) ?></p>
  <?php else: ?>
    <p class="meta"><?= count($rows) ?> total · +<?= $week ?> in the last 7 days · one row per address, no tracking pixels</p>
    <div class="actions">
      <button type="button" class="btn-sm" id="copy-all">Copy all emails</button>
      <button type="button" class="btn-sm" id="csv">Download CSV</button>
      <span class="muted" id="copied" aria-live="polite"></span>
    </div>
    <table class="data-table">
      <thead><tr><th>Email</th><th>Name</th><th>WhatsApp</th><th>Source</th><th>Joined</th><th>Unsubscribe link</th><th></th></tr></thead>
      <tbody>
        <?php if (count($rows) === 0): ?>
          <tr><td colspan="7"><em>No subscribers yet. The signup forms go live with the next deploy.</em></td></tr>
        <?php endif; ?>
        <?php foreach ($rows as $r): ?>
          <?php $unsub = $base . '/api/subscribe.php?unsubscribe=' . $r['unsub_token']; ?>
          <tr>
            <td><?= htmlspecialchars($r['email']) ?></td>
            <td><?= htmlspecialchars($r['name'] !== '' ? $r['name'] : '—') ?></td>
            <td><?= htmlspecialchars($r['whatsapp'] !== '' ? $r['whatsapp'] : '—') ?></td>
            <td><?= htmlspecialchars($r['source'] !== '' ? $r['source'] : '—') ?></td>
            <td><?= htmlspecialchars(date('M j, Y', strtotime($r['created_at']))) ?></td>
            <td><button type="button" class="btn-sm copy-unsub" data-url="<?= htmlspecialchars($unsub) ?>">Copy link</button></td>
            <td>
              <form method="post" onsubmit="return confirm('Delete this subscriber?')">
                <input type="hidden" name="delete" value="<?= (int)$r['id'] ?>">
                <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrfToken, ENT_QUOTES, 'UTF-8') ?>">
                <button type="submit" class="btn-sm btn-danger">Delete</button>
              </form>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <p class="hint">Send essay updates with these addresses in BCC and include the reader's unsubscribe link. Deleting a row removes the address permanently.</p>
  <?php endif; ?>
</main>
<script>
const ROWS = <?= json_encode(array_map(static fn($r) => [
    'email' => $r['email'],
    'name' => $r['name'],
    'whatsapp' => $r['whatsapp'],
    'source' => $r['source'],
    'joined' => $r['created_at'],
], $rows), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;

const note = document.getElementById('copied');
const flash = (text) => { if (!note) return; note.textContent = text; setTimeout(() => { note.textContent = ''; }, 2000); };

document.getElementById('copy-all')?.addEventListener('click', async () => {
  try {
    await navigator.clipboard.writeText(ROWS.map((r) => r.email).join('\n'));
    flash('Copied ' + ROWS.length + ' addresses');
  } catch { flash('Copy failed — select the table instead'); }
});

document.getElementById('csv')?.addEventListener('click', () => {
  const cell = (v) => '"' + String(v).replace(/"/g, '""') + '"';
  const csv = ['email,name,whatsapp,source,joined', ...ROWS.map((r) => [r.email, r.name, r.whatsapp, r.source, r.joined].map(cell).join(','))].join('\n');
  const url = URL.createObjectURL(new Blob([csv], { type: 'text/csv' }));
  const a = document.createElement('a');
  a.href = url;
  a.download = 'subscribers.csv';
  a.click();
  URL.revokeObjectURL(url);
});

document.querySelectorAll('.copy-unsub').forEach((button) => {
  button.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(button.dataset.url);
      flash('Unsubscribe link copied');
    } catch { flash('Copy failed'); }
  });
});
</script>
</body>
</html>
