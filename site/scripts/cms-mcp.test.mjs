#!/usr/bin/env node
// Protocol test for the local CMS MCP server. Runs against the disposable harness
// started by cms-smoke.sh (CMS_MCP_TEST=1). It creates a scoped token, spawns the
// server over stdio, and exercises the JSON-RPC lifecycle plus real tool calls.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import readline from 'node:readline';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const SERVER = path.join(HERE, 'cms-mcp.mjs');
const SITE = process.env.CMS_TEST_URL ?? '';
const SESSION_TOKEN = process.env.CMS_TEST_TOKEN ?? '';
const SESSION_CSRF = process.env.CMS_TEST_CSRF ?? '';
const FILE = process.env.CMS_TEST_FILE ?? '';
const missing = ['CMS_TEST_URL', 'CMS_TEST_TOKEN', 'CMS_TEST_CSRF', 'CMS_TEST_FILE'].filter((k) => !process.env[k]);

if (missing.length) {
  test('CMS MCP protocol', { skip: `harness env missing: ${missing.join(', ')}` }, () => {});
} else {
  const API = `${SITE.replace(/\/$/, '')}/api`;
  const ALL_SCOPES = ['content:read', 'content:write', 'media:read', 'media:write', 'crm:read', 'crm:write'];
  let scoped = null;
  let client = null;

  function startServer(env) {
    const child = spawn(process.execPath, [SERVER], {
      env: { ...process.env, ...env },
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    const rl = readline.createInterface({ input: child.stdout });
    const pending = new Map();
    let nextId = 1;
    let stderr = '';
    child.stderr.on('data', (d) => { stderr += d.toString(); });
    const failAll = (why) => {
      for (const [id, p] of pending) { pending.delete(id); p.reject(new Error(why)); }
    };
    child.on('exit', (code) => failAll(`MCP server exited (${code}) ${stderr}`));
    rl.on('line', (line) => {
      let msg;
      try { msg = JSON.parse(line); } catch { return; }
      if (msg.id === undefined || !pending.has(msg.id)) return;
      const p = pending.get(msg.id);
      pending.delete(msg.id);
      if (msg.error) p.reject(new Error(`${msg.error.code}: ${msg.error.message}`));
      else p.resolve(msg.result);
    });
    const request = (method, params) => new Promise((resolve, reject) => {
      const id = nextId++;
      pending.set(id, { resolve, reject });
      child.stdin.write(JSON.stringify({ jsonrpc: '2.0', id, method, params }) + '\n');
      setTimeout(() => {
        if (pending.has(id)) { pending.delete(id); reject(new Error(`timeout: ${method} ${stderr}`)); }
      }, 15000);
    });
    const notify = (method, params) => {
      child.stdin.write(JSON.stringify({ jsonrpc: '2.0', method, params }) + '\n');
    };
    return { child, request, notify, stderr: () => stderr };
  }

  async function callTool(name, args = {}) {
    const result = await client.request('tools/call', { name, arguments: args });
    assert.ok(Array.isArray(result.content), 'tool result has content array');
    const text = result.content.find((c) => c.type === 'text')?.text ?? '';
    let body;
    try { body = JSON.parse(text); } catch { body = text; }
    return { body, isError: result.isError === true };
  }

  before(async () => {
    const res = await fetch(`${API}/tokens.php`, {
      method: 'POST',
      headers: {
        'X-Auth-Token': SESSION_TOKEN,
        'X-CSRF-Token': SESSION_CSRF,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ label: 'mcp-harness', scopes: ALL_SCOPES, days: 1 }),
    });
    assert.equal(res.status, 201, 'scoped token create');
    scoped = await res.json();
    assert.match(scoped.token, /^[0-9a-f]{64}$/);
    assert.match(scoped.csrf, /^[0-9a-f]{64}$/);

    client = startServer({
      CMS_API_BASE: API,
      CMS_API_TOKEN: scoped.token,
      CMS_API_CSRF: scoped.csrf,
    });
    const init = await client.request('initialize', {
      protocolVersion: '2025-06-18',
      capabilities: {},
      clientInfo: { name: 'cms-mcp-test', version: '0.0.0' },
    });
    assert.equal(init.serverInfo.name, 'portfolio-cms');
    assert.ok(init.capabilities.tools, 'advertises tools capability');
    client.notify('notifications/initialized', {});
  });

  after(async () => {
    if (client) {
      client.child.kill();
      await new Promise((r) => client.child.once('exit', r));
    }
    if (scoped?.id) {
      await fetch(`${API}/tokens.php?id=${scoped.id}`, {
        method: 'DELETE',
        headers: { 'X-Auth-Token': SESSION_TOKEN, 'X-CSRF-Token': SESSION_CSRF },
      });
    }
  });

  test('tools/list exposes content, media and CRM tools with schemas', async () => {
    const { tools } = await client.request('tools/list', {});
    const names = tools.map((t) => t.name);
    for (const expected of [
      'cms_content_schema', 'cms_content_list', 'cms_content_create', 'cms_content_update', 'cms_content_delete',
      'cms_media_list', 'cms_media_upload', 'cms_media_delete',
      'cms_crm_enquiries', 'cms_crm_enquiry_update', 'cms_crm_subscribers', 'cms_crm_subscriber_delete',
      'cms_crm_settings_get', 'cms_crm_settings_update',
    ]) assert.ok(names.includes(expected), `missing tool ${expected}`);
    for (const tool of tools) {
      assert.equal(tool.inputSchema.type, 'object', `${tool.name} has object schema`);
      assert.ok(typeof tool.description === 'string' && tool.description.length > 0);
    }
  });

  test('content schema returns typed profile fields', async () => {
    const { body, isError } = await callTool('cms_content_schema', { entity: 'profile' });
    assert.equal(isError, false);
    assert.equal(body.entity, 'profile');
    const years = body.fields.find((f) => f.name === 'experience_years');
    assert.equal(years.type, 'number');
  });

  test('content create/read/update/delete round-trip', async () => {
    const slug = `mcp-harness-${Date.now()}`;
    const created = await callTool('cms_content_create', {
      entity: 'apps',
      data: {
        slug, name: 'MCP Harness App', tagline: 'Created through MCP',
        platforms: ['iOS'], links: {}, metrics: [], features: [], screenshots: [], stack: [],
        published: 0, sort_order: 99,
      },
    });
    assert.equal(created.isError, false);
    assert.ok(Number.isInteger(created.body.id));
    const id = created.body.id;

    const read = await callTool('cms_content_list', { entity: 'apps', id });
    assert.equal(read.isError, false);
    assert.equal(read.body.slug, slug);

    const updated = await callTool('cms_content_update', { entity: 'apps', id, data: { tagline: 'Updated through MCP' } });
    assert.equal(updated.isError, false);
    const read2 = await callTool('cms_content_list', { entity: 'apps', id });
    assert.equal(read2.body.tagline, 'Updated through MCP');

    const deleted = await callTool('cms_content_delete', { entity: 'apps', id });
    assert.equal(deleted.isError, false);
    const gone = await callTool('cms_content_list', { entity: 'apps', id });
    assert.equal(gone.isError, true);
  });

  test('media upload/list/delete round-trip', async () => {
    const up = await callTool('cms_media_upload', { file_path: FILE, folder: 'mcp-harness' });
    assert.equal(up.isError, false, JSON.stringify(up.body));
    assert.match(up.body.path, /^\/media\/uploads\/mcp-harness\//);

    const list = await callTool('cms_media_list', { folder: 'mcp-harness' });
    assert.equal(list.isError, false);
    const row = list.body.rows.find((r) => r.path === up.body.path);
    assert.ok(row, 'uploaded file appears in library');

    const del = await callTool('cms_media_delete', { id: row.id });
    assert.equal(del.isError, false);
  });

  test('CRM settings get/update and enquiries list', async () => {
    const get = await callTool('cms_crm_settings_get');
    assert.equal(get.isError, false);
    assert.equal(typeof get.body, 'object');

    const put = await callTool('cms_crm_settings_update', { data: { announcement: 'MCP harness announcement' } });
    assert.equal(put.isError, false);
    assert.ok(put.body.updated.includes('announcement'));

    const enquiries = await callTool('cms_crm_enquiries', { page: 1 });
    assert.equal(enquiries.isError, false);
    assert.ok(Array.isArray(enquiries.body.rows));
  });

  test('unknown tool is a JSON-RPC error', async () => {
    await assert.rejects(
      () => client.request('tools/call', { name: 'cms_does_not_exist', arguments: {} }),
      /-32602/,
    );
  });

  test('invalid arguments are rejected', async () => {
    await assert.rejects(
      () => client.request('tools/call', { name: 'cms_content_create', arguments: { entity: 'apps' } }),
      /-32602/,
    );
  });
}