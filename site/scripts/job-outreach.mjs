import { createHash } from 'node:crypto';
import { execFile } from 'node:child_process';
import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { promisify } from 'node:util';

import { profile } from '../src/content/profile.js';
import { resume } from '../src/content/resume.js';

const execFileAsync = promisify(execFile);
export const MAX_OUTREACH_PER_WINDOW = 5;
export const OUTREACH_WINDOW_DAYS = 7;
export const PORTFOLIO_URL = 'https://hasanabbassorathiya.tech';
export const RESUME_URL = 'https://flowcv.com/resume/pmesjl0q9sm9';
export const EXPERIENCE_CLAIM = '7+';
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const headerPattern = /^[^\r\n,]+$/;

const focusDefinitions = [
  {
    key: 'mobile',
    label: 'Flutter / Mobile',
    pattern: /flutter|dart|mobile|ios|android|android tv|riverpod|bloc|app store|play store/,
    paragraph:
      'My strongest production area is Flutter and Dart: architecture, state management, API integration, testing, CI/CD, and iOS/Android release ownership.',
    evidence: 'EVLAB mobile engineering case study',
    evidenceUrl: 'https://hasanabbassorathiya.tech/work/evlab',
  },
  {
    key: 'ai',
    label: 'AI / GenAI',
    pattern: /\bai\b|genai|llm|rag|agent|mcp|n8n|automation|machine learning/,
    paragraph:
      'I also build bounded AI systems, including LLM integrations, RAG pipelines, agents, MCP tools, and n8n automation with evaluation and human-review boundaries.',
    evidence: 'AI integration and automation work',
    evidenceUrl: 'https://hasanabbassorathiya.tech/services/ai-integration-automation',
  },
  {
    key: 'fullstack',
    label: 'Full-stack / API',
    pattern: /full.?stack|node|react|mern|backend|api|graphql|express|mongodb|firebase|aws|gcp/,
    paragraph:
      'For full-stack work, I connect React or Flutter interfaces to validated APIs and service layers using Node.js, Express, MongoDB, Firebase, AWS, and GCP where appropriate.',
    evidence: 'backend, API, and full-stack integration work',
    evidenceUrl: 'https://hasanabbassorathiya.tech/services/full-stack-api-development',
  },
];

const value = (item, key) => String(item?.[key] ?? '').trim();

export function parseCsv(source) {
  const text = String(source ?? '').replace(/^\uFEFF/, '');
  const rows = [];
  let row = [];
  let cell = '';
  let quoted = false;

  for (let index = 0; index < text.length; index += 1) {
    const character = text[index];
    const next = text[index + 1];
    if (character === '"' && quoted && next === '"') {
      cell += '"';
      index += 1;
    } else if (character === '"') {
      quoted = !quoted;
    } else if (character === ',' && !quoted) {
      row.push(cell);
      cell = '';
    } else if ((character === '\n' || character === '\r') && !quoted) {
      if (character === '\r' && next === '\n') index += 1;
      row.push(cell);
      if (row.some((part) => part.trim() !== '')) rows.push(row);
      row = [];
      cell = '';
    } else {
      cell += character;
    }
  }
  if (cell !== '' || row.length) {
    row.push(cell);
    if (row.some((part) => part.trim() !== '')) rows.push(row);
  }

  if (rows.length === 0) return [];
  const headers = rows[0].map((header) => header.trim().toLowerCase());
  if (headers.some((header) => !header || !headerPattern.test(header))) {
    throw new Error('CSV headers must be non-empty and may not contain commas or newlines.');
  }
  if (new Set(headers).size !== headers.length) throw new Error('CSV headers must be unique.');
  return rows.slice(1).map((parts, rowIndex) => Object.fromEntries(
    headers.map((header, columnIndex) => [header, String(parts[columnIndex] ?? '').trim()]),
  )).map((item, index) => ({ ...item, _row: index + 2 }));
}

function isTrue(valueToCheck) {
  return ['1', 'true', 'yes', 'y', 'verified'].includes(String(valueToCheck).trim().toLowerCase());
}

function contactId(contact) {
  return createHash('sha256')
    .update([contact.email, contact.company, contact.role, contact.jobUrl].join('|').toLowerCase())
    .digest('hex')
    .slice(0, 16);
}

export function normalizeContact(raw) {
  const contact = {
    name: value(raw, 'name'),
    company: value(raw, 'company'),
    role: value(raw, 'role'),
    email: value(raw, 'email').toLowerCase(),
    jobUrl: value(raw, 'job_url') || value(raw, 'joburl'),
    source: value(raw, 'source'),
    country: value(raw, 'country'),
    contactType: value(raw, 'contact_type') || 'recruiter / HR',
    personalization: value(raw, 'personalization'),
    verified: isTrue(raw?.verified),
  };

  const row = raw?._row ? ` (CSV row ${raw._row})` : '';
  if (!contact.company) throw new Error(`Company is required${row}.`);
  if (!contact.role) throw new Error(`Role is required for ${contact.company}${row}.`);
  if (!emailPattern.test(contact.email)) throw new Error(`Invalid email for ${contact.company}${row}.`);
  if (!contact.source) throw new Error(`Source is required for ${contact.email}${row}.`);
  if (!contact.verified) throw new Error(`Email must be verified before outreach: ${contact.email}${row}.`);

  const focus = focusDefinitions.find((definition) => definition.pattern.test(`${contact.role} ${contact.company}`.toLowerCase())) ?? {
    key: 'general',
    label: 'Software Engineering',
    paragraph:
      'I bring senior ownership across mobile, AI, full-stack, API, cloud, and production delivery work, and I adapt the emphasis to the team’s actual needs.',
    evidence: 'selected portfolio work',
    evidenceUrl: PORTFOLIO_URL,
  };

  return {
    ...contact,
    id: contactId(contact),
    focus: focus.key,
    focusLabel: focus.label,
    focusParagraph: focus.paragraph,
    evidence: focus.evidence,
    evidenceUrl: focus.evidenceUrl,
    status: 'draft',
  };
}

function firstName(name) {
  return name ? name.split(/\s+/)[0] : '';
}

export function renderDraft(contact) {
  const greeting = contact.name ? `Hi ${firstName(contact.name)},` : `Hello ${contact.company} recruiting team,`;
  const jobLine = contact.jobUrl
    ? `I saw the ${contact.role} opportunity at ${contact.company} (${contact.jobUrl}) and wanted to reach out directly.`
    : `I saw the ${contact.role} opportunity at ${contact.company} and wanted to reach out directly.`;
  const personalLine = contact.personalization || jobLine;
  const subject = `Remote ${contact.focusLabel} Engineer — ${contact.company}`;
  const body = [
    greeting,
    '',
    personalLine,
    '',
    `I’m Hasan Abbas Sorathiya, a Senior Software & AI Engineer based in Dubai, with ${EXPERIENCE_CLAIM} years of experience shipping production software. I’m open to remote opportunities and can work across time zones.`,
    '',
    contact.focusParagraph,
    '',
    `Relevant profile: ${contact.evidence} — ${contact.evidenceUrl}`,
    '',
    `Portfolio: ${PORTFOLIO_URL}`,
    `Resume: ${RESUME_URL}`,
    `LinkedIn: ${profile.linkedin}`,
    `GitHub: ${profile.github}`,
    '',
    `If this role is still open, I’d be glad to share more context or speak with the hiring team. If you are not the right contact, a pointer to the appropriate person would be appreciated.`,
    '',
    'Best regards,',
    profile.name,
    profile.email,
  ].join('\n');
  return { subject, body };
}

function header(valueToEncode) {
  return String(valueToEncode).replace(/[\r\n]/g, ' ');
}

export function renderEml(contact) {
  const { subject, body } = renderDraft(contact);
  return [
    `To: ${header(contact.email)}`,
    `Subject: ${header(subject)}`,
    `X-Outreach-Id: ${contact.id}`,
    'Content-Type: text/plain; charset="UTF-8"',
    'Content-Transfer-Encoding: 8bit',
    '',
    body,
    '',
  ].join('\r\n');
}

export function mailtoFor(contact) {
  const { subject, body } = renderDraft(contact);
  return `mailto:${encodeURIComponent(contact.email)}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
}

function parseDate(valueToParse) {
  const date = new Date(valueToParse);
  return Number.isNaN(date.valueOf()) ? null : date;
}

export function sentWithinWindow(manifest, now = new Date()) {
  const cutoff = now.valueOf() - OUTREACH_WINDOW_DAYS * 24 * 60 * 60 * 1000;
  return (manifest.contacts ?? []).filter((contact) => {
    const sentAt = parseDate(contact.sentAt);
    return sentAt && sentAt.valueOf() >= cutoff;
  });
}

export function canRecordSend(manifest, now = new Date()) {
  return sentWithinWindow(manifest, now).length < MAX_OUTREACH_PER_WINDOW;
}

function csvEscape(valueToEscape) {
  const escaped = String(valueToEscape ?? '').replace(/"/g, '""');
  return /[",\r\n]/.test(escaped) ? `"${escaped}"` : escaped;
}

function usage() {
  return `Job outreach workflow\n\nCommands:\n  prepare      Validate contacts and write reviewed .eml drafts\n  list         Show draft/sent contacts in a manifest\n  compose      Print or open one reviewed draft in the default mail client\n  mark-sent    Record one message after you sent it manually\n\nPrepare CSV columns:\n  company,role,email,name,job_url,source,verified,country,contact_type,personalization\n\nExamples:\n  npm run outreach -- prepare --contacts contacts.csv --out .outreach\n  npm run outreach -- list --manifest .outreach/manifest.json\n  npm run outreach -- compose --manifest .outreach/manifest.json --id <id> --open\n  npm run outreach -- mark-sent --manifest .outreach/manifest.json --id <id> --confirm\n\nThe workflow allows at most ${MAX_OUTREACH_PER_WINDOW} recorded sends in a rolling ${OUTREACH_WINDOW_DAYS}-day window.\nEvery address must be explicitly marked verified and include a source. No message is sent by this CLI.\n`;
}

function optionsFrom(argv) {
  const options = {};
  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (!item.startsWith('--')) continue;
    const key = item.slice(2).replaceAll('-', '_');
    const next = argv[index + 1];
    if (next && !next.startsWith('--')) {
      options[key] = next;
      index += 1;
    } else {
      options[key] = true;
    }
  }
  return options;
}

async function readJson(file) {
  return JSON.parse(await fs.readFile(file, 'utf8'));
}

async function writeJson(file, data) {
  await fs.mkdir(path.dirname(file), { recursive: true });
  await fs.writeFile(file, `${JSON.stringify(data, null, 2)}\n`);
}

async function prepare(options) {
  if (!options.contacts || !options.out) throw new Error('prepare requires --contacts and --out.');
  const outDir = path.resolve(options.out);
  const rows = parseCsv(await fs.readFile(options.contacts, 'utf8'));
  const contacts = rows.map(normalizeContact);
  const max = Math.min(Number(options.max ?? MAX_OUTREACH_PER_WINDOW), MAX_OUTREACH_PER_WINDOW);
  if (!Number.isInteger(max) || max < 1) throw new Error(`--max must be an integer from 1 to ${MAX_OUTREACH_PER_WINDOW}.`);
  if (contacts.length > max) {
    throw new Error(`Received ${contacts.length} contacts; prepare at most ${max} reviewed contacts per batch.`);
  }
  const manifestPath = path.join(outDir, 'manifest.json');
  let oldManifest = { version: 1, contacts: [] };
  try { oldManifest = await readJson(manifestPath); } catch (error) { if (error.code !== 'ENOENT') throw error; }
  const previous = new Map((oldManifest.contacts ?? []).map((contact) => [contact.id, contact]));
  const incomingIds = new Set(contacts.map((contact) => contact.id));
  const existingContacts = (oldManifest.contacts ?? []).filter((contact) => !incomingIds.has(contact.id));
  const manifest = {
    version: 1,
    generatedAt: new Date().toISOString(),
    profile: { name: profile.name, email: profile.email, website: resume.website },
    contacts: [
      ...existingContacts,
      ...contacts.map((contact) => ({
        ...contact,
        ...(previous.get(contact.id)?.sentAt ? {
          status: 'sent',
          sentAt: previous.get(contact.id).sentAt,
          followUpAt: previous.get(contact.id).followUpAt,
        } : {}),
      })),
    ],
  };
  await fs.mkdir(outDir, { recursive: true });
  for (const contact of manifest.contacts) {
    await fs.writeFile(path.join(outDir, `${contact.id}.eml`), renderEml(contact));
  }
  const reviewRows = [
    ['id', 'company', 'role', 'email', 'verified', 'source', 'status', 'sent_at', 'follow_up_at'],
    ...manifest.contacts.map((contact) => [contact.id, contact.company, contact.role, contact.email, contact.verified, contact.source, contact.status, contact.sentAt ?? '', contact.followUpAt ?? '']),
  ];
  await fs.writeFile(path.join(outDir, 'review.csv'), `${reviewRows.map((row) => row.map(csvEscape).join(',')).join('\n')}\n`);
  await writeJson(manifestPath, manifest);
  console.log(`Prepared ${manifest.contacts.length} draft(s) in ${outDir}`);
  console.log(`Review ${path.join(outDir, 'review.csv')} and send individually with compose --open.`);
}

async function loadManifest(options) {
  if (!options.manifest) throw new Error('This command requires --manifest.');
  return { path: path.resolve(options.manifest), data: await readJson(options.manifest) };
}

async function listContacts(options) {
  const { data } = await loadManifest(options);
  for (const contact of data.contacts ?? []) {
    console.log(`${contact.id}\t${contact.status}\t${contact.company}\t${contact.role}\t${contact.email}`);
  }
}

async function compose(options) {
  const { data } = await loadManifest(options);
  const contact = (data.contacts ?? []).find((item) => item.id === options.id);
  if (!contact) throw new Error(`No contact found for id ${options.id ?? '(missing)'}.`);
  if (contact.status === 'sent') throw new Error(`Contact ${contact.id} is already marked sent.`);
  const mailto = mailtoFor(contact);
  if (!options.open) {
    console.log(mailto);
    return;
  }
  if (process.platform !== 'darwin') throw new Error('--open currently supports macOS only; copy the printed mailto URL instead.');
  await execFileAsync('open', [mailto]);
  console.log(`Opened ${contact.email} in the default mail client. Run mark-sent only after sending.`);
}

async function markSent(options) {
  if (!options.confirm) throw new Error('mark-sent requires --confirm after you have manually sent the reviewed message.');
  const { path: manifestPath, data } = await loadManifest(options);
  const contact = (data.contacts ?? []).find((item) => item.id === options.id);
  if (!contact) throw new Error(`No contact found for id ${options.id ?? '(missing)'}.`);
  if (contact.status === 'sent') throw new Error(`Contact ${contact.id} is already marked sent.`);
  if (!canRecordSend(data)) throw new Error(`The rolling ${OUTREACH_WINDOW_DAYS}-day limit of ${MAX_OUTREACH_PER_WINDOW} recorded sends has been reached.`);
  const now = new Date().toISOString();
  contact.status = 'sent';
  contact.sentAt = now;
  contact.followUpAt = new Date(Date.now() + 8 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
  await writeJson(manifestPath, data);
  console.log(`Recorded ${contact.id} as sent. Follow up once after ${contact.followUpAt} if appropriate.`);
}

export async function main(argv = process.argv.slice(2)) {
  const command = argv[0];
  const options = optionsFrom(argv.slice(1));
  if (!command || command === 'help' || options.help) {
    console.log(usage());
    return;
  }
  if (command === 'prepare') return prepare(options);
  if (command === 'list') return listContacts(options);
  if (command === 'compose') return compose(options);
  if (command === 'mark-sent') return markSent(options);
  throw new Error(`Unknown command: ${command}\n\n${usage()}`);
}

const entry = process.argv[1] ? pathToFileURL(path.resolve(process.argv[1])).href : '';
if (import.meta.url === entry) {
  main().catch((error) => {
    console.error(`outreach: ${error.message}`);
    process.exitCode = 1;
  });
}

export const scriptPath = fileURLToPath(import.meta.url);
