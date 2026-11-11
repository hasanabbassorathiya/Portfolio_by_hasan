#!/usr/bin/env node
/**
 * Run the Postman collection against a real CMS API and report per-request results.
 *
 * This is a deliberate re-execution of the artefact, not a reimplementation of it:
 * each request's own pre-request and test scripts are evaluated in a `vm` sandbox
 * with a small `pm` shim, so a broken script or a bad example body fails here exactly
 * as it would fail in Postman.
 *
 * SAFETY: it refuses to run unless CMS_VERIFY_BASE names a loopback host. This script
 * sends POST/PUT/DELETE bodies, so pointing it at production would create real rows.
 *
 *   CMS_VERIFY_BASE=http://127.0.0.1:8123/api \
 *   CMS_VERIFY_SITE=http://127.0.0.1:8123 \
 *   CMS_VERIFY_EMAIL=… CMS_VERIFY_PASSWORD=… CMS_VERIFY_FILE=/tmp/probe.png \
 *     node scripts/verify-postman.mjs
 */
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import path from 'node:path';

const BASE = process.env.CMS_VERIFY_BASE ?? '';
const SITE = process.env.CMS_VERIFY_SITE ?? '';
const EMAIL = process.env.CMS_VERIFY_EMAIL ?? '';
const PASSWORD = process.env.CMS_VERIFY_PASSWORD ?? '';
const FILE = process.env.CMS_VERIFY_FILE ?? '';

const host = (() => { try { return new URL(BASE).hostname; } catch { return ''; } })();
if (!['127.0.0.1', 'localhost', '::1'].includes(host)) {
  console.error(`REFUSING TO RUN: CMS_VERIFY_BASE must be a loopback host.\n` +
    `  got: ${BASE || '(unset)'}\n` +
    `  This collection creates and deletes rows. Point it at the local harness, never the live site.`);
  process.exit(2);
}
if (!EMAIL || !PASSWORD) {
  console.error('REFUSING TO RUN: CMS_VERIFY_EMAIL and CMS_VERIFY_PASSWORD must be set (a local throwaway admin).');
  process.exit(2);
}

const COLLECTION = JSON.parse(readFileSync(
  new URL('../postman/portfolio-api.postman_collection.json', import.meta.url), 'utf8'));

// ------------------------------------------------------------------ pm shim

const typeOf = (v) => (Array.isArray(v) ? 'array' : v === null ? 'null' : typeof v);

function chain(target, label) {
  const fail = (msg) => { throw new Error(`${label}: ${msg}`); };
  const be = {
    an: (t) => { if (typeOf(target) !== t) fail(`expected type ${t}, got ${typeOf(target)}`); },
    a: (t) => be.an(t),
    get true() { if (target !== true) fail(`expected true, got ${JSON.stringify(target)}`); },
    get false() { if (target !== false) fail(`expected false, got ${JSON.stringify(target)}`); },
    get null() { if (target !== null) fail(`expected null, got ${JSON.stringify(target)}`); },
  };
  const have = {
    property: (name) => {
      if (target === null || target === undefined || !(name in Object(target))) {
        fail(`expected object to have property ${name}`);
      }
    },
    status: (code) => {
      const actual = target && typeof target === 'object' ? target.code : undefined;
      if (actual !== code) fail(`expected status ${code}, got ${actual}`);
    },
  };
  return {
    to: {
      eql: (exp) => {
        if (JSON.stringify(target) !== JSON.stringify(exp)) {
          fail(`expected ${JSON.stringify(exp)}, got ${JSON.stringify(target)}`);
        }
      },
      equal: (exp) => { if (target !== exp) fail(`expected ${JSON.stringify(exp)}, got ${JSON.stringify(target)}`); },
      match: (re) => { if (!re.test(String(target))) fail(`${JSON.stringify(target)} does not match ${re}`); },
      include: (x) => {
        if (Array.isArray(target)) { if (!target.includes(x)) fail(`[${target}] does not include ${JSON.stringify(x)}`); }
        else if (typeof target === 'string') { if (!target.includes(String(x))) fail(`"${target}" does not include "${x}"`); }
        else if (target && typeof target === 'object') { if (!(x in target)) fail(`object lacks key ${x}`); }
        else fail('value is not a container');
      },
      not: { include: (x) => { if (Array.isArray(target) ? target.includes(x) : String(target).includes(x)) fail(`unexpectedly includes ${x}`); } },
      be,
      have,
      deep: { eql: (exp) => chain(target, label).to.eql(exp) },
    },
  };
}

function runScripts(kind, events, ctx) {
  const found = (events || []).filter((e) => e.listen === kind);
  for (const e of found) {
    const source = (e.script?.exec || []).join('\n');
    const sandbox = {
      pm: ctx.pm,
      console: { log: (...a) => ctx.logs.push(a.join(' ')) },
      Date, Math, JSON, Object, Array, String, Number, RegExp, Error,
      atob: (s) => Buffer.from(s, 'base64').toString('binary'),
    };
    vm.createContext(sandbox);
    try {
      vm.runInContext(source, sandbox, { timeout: 2000 });
    } catch (err) {
      ctx.errors.push(`${kind} script threw: ${err.message}`);
    }
    ctx.assertions.push(...ctx.pending.splice(0).map(([name, fn]) => {
      try { fn(); return { name, ok: true }; } catch (err) { return { name, ok: false, why: err.message }; }
    }));
  }
}

// ------------------------------------------------------------------ variables

const collection = new Map();
for (const v of COLLECTION.variable || []) collection.set(v.key, v.value);
collection.set('baseUrl', BASE.replace(/\/$/, ''));
collection.set('siteUrl', SITE.replace(/\/$/, ''));
collection.set('adminEmail', EMAIL);
collection.set('adminPassword', PASSWORD);
let transaction = new Map();

const readVar = (k) => (transaction.has(k) ? transaction.get(k) : collection.has(k) ? collection.get(k) : undefined);

function sub(text) {
  if (typeof text !== 'string') return text;
  return text.replace(/\{\{(\$?[A-Za-z][A-Za-z0-9_]*)\}\}/g, (m, k) => {
    // `$guid` and friends are Postman's dynamic variables, generated per send.
    if (k === '$guid') return crypto.randomUUID();
    if (k === '$timestamp') return String(Math.floor(Date.now() / 1000));
    if (k === '$isoTimestamp') return new Date().toISOString();
    const v = readVar(k);
    return v === undefined ? m : String(v);
  });
}

// ------------------------------------------------------------------ cookie jar

const jar = new Map();
function stealCookies(response) {
  const raw = response.headers.getSetCookie ? response.headers.getSetCookie() : [];
  for (const line of raw) {
    const [pair] = line.split(';');
    const eq = pair.indexOf('=');
    if (eq > 0) jar.set(pair.slice(0, eq).trim(), pair.slice(eq + 1).trim());
  }
}
const cookieHeader = () => [...jar].map(([k, v]) => `${k}=${v}`).join('; ');

// ------------------------------------------------------------------ walker

const SKIP = ['SEO tools'];   // makes an outbound call to indexnow.org
const results = [];

function resolveUrl(url) {
  if (typeof url === 'string') return sub(url);
  let raw = url.raw ? sub(url.raw) : '';
  // `raw` already carries the enabled query; rebuild it so disabled params are honoured.
  const qs = (url.query || []).filter((q) => !q.disabled).map((q) => `${q.key}=${sub(q.value ?? '')}`);
  if (qs.length) raw = raw.split('?')[0] + '?' + qs.join('&');
  return raw;
}

async function dispatchRequest(spec, cb) {
  try {
    const url = typeof spec === 'string' ? sub(spec) : sub(spec?.url);
    const headers = {};
    const rawHeaders = Array.isArray(spec?.header) ? spec.header
      : Object.entries(spec?.header || {}).map(([key, value]) => ({ key, value }));
    for (const h of rawHeaders) if (h?.key) headers[h.key] = sub(h.value);
    const init = { method: spec?.method || 'GET', headers };
    if (spec?.body?.mode === 'raw') {
      init.body = sub(spec.body.raw);
      headers['Content-Type'] ??= 'application/json';
    }
    const res = await fetch(url, init);
    const text = await res.text();
    stealCookies(res);
    if (cb) cb(null, {
      code: res.status, status: res.status, statusText: res.statusText,
      headers: res.headers, text: () => text, json: () => JSON.parse(text),
    });
  } catch (err) {
    // Postman hands the error to the callback and keeps running; a rejected promise
    // here would abort the whole collection on one bad sub-request.
    if (cb) cb(err, null); else console.log(`    · sendRequest failed: ${err.message}`);
  }
}

async function send(item) {
  const r = item.request;

  // Phase order matches Postman: the pre-request script (and any pm.sendRequest it waits
  // on) runs first, because it is what sets the variables the URL and headers reference.
  transaction = new Map();
  const ctx = { pending: [], assertions: [], errors: [], logs: [], sends: [], pm: null };
  ctx.pm = makePm(ctx, null);
  runScripts('prerequest', item.event, ctx);
  await Promise.all(ctx.sends.splice(0));

  const url = resolveUrl(r.url);
  const headers = {};
  for (const h of r.header || []) {
    if (h.disabled) continue;
    if (/^content-type$/i.test(h.key) && r.body?.mode === 'formdata') continue; // let fetch set the boundary
    headers[h.key] = sub(h.value);
  }

  let init = { method: r.method, headers };
  if (r.body?.mode === 'raw') {
    init.body = sub(r.body.raw);
    headers['Content-Type'] ??= 'application/json';
  } else if (r.body?.mode === 'formdata') {
    const fd = new FormData();
    for (const f of r.body.formdata || []) {
      if (f.disabled) continue;
      if (f.type === 'file') {
        if (!FILE) { ctx.errors.push('formdata file field with no CMS_VERIFY_FILE set'); continue; }
        const buf = readFileSync(FILE);
        fd.append(f.key, new Blob([buf], { type: 'image/png' }), path.basename(FILE));
      } else {
        fd.append(f.key, sub(f.value ?? ''));
      }
    }
    init.body = fd;
    delete headers['Content-Type'];
  }

  let response, status, bodyText = '';
  const started = Date.now();
  try {
    response = await fetch(url, init);
    status = response.status;
    bodyText = await response.text();
    stealCookies(response);
  } catch (err) {
    results.push({ name: item.name, url, status: 'ERR', ok: false, why: err.message, logs: [], ms: Date.now() - started });
    return;
  }

  const json = () => JSON.parse(bodyText);
  // Postman chai-wraps pm.response, so `pm.response.to.have.status(n)` works.
  // Mirror that shape: the response fields plus a `to` assertion root bound to `{code}`.
  ctx.pm = makePm(ctx, {
    code: status,
    statusText: response.statusText,
    headers: { get: (n) => response.headers.get(n) },
    json,
    text: () => bodyText,
    to: chain({ code: status }, 'pm.response').to,
  });
  runScripts('test', item.event, ctx);
  await Promise.all(ctx.sends.splice(0));

  const failed = ctx.assertions.filter((a) => !a.ok);
  results.push({
    name: item.name, url, status,
    ok: failed.length === 0 && ctx.errors.length === 0,
    why: [...ctx.errors, ...failed.map((f) => `"${f.name}" — ${f.why}`)].join('; '),
    assertions: ctx.assertions.length,
    logs: ctx.logs,
    ms: Date.now() - started,
  });
}

function makePm(ctx, response) {
  return {
    test: (name, fn) => ctx.pending.push([name, fn]),
    expect: (v) => chain(v, 'expect'),
    response: response ?? undefined,
    sendRequest: (spec, cb) => ctx.sends.push(dispatchRequest(spec, cb)),
    variables: {
      set: (k, v) => transaction.set(k, String(v)),
      get: (k) => readVar(k),
      replace: (o) => { for (const [k, v] of Object.entries(o || {})) transaction.set(k, String(v)); },
      replaceIn: (text) => sub(text),
    },
    collectionVariables: {
      set: (k, v) => collection.set(k, String(v)),
      get: (k) => collection.get(k),
      unset: (k) => collection.delete(k),
    },
  };
}

// Document order is the intended flow: Login fills the tokens, and each folder's
// Create captures the id that the requests after it read.
async function walk(items) {
  for (const item of items) {
    if (item.item) {
      if (SKIP.some((s) => item.name.includes(s))) { console.log(`skip  ${item.name}`); continue; }
      await walk(item.item);
      continue;
    }
    if (!item.request) continue;
    await send(item);
    const last = results[results.length - 1];
    const mark = last.ok ? 'ok  ' : 'FAIL';
    console.log(`${mark} ${String(last.status).padEnd(4)} ${item.name.padEnd(34)} ${last.url}` + (last.ok ? '' : `\n     → ${last.why}`));
  }
}

// Postman's own flow: login is what fills token/csrf, so document order is already correct.
await walk(COLLECTION.item);

const bad = results.filter((r) => !r.ok);
const asserted = results.reduce((n, r) => n + (r.assertions || 0), 0);
console.log(`\n${results.length} requests · ${asserted} scripted assertions · ${bad.length} failing`);
if (bad.length) {
  console.log('\nfailures:');
  for (const b of bad) console.log(`  ${b.status} ${b.name} — ${b.why}`);
}
process.exit(bad.length ? 1 : 0);
