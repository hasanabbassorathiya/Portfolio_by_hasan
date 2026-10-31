/**
 * Post-deploy verification: collections linked, rows prefilled, write path works,
 * and the original value is restored.
 *
 * Usage:
 *   DIRECTUS_URL=https://cms.hasanabbassorathiya.tech \
 *   DIRECTUS_TOKEN=<admin static token> \
 *   node scripts/verify.mjs
 */
const API = (process.env.DIRECTUS_URL || 'http://127.0.0.1:8055').replace(/\/+$/, '');
const TOKEN = process.env.DIRECTUS_TOKEN;
const required = ['apps', 'clients', 'posts', 'projects', 'experiences', 'skills', 'testimonials', 'profile', 'settings'];

if (!TOKEN) {
  console.error('DIRECTUS_TOKEN is required.');
  process.exit(1);
}

async function api(path, init = {}) {
  const response = await fetch(`${API}${path}`, {
    ...init,
    headers: { Authorization: `Bearer ${TOKEN}`, 'Content-Type': 'application/json', ...(init.headers || {}) },
  });
  const text = await response.text();
  if (!response.ok) throw new Error(`${init.method || 'GET'} ${path} -> ${response.status}: ${text.slice(0, 300)}`);
  return text ? JSON.parse(text) : null;
}

let failures = 0;
function check(label, ok, detail = '') {
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${label}${detail ? ` — ${detail}` : ''}`);
  if (!ok) failures += 1;
}

const me = await api('/users/me?fields=email');
check('authenticated', true, me.data.email);

const collections = new Set((await api('/collections?limit=-1')).data.map((item) => item.collection));
for (const name of required) check(`collection ${name}`, collections.has(name));

const apps = (await api('/items/apps?limit=20&fields=id,name,tagline&sort=sort_order')).data;
check('apps listed', apps.length > 0, `${apps.length} rows`);

if (apps.length > 0) {
  const first = apps[0];
  const full = (await api(`/items/apps/${first.id}`)).data;
  const columns = Object.keys(full).length;
  const filled = Object.entries(full).filter(([, value]) => value !== null && value !== '' && value !== undefined).length;
  check('item prefilled', filled >= 10, `${filled}/${columns} columns have values`);

  check('utf-8 intact', !/â€|Ã/.test(String(full.tagline || '')), `tagline: ${String(full.tagline).slice(0, 60)}`);

  const probe = `verify-${Date.now()}`;
  await api(`/items/apps/${first.id}`, { method: 'PATCH', body: JSON.stringify({ tagline: probe }) });
  const written = (await api(`/items/apps/${first.id}?fields=tagline`)).data.tagline;
  check('write round-trip', written === probe);

  await api(`/items/apps/${first.id}`, { method: 'PATCH', body: JSON.stringify({ tagline: first.tagline }) });
  const restored = (await api(`/items/apps/${first.id}?fields=tagline`)).data.tagline;
  check('original restored', restored === first.tagline);
}

console.log(failures === 0 ? '\nAll checks passed.' : `\n${failures} check(s) failed.`);
process.exit(failures === 0 ? 0 : 1);
