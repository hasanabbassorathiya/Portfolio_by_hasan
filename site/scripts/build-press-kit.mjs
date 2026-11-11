#!/usr/bin/env node
/**
 * Assemble the downloadable press kit at site/public/media/brand/press-kit.zip.
 *
 * The zip is a build product of brand/, not a source: every file in it is either copied verbatim or
 * regenerated here from an SVG with rsvg-convert, so re-running after a brand change is enough.
 * The four boards are 4.2 MB as PNG, which is too heavy to hand a recruiter, so they ship as 1600 px
 * JPEG and the PNG originals stay in the repo.
 *
 *   cd site && npm run brand:kit
 */
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { copyFile, mkdir, mkdtemp, readdir, rm, writeFile } from 'node:fs/promises';
import { readFileSync, statSync } from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const SITE_ROOT = path.resolve(import.meta.dirname, '..');
const REPO_ROOT = path.resolve(SITE_ROOT, '..');
const BRAND = path.join(REPO_ROOT, 'brand');
const OUT = path.join(SITE_ROOT, 'public', 'media', 'brand', 'press-kit.zip');
const KIT_NAME = 'hasan-sorathiya-brand';
const BOARD_WIDTH = 1600;

const VERBATIM = [
  ['BRAND.md', 'BRAND.md'],
  ['README.md', 'README.md'],
  ['tokens.css', 'tokens.css'],
  ['logo-mark.svg', 'logos/logo-mark.svg'],
  ['lockup-horizontal.svg', 'logos/lockup-horizontal.svg'],
  ['seal-ink.svg', 'logos/seal-ink.svg'],
  ['seal-paper.svg', 'logos/seal-paper.svg'],
  ['icons/favicon-16.png', 'icons/favicon-16.png'],
  ['icons/favicon-32.png', 'icons/favicon-32.png'],
  ['icons/apple-touch-icon.png', 'icons/apple-touch-icon-180.png'],
  ['icons/icon-192.png', 'icons/icon-192.png'],
  ['icons/icon-512.png', 'icons/icon-512.png'],
  ['icons/glyphs/phone.svg', 'icons/glyphs/phone.svg'],
  ['icons/glyphs/mail.svg', 'icons/glyphs/mail.svg'],
  ['icons/glyphs/web.svg', 'icons/glyphs/web.svg'],
  ['email-signature.html', 'email-signature.html'],
  ['signature-plaintext.txt', 'signature-plaintext.txt'],
  ['newsletter-template.html', 'newsletter-template.html'],
  ['letterhead.html', 'print/letterhead.html'],
  ['business-card.html', 'print/business-card.html'],
];

// Rendered, not copied: the kit's seals are the two SVGs at 128 px, the same sizes the site serves.
// The contact glyphs are rendered at 42 px — 3x the 14 px they are drawn at in the signature.
const RENDERED = [
  ['seal-ink.svg', 'png/seal-ink-128.png', 128],
  ['seal-paper.svg', 'png/seal-paper-128.png', 128],
  ['icons/glyphs/phone.svg', 'png/glyph-phone-42.png', 42],
  ['icons/glyphs/mail.svg', 'png/glyph-mail-42.png', 42],
  ['icons/glyphs/web.svg', 'png/glyph-web-42.png', 42],
];

const rsvg = (svg, dest, px) =>
  execFileSync('rsvg-convert', ['-w', px, '-h', px, svg, '-o', dest], { stdio: 'pipe' });

const stage = await mkdtemp(path.join(os.tmpdir(), 'press-kit-'));
const kit = path.join(stage, KIT_NAME);
try {
  await mkdir(kit, { recursive: true });

  for (const [src, dest] of VERBATIM) {
    const abs = path.join(kit, dest);
    await mkdir(path.dirname(abs), { recursive: true });
    await copyFile(path.join(BRAND, src), abs);
  }

  for (const [src, dest, px] of RENDERED) {
    const abs = path.join(kit, dest);
    await mkdir(path.dirname(abs), { recursive: true });
    rsvg(path.join(BRAND, src), abs, px);
  }

  const boards = (await readdir(path.join(BRAND, 'boards'))).filter((f) => f.endsWith('.png')).sort();
  const boardDir = path.join(kit, 'boards');
  await mkdir(boardDir, { recursive: true });
  for (const board of boards) {
    const out = path.join(boardDir, board.replace(/\.png$/, '.jpg'));
    execFileSync('sips', ['-s', 'format', 'jpeg', '-s', 'formatOptions', '82',
      '--resampleWidth', String(BOARD_WIDTH), path.join(BRAND, 'boards', board), '--out', out],
      { stdio: 'pipe' });
  }

  await writeFile(path.join(kit, 'LICENSE.txt'), [
    'Hasan Abbas Sorathiya — brand assets',
    '',
    'You may use these files to write about, present or link to Hasan Abbas Sorathiya and the apps at',
    'hasanabbassorathiya.tech. Please keep the attribution intact and do not remix the identity itself:',
    '',
    '  • The monogram is ink on paper or paper on ink. No third colour, no gradient, no shadow, no outline.',
    '  • Clearspace on all four sides at least the cap height of the H.',
    '  • Do not rotate, stretch, re-letter or rebuild the mark from a font.',
    '  • For anything not covered here, ask first: hasanabbassorathiya12@gmail.com',
    '',
    'Full specification: BRAND.md. Usage and rebuild instructions: README.md.',
    '',
  ].join('\n'));

  await rm(OUT, { force: true });
  execFileSync('zip', ['-X', '-r', '-q', OUT, KIT_NAME], { cwd: stage, stdio: 'pipe' });

  const entries = [];
  const walk = async (dir, prefix = '') => {
    for (const name of (await readdir(dir)).sort()) {
      const abs = path.join(dir, name);
      if (statSync(abs).isDirectory()) await walk(abs, `${prefix}${name}/`);
      else entries.push(`${prefix}${name} ${statSync(abs).size}`);
    }
  };
  await walk(kit);

  const sha = createHash('sha256').update(readFileSync(OUT)).digest('hex');
  console.log(`press-kit.zip → ${path.relative(REPO_ROOT, OUT)}`);
  console.log(`  ${entries.length} files · ${statSync(OUT).size.toLocaleString('en-US')} B · sha256 ${sha.slice(0, 16)}…`);
  console.log(`  boards ${boards.length} PNG → ${boards.length} JPEG @ ${BOARD_WIDTH}px`);
} finally {
  await rm(stage, { recursive: true, force: true });
}
