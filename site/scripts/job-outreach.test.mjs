import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  MAX_OUTREACH_PER_WINDOW,
  EXPERIENCE_CLAIM,
  RESUME_URL,
  canRecordSend,
  mailtoFor,
  normalizeContact,
  parseCsv,
  renderDraft,
  renderEml,
} from './job-outreach.mjs';

const verifiedContact = {
  name: 'Maya Recruiter',
  company: 'Remote Mobility Labs',
  role: 'Senior Flutter Engineer',
  email: 'maya@example.com',
  job_url: 'https://jobs.example.com/flutter',
  source: 'Official company job posting',
  verified: 'true',
};

test('CSV parser handles quoted commas and newlines', () => {
  const rows = parseCsv('company,role,personalization\n"Acme, Inc.",Engineer,"Line one\nLine two"\n');
  assert.deepEqual(rows, [{
    company: 'Acme, Inc.',
    role: 'Engineer',
    personalization: 'Line one\nLine two',
    _row: 2,
  }]);
});

test('contact validation requires a source and explicit verification', () => {
  assert.throws(() => normalizeContact({ ...verifiedContact, verified: 'no' }), /must be verified/);
  assert.throws(() => normalizeContact({ ...verifiedContact, source: '' }), /Source is required/);
  assert.throws(() => normalizeContact({ ...verifiedContact, email: 'not-an-email' }), /Invalid email/);
});

test('drafts match the role to profile evidence and contain no header injection', () => {
  const contact = normalizeContact(verifiedContact);
  const draft = renderDraft(contact);
  assert.match(draft.subject, /Flutter \/ Mobile/);
  assert.match(draft.body, /Flutter and Dart/);
  assert.ok(draft.body.includes(`${EXPERIENCE_CLAIM} years`));
  assert.match(draft.body, new RegExp(RESUME_URL.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
  assert.match(draft.body, /hasanabbassorathiya\.tech/);
  assert.doesNotMatch(renderEml({ ...contact, email: 'x@example.com\r\nBcc:bad@example.com' }), /\r\nBcc:/);
});

test('mailto output is encoded for one reviewed recipient', () => {
  const contact = normalizeContact(verifiedContact);
  const mailto = mailtoFor(contact);
  assert.match(mailto, /^mailto:maya%40example\.com\?/);
  assert.match(mailto, /subject=/);
  assert.match(mailto, /body=/);
});

test('send ledger enforces the rolling outreach cap', () => {
  const now = new Date('2026-11-02T12:00:00.000Z');
  const recent = Array.from({ length: MAX_OUTREACH_PER_WINDOW }, (_, index) => ({
    sentAt: new Date(now.valueOf() - index * 60_000).toISOString(),
  }));
  assert.equal(canRecordSend({ contacts: recent }, now), false);
  assert.equal(canRecordSend({ contacts: [{ sentAt: '2026-10-01T12:00:00.000Z' }] }, now), true);
});
