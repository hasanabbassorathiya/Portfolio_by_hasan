import { spawn } from 'node:child_process';
import { mkdirSync } from 'node:fs';
import mysql from 'mysql2/promise';

const env = process.env;

// Passenger-style hosts hand Node a unix socket path instead of a port.
if (env.PORT && !/^\d+$/.test(env.PORT) && !env.UNIX_SOCKET_PATH) {
  env.UNIX_SOCKET_PATH = env.PORT;
  delete env.PORT;
}

for (const dir of ['uploads', 'extensions']) mkdirSync(new URL(`../${dir}`, import.meta.url), { recursive: true });

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
  await run('npx', ['directus', 'bootstrap']);
}

console.log('[start] starting Directus.');
const server = spawn('npx', ['directus', 'start'], { stdio: 'inherit', env });
for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, () => server.kill(signal));
}
server.on('exit', (code) => process.exit(code ?? 0));
