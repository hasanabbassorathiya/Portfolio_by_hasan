<?php
declare(strict_types=1);
header('Cache-Control: no-store, private');
header('X-Robots-Tag: noindex, nofollow');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: no-referrer');
header("Content-Security-Policy: default-src 'none'; style-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'none'");
require __DIR__ . '/guard.php';
require __DIR__ . '/../api/enquiry-store.php';

$error = null;
$detail = null;
$list = null;
$csrf = '';
$id = 0;
$filter = '';
$page = 1;
$submitted = null;

function enquiry_admin_integer($value, int $max = PHP_INT_MAX): int {
    if (!is_string($value) || !ctype_digit($value) || strlen($value) > 18 || (float)$value < 1 || (float)$value > $max) throw new EnquiryError(422, 'invalid_identifier');
    return (int)$value;
}

try {
    if (!function_exists('admin_csrf_token') || !function_exists('require_admin_csrf')) throw new EnquiryError(503, 'admin_security_helpers_required');
    $method = $_SERVER['REQUEST_METHOD'] ?? '';
    if (!in_array($method, ['GET', 'POST'], true)) { header('Allow: GET, POST'); throw new EnquiryError(405, 'method_not_allowed'); }
    if ($method === 'POST') {
        require_admin_csrf(is_string($_POST['csrf_token'] ?? null) ? $_POST['csrf_token'] : '');
        $id = enquiry_admin_integer($_POST['id'] ?? null);
        $version = enquiry_admin_integer($_POST['version'] ?? null, 4294967295);
        $submitted = $_POST;
        enquiry_update(db(), $id, $version, $_POST, $_admin_id);
        header('Location: enquiries.php?id=' . $id . '&saved=1', true, 303);
        exit;
    }
    $csrf = admin_csrf_token();
    if (isset($_GET['id'])) {
        $id = enquiry_admin_integer($_GET['id']);
        $detail = enquiry_detail(db(), $id);
        if (!$detail) throw new EnquiryError(404, 'enquiry_not_found');
    } else {
        if (isset($_GET['page'])) $page = enquiry_admin_integer($_GET['page'], 10000);
        $filter = enquiry_text($_GET['status'] ?? '', 'status', 0, 20);
        $list = enquiry_list(db(), $page, $filter);
    }
} catch (Throwable $e) {
    http_response_code($e instanceof EnquiryError ? $e->httpStatus : 503);
    $error = $e instanceof EnquiryError ? str_replace('_', ' ', $e->errorCode) : 'Enquiries unavailable. Verify the database and import api/enquiries-schema.sql before retrying.';
    if ($submitted !== null && $id > 0) {
        try { $detail = enquiry_detail(db(), $id); $csrf = admin_csrf_token(); }
        catch (Throwable $ignored) { $detail = null; }
    }
}

$values = $detail;
if ($values && $submitted !== null) {
    foreach (['status', 'notes', 'next_action', 'follow_up_date', 'version'] as $key) {
        if (isset($submitted[$key]) && is_string($submitted[$key])) $values[$key] = $submitted[$key];
    }
}

function h($value): string { return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8'); }
?><!doctype html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Enquiries — Portfolio CMS</title><link rel="stylesheet" href="admin.css"></head>
<body>
<nav class="topbar"><a href="dashboard.php" class="back">&larr; Dashboard</a><span class="logo">Enquiries</span><a href="enquiries.php" class="back">All enquiries</a></nav>
<main>
<div class="page-head"><div><h1><?= $detail ? 'Enquiry ' . h($detail['reference']) : 'Enquiries' ?></h1><p class="meta">Private lead management. Dates and timestamps are UTC.</p></div></div>

<?php if ($error): ?>
<p class="error" role="alert"><?= h($error) ?><?php if ($id > 0): ?> <a href="enquiries.php?id=<?= $id ?>">Reload current record</a> before saving again. Copy your draft first.<?php endif; ?></p>
<?php endif; ?>

<?php if (isset($_GET['saved']) && !$error): ?>
<p class="notice" role="status">Changes saved.</p>
<?php endif; ?>

<?php if ($detail): ?>
<section class="editor" aria-labelledby="enquiry-contact">
    <h2 id="enquiry-contact">Contact & follow-up</h2>
    <dl class="enquiry-contact-dt">
        <dt>Name</dt><dd><?= h($detail['name']) ?></dd>
        <dt>Email</dt><dd><?php $detail_email = (string)($detail['email'] ?? ''); ?><?php if ($detail_email !== ''): ?><a href="mailto:<?= h($detail_email) ?>"><?= h($detail_email) ?></a><?php else: ?>—<?php endif; ?></dd>
        <dt>Type</dt><dd><?= h($detail['type']) ?></dd>
        <dt>Received</dt><dd><?= h($detail['created_at']) ?></dd>
        <dt>Consent</dt><dd><?= h($detail['consent_at']) ?> (<?= h($detail['consent_version']) ?>)</dd>
    </dl>
    <div class="enquiry-message">
        <h3>Message</h3>
        <p><?= nl2br(h($detail['message'])) ?></p>
    </div>
</section>

<form method="post" action="enquiries.php" class="editor">
    <input type="hidden" name="csrf_token" value="<?= h($csrf) ?>">
    <input type="hidden" name="id" value="<?= (int)$detail['id'] ?>">
    <input type="hidden" name="version" value="<?= h($values['version']) ?>">
    
    <h3>Follow-up details</h3>
    <div class="editor-grid">
        <label class="field">
            <span>Status</span>
            <select name="status" required>
                <?php foreach (ENQUIRY_STATUSES as $status): ?>
                <option value="<?= $status ?>"<?= $values['status'] === $status ? ' selected' : '' ?>><?= ucfirst($status) ?></option>
                <?php endforeach; ?>
            </select>
        </label>
        <label class="field">
            <span>Follow-up date (UTC)</span>
            <input type="date" name="follow_up_date" value="<?= h($values['follow_up_date']) ?>">
        </label>
        <label class="field field-wide">
            <span>Next action</span>
            <input type="text" name="next_action" maxlength="255" value="<?= h($values['next_action']) ?>">
        </label>
        <label class="field field-wide">
            <span>Notes (private)</span>
            <textarea name="notes" rows="6" maxlength="10000"><?= h($values['notes']) ?></textarea>
        </label>
    </div>
    
    <div class="editor-actions">
        <button class="btn-primary" type="submit">Save changes</button>
        <span class="muted">Updated <?= h($detail['updated_at']) ?> · version <?= (int)$detail['version'] ?></span>
    </div>
</form>

<section class="panel" aria-labelledby="mail-title">
    <h2 id="mail-title">Notification outbox</h2>
    <p class="meta">Sent means accepted; pending items will retry automatically.</p>
    <?php if (empty($detail['outbox'])): ?>
        <p class="muted">No notifications sent for this enquiry.</p>
    <?php else: ?>
        <div class="table-wrap"><table class="data-table">
            <thead>
                <tr>
                    <th>ID / type</th>
                    <th>State</th>
                    <th>Status</th>
                    <th>Next attempt (UTC)</th>
                    <th>Failure</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($detail['outbox'] as $mail): ?>
                <tr>
                    <td><?= (int)$mail['id'] ?> / <?= h($mail['kind']) ?></td>
                    <td><span class="pill <?= $mail['status'] ?>"><?= h($mail['status']) ?></span></td>
                    <td><?= (int)$mail['attempts'] ?> / <?= (int)$mail['total_attempts'] ?></td>
                    <td><?= h($mail['next_attempt_at'] ?? $mail['accepted_at'] ?? 'Pending') ?></td>
                    <td><?= h($mail['last_error'] ?? '—') ?></td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table></div>
        <p class="hint">To retry a failed outbox ID: <code>php site/scripts/enquiry-worker.php --retry=ID</code></p>
    <?php endif; ?>
</section>

<?php elseif ($list !== null): ?>
<form method="get" action="enquiries.php" class="editor">
    <label class="field">
        <span>Status filter</span>
        <select name="status">
            <option value="">All statuses</option>
            <?php foreach (ENQUIRY_STATUSES as $status): ?>
            <option value="<?= $status ?>"<?= $filter === $status ? ' selected' : '' ?>><?= ucfirst($status) ?></option>
            <?php endforeach; ?>
        </select>
    </label>
    <div class="editor-actions">
        <button type="submit" class="btn-sm">Filter</button>
    </div>
</form>

<div class="table-wrap"><table class="data-table">
    <thead>
        <tr>
            <th>Received</th>
            <th>Contact</th>
            <th>Status</th>
            <th>Follow-up</th>
            <th>Owner</th>
        </tr>
    </thead>
    <tbody>
    <?php if (!$list['rows']): ?>
        <tr><td colspan="5" class="empty-state">No enquiries on this page.</td></tr>
    <?php endif; ?>
    <?php foreach ($list['rows'] as $row): ?>
        <tr>
            <td><a href="enquiries.php?id=<?= (int)$row['id'] ?>"><?= h($row['created_at']) ?></a></td>
            <td><strong><?= h($row['name']) ?></strong><br><?php $row_email = (string)($row['email'] ?? ''); ?><?php if ($row_email !== ''): ?><a href="mailto:<?= h($row_email) ?>"><?= h($row_email) ?></a><?php else: ?>—<?php endif; ?></td>
            <td><span class="pill <?= $row['status'] ?>"><?= h($row['status']) ?></span></td>
            <td><?= h($row['follow_up_date'] ?? 'Not scheduled') ?><br><?= h($row['next_action']) ?: '—' ?></td>
            <td><?= h($row['owner_mail'] ?? 'Unassigned') ?></td>
        </tr>
    <?php endforeach; ?>
    </tbody>
</table></div>

<nav class="editor-actions" aria-label="Enquiry pages">
    <?php if ($page > 1): ?>
    <a class="btn-sm" href="enquiries.php?page=<?= $page - 1 ?>&amp;status=<?= rawurlencode($filter) ?>">Previous</a>
    <?php endif; ?>
    <span class="meta">Page <?= $page ?> · up to 25 enquiries per page</span>
    <?php if ($list['has_more']): ?>
    <a class="btn-sm" href="enquiries.php?page=<?= $page + 1 ?>&amp;status=<?= rawurlencode($filter) ?>">Next</a>
    <?php endif; ?>
</nav>
<?php endif; ?>
</main>
</body>
</html>
