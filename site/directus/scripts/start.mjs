import { spawn } from 'node:child_process';
import { mkdirSync, rmSync, unlinkSync, writeFileSync } from 'node:fs';
import { createServer, request as httpRequest } from 'node:http';
import { connect as netConnect } from 'node:net';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import mysql from 'mysql2/promise';

const env = process.env;

// Hostinger's runtime PATH has no npm/npx, so the CLI must be run with the
// same node binary that runs this script.
const directusCli = fileURLToPath(new URL('../node_modules/directus/cli.js', import.meta.url));

// Hostinger proxies apps through LiteSpeed, which hands the app a unix socket
// in LSNODE_SOCKET; other hosts inject a port instead. This process keeps that
// endpoint for its whole lifetime and proxies to Directus on a private unix
// socket. Directus must not bind the platform socket itself: handing the path
// over leaves a window in which the LiteSpeed supervisor rebinds it, and
// Directus then dies with "socket is already in use". The internal socket is
// scoped to this pid because the platform may briefly run more than one app
// instance (one per hostname) and they must not fight over a fixed path or port.
// It lives in the temp dir: the extapp-sock directory rejects any name other
// than the one assignment with EACCES.
const publicSocket = env.LSNODE_SOCKET || env.UNIX_SOCKET_PATH || '';
const publicPort = publicSocket ? null : Number((String(env.PORT ?? '').match(/(\d+)\s*$/) || [])[1]);
const internalSocket = join(tmpdir(), `directus-${process.pid}.sock`);

env.UNIX_SOCKET_PATH = internalSocket;
delete env.PORT;

console.log(
  `[start] serving ${publicSocket ? `socket ${publicSocket}` : publicPort ? `port ${publicPort}` : '(nowhere)'} -> Directus on ${internalSocket} (pid ${process.pid})`,
);

for (const dir of ['uploads', 'extensions']) mkdirSync(new URL(`../${dir}`, import.meta.url), { recursive: true });

function isWritable(dir) {
  try {
    mkdirSync(dir, { recursive: true });
    const probe = join(dir, `.write-test-${process.pid}`);
    writeFileSync(probe, 'ok');
    rmSync(probe);
    return true;
  } catch {
    return false;
  }
}

// The configured uploads dir is easiest to persist, but if the runtime can't
// write there, fall back to a folder outside hbuilds that survives redeploys.
const fallbackUploads = fileURLToPath(new URL('../../../../../uploads', import.meta.url));
if (!isWritable(env.STORAGE_LOCAL_ROOT ?? '')) {
  if (!isWritable(fallbackUploads)) throw new Error(`No writable uploads directory (${env.STORAGE_LOCAL_ROOT}, ${fallbackUploads})`);
  console.warn(`[start] ${env.STORAGE_LOCAL_ROOT} is not writable; storing uploads in ${fallbackUploads}`);
  env.STORAGE_LOCAL_ROOT = fallbackUploads;
}

function proxyRequest(request, response) {
  const upstream = httpRequest(
    { socketPath: internalSocket, method: request.method, path: request.url, headers: request.headers },
    (upstreamResponse) => {
      response.writeHead(upstreamResponse.statusCode ?? 502, upstreamResponse.headers);
      upstreamResponse.pipe(response);
    },
  );
  upstream.on('error', (error) => {
    if (response.writableEnded) return;
    response.writeHead(503, { 'Content-Type': 'text/plain; charset=utf-8', 'Retry-After': '5' });
    response.end(`Directus is starting up, please retry in a moment. [pid ${process.pid}, ${error.code ?? error.message}]\n`);
  });
  response.on('close', () => {
    if (!response.writableFinished) upstream.destroy();
  });
  request.pipe(upstream);
}

// Directus's realtime API needs websocket upgrades forwarded as raw sockets.
function proxyUpgrade(request, socket, head) {
  const upstream = netConnect({ path: internalSocket }, () => {
    const lines = [`${request.method} ${request.url} HTTP/1.1`];
    for (let index = 0; index < request.rawHeaders.length; index += 2) {
      lines.push(`${request.rawHeaders[index]}: ${request.rawHeaders[index + 1]}`);
    }
    upstream.write(`${lines.join('\r\n')}\r\n\r\n`);
    if (head?.length) upstream.write(head);
    upstream.pipe(socket);
    socket.pipe(upstream);
  });
  upstream.on('error', () => socket.destroy());
  socket.on('error', () => upstream.destroy());
}

// The platform expects listen() within a few seconds, so the proxy starts
// before the database check and answers 503 until Directus accepts traffic.
const proxy = createServer(proxyRequest);
proxy.on('upgrade', proxyUpgrade);

if (publicSocket) {
  try {
    unlinkSync(publicSocket);
  } catch {}
  await new Promise((resolve, reject) => {
    proxy.once('error', reject);
    proxy.listen({ path: publicSocket }, resolve);
  });
  console.log(`[start] listening on ${publicSocket}`);
} else if (Number.isInteger(publicPort)) {
  await new Promise((resolve, reject) => {
    proxy.once('error', reject);
    proxy.listen({ host: '0.0.0.0', port: publicPort }, resolve);
  });
  console.log(`[start] listening on port ${publicPort}`);
} else {
  console.warn('[start] no LSNODE_SOCKET or PORT provided; not accepting requests.');
}

async function isInstalled() {
  const connection = await mysql.createConnection({
    host: env.DB_HOST,
    port: Number(env.DB_PORT || 3306),
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    database: env.DB_DATABASE,
  });
  try {
    const [rows] = await connection.execute(
      "SELECT COUNT(*) AS count FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'directus_users'",
    );
    return Number(rows[0]?.count || 0) > 0;
  } finally {
    await connection.end();
  }
}

function run(command, args) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, { stdio: 'inherit', env });
    child.on('error', reject);
    child.on('exit', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`${command} ${args.join(' ')} exited with ${code}`));
    });
  });
}

if (!(await isInstalled())) {
  console.log('[start] Directus is not installed yet; bootstrapping.');
  await run(process.execPath, [directusCli, 'bootstrap']);
} else {
  // `directus start` only warns when migrations are pending, and Directus 12
  // crashes in the license manager if the licensing migration is missing.
  console.log('[start] applying pending database migrations.');
  await run(process.execPath, [directusCli, 'database', 'migrate:latest']);
}

console.log('[start] starting Directus.');
try {
  unlinkSync(internalSocket);
} catch {}
const server = spawn(process.execPath, [directusCli, 'start'], { stdio: 'inherit', env });
process.on('exit', () => {
  try {
    unlinkSync(internalSocket);
  } catch {}
});
for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, () => {
    proxy.close();
    server.kill(signal);
  });
}
server.on('exit', (code) => process.exit(code ?? 0));
