import assert from 'node:assert/strict';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';

const root = process.cwd();
const { resume } = await import('../src/content/resume.js');

const pdfPath = path.join(root, 'public/hasan-abbas-sorathiya-resume.pdf');
const { size } = await stat(pdfPath);
assert.ok(size > 25000, `resume PDF is too small (${size} bytes)`);
const pdf = await readFile(pdfPath);
assert.equal(pdf.subarray(0, 5).toString('latin1'), '%PDF-', 'resume PDF has no PDF header');
assert.match(pdf.subarray(-2048).toString('latin1'), /%%EOF/, 'resume PDF is truncated');

// renderToString separates adjacent text nodes with comments; they are not visible.
const html = (await readFile(path.join(root, 'dist/resume.html'), 'utf8')).replaceAll('<!-- -->', '');
assert.match(
  html,
  /<link rel="canonical" href="https:\/\/hasanabbassorathiya\.tech\/resume"/,
  'resume canonical is missing',
);
assert.match(html, /<title>Résumé · Hasan Abbas Sorathiya/, 'resume title is missing');
assert.equal((html.match(/<h1\b/g) || []).length, 1, 'resume needs exactly one h1');
assert.ok(html.includes('Updated 31 October 2026'), 'resume update date is missing');
assert.ok(html.includes('/hasan-abbas-sorathiya-resume.pdf'), 'resume PDF link is missing');
assert.doesNotMatch(html, /flowcv\.com/, 'old FlowCV link should not appear in the resume shell');
for (const role of resume.roles) {
  assert.ok(html.includes(role.company), `missing role: ${role.company}`);
  assert.ok(html.includes(role.period), `missing period: ${role.period}`);
  assert.ok(html.includes(role.location), `missing location: ${role.location}`);
}
for (const app of resume.apps) assert.ok(html.includes(app.name), `missing app: ${app.name}`);

const sitemap = await readFile(path.join(root, 'dist/sitemap.xml'), 'utf8');
assert.match(
  sitemap,
  /<loc>https:\/\/hasanabbassorathiya\.tech\/resume<\/loc>/,
  'resume is missing from the sitemap',
);

console.log(`resume: PDF ${size} bytes, ${resume.roles.length} roles, ${resume.apps.length} products, sitemap OK`);
