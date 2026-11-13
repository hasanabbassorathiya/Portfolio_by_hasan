#!/usr/bin/env node
// MCP test cleanup script - removes test artifacts and resets state
import { readFile, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';

const TEST_FILES = [
  '.mcp.test.env',
  'test-token.txt',
  'test-csrf.txt',
];

const CLEANUP_MARKER = '# === MCP TEST CLEANUP COMPLETE ===';

async function cleanup() {
  console.log('Cleaning up MCP test artifacts...');

  for (const file of TEST_FILES) {
    const filePath = path.join(import.meta.dirname, '..', file);
    try {
      await rm(filePath, { force: true });
      console.log(`Removed: ${file}`);
    } catch (e) {
      console.log(`Not found or error: ${file}`);
    }
  }

  // Update .mcp.json to remove test config
  const mcpPath = path.join(import.meta.dirname, '..', '..', '.mcp.json');
  try {
    const content = await readFile(mcpPath, 'utf8');
    if (content.includes('"portfolio-cms"')) {
      console.log('.mcp.json already has portfolio-cms configured');
    }
  } catch (e) {
    console.log('Could not read .mcp.json:', e.message);
  }

  console.log('MCP cleanup complete.');
}

if (import.meta.main) {
  cleanup().catch((e) => {
    console.error('Cleanup failed:', e);
    process.exit(1);
  });
}