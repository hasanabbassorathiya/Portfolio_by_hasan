import assert from 'node:assert/strict';
import { before, after, test } from 'node:test';
import { fileURLToPath } from 'node:url';
import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { createServer } from 'vite';
import { chromium } from 'playwright-core';

// Real Contact + browser + fetch; only HTTP transport is mocked. No backend integration.
// Run: node --test site/scripts/contact-enquiry.test.mjs (local Vite must use port 5173).
const base = 'http://127.0.0.1:5173';
const reference = '0123456789abcdef0123456789abcdef';
const details = {
  name: 'Enquiry Test', email: 'enquiry@example.test', type: 'New application',
  message: 'Please help build an accessible mobile application.', website: '', consent: true,
};
const types = ['Employment', 'New application', 'Existing improvement', 'AI integration', 'Technical consultation', 'Other'];
let browser;
before(async () => { browser = await chromium.launch({ channel: 'chrome', headless: true }); });
after(async () => { await browser?.close(); });

const reply = (route, status, body) => route.fulfill({ status, contentType: 'application/json', body: JSON.stringify(body) });
const success = (route) => reply(route, 201, { ok: true, reference });

async function contact(t, respond = success, width = 1440) {
  const page = await browser.newPage({ viewport: { width, height: 1000 }, reducedMotion: 'reduce', serviceWorkers: 'block' });
  page.setDefaultTimeout(4000);
  const requests = [];
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  t.after(async () => {
    await page.close();
    assert.deepEqual(errors, [], 'No uncaught browser errors');
  });
  await page.addInitScript(() => {
    const fetch = window.fetch.bind(window);
    window.__enquirySignals = [];
    window.fetch = (input, options) => {
      if (String(input).includes('/api/enquiries.php')) window.__enquirySignals.push(options?.signal);
      return fetch(input, options);
    };
  });
  await page.route('**/*', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    if (url.origin !== base) return route.abort(); // Never send analytics or external traffic.
    if (url.pathname === '/api/enquiries.php') {
      requests.push({ method: request.method(), headers: request.headers(), body: request.postDataJSON(), raw: request.postData() });
      return respond(route, requests.length);
    }
    if (url.pathname.startsWith('/api/')) return reply(route, 200, { data: [] });
    if (url.pathname === '/src/lib/analytics.js') {
      // Enable the real analytics module only in this isolated browser, without config edits.
      const response = await route.fetch();
      return route.fulfill({ response, body: (await response.text()).replace('import.meta.env.VITE_GA4_ID', '"G-LOCALTEST"') });
    }
    return route.continue();
  });
  await page.goto(base);
  await page.locator('#contact-name').waitFor();
  return { page, form: page.locator('#contact form'), requests };
}

async function fill(page, values = {}) {
  const value = { ...details, ...values };
  await page.getByLabel('Name', { exact: true }).fill(value.name);
  await page.locator('#contact-email').fill(value.email);
  await page.getByLabel('What do you need?', { exact: true }).selectOption(value.type);
  await page.getByLabel('Project', { exact: true }).fill(value.message);
  await page.locator('#contact-consent').setChecked(value.consent);
}

async function submit(form) {
  await form.getByRole('button', { name: 'Send message', exact: true }).click();
}

async function formEvents(page) {
  return page.evaluate(() => (window.dataLayer || []).map((args) => Array.from(args))
    .filter(([kind, event]) => kind === 'event' && event === 'enquiry_submit'));
}

async function retained(page) {
  assert.equal(await page.locator('#contact-name').inputValue(), details.name);
  assert.equal(await page.locator('#contact-email').inputValue(), details.email);
  assert.equal(await page.locator('#contact-message').inputValue(), details.message);
  assert.ok(await page.locator('#contact-consent').isChecked());
}

test('consent, privacy and input constraints are accessible; honeypot is not focusable', async (t) => {
  const { page, form, requests } = await contact(t);
  const consent = form.getByRole('checkbox', { name: /agree/i });
  assert.equal(await consent.count(), 1, 'Consent is required before private storage');
  assert.equal(await consent.getAttribute('required'), '');
  assert.equal(await consent.isChecked(), false);
  const explanation = await consent.getAttribute('aria-describedby');
  assert.ok(explanation);
  assert.match(await page.locator(`#${explanation}`).innerText(), /privately.*respond/i);
  assert.match(await form.innerText(), /no marketing/i);
  assert.doesNotMatch(await page.locator('#contact').innerText(), /within 24 hours|nothing is stored|opens your email app/i);
  assert.deepEqual(await form.locator('select option').allTextContents(), types);
  for (const [id, max] of [['name', 120], ['email', 190], ['message', 10000]]) {
    assert.equal(await page.locator(`#contact-${id}`).getAttribute('maxlength'), String(max));
  }
  assert.equal(await page.locator('#contact-message').getAttribute('minlength'), '20');
  const honeypot = form.locator('[name="website"]');
  assert.equal(await honeypot.count(), 1);
  assert.equal(await honeypot.getAttribute('tabindex'), '-1');
  assert.equal(await honeypot.evaluate((node) => !!node.closest('[aria-hidden="true"]')), true);
  await honeypot.evaluate((node) => node.focus());
  assert.equal(await honeypot.evaluate((node) => document.activeElement === node), false);
  const email = page.locator('#contact').getByRole('link', { name: 'Email me', exact: true });
  assert.equal(await email.getAttribute('href'), 'mailto:hasanabbassorathiya12@gmail.com');
  await fill(page, { consent: false });
  await submit(form);
  assert.equal(await consent.evaluate((node) => node.validity.valueMissing), true);
  assert.equal(requests.length, 0);
  await consent.check();
  await page.locator('#contact-email').fill('invalid');
  await submit(form);
  assert.equal(requests.length, 0);
  await page.locator('#contact-email').fill(details.email);
  await page.locator('#contact-message').fill('Too short');
  await submit(form);
  assert.equal(requests.length, 0);
  await page.locator('#contact-message').fill('                    ');
  await submit(form);
  assert.equal(requests.length, 0, 'Whitespace is not a valid project');
  await page.locator('#contact-message').fill(details.message);
  await page.locator('#contact-name').fill('   ');
  await submit(form);
  assert.equal(requests.length, 0, 'Whitespace is not a valid name');
});

test('201 durable success posts the exact contract and records success only after confirmation', async (t) => {
  const { page, form, requests } = await contact(t);
  await fill(page);
  await page.clock.install();
  await submit(form);
  await form.getByRole('status').filter({ hasText: reference }).waitFor();
  assert.equal(requests.length, 1);
  assert.equal(requests[0].method, 'POST');
  assert.match(requests[0].headers['content-type'], /^application\/json/);
  const { requestId, ...payload } = requests[0].body;
  assert.deepEqual(payload, details);
  assert.match(requestId, /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i);
  assert.match(await form.getByRole('status').innerText(), /saved/i);
  assert.doesNotMatch(await form.getByRole('status').innerText(), /inbox|delivered|24 hours/i);
  const events = await formEvents(page);
  assert.equal(events.length, 1);
  assert.deepEqual(events[0][2], { type: 'New application', category: 'project' });
  assert.doesNotMatch(JSON.stringify(events[0][2]), /Enquiry Test|enquiry@example/i, 'No personal data in telemetry');
  await page.clock.fastForward(16000);
  assert.equal(await page.evaluate(() => window.__enquirySignals[0].aborted), false, 'Success clears its timeout');
});

for (const [type, category] of [
  ['Employment', 'recruitment'],
  ['Technical consultation', 'consulting'],
]) {
  test(`${type} enquiries are measured separately from client project work`, async (t) => {
    const { page, form } = await contact(t);
    await fill(page, { type });
    await submit(form);
    await form.getByRole('status').filter({ hasText: reference }).waitFor();
    const events = await formEvents(page);
    assert.equal(events.length, 1);
    assert.deepEqual(events[0][2], { type, category });
  });
}

test('pending disables every field and synchronously guards duplicate submissions', async (t) => {
  let release;
  const held = new Promise((resolve) => { release = resolve; });
  const { page, form, requests } = await contact(t, async (route) => { await held; await success(route); });
  await fill(page);
  await submit(form);
  await form.getByRole('button', { name: /sending/i }).waitFor();
  assert.equal(await form.getAttribute('aria-busy'), 'true');
  assert.equal(await form.locator('input:enabled, select:enabled, textarea:enabled, button:enabled').count(), 0);
  assert.match(await form.getByRole('status').innerText(), /sending/i);
  await form.evaluate((node) => {
    node.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
    node.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
  });
  assert.equal(requests.length, 1);
  assert.equal((await formEvents(page)).length, 0);
  release();
  await form.getByRole('status').filter({ hasText: reference }).waitFor();
  assert.equal(await form.getAttribute('aria-busy'), 'false');
});

for (const [status, code, message] of [
  [422, 'validation_failed', /check|review/i],
  [500, 'internal_error', /confirm|unavailable/i],
  [429, 'rate_limited', /too many|wait/i],
  [503, 'unavailable', /unavailable|confirm/i],
  [409, 'conflict', /conflict|already used/i],
]) {
  test(`${status} ${code}: accessible error preserves details and never signals success`, async (t) => {
    const { page, form, requests } = await contact(t, (route) => reply(route, status, { ok: false, error: code }));
    await fill(page);
    await submit(form);
    await form.getByRole('alert').waitFor();
    assert.match(await form.getByRole('alert').innerText(), message);
    await retained(page);
    assert.equal(await form.getByRole('button', { name: 'Send message', exact: true }).isEnabled(), true);
    assert.equal(await form.getByRole('status').filter({ hasText: /saved/i }).count(), 0);
    assert.equal((await formEvents(page)).length, 0);
    assert.equal(requests.length, 1);
  });
}

for (const [label, status, body] of [
  ['200 instead of 201', 200, { ok: true, reference }],
  ['missing reference', 201, { ok: true }],
  ['non-hex reference', 201, { ok: true, reference: 'z'.repeat(32) }],
  ['non-string reference', 201, { ok: true, reference: 123 }],
  ['truthy ok', 201, { ok: 'true', reference }],
  ['false ok', 201, { ok: false, reference }],
  ['null JSON', 201, null],
]) {
  test(`rejects invalid success: ${label}`, async (t) => {
    const { page, form } = await contact(t, (route) => reply(route, status, body));
    await fill(page);
    await submit(form);
    await form.getByRole('alert').waitFor();
    await retained(page);
    assert.equal((await formEvents(page)).length, 0);
  });
}

test('malformed response never confirms success', async (t) => {
  const { page, form } = await contact(t, (route) => route.fulfill({ status: 201, contentType: 'application/json', body: '<html>broken</html>' }));
  await fill(page);
  await submit(form);
  await form.getByRole('alert').waitFor();
  await retained(page);
  assert.equal((await formEvents(page)).length, 0);
});

test('network loss permits only manual retry with the identical request ID and payload', async (t) => {
  const { page, form, requests } = await contact(t, (route, count) => count === 1 ? route.abort('failed') : success(route));
  await fill(page);
  await page.clock.install();
  await submit(form);
  await form.getByRole('alert').waitFor();
  await retained(page);
  assert.match(await form.getByRole('alert').innerText(), /confirm/i);
  assert.equal((await formEvents(page)).length, 0);
  await page.clock.fastForward(60000);
  assert.equal(requests.length, 1, 'No automatic retry');
  await submit(form);
  await form.getByRole('status').filter({ hasText: reference }).waitFor();
  assert.equal(requests.length, 2);
  assert.equal(requests[1].raw, requests[0].raw, 'Retry reuses the entire serialized attempt');
  assert.equal((await formEvents(page)).length, 1);
});

test('editing after a failed attempt clears the error and uses a new request ID', async (t) => {
  const { page, form, requests } = await contact(t, (route, count) => count === 1 ? route.abort('failed') : success(route));
  await fill(page);
  await submit(form);
  await form.getByRole('alert').waitFor();
  const changed = `${details.message} We also need a web app.`;
  await page.locator('#contact-message').fill(changed);
  assert.equal(await form.getByRole('alert').count(), 0);
  await submit(form);
  await form.getByRole('status').filter({ hasText: reference }).waitFor();
  assert.notEqual(requests[1].body.requestId, requests[0].body.requestId);
  assert.equal(requests[1].body.message, changed);
});

test('all supported project types are sent unchanged', async (t) => {
  const { page, form, requests } = await contact(t, (route) => reply(route, 422, { ok: false, error: 'validation_failed' }));
  for (const type of types) {
    await fill(page, { type });
    await submit(form);
    await form.getByRole('alert').waitFor();
    assert.equal(requests.at(-1).body.type, type);
  }
  assert.equal(new Set(requests.map(({ body }) => body.requestId)).size, types.length);
});

test('timeout aborts the request, retains details and reuses the same attempt on manual retry', async (t) => {
  const { page, form, requests } = await contact(t, (route, count) => count === 1 ? undefined : success(route));
  await fill(page);
  await page.clock.install();
  await submit(form);
  await page.waitForFunction(() => window.__enquirySignals.length === 1);
  await page.clock.fastForward(15001);
  await form.getByRole('alert').waitFor();
  assert.match(await form.getByRole('alert').innerText(), /timed out/i);
  assert.equal(await page.evaluate(() => window.__enquirySignals[0].aborted), true);
  await retained(page);
  await submit(form);
  await form.getByRole('status').filter({ hasText: reference }).waitFor();
  assert.equal(requests[1].raw, requests[0].raw);
});

test('leaving Contact aborts pending work without analytics or an automatic retry', async (t) => {
  const { page, form, requests } = await contact(t, () => undefined);
  await fill(page);
  await page.clock.install();
  await submit(form);
  await page.locator('#writing').getByRole('link', { name: /all essays/i }).click();
  await page.waitForFunction(() => !document.getElementById('contact'));
  assert.equal(await page.evaluate(() => window.__enquirySignals[0].aborted), true);
  await page.clock.fastForward(60000);
  assert.equal((await formEvents(page)).length, 0);
  assert.equal(requests.length, 1);
});

for (const width of [320, 390, 1440]) {
  test(`${width}px preserves the email CTA and keeps the consent/form within the viewport`, async (t) => {
    const { page, form } = await contact(t, success, width);
    assert.ok(await page.locator('#contact').getByRole('link', { name: 'Email me', exact: true }).isVisible());
    await fill(page);
    await submit(form);
    await form.getByRole('status').filter({ hasText: reference }).waitFor();
    assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
    const box = await form.boundingBox();
    assert.ok(box && box.x >= 0 && box.x + box.width <= width);
  });
}

test('Contact renders on the server without window/document or creating a request UUID', async (t) => {
  const server = await createServer({
    root: fileURLToPath(new URL('../', import.meta.url)), configFile: false, envFile: false,
    server: { middlewareMode: true, hmr: false, watch: null }, appType: 'custom', logLevel: 'silent',
  });
  t.after(() => server.close());
  const { Contact } = await server.ssrLoadModule('/src/sections/ref-about.jsx');
  const original = Object.getOwnPropertyDescriptor(globalThis, 'crypto');
  Object.defineProperty(globalThis, 'crypto', { configurable: true, get() { throw new Error('UUID creation during SSR'); } });
  try {
    const html = renderToStaticMarkup(React.createElement(Contact));
    assert.match(html, /id="contact-consent"/);
    assert.match(html, /mailto:hasanabbassorathiya12@gmail.com/);
    assert.match(html, />Send message</);
    assert.doesNotMatch(html, /aria-busy="true"|Enquiry saved/);
  } finally {
    if (original) Object.defineProperty(globalThis, 'crypto', original);
    else delete globalThis.crypto;
  }
});
