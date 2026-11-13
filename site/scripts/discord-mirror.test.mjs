import assert from 'node:assert/strict';
import { test } from 'node:test';
import { execFileSync, spawn } from 'node:child_process';
import { mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { createServer, connect } from 'node:net';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// Run: node --test scripts/discord-mirror.test.mjs
const root = fileURLToPath(new URL('../', import.meta.url));

function freePort() {
  return new Promise((resolve, reject) => {
    const probe = createServer();
    probe.on('error', reject);
    probe.listen(0, '127.0.0.1', () => {
      const { port } = probe.address();
      probe.close(() => resolve(port));
    });
  });
}

async function waitForPort(port) {
  for (let attempt = 0; attempt < 50; attempt += 1) {
    const up = await new Promise((resolve) => {
      const socket = connect({ port, host: '127.0.0.1' });
      socket.once('connect', () => { socket.destroy(); resolve(true); });
      socket.once('error', () => resolve(false));
    });
    if (up) return;
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  throw new Error(`the test server never came up on port ${port}`);
}

test('the Discord mirror files parse and satisfy their contract', () => {
  for (const file of ['api/discord-lib.php', 'api/discord-publish.php', 'api/social.php', 'api/social-lib.php']) {
    execFileSync('php', ['-l', path.join(root, file)], { stdio: 'pipe' });
  }
  const output = execFileSync('php', [path.join(root, 'scripts/discord-mirror-check.php')], {
    encoding: 'utf8',
  });
  assert.match(output, /all checks passed/);
});

test('the configured shared secret wins over the secret file', () => {
  const lib = path.join(root, 'api/social-lib.php');
  const output = execFileSync(
    'php',
    ['-r', `define('SOCIAL_WEBHOOK_SECRET', str_repeat('a', 40)); require ${JSON.stringify(lib)}; echo social_webhook_secret('/nonexistent');`],
    { encoding: 'utf8' },
  );
  assert.equal(output, 'a'.repeat(40));
});

test('discord_send posts the payload and reports Discord failures', async (t) => {
  // The receiver runs in its own process: execFileSync blocks this event loop,
  // so a same-process server could never answer the sender.
  const dir = mkdtempSync(path.join(tmpdir(), 'discord-mirror-'));
  const receivedFile = path.join(dir, 'received.json');
  const statusFile = path.join(dir, 'status');
  const router = path.join(dir, 'router.php');
  writeFileSync(statusFile, '204');
  writeFileSync(router, `<?php
$body = file_get_contents('php://input');
file_put_contents(${JSON.stringify(receivedFile)}, json_encode([
    'url' => $_SERVER['REQUEST_URI'] ?? '',
    'type' => $_SERVER['CONTENT_TYPE'] ?? '',
    'body' => $body,
]));
http_response_code((int)trim((string)file_get_contents(${JSON.stringify(statusFile)})));
`);
  const port = await freePort();
  const server = spawn('php', ['-S', `127.0.0.1:${port}`, router], { stdio: 'ignore' });
  t.after(() => server.kill());
  await waitForPort(port);

  const runner = path.join(dir, 'runner.php');
  writeFileSync(runner, `<?php
require ${JSON.stringify(path.join(root, 'api/discord-lib.php'))};
echo discord_send($argv[1], json_decode($argv[2], true)) ? 'sent' : 'failed';
`);

  const url = `http://127.0.0.1:${port}/webhook`;
  const payload = { username: 'Hasan Abbas Sorathiya', embeds: [{ title: 'New on LinkedIn' }] };
  const sent = execFileSync('php', [runner, url, JSON.stringify(payload)], { encoding: 'utf8' });
  assert.equal(sent, 'sent');
  const received = JSON.parse(readFileSync(receivedFile, 'utf8'));
  assert.equal(received.url, '/webhook');
  assert.equal(received.type, 'application/json');
  assert.deepEqual(JSON.parse(received.body), payload);

  writeFileSync(statusFile, '500');
  const failed = execFileSync('php', [runner, url, JSON.stringify(payload)], { encoding: 'utf8' });
  assert.equal(failed, 'failed');
});
