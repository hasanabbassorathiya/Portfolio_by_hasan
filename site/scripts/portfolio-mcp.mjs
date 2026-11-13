#!/usr/bin/env node
// Unified Portfolio MCP Server - All site operations via MCP
import { readFile, stat, writeFile } from 'node:fs/promises';
import readline from 'node:readline';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.dirname(HERE);
const SITE_DIR = path.join(PROJECT_ROOT, 'site');

const SUPPORTED_VERSIONS = ['2025-06-18', '2025-03-26', '2024-11-05'];
const SERVER_INFO = { name: 'portfolio-mcp', version: '1.0.0' };

class ApiError extends Error {
  constructor(status, body) {
    super(`API returned ${status}`);
    this.status = status;
    this.body = body;
  }
}

// Session state
let sessionToken = null;
let sessionCsrf = null;
let apiBase = null;
let fmApiUrl = null;

const obj = (properties, required = []) => ({ type: 'object', properties, required });
const str = { type: 'string' };
const int = { type: 'integer' };
const bool = { type: 'boolean' };

function config() {
  if (apiBase === null && process.env.CMS_API_BASE) {
    apiBase = process.env.CMS_API_BASE.replace(/\/$/, '');
  }
  const base = process.env.CMS_API_BASE?.replace(/\/$/, '') ?? apiBase ?? '';
  const token = process.env.CMS_API_TOKEN ?? sessionToken ?? '';
  const csrf = process.env.CMS_API_CSRF ?? sessionCsrf ?? '';
  if (!base) throw new Error('CMS_API_BASE must be set');
  if (!token) throw new Error('CMS_API_TOKEN or cms_auth_login required');
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
    if (!csrf) throw new Error('CSRF token required for write operations');
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

const TOOLS = [
  // ===== AUTHENTICATION =====
  {
    name: 'cms_auth_login',
    description: 'Log in to the CMS admin API. Returns token, csrf, and expires_in.',
    inputSchema: obj({ email: str, password: str }, ['email', 'password']),
    handler: async ({ email, password }) => {
      const cfg = config();
      const url = new URL('auth.php?action=login', cfg.base);
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
    description: 'Clear the current session token and CSRF.',
    inputSchema: obj({}),
    handler: () => {
      sessionToken = null;
      sessionCsrf = null;
      return { cleared: true };
    },
  },

  // ===== CMS CONTENT =====
  {
    name: 'cms_content_list',
    description: 'List rows for an entity, or fetch one row by id. For profile, pass k to fetch a single key/value row.',
    inputSchema: obj({ entity: str, id: int, k: str }, ['entity']),
    handler: ({ entity, id, k }) => api('crud.php', { query: { entity, id, k } }),
  },

  // ===== MEDIA LIBRARY =====
  {
    name: 'cms_media_upload',
    description: 'Upload a local file to the media library.',
    inputSchema: obj({ file_path: str, folder: str }, ['file_path']),
    handler: async ({ file_path, folder }) => {
      const info = await stat(file_path);
      if (!info.isFile()) throw new Error('file_path is not a regular file');
      if (info.size > 8 * 1024 * 1024) throw new Error('file exceeds 8 MB limit');
      const buf = await readFile(file_path);
      const form = new FormData();
      form.append('folder', folder || 'uploads');
      form.append('file', new Blob([buf], { type: 'application/octet-stream' }), path.basename(file_path));
      return api('media.php', { method: 'POST', form });
    },
  },

  // ===== CRM =====
  {
    name: 'cms_crm_enquiries',
    description: 'List enquiries with optional status filter.',
    inputSchema: obj({ id: int, page: int, status: str }),
    handler: ({ id, page, status }) => api('crm.php', { query: { resource: 'enquiries', id, page, status } }),
  },
  {
    name: 'cms_crm_settings_get',
    description: 'Get site settings as key/value map.',
    inputSchema: obj({}),
    handler: () => api('crm.php', { query: { resource: 'settings' } }),
  },

  // ===== BUILD SYSTEM =====
  {
    name: 'build_site',
    description: 'Build the portfolio site. Runs npm run build in the site directory. Returns success status and output.',
    inputSchema: obj({ watch: bool }, ['watch']),
    handler: async ({ watch = false }) => {
      return new Promise((resolve, reject) => {
        const child = spawn('npm', ['run', 'build'], {
          cwd: SITE_DIR,
          env: { ...process.env, FORCE_COLOR: '0' },
          stdio: ['ignore', 'pipe', 'pipe'],
        });
        let stdout = '';
        let stderr = '';

        child.stdout.on('data', (d) => stdout += d.toString());
        child.stderr.on('data', (d) => stderr += d.toString());

        child.on('error', (err) => reject(new Error(`Spawn error: ${err.message}`)));
        child.on('exit', (code) => {
          resolve({
            success: code === 0,
            exitCode: code,
            stdout: stdout.trim(),
            stderr: stderr.trim(),
          });
        });
      });
    },
  },

  {
    name: 'build_prerender',
    description: 'Run the prerender script to generate static HTML pages. Should run after build_site.',
    inputSchema: obj({}),
    handler: async () => {
      return new Promise((resolve, reject) => {
        const child = spawn(process.execPath, ['site/scripts/prerender-meta.mjs'], {
          cwd: PROJECT_ROOT,
          env: { ...process.env, FORCE_COLOR: '0' },
          stdio: ['ignore', 'pipe', 'pipe'],
        });
        let stdout = '';
        let stderr = '';

        child.stdout.on('data', (d) => stdout += d.toString());
        child.stderr.on('data', (d) => stderr += d.toString());

        child.on('error', (err) => reject(new Error(`Spawn error: ${err.message}`)));
        child.on('exit', (code) => {
          resolve({
            success: code === 0,
            exitCode: code,
            stdout: stdout.trim(),
            stderr: stderr.trim(),
          });
        });
      });
    },
  },

  // ===== FILE SYSTEM =====
  {
    name: 'fs_read',
    description: 'Read a file from the project.',
    inputSchema: obj({ path: str }, ['path']),
    handler: async ({ path: filePath }) => {
      const fullPath = filePath.startsWith('/') ? filePath : path.join(PROJECT_ROOT, filePath);
      return { content: await readFile(fullPath, 'utf8'), path: fullPath };
    },
  },

  {
    name: 'fs_write',
    description: 'Write content to a file. Creates the file if it does not exist.',
    inputSchema: obj({ path: str, content: str, create_only: bool }, ['path', 'content']),
    handler: async ({ path: filePath, content, create_only }) => {
      const fullPath = filePath.startsWith('/') ? filePath : path.join(PROJECT_ROOT, filePath);
      const opts = create_only ? { exclusive: true } : {};
      await writeFile(fullPath, content, 'utf8');
      return { written: true, path: fullPath };
    },
  },

  {
    name: 'fs_list',
    description: 'List files in a directory.',
    inputSchema: obj({ path: str }, ['path']),
    handler: async ({ path: dirPath }) => {
      const fullPath = dirPath === '.' ? PROJECT_ROOT : (dirPath.startsWith('/') ? dirPath : path.join(PROJECT_ROOT, dirPath));
      const entries = await import('node:fs').then(fs => fs.readdirSync(fullPath, { withFileTypes: true }));
      return { entries: entries.map(e => ({ name: e.name, isDirectory: e.isDirectory(), isFile: e.isFile() })) };
    },
  },

  // ===== SITE INFO =====
  {
    name: 'site_info',
    description: 'Get information about the portfolio site including build status, routes, and current config.',
    inputSchema: obj({}),
    handler: async () => {
      const distExists = await import('node:fs').then(fs => {
        try { fs.accessSync(path.join(SITE_DIR, 'dist')); return true;
        } catch { return false; }
      });

      return {
        projectRoot: PROJECT_ROOT,
        siteDir: SITE_DIR,
        buildExists: distExists,
        entities: ['apps', 'clients', 'posts', 'projects', 'experiences', 'skills', 'testimonials', 'profile'],
        routes: ['/', '/apps', '/work', '/blog', '/resume', '/brand', '/privacy', '/services'],
        env: {
          hasCmsApiBase: !!process.env.CMS_API_BASE,
          hasCmsToken: !!process.env.CMS_API_TOKEN,
          hasFmApiUrl: !!process.env.FM_API_URL,
        },
      };
    },
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
  if (schema.type === 'boolean') return typeof value === 'boolean' ? null : `${label} must be a boolean`;
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
    return { result: textResult({ error: { message: err.message } }, true) };
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
        instructions: `Portfolio MCP - Unified site operations.

AUTHENTICATION:
- cms_auth_login(email, password) → login to CMS
- cms_session_clear() → clear session

CMS CONTENT:
- cms_content_list(entity, id?, k?)
- cms_media_upload(file_path, folder?)

CRM:
- cms_crm_enquiries(page?, status?)
- cms_crm_settings_get()

BUILD:
- build_site(watch?) → npm run build
- build_prerender() → generate static HTML

FILE SYSTEM:
- fs_read(path)
- fs_write(path, content)
- fs_list(path)

INFO:
- site_info() → project overview
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
    process.stderr.write(`portfolio-mcp: ${err.stack ?? err.message}\n`);
    if (msg?.id !== undefined) respond(msg.id, { error: { code: -32603, message: 'internal error' } });
  });
});