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
    // Preserve valid scalar draft fields on validation/conflict errors, but do not silently overwrite a concurrent edit.
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
?><!doctype html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Enquiries — Portfolio CMS</title><link rel="stylesheet" href="admin.css"></head>
<body>
<nav class="topbar"><a href="dashboard.php" class="back">&larr; Dashboard</a><span class="logo">Private enquiries</span><a href="enquiries.php" class="back">All enquiries</a></nav>
<main>
<div class="page-head"><div><h1><?= $detail ? 'Enquiry ' . enquiry_escape($detail['reference']) : 'Enquiries' ?></h1><p class="meta">Private lead management. Dates and timestamps are UTC.</p></div></div>
<?php if ($error): ?><p class="error" role="alert"><?= enquiry_escape($error) ?><?php if ($id > 0): ?> <a href="enquiries.php?id=<?= $id ?>">Reload current record</a> before saving again. Copy your draft first.<?php endif; ?></p><?php endif; ?>
<?php if (isset($_GET['saved']) && !$error): ?><p class="meta" role="status">Changes saved.</p><?php endif; ?>
<?php if ($detail): ?>
<section class="editor" aria-labelledby="enquiry-contact">
<h2 id="enquiry-contact">Contact and enquiry</h2>
<dl>
<dt>Name</dt><dd><?= enquiry_escape($detail['name']) ?></dd>
<dt>Email</dt><dd><?= enquiry_escape($detail['email']) ?></dd>
<dt>Type</dt><dd><?= enquiry_escape($detail['type']) ?></dd>
<dt>Received</dt><dd><?= enquiry_escape($detail['created_at']) ?></dd>
<dt>Consent recorded</dt><dd><?= enquiry_escape($detail['consent_at']) ?> (<?= enquiry_escape($detail['consent_version']) ?>)</dd>
</dl>
<p><?= nl2br(enquiry_escape($detail['message'])) ?></p>
</section>
<form method="post" action="enquiries.php" class="editor">
<input type="hidden" name="csrf_token" value="<?= enquiry_escape($csrf) ?>">
<input type="hidden" name="id" value="<?= (int)$detail['id'] ?>">
<input type="hidden" name="version" value="<?= enquiry_escape($values['version']) ?>">
<h2>Private follow-up</h2>
<div class="editor-grid">
<label class="field">Status<select name="status" required><?php foreach (ENQUIRY_STATUSES as $status): ?><option value="<?= $status ?>"<?= $values['status'] === $status ? ' selected' : '' ?>><?= ucfirst($status) ?></option><?php endforeach; ?></select></label>
<label class="field">Follow-up date (UTC)<input type="date" name="follow_up_date" value="<?= enquiry_escape($values['follow_up_date']) ?>"></label>
<label class="field field-wide">Next action<input type="text" name="next_action" maxlength="255" value="<?= enquiry_escape($values['next_action']) ?>"></label>
<label class="field field-wide">Notes (private)<textarea name="notes" rows="8" maxlength="10000"><?= enquiry_escape($values['notes']) ?></textarea></label>
</div>
<div class="editor-actions"><button class="btn-primary" type="submit">Save changes</button><span class="muted">Updated <?= enquiry_escape($detail['updated_at']) ?> · version <?= (int)$detail['version'] ?></span></div>
</form>
<section class="panel" aria-labelledby="mail-title">
<h2 id="mail-title">Notification outbox</h2>
<p class="meta">“Sent” means the local mail transport accepted the message, not confirmed inbox delivery. Pending and failed messages do not affect the saved enquiry.</p>
<div class="table-wrap"><table class="data-table"><thead><tr><th>Outbox ID / kind</th><th>State</th><th>Attempts / lifetime</th><th>Next attempt / acceptance (UTC)</th><th>Failure</th></tr></thead><tbody>
<?php foreach ($detail['outbox'] as $mail): ?>
<tr><td><?= (int)$mail['id'] ?> / <?= enquiry_escape($mail['kind']) ?></td><td><span class="pill"><?= enquiry_escape($mail['status']) ?></span></td><td><?= (int)$mail['attempts'] ?> / <?= (int)$mail['total_attempts'] ?></td><td><?= enquiry_escape($mail['next_attempt_at'] ?? $mail['accepted_at'] ?? 'Manual review required') ?></td><td><?= enquiry_escape($mail['last_error'] ?? '—') ?></td></tr>
<?php endforeach; ?>
</tbody></table></div>
<p class="hint">The CLI worker retries definite failures up to five attempts. After correcting transport settings, retry one failed outbox ID with <code>php site/scripts/enquiry-worker.php --send --retry=ID</code>. For <code>acceptance_unknown</code>, inspect the transport first; add <code>--accept-duplicate-risk</code> only if willing to send a possible duplicate. No leads or outbox history are automatically deleted.</p>
</section>
<?php elseif ($list !== null): ?>
<form method="get" action="enquiries.php" class="editor">
<label class="field">Status<select name="status"><option value="">All statuses</option><?php foreach (ENQUIRY_STATUSES as $status): ?><option value="<?= $status ?>"<?= $filter === $status ? ' selected' : '' ?>><?= ucfirst($status) ?></option><?php endforeach; ?></select></label>
<div class="editor-actions"><button type="submit" class="btn-sm">Filter</button></div>
</form>
<div class="table-wrap"><table class="data-table"><thead><tr><th>Received (UTC)</th><th>Name / type</th><th>Status</th><th>Follow-up / next action</th><th>Owner / acknowledgement mail</th></tr></thead><tbody>
<?php if (!$list['rows']): ?><tr><td colspan="5">No enquiries on this page.</td></tr><?php endif; ?>
<?php foreach ($list['rows'] as $row): ?>
<tr><td><a href="enquiries.php?id=<?= (int)$row['id'] ?>"><?= enquiry_escape($row['created_at']) ?></a></td><td><?= enquiry_escape($row['name']) ?> / <?= enquiry_escape($row['type']) ?></td><td><?= enquiry_escape($row['status']) ?></td><td><?= enquiry_escape($row['follow_up_date'] ?? 'Not scheduled') ?> / <?= enquiry_escape($row['next_action']) ?></td><td><?= enquiry_escape($row['owner_mail'] ?? 'missing') ?> / <?= enquiry_escape($row['ack_mail'] ?? 'missing') ?></td></tr>
<?php endforeach; ?>
</tbody></table></div>
<nav class="editor-actions" aria-label="Enquiry pages">
<?php if ($page > 1): ?><a class="btn-sm" href="enquiries.php?page=<?= $page - 1 ?>&amp;status=<?= rawurlencode($filter) ?>">Previous</a><?php endif; ?>
<span class="meta">Page <?= $page ?> · up to 25 enquiries per page</span>
<?php if ($list['has_more']): ?><a class="btn-sm" href="enquiries.php?page=<?= $page + 1 ?>&amp;status=<?= rawurlencode($filter) ?>">Next</a><?php endif; ?>
</nav>
<?php endif; ?>
</main></body></html>
