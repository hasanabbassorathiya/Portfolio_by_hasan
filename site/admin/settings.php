<?php
declare(strict_types=1);
require __DIR__ . '/guard.php';

function h($value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

$csrf = admin_csrf_token();
$pdo = db();
$ready = true;
$notice = null;
$error = null;

$fields = [
    'ga4_id' => ['label' => 'GA4 measurement ID', 'group' => 'analytics', 'type' => 'text', 'placeholder' => 'G-XXXXXXXXXX', 'help' => 'Runtime setting. Takes effect on next page load, no rebuild.'],
    'gsc_verification' => ['label' => 'Search Console verification token', 'group' => 'search', 'type' => 'text', 'placeholder' => 'google-site-verification value', 'help' => 'Compiled at build time from GSC_VERIFICATION env var.'],
    'indexnow_key' => ['label' => 'IndexNow key', 'group' => 'search', 'type' => 'text', 'placeholder' => '64 hex characters', 'help' => 'Serves /<key>.txt and submits sitemap to IndexNow.'],
    'calcom_url' => ['label' => 'Cal.com booking URL', 'group' => 'booking', 'type' => 'url', 'placeholder' => 'https://cal.com/…', 'help' => 'Booking CTA appears when set.'],
    'discord_invite' => ['label' => 'Discord invite URL', 'group' => 'community', 'type' => 'url', 'placeholder' => 'https://discord.gg/…', 'help' => 'Powers the community page.'],
    'community_enabled' => ['label' => 'Community page', 'group' => 'community', 'type' => 'select', 'options' => ['1' => 'Enabled', '0' => 'Hidden'], 'help' => 'Hidden removes from nav and sitemaps.'],
    'announcement' => ['label' => 'Site announcement', 'group' => 'site', 'type' => 'text', 'placeholder' => 'Optional one-line banner', 'help' => 'Shown above header when set.'],
    'default_og_image' => ['label' => 'Default share image path', 'group' => 'site', 'type' => 'text', 'placeholder' => '/og.png', 'help' => 'Fallback for pages without images.'],
    'contact_email' => ['label' => 'Public contact email', 'group' => 'site', 'type' => 'text', 'placeholder' => 'you@example.com', 'help' => 'Displayed by community page.'],
    'linkedin_url' => ['label' => 'LinkedIn', 'group' => 'social', 'type' => 'url'],
    'github_url' => ['label' => 'GitHub', 'group' => 'social', 'type' => 'url'],
    'x_url' => ['label' => 'X / Twitter', 'group' => 'social', 'type' => 'url'],
    'instagram_url' => ['label' => 'Instagram', 'group' => 'social', 'type' => 'url'],
    'play_dev_url' => ['label' => 'Google Play dev page', 'group' => 'social', 'type' => 'url'],
    'appstore_dev_url' => ['label' => 'App Store dev page', 'group' => 'social', 'type' => 'url'],
];

$groups = [
    'analytics' => 'Analytics',
    'search' => 'Search &amp; indexing',
    'booking' => 'Booking',
    'community' => 'Community',
    'social' => 'Social profiles',
    'site' => 'Site',
];

$values = [];
try {
    foreach ($pdo->query('SELECT k, v FROM settings')->fetchAll() as $row) {
        $values[$row['k']] = (string)$row['v'];
    }
} catch (Throwable $e) {
    $ready = false;
    $error = 'Settings table missing. Run v2-schema.sql in phpMyAdmin.';
}

if ($ready && ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    if (!hash_equals($csrf, (string)($_POST['csrf'] ?? ''))) {
        http_response_code(403);
        $error = 'Session expired. Reload and try again.';
    } else {
        $updates = [];
        $problems = [];
        foreach ($fields as $key => $field) {
            if (!array_key_exists($key, $_POST)) continue;
            $value = trim((string)$_POST[$key]);
            if (strlen($value) > 600) {
                $problems[] = h($field['label']) . ' is too long.';
                continue;
            }
            if ($field['type'] === 'select') {
                if (!isset($field['options'][$value])) continue;
            } elseif ($field['type'] === 'url') {
                if ($value !== '' && (filter_var($value, FILTER_VALIDATE_URL) === false || !str_starts_with($value, 'https://'))) {
                    $problems[] = h($field['label']) . ' must be an https URL.';
                    continue;
                }
            } elseif ($key === 'ga4_id') {
                if ($value !== '' && preg_match('/\AG-[A-Z0-9]{4,20}\z/', $value) !== 1) {
                    $problems[] = 'GA4 ID must look like G-XXXXXXXXXX.';
                    continue;
                }
            } elseif ($key === 'indexnow_key') {
                if ($value !== '' && preg_match('/\A[a-f0-9]{8,128}\z/', $value) !== 1) {
                    $problems[] = 'IndexNow key must be 8-128 lowercase hex.';
                    continue;
                }
            } elseif ($key === 'gsc_verification') {
                if ($value !== '' && preg_match('/\A[A-Za-z0-9_\-]{10,120}\z/', $value) !== 1) {
                    $problems[] = 'Search Console token has unexpected characters.';
                    continue;
                }
            } elseif ($key === 'contact_email') {
                if ($value !== '' && filter_var($value, FILTER_VALIDATE_EMAIL) === false) {
                    $problems[] = 'Contact email is not a valid address.';
                    continue;
                }
            }
            $updates[$key] = $value;
        }

        if ($problems) {
            $error = implode(' ', $problems);
        } else {
            $stmt = $pdo->prepare('INSERT INTO settings (k, v, is_public) VALUES (?, ?, 1)
                ON DUPLICATE KEY UPDATE v = VALUES(v)');
            foreach ($updates as $key => $value) {
                $stmt->execute([$key, $value]);
                $values[$key] = $value;
            }
            $notice = 'Settings saved. ' . count($updates) . ' value' . (count($updates) === 1 ? '' : 's') . ' written.';
        }
    }
}

$field = function (string $key) use ($fields, $values): string {
    $config = $fields[$key];
    $value = $values[$key] ?? '';
    $label = h($config['label']);
    $help = isset($config['help']) ? '<span class="field-help">' . $config['help'] . '</span>' : '';
    $id = 'set-' . $key;
    if ($config['type'] === 'select') {
        $options = '';
        foreach ($config['options'] as $optionValue => $optionLabel) {
            $options .= '<option value="' . h($optionValue) . '"' . ((string)$optionValue === $value ? ' selected' : '') . '>' . h($optionLabel) . '</option>';
        }
        return '<label class="field"><span>' . $label . '</span><select id="' . $id . '" name="' . $key . '">' . $options . '</select>' . $help . '</label>';
    }
    return '<label class="field"><span>' . $label . '</span>'
        . '<input id="' . $id . '" type="text" name="' . $key . '" value="' . h($value) . '"'
        . (isset($config['placeholder']) ? ' placeholder="' . h($config['placeholder']) . '"' : '')
        . '>' . $help . '</label>';
};

$siteOrigin = (is_https() ? 'https' : 'http') . '://' . ($_SERVER['HTTP_HOST'] ?? 'hasanabbassorathiya.tech');
?><!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex,nofollow">
<title>Settings — Portfolio CMS</title><link rel="stylesheet" href="admin.css"></head>
<body>
<nav class="topbar"><a href="dashboard.php" class="back">&larr; Dashboard</a><span class="logo">Settings</span></nav>

<main class="settings-page">
  <header class="page-head">
    <div>
      <h1>Settings</h1>
      <p class="meta">Platform IDs and links. Database credentials stay in <code>api/config.php</code>. Nothing here is a secret.</p>
    </div>
  </header>

  <?php if ($notice): ?><div class="notice"><strong>Saved.</strong> <?= h($notice) ?></div><?php endif; ?>
  <?php if ($error): ?><p class="error"><?= h($error) ?></p><?php endif; ?>

  <form method="post" action="settings.php">
    <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
    
    <?php foreach ($groups as $groupKey => $groupLabel): ?>
      <section class="settings-group"<?= $groupKey === 'community' ? ' id="community"' : '' ?>>
        <h2><?= h($groupLabel) ?></h2>
        <?php foreach ($fields as $key => $config): ?>
          <?php if ($config['group'] !== $groupKey) continue; ?>
          <?= $field($key) ?>
        <?php endforeach; ?>

        <?php if ($groupKey === 'search'): ?>
          <div class="settings-actions">
            <button class="btn-sm" type="button" id="indexnow-btn">Submit sitemap to IndexNow</button>
            <span class="muted" id="indexnow-result"></span>
          </div>
          <p class="field-help">
            Search Console verification compiled at build time. Set <code>GSC_VERIFICATION</code> in your deployment and rebuild.
          </p>
        <?php endif; ?>
      </section>
    <?php endforeach; ?>

    <div class="settings-actions">
      <button class="btn-primary" type="submit">Save settings</button>
      <span class="muted">Changes apply to live site. Search Console requires rebuild.</span>
    </div>
  </form>

  <section class="settings-group" id="utm">
    <h2>UTM campaign builder</h2>
    <p class="field-help">Compose tagged links for analytics tracking.</p>
    <div class="editor-grid">
      <label class="field"><span>Path</span><input id="utm-path" type="text" value="/" placeholder="/services"></label>
      <label class="field"><span>Source</span><input id="utm-source" type="text" placeholder="linkedin"></label>
      <label class="field"><span>Medium</span><input id="utm-medium" type="text" placeholder="social"></label>
      <label class="field"><span>Campaign</span><input id="utm-campaign" type="text" placeholder="senior-flutter-roles"></label>
    </div>
    <div class="copy-row">
      <input id="utm-output" type="text" readonly value="<?= h($siteOrigin) ?>/">
      <button class="btn-sm" type="button" id="utm-copy">Copy</button>
    </div>
    <p class="field-help" id="utm-note" style="margin-top:.5rem"></p>
  </section>
</main>

<script>
const CSRF = <?= json_encode($csrf) ?>;

document.getElementById('indexnow-btn')?.addEventListener('click', async (event) => {
  const button = event.currentTarget;
  const result = document.getElementById('indexnow-result');
  button.disabled = true;
  result.textContent = 'Submitting...';
  try {
    const res = await fetch('../api/indexnow.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': CSRF },
      body: '{}',
    });
    const data = await res.json().catch(() => ({}));
    if (res.ok) {
      result.textContent = 'Submitted ' + data.submitted + ' URLs · HTTP ' + data.status;
    } else {
      result.textContent = data.detail || data.error || 'Submission failed.';
    }
  } catch {
    result.textContent = 'Network error — try again.';
  }
  button.disabled = false;
});

const utmInputs = ['path', 'source', 'medium', 'campaign'].map((key) => document.getElementById('utm-' + key));
const utmOutput = document.getElementById('utm-output');

function buildUtm() {
  const [path, source, medium, campaign] = utmInputs.map((input) => input.value.trim());
  const url = new URL(path || '/', <?= json_encode($siteOrigin) ?> + '/');
  if (source) url.searchParams.set('utm_source', source);
  if (medium) url.searchParams.set('utm_medium', medium);
  if (campaign) url.searchParams.set('utm_campaign', campaign);
  utmOutput.value = url.toString();
}

utmInputs?.forEach((input) => input?.addEventListener('input', buildUtm));

document.getElementById('utm-copy')?.addEventListener('click', async () => {
  try {
    await navigator.clipboard.writeText(utmOutput.value);
    document.getElementById('utm-note').textContent = 'Copied.';
  } catch {
    utmOutput.select();
    document.getElementById('utm-note').textContent = 'Select and copy manually.';
  }
});

buildUtm();
</script>
</body>
</html>
