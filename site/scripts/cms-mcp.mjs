#!/usr/bin/env node
// Local stdio MCP server for the portfolio CMS API. Dependency-free JSON-RPC 2.0.
// Configure with CMS_API_BASE (…/api), CMS_API_TOKEN and CMS_API_CSRF (scoped token pair).
import readline from 'node:readline';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';

const SUPPORTED_VERSIONS = ['2025-06-18', '2025-03-26', '2024-11-05'];
const SERVER_INFO = { name: 'portfolio-cms', version: '1.0.0' };

class ApiError extends Error {
  constructor(status, body) {
    super(`CMS API returned ${status}`);
    this.status = status;
    this.body = body;
  }
}

function config() {
  // Allow config from env vars OR from session/login
  // Initialize apiBase from env on first call
  if (apiBase === null && process.env.CMS_API_BASE) {
    apiBase = process.env.CMS_API_BASE.replace(/\/$/, '');
  }
  const base = process.env.CMS_API_BASE?.replace(/\/$/, '') ?? apiBase ?? '';
  const token = process.env.CMS_API_TOKEN ?? sessionToken ?? '';
  const csrf = process.env.CMS_API_CSRF ?? sessionCsrf ?? '';
  if (!base) throw new Error('CMS_API_BASE must be set (via env or cms_auth_login)');
  if (!token) throw new Error('CMS_API_TOKEN or cms_auth_login required');
  const url = new URL(base);
  if (!['http:', 'https:'].includes(url.protocol)) throw new Error('CMS_API_BASE must be http(s)');
  return { base, token, csrf };
}

async function api(endpoint, { method = 'GET', query, body, form } = {}) {
  const { base, token, csrf } = config();
  const url = new URL(`${base}/${endpoint}`);
  for (const [k, v] of Object.entries(query ?? {})) {
    if (v !== undefined && v !== null && v !== '') url.searchParams.set(k, String(v));
  }
  const headers = { 'X-Auth-Token': token, Accept: 'application/json' };
  const init = { method, headers };
  if (method !== 'GET' && method !== 'HEAD') {
    if (!csrf) throw new Error('CMS_API_CSRF is required for write operations');
    headers['X-CSRF-Token'] = csrf;
  }
  if (form) {
    init.body = form;
  } else if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
    init.body = JSON.stringify(body);
  }
  const res = await fetch(url, init);
  const text = await res.text();
  let data;
  try { data = JSON.parse(text); } catch { data = text; }
  if (!res.ok) throw new ApiError(res.status, data);
  return data;
}

const obj = (properties, required = []) => ({ type: 'object', properties, required });
const str = { type: 'string' };
const int = { type: 'integer' };

// Session storage for dynamic auth (token/csrf from login, or scoped token)
let sessionToken = null;
let sessionCsrf = null;
let apiBase = null;

const TOOLS = [
  {
    name: 'cms_auth_login',
    description: 'Log in to the CMS admin API using email/password. Returns token, csrf, and expires_in for session use. After login, token/csrf are used for subsequent write operations until session expiry (7 days).',
    inputSchema: obj({ email: str, password: str }, ['email', 'password']),
    handler: async ({ email, password }) => {
      const cfg = config();
      const url = new URL(`auth.php?action=login`, cfg.base);
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      const text = await res.text();
      let data;
      try { data = JSON.parse(text); } catch { data = text; }
      if (!res.ok) throw new ApiError(res.status, data);
      sessionToken = data.token;
      sessionCsrf = data.csrf;
      return data;
    },
  },
  {
    name: 'cms_session_clear',
    description: 'Clear the current session token and CSRF. After calling this, cms_auth_login must be called again to perform write operations.',
    inputSchema: obj({}),
    handler: () => {
      sessionToken = null;
      sessionCsrf = null;
      return { cleared: true };
    },
  },
  {
    name: 'cms_admin_info',
    description: 'Return information about available CMS entities, their fields, and the current session status. Useful for understanding the data model before querying.',
    inputSchema: obj({}),
    handler: () => {
      const entities = ['apps', 'clients', 'posts', 'projects', 'experiences', 'skills', 'testimonials', 'profile'];
      return {
        entities,
        session: {
          hasToken: !!sessionToken,
          hasCsrf: !!sessionCsrf,
          apiBase: apiBase,
        },
        auth: {
          requiresLogin: !process.env.CMS_API_TOKEN,
          loginEndpoint: 'cms_auth_login',
        },
      };
    },
  },
  {
    name: 'cms_content_list',
    description: 'List rows for an entity, or fetch one row by id. For profile, pass k to fetch a single key/value row.',
    inputSchema: obj({ entity: str, id: int, k: str }, ['entity']),
    handler: ({ entity, id, k }) => api('crud.php', { query: { entity, id, k } }),
  },
  {
    name: 'cms_content_create',
    description: 'Create a row. data carries the entity fields; for profile use {k, v}.',
    inputSchema: obj({ entity: str, data: { type: 'object' } }, ['entity', 'data']),
    handler: ({ entity, data }) => api('crud.php', { method: 'POST', query: { entity }, body: data }),
  },
  {
    name: 'cms_content_update',
    description: 'Update a row by id. For profile, omit id and pass {k, v, previous_k?}.',
    inputSchema: obj({ entity: str, id: int, data: { type: 'object' } }, ['entity', 'data']),
    handler: ({ entity, id, data }) => api('crud.php', { method: 'PUT', query: { entity, id }, body: data }),
  },
  {
    name: 'cms_content_delete',
    description: 'Delete a row by id, or a profile key by k.',
    inputSchema: obj({ entity: str, id: int, k: str }, ['entity']),
    handler: ({ entity, id, k }) => api('crud.php', { method: 'DELETE', query: { entity, id, k } }),
  },
  {
    name: 'cms_media_list',
    description: 'List media library rows, optionally filtered by folder.',
    inputSchema: obj({ folder: str, page: int }),
    handler: ({ folder, page }) => api('media.php', { query: { folder, page } }),
  },
  {
    name: 'cms_media_upload',
    description: 'Upload a local image file into the media library. file_path is read from this machine; folder defaults to uploads.',
    inputSchema: obj({ file_path: str, folder: str }, ['file_path']),
    handler: async ({ file_path, folder }) => {
      const info = await stat(file_path);
      if (!info.isFile()) throw new Error('file_path is not a regular file');
      if (info.size > 8 * 1024 * 1024) throw new Error('file exceeds the 8 MB upload limit');
      const buf = await readFile(file_path);
      const form = new FormData();
      form.append('folder', folder || 'uploads');
      form.append('file', new Blob([buf], { type: 'application/octet-stream' }), path.basename(file_path));
      return api('media.php', { method: 'POST', form });
    },
  },
  {
    name: 'cms_media_delete',
    description: 'Delete a media library row and its file by id.',
    inputSchema: obj({ id: int }, ['id']),
    handler: ({ id }) => api('media.php', { method: 'DELETE', query: { id } }),
  },
  {
    name: 'cms_crm_enquiries',
    description: 'List enquiries, or fetch one by id. Optional status filter and 1-based page.',
    inputSchema: obj({ id: int, page: int, status: str }),
    handler: ({ id, page, status }) => api('crm.php', { query: { resource: 'enquiries', id, page, status } }),
  },
  {
    name: 'cms_crm_enquiry_update',
    description: 'Update an enquiry with optimistic locking. version is required; data carries status/notes/next_action/follow_up_date.',
    inputSchema: obj({ id: int, version: int, data: { type: 'object' } }, ['id', 'version', 'data']),
    handler: ({ id, version, data }) => api('crm.php', { method: 'PUT', query: { resource: 'enquiries', id }, body: { ...data, version } }),
  },
  {
    name: 'cms_crm_subscribers',
    description: 'List newsletter subscribers (1-based page).',
    inputSchema: obj({ page: int }),
    handler: ({ page }) => api('crm.php', { query: { resource: 'subscribers', page } }),
  },
  {
    name: 'cms_crm_subscriber_delete',
    description: 'Delete a subscriber by id.',
    inputSchema: obj({ id: int }, ['id']),
    handler: ({ id }) => api('crm.php', { method: 'DELETE', query: { resource: 'subscribers', id } }),
  },
  {
    name: 'cms_crm_settings_get',
    description: 'Return site settings as a key/value map.',
    inputSchema: obj({}),
    handler: () => api('crm.php', { query: { resource: 'settings' } }),
  },
  {
    name: 'cms_crm_settings_update',
    description: 'Update site settings. data carries only the keys to change; invalid values are rejected by the API.',
    inputSchema: obj({ data: { type: 'object' } }, ['data']),
    handler: ({ data }) => api('crm.php', { method: 'PUT', query: { resource: 'settings' }, body: data }),
  },
];

function validate(schema, value, label = 'arguments') {
  if (schema.type === 'object') {
    if (typeof value !== 'object' || value === null || Array.isArray(value)) return `${label} must be an object`;
    for (const req of schema.required ?? []) {
      if (!(req in value)) return `${label} missing required field: ${req}`;
    }
    for (const [k, v] of Object.entries(value)) {
      if (v === undefined) continue;
      const prop = schema.properties?.[k];
      if (prop) {
        const err = validate(prop, v, `${label}.${k}`);
        if (err) return err;
      }
    }
    return null;
  }
  if (schema.type === 'string') return typeof value === 'string' ? null : `${label} must be a string`;
  if (schema.type === 'integer') return Number.isInteger(value) ? null : `${label} must be an integer`;
  if (schema.type === 'number') return typeof value === 'number' && Number.isFinite(value) ? null : `${label} must be a number`;
  if (schema.type === 'boolean') return typeof value === 'boolean' ? null : `${label} must be a boolean`;
  if (schema.type === 'array') return Array.isArray(value) ? null : `${label} must be an array`;
  return null;
}

const textResult = (data, isError = false) => ({
  content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
  isError,
});

async function callTool(name, args) {
  const tool = TOOLS.find((t) => t.name === name);
  if (!tool) return { error: { code: -32602, message: `unknown tool: ${name}` } };
  const invalid = validate(tool.inputSchema, args ?? {});
  if (invalid) return { error: { code: -32602, message: invalid } };
  try {
    return { result: textResult(await tool.handler(args ?? {})) };
  } catch (err) {
    if (err instanceof ApiError) {
      return { result: textResult({ error: 'api_error', status: err.status, body: err.body }, true) };
    }
    return { result: textResult({ error: err.message }, true) };
  }
}

function respond(id, payload) {
  process.stdout.write(JSON.stringify({ jsonrpc: '2.0', id, ...payload }) + '\n');
}

async function handle(msg) {
  if (typeof msg !== 'object' || msg === null || msg.jsonrpc !== '2.0' || typeof msg.method !== 'string') {
    if (msg?.id !== undefined) respond(msg.id, { error: { code: -32600, message: 'invalid request' } });
    return;
  }
  const { id, method, params } = msg;
  const isNotification = id === undefined;
  if (method === 'notifications/initialized' || method === 'notifications/cancelled') return;
  if (isNotification) return;

  if (method === 'initialize') {
    const requested = params?.protocolVersion;
    const protocolVersion = SUPPORTED_VERSIONS.includes(requested) ? requested : SUPPORTED_VERSIONS[0];
    respond(id, {
      result: {
        protocolVersion,
        capabilities: { tools: { listChanged: false } },
        serverInfo: SERVER_INFO,
        instructions: `Portfolio CMS API MCP server.

Authentication: Set CMS_API_BASE (required) and CMS_API_TOKEN + CMS_API_CSRF for token auth, OR use cms_auth_login(email, password) to log in. Session tokens expire after 7 days.

Available tools:
- cms_auth_login: Log in with email/password
- cms_session_clear: Clear current session
- cms_admin_info: Get info about entities and session status
- cms_content_*: CRUD operations for apps, clients, posts, profiles, etc.
- cms_media_*: Media library operations
- cms_crm_*: CRM operations (enquiries, subscribers, settings)
`,
      },
    });
    return;
  }
  if (method === 'ping') { respond(id, { result: {} }); return; }
  if (method === 'tools/list') {
    respond(id, { result: { tools: TOOLS.map(({ name, description, inputSchema }) => ({ name, description, inputSchema })) } });
    return;
  }
  if (method === 'tools/call') {
    const { error, result } = await callTool(params?.name, params?.arguments);
    respond(id, error ? { error } : { result });
    return;
  }
  respond(id, { error: { code: -32601, message: `method not found: ${method}` } });
}

const rl = readline.createInterface({ input: process.stdin });
rl.on('line', (line) => {
  const trimmed = line.trim();
  if (!trimmed) return;
  let msg;
  try { msg = JSON.parse(trimmed); } catch {
    process.stdout.write(JSON.stringify({ jsonrpc: '2.0', id: null, error: { code: -32700, message: 'parse error' } }) + '\n');
    return;
  }
  handle(msg).catch((err) => {
    process.stderr.write(`cms-mcp: ${err.stack ?? err.message}\n`);
    if (msg?.id !== undefined) respond(msg.id, { error: { code: -32603, message: 'internal error' } });
  });
});