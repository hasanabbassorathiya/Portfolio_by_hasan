import assert from 'node:assert/strict';
import { before, after, test } from 'node:test';
import { chromium } from 'playwright-core';

const base = process.env.CMS_TEST_URL;
assert.equal(base, 'http://127.0.0.1:8097', 'Run through CMS_BROWSER_TEST=1 CMS_SMOKE_ALLOW=1 bash scripts/cms-smoke.sh');
const token = process.env.CMS_TEST_TOKEN;
const csrf = process.env.CMS_TEST_CSRF;
let browser;
before(async () => { browser = await chromium.launch({ channel: 'chrome', headless: true }); });
after(async () => { await browser?.close(); });

async function api(method, query, body) {
  const response = await fetch(`${base}/api/crud.php?${query}`, {
    method, headers: { 'X-Auth-Token': token, 'X-CSRF-Token': csrf, 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  assert.ok(response.ok, await response.clone().text());
  return response.json();
}

async function editorFor(t, width = 1280) {
  const context = await browser.newContext({ viewport: { width, height: 900 }, reducedMotion: 'reduce' });
  await context.addCookies([{ name: 'admin_token', value: token, url: base }]);
  await context.tracing.start({ screenshots: true, snapshots: true });
  const page = await context.newPage();
  page.setDefaultTimeout(5000);
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  t.after(async () => {
    await context.tracing.stop({ path: `${process.env.CMS_TEST_OUTPUT}/${t.name.replace(/\W+/g, '-')}.zip` });
    await context.close();
    assert.deepEqual(errors, [], 'No unhandled browser errors');
  });
  await page.goto(`${base}/admin/edit.php?entity=apps`);
  await page.getByRole('button', { name: '+ New App', exact: true }).click();
  return page;
}

async function requiredFields(page, slug) {
  await page.getByRole('textbox', { name: /^Slug/ }).fill(slug);
  await page.getByLabel('Name', { exact: true }).fill('Panel test app');
  await page.getByLabel('Tagline', { exact: true }).fill('Created without JSON');
}

async function save(page) {
  const slug = await page.getByRole('textbox', { name: /^Slug/ }).inputValue();
  const response = page.waitForResponse((r) => r.url().includes('/api/crud.php') && ['POST', 'PUT'].includes(r.request().method()));
  const reload = page.waitForEvent('domcontentloaded');
  await page.locator('#save-btn').click();
  assert.ok((await response).ok(), 'Save request succeeds');
  await reload;
  await page.locator('#page-status').filter({ hasText: /Record saved/ }).waitFor();
  const { data } = await api('GET', 'entity=apps');
  const row = data.find((item) => item.slug === slug);
  assert.ok(row, 'Saved row exists in the database');
  return row;
}

for (const width of [390, 1280]) {
  test(`${width}px: structured fields and screenshots round-trip without JSON`, async (t) => {
    const page = await editorFor(t, width);
    const slug = `panel-${width}-${Date.now()}`;
    await requiredFields(page, slug);
    const shots = page.getByRole('group', { name: 'Screenshots', exact: true });
    assert.equal(await shots.count(), 1, 'Screenshots must have an image-list editor, not a JSON textarea');
    assert.equal(await page.locator('textarea[data-json]:visible').count(), 0);
    const platforms = page.getByRole('group', { name: 'Platforms', exact: true });
    await platforms.getByRole('button', { name: 'Add item', exact: true }).click();
    await platforms.getByRole('textbox', { name: 'Item 1', exact: true }).fill('iOS');
    const metrics = page.getByRole('group', { name: 'Metrics', exact: true });
    await metrics.getByRole('button', { name: 'Add item', exact: true }).click();
    await metrics.getByRole('textbox', { name: 'Label 1', exact: true }).fill('4.9');
    await metrics.getByRole('textbox', { name: 'Value 1', exact: true }).fill('Test rating');
    const links = page.getByRole('group', { name: 'Store links', exact: true });
    await links.getByRole('button', { name: 'Add item', exact: true }).click();
    await links.getByRole('textbox', { name: 'Key 1', exact: true }).fill('ios');
    await links.getByRole('textbox', { name: 'Value 1', exact: true }).fill('https://example.test/app');
    const image = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==', 'base64');
    await shots.locator('input[type=file]').setInputFiles([
      { name: 'one.png', mimeType: 'image/png', buffer: image },
      { name: 'two.png', mimeType: 'image/png', buffer: image },
    ]);
    await shots.getByRole('textbox', { name: 'Image path 2', exact: true }).waitFor();
    const first = await shots.getByRole('textbox', { name: 'Image path 1', exact: true }).inputValue();
    const second = await shots.getByRole('textbox', { name: 'Image path 2', exact: true }).inputValue();
    assert.notEqual(first, second);
    await shots.getByRole('button', { name: 'Move item 2 up', exact: true }).click();
    assert.equal(await shots.getByRole('textbox', { name: 'Image path 1', exact: true }).inputValue(), second);
    assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'No horizontal page overflow');
    await shots.scrollIntoViewIfNeeded();
    await page.screenshot({ path: `${process.env.CMS_TEST_OUTPUT}/panel-${width}.png` });
    const { id } = await save(page);
    t.after(() => api('DELETE', `entity=apps&id=${id}`));
    const row = await api('GET', `entity=apps&id=${id}`);
    assert.deepEqual(JSON.parse(row.screenshots), [second, first]);
    assert.deepEqual(JSON.parse(row.platforms), ['iOS']);
    assert.deepEqual(JSON.parse(row.metrics), [['4.9', 'Test rating']]);
    assert.deepEqual(JSON.parse(row.links), { ios: 'https://example.test/app' });
    await page.getByRole('row').filter({ hasText: 'Panel test app' }).getByRole('button', { name: 'Edit', exact: true }).click();
    await shots.getByRole('textbox', { name: 'Image path 2', exact: true }).waitFor();
    assert.equal(await shots.getByRole('textbox', { name: 'Image path 1', exact: true }).inputValue(), second);
    await shots.getByRole('button', { name: 'Remove item 2', exact: true }).click();
    await shots.getByRole('button', { name: 'Remove item 1', exact: true }).click();
    await save(page);
    assert.deepEqual(JSON.parse((await api('GET', `entity=apps&id=${id}`)).screenshots), []);
  });
}

test('discard protection keeps edited text when cancelled', async (t) => {
  const page = await editorFor(t);
  await page.getByLabel('Name', { exact: true }).fill('Keep this work');
  let dialogs = 0;
  page.on('dialog', async (dialog) => { dialogs++; await dialog.dismiss(); });
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  assert.equal(dialogs, 1, 'Cancelling a dirty editor must ask before discarding');
  assert.equal(await page.locator('#editor').isVisible(), true);
  assert.equal(await page.getByLabel('Name', { exact: true }).inputValue(), 'Keep this work');
  await page.getByRole('button', { name: '+ New App', exact: true }).click();
  assert.equal(dialogs, 2);
  assert.equal(await page.getByLabel('Name', { exact: true }).inputValue(), 'Keep this work');
});

test('server validation focuses the field and preserves the draft', async (t) => {
  const page = await editorFor(t);
  await requiredFields(page, 'Invalid slug');
  const response = page.waitForResponse((r) => r.url().includes('/api/crud.php') && r.request().method() === 'POST');
  await page.locator('#save-btn').click();
  assert.equal((await response).status(), 422);
  await page.locator('#form-error').filter({ hasText: /lowercase/ }).waitFor();
  assert.equal(await page.getByRole('textbox', { name: /^Slug/ }).getAttribute('aria-invalid'), 'true');
  assert.equal(await page.getByRole('textbox', { name: /^Slug/ }).evaluate((el) => el === document.activeElement), true);
  assert.equal(await page.getByLabel('Name', { exact: true }).inputValue(), 'Panel test app');
  await page.getByRole('textbox', { name: /^Slug/ }).fill(`corrected-${Date.now()}`);
  const { id } = await save(page);
  t.after(() => api('DELETE', `entity=apps&id=${id}`));
});

test('empty object fields returned by PHP remain editable', async (t) => {
  const slug = `empty-links-${Date.now()}`;
  const { id } = await api('POST', 'entity=apps', { slug, name: 'Empty links app', tagline: 'Round trip', links: {}, published: 0 });
  t.after(() => api('DELETE', `entity=apps&id=${id}`));
  const stored = await api('GET', `entity=apps&id=${id}`);
  assert.equal(stored.links, '[]', 'PHP stores an empty decoded object as []');
  const page = await editorFor(t);
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  await page.getByRole('row').filter({ hasText: 'Empty links app' }).getByRole('button', { name: 'Edit', exact: true }).click();
  await page.waitForFunction(() => document.getElementById('editor-form').getAttribute('aria-busy') === 'false');
  assert.equal(await page.locator('#save-btn').isDisabled(), false, 'An empty PHP object must not block the editor');
  await page.getByLabel('Tagline', { exact: true }).fill('Still editable');
  const links = page.getByRole('group', { name: 'Store links', exact: true });
  await links.getByRole('button', { name: 'Add item', exact: true }).click();
  await links.getByRole('textbox', { name: 'Key 1', exact: true }).fill('ios');
  await links.getByRole('textbox', { name: 'Value 1', exact: true }).fill('https://example.test/app');
  await save(page);
  await page.getByRole('row').filter({ hasText: 'Empty links app' }).getByRole('button', { name: 'Edit', exact: true }).click();
  await links.getByRole('button', { name: 'Remove item 1', exact: true }).click();
  await save(page);
  await page.getByRole('row').filter({ hasText: 'Empty links app' }).getByRole('button', { name: 'Edit', exact: true }).click();
  await page.waitForFunction(() => document.getElementById('editor-form').getAttribute('aria-busy') === 'false');
  assert.equal(await page.locator('#save-btn').isDisabled(), false);
  assert.equal((await api('GET', `entity=apps&id=${id}`)).tagline, 'Still editable');
});

test('duplicate object keys are rejected without losing either value', async (t) => {
  const page = await editorFor(t);
  await requiredFields(page, `duplicates-${Date.now()}`);
  const links = page.getByRole('group', { name: 'Store links', exact: true });
  for (const n of [1, 2]) {
    await links.getByRole('button', { name: 'Add item', exact: true }).click();
    await links.getByRole('textbox', { name: `Key ${n}`, exact: true }).fill('ios');
    await links.getByRole('textbox', { name: `Value ${n}`, exact: true }).fill(`https://example.test/${n}`);
  }
  await page.locator('#save-btn').click();
  await page.locator('#form-error').filter({ hasText: /unique/ }).waitFor();
  assert.equal(await links.getByRole('textbox', { name: 'Value 2', exact: true }).inputValue(), 'https://example.test/2');
  await links.getByRole('textbox', { name: 'Key 2', exact: true }).fill('android');
  const { id } = await save(page);
  t.after(() => api('DELETE', `entity=apps&id=${id}`));
  assert.deepEqual(JSON.parse((await api('GET', `entity=apps&id=${id}`)).links), { ios: 'https://example.test/1', android: 'https://example.test/2' });
});

test('partial upload keeps successful images and blocks switching during upload', async (t) => {
  const page = await editorFor(t);
  await requiredFields(page, `upload-${Date.now()}`);
  const shots = page.getByRole('group', { name: 'Screenshots', exact: true });
  const entered = Promise.withResolvers();
  const release = Promise.withResolvers();
  await page.route('**/api/upload.php', async (route) => { entered.resolve(); await release.promise; await route.continue(); });
  const image = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==', 'base64');
  await shots.locator('input[type=file]').setInputFiles([
    { name: 'valid.png', mimeType: 'image/png', buffer: image },
    { name: 'invalid.png', mimeType: 'image/png', buffer: Buffer.from('not an image') },
  ]);
  await entered.promise;
  try {
    assert.equal(await page.locator('#save-btn').isDisabled(), true);
    await page.getByRole('button', { name: '+ New App', exact: true }).click();
    assert.equal(await page.getByLabel('Name', { exact: true }).inputValue(), 'Panel test app');
  } finally { release.resolve(); }
  await page.locator('#form-error').filter({ hasText: /invalid.png/ }).waitFor();
  assert.equal(await shots.getByRole('textbox').count(), 1);
  assert.equal(await page.locator('#save-btn').isDisabled(), false);
  const { id } = await save(page);
  t.after(() => api('DELETE', `entity=apps&id=${id}`));
  assert.equal(JSON.parse((await api('GET', `entity=apps&id=${id}`)).screenshots).length, 1);
});

test('stale load cannot overwrite a newly opened blank record', async (t) => {
  const page = await editorFor(t);
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  const entered = Promise.withResolvers();
  const release = Promise.withResolvers();
  await page.route('**/api/crud.php?*', async (route) => {
    const response = await route.fetch();
    entered.resolve();
    await release.promise;
    await route.fulfill({ response });
  });
  await page.getByRole('button', { name: 'Edit', exact: true }).first().click();
  await entered.promise;
  assert.equal(await page.locator('#save-btn').isDisabled(), true);
  await page.getByRole('button', { name: '+ New App', exact: true }).click();
  const response = page.waitForResponse((r) => r.url().includes('/api/crud.php'));
  release.resolve();
  await response;
  await page.evaluate(() => new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve))));
  assert.equal(await page.getByLabel('Name', { exact: true }).inputValue(), '');
  assert.equal(await page.locator('#save-btn').isDisabled(), false);
});

test('profile edits do not leak the previous key into a new field', async (t) => {
  const page = await editorFor(t);
  const original = `panel_old_${Date.now()}`;
  const next = `panel_new_${Date.now()}`;
  await api('POST', 'entity=profile', { k: original, v: 'Original value' });
  t.after(async () => {
    await api('DELETE', `entity=profile&k=${original}`);
    await api('DELETE', `entity=profile&k=${next}`);
  });
  await page.goto(`${base}/admin/edit.php?entity=profile`);
  await page.getByRole('row').filter({ hasText: original }).getByRole('button', { name: 'Edit', exact: true }).click();
  await page.getByRole('textbox', { name: /^Key/ }).filter({ visible: true }).waitFor();
  await page.waitForFunction(() => document.getElementById('editor-form').getAttribute('aria-busy') === 'false');
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  await page.getByRole('button', { name: '+ New Profile field', exact: true }).click();
  await page.getByRole('textbox', { name: /^Key/ }).fill(next);
  await page.getByRole('textbox', { name: /^Value/ }).fill('New value');
  const reload = page.waitForEvent('domcontentloaded');
  await page.locator('#save-btn').click();
  await reload;
  assert.equal((await api('GET', `entity=profile&k=${original}`)).v, 'Original value');
  assert.equal((await api('GET', `entity=profile&k=${next}`)).v, 'New value');
});

test('network failure while loading is handled without enabling save', async (t) => {
  const page = await editorFor(t);
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  await page.route('**/api/crud.php?*', (route) => route.abort());
  await page.getByRole('button', { name: 'Edit', exact: true }).first().click();
  await page.locator('#form-error').filter({ hasText: /load/i }).waitFor();
  assert.equal(await page.locator('#save-btn').isDisabled(), true);
});

test('failed record load cannot save an empty replacement', async (t) => {
  const page = await editorFor(t);
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  await page.route('**/api/crud.php?*', (route) => route.fulfill({ status: 404, json: { error: 'not found' } }));
  const firstEdit = page.getByRole('button', { name: 'Edit', exact: true }).first();
  await firstEdit.click();
  await page.locator('#form-error').filter({ hasText: /load/i }).waitFor();
  assert.equal(await page.locator('#save-btn').isDisabled(), true);
});
