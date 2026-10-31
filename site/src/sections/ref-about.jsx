import React, { useEffect, useRef, useState } from 'react';
import { Link } from '../lib/router';
import { useClients, usePosts, useProfile } from '../lib/live-content';
import { useSiteMetrics } from '../lib/site-metrics';
import { trackCta, trackEnquiry, trackOutbound, trackResume } from '../lib/analytics';
import { Arrow, ArrowBadge, Kicker, SectionHead } from './ref-ui';

// Build-time only: without VITE_CAL_URL the booking link is absent from the bundle and the DOM.
const bookingUrl = /^https:\/\/\S+$/.test(import.meta.env.VITE_CAL_URL || '')
  ? import.meta.env.VITE_CAL_URL
  : null;

const tools = [
  { label: 'Mobile', items: ['Flutter', 'Dart', 'Riverpod', 'BLoC', 'Firebase', 'Android TV'] },
  { label: 'AI', items: ['LangChain', 'RAG', 'Agents', 'MCP', 'OpenAI', 'Claude'] },
  { label: 'Full-stack', items: ['MongoDB', 'Express', 'React', 'Node.js', 'AWS', 'GitHub Actions'] },
];

const openSource = [
  ['stoolap-flutter', 'Pure-Rust embedded SQL for Flutter with vector search and reactive streams.', 'https://pub.dev/packages/stoolap_flutter'],
  ['BULBVPN', 'A secure Flutter VPN built for restricted networks.'],
  ['ChucklePlay', 'Lightweight multi-platform IPTV player.'],
  ['wp-mcp-server', 'MCP server for the WordPress REST API.'],
  ['duas-crm', 'Content operations CRM behind Duas and Aamal.'],
];

const channels = [
  ['Email', 'hasanabbassorathiya12@gmail.com', 'mailto:hasanabbassorathiya12@gmail.com'],
  ['LinkedIn', '/in/hasanabbassorathiya', 'https://www.linkedin.com/in/hasanabbassorathiya/'],
  ['Phone', '+971 58 960 2320', 'tel:+971589602320'],
  ['Résumé', 'hasanabbassorathiya.tech/resume', '/resume'],
];

const projectTypes = ['Employment', 'New application', 'Existing improvement', 'AI integration', 'Technical consultation', 'Other'];
const emptyEnquiry = { name: '', email: '', type: projectTypes[0], message: '', website: '', consent: false };
const enquiryTimeoutMs = 15000;
const uncertainEnquiry = 'We could not confirm whether your enquiry was saved. Retry without editing to safely check the same enquiry, or email me directly.';
const enquiryErrors = {
  409: 'This request conflicts with an already used request ID. Edit your details to start a new enquiry, or email me directly.',
  422: 'Please review your name, email, project details (20–10,000 characters) and consent, then try again.',
  429: 'Too many enquiries right now. Please wait before trying again, or email me directly.',
  503: 'Enquiry storage is currently unavailable. Please try again later, or email me directly.',
};

export function About() {
  const metrics = useSiteMetrics();
  const profile = useProfile();
  const clients = useClients();
  const good2go = clients.find((client) => client.slug === 'good2go-loans');
  const facts = [
    ['Based in', profile.location],
    ['Experience', metrics.yearsLabel && `${metrics.yearsLabel} years`],
    ['App profiles', metrics.appsCount > 0 && String(metrics.appsCount)],
    ['Languages', 'English · Hindi · Gujarati · Urdu'],
    ['Education', profile.education],
    ['Availability', profile.availability_detail || profile.availability],
  ].filter(([, value]) => value);

  return (
    <section id="about" className="border-y border-ink/10 bg-surface">
      <div className="mx-auto grid max-w-[1180px] gap-12 px-5 py-24 md:py-32 lg:grid-cols-[1.05fr_0.95fr] lg:gap-16">
        <div className="flex flex-col">
          <Kicker>Who I am</Kicker>
          <h2 className="mt-5 max-w-[18ch] font-serif text-[clamp(2.3rem,4.6vw,3.9rem)] font-normal leading-[1.01] tracking-[-0.015em] text-text">
            {metrics.yearsLabel} years of shipping products people <em className="italic text-hl-a">keep</em> —
          </h2>
          <div className="mt-7 flex flex-col gap-5 text-[15px] leading-[1.8] text-text-muted">
            <p className="text-text">not just launch, forget, and rewrite a year later.</p>
            <p>
              I&apos;m a senior software and AI engineer in Dubai. For more than {metrics.years} years
              I have shipped mobile products across fintech, e-commerce, mobility, and community
              platforms, with named outcomes such as Good2Go Loans reaching 50,000+ users in
              New Zealand.
            </p>
            <p>
              Most recently I led mobile engineering at Chalhoub Group for EVLAB: architecture,
              delivery, releases, and production support. Before that I led Flutter teams at
              Belong Interactive and built digital lending at Beedev
              {good2go ? ` for ${good2go.metric} users` : ''} in New Zealand.
            </p>
            <p>
              Now I work independently across mobile products — iOS and Android delivery, with
              Flutter as my primary cross-platform stack — plus backend, API and full-stack
              integrations, AI systems and automation. From product UI/UX to APIs and app audits,
              the focus is useful software with clear ownership. I am also working toward Google
              Developer Expert in Flutter through writing, talks, and open source.
            </p>
            <p className="text-text/90">
              Open to senior and lead roles, consulting, and product collaborations.
            </p>
          </div>

          <div className="mt-8 flex flex-wrap gap-2.5">
            <a
              href="/resume"
              onClick={() => trackResume('about')}
              className="rounded-full bg-accent-solid px-4 py-2.5 text-sm font-medium text-on-accent transition duration-300 hover:bg-accent-solid/90"
            >
              Résumé
            </a>
            {[
              ['LinkedIn', 'https://www.linkedin.com/in/hasanabbassorathiya/'],
              ['GitHub', 'https://github.com/hasanabbassorathiya'],
              ['App Store', 'https://apps.apple.com/ae/developer/hasan-abbas-sorathiya/id1734376366'],
              ['Google Play', 'https://play.google.com/store/apps/dev?id=5895887615343030170'],
            ].map(([label, href]) => (
              <a
                key={label}
                href={href}
                target="_blank"
                rel="noreferrer"
                onClick={() => trackOutbound(label, href)}
                className="rounded-full border border-ink/15 px-4 py-2.5 text-sm text-text transition-colors duration-300 hover:border-ink/40"
              >
                {label} ↗
              </a>
            ))}
          </div>
        </div>

        <div className="flex flex-col gap-4">
          <div className="rounded-[1.6rem] bg-band p-7 text-band-fg">
            <Kicker tone="dark">Facts</Kicker>
            <dl className="mt-5 grid gap-x-6 gap-y-4 sm:grid-cols-2">
              {facts.map(([label, value]) => (
                <div key={label} className="flex flex-col gap-1">
                  <dt className="font-mono text-[9px] uppercase tracking-[0.18em] text-band-fg/70">
                    {label}
                  </dt>
                  <dd className="text-sm text-band-fg/90">{value}</dd>
                </div>
              ))}
            </dl>
          </div>

          <div className="rounded-[1.6rem] border border-ink/10 bg-canvas p-7">
            <Kicker>Tools I reach for</Kicker>
            <div className="mt-5 flex flex-col gap-4">
              {tools.map((group) => (
                <div key={group.label}>
                  <p className="font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
                    {group.label}
                  </p>
                  <div className="mt-2 flex flex-wrap gap-1.5">
                    {group.items.map((item) => (
                      <span
                        key={item}
                        className="rounded-full border border-ink/10 px-2.5 py-1 font-mono text-[10px] text-text/75"
                      >
                        {item}
                      </span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-[1.6rem] border border-ink/10 bg-canvas p-7">
            <div className="flex items-center justify-between gap-3">
              <Kicker>Open source</Kicker>
              <a
                href="https://github.com/hasanabbassorathiya"
                target="_blank"
                rel="noreferrer"
                onClick={() => trackOutbound('GitHub', 'https://github.com/hasanabbassorathiya')}
                className="text-xs text-text-muted transition-colors duration-300 hover:text-text"
              >
                All repos ↗
              </a>
            </div>
            <ul className="mt-4 flex flex-col divide-y divide-ink/10">
              {openSource.map(([name, copy, pubdev]) => (
                <li key={name} className="py-3 first:pt-0 last:pb-0">
                  <p className="font-mono text-xs text-text">{name}</p>
                  <p className="mt-1 text-xs leading-relaxed text-text-muted">{copy}</p>
                  {pubdev && (
                    <a
                      href={pubdev}
                      target="_blank"
                      rel="noreferrer"
                      onClick={() => trackOutbound(`${name} on pub.dev`, pubdev)}
                      className="mt-1.5 inline-flex min-h-9 items-center text-xs text-accent underline decoration-accent/40 underline-offset-4 hover:decoration-accent"
                    >
                      Published on pub.dev ↗
                    </a>
                  )}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}

export function WritingSection() {
  const posts = usePosts();
  const latest = posts.slice(0, 3);
  return (
    <section id="writing" className="mx-auto max-w-[1180px] px-5 py-24 md:py-32">
      <SectionHead
        kicker="Writing"
        title={
          <>
            Thinking in <em className="italic text-accent">public</em>
          </>
        }
        blurb="Essays on Flutter architecture, AI in production, and building apps people keep using."
        action={
          <Link
            to="/blog"
            className="group inline-flex items-center rounded-full border border-ink/15 py-1.5 pl-4 pr-1.5 text-sm text-text transition-colors duration-300 hover:border-ink/40"
          >
            All essays
            <ArrowBadge tone="dark" />
          </Link>
        }
      />

      <div className="mt-12 grid gap-4 md:grid-cols-3">
        {latest.map((post) => (
          <Link
            key={post.slug}
            to={`/blog/${post.slug}`}
            className="group flex flex-col rounded-[1.5rem] border border-ink/10 bg-surface p-6 transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:-translate-y-1 hover:border-ink/25"
          >
            <div className="flex items-center justify-between gap-3 font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted">
              <span>{post.category}</span>
              <span>{post.dateLabel}</span>
            </div>
            <h3 className="mt-6 font-serif text-[1.65rem] leading-[1.1] tracking-[-0.01em] text-text">
              {post.title}
            </h3>
            <p className="mt-3 flex-1 text-sm leading-[1.65] text-text-muted">{post.dek}</p>
            <div className="mt-6 flex items-center justify-between border-t border-ink/10 pt-4 font-mono text-[9px] uppercase tracking-[0.14em] text-text-muted">
              <span>{post.minutes} min read</span>
              <span className="text-text transition-colors duration-300 group-hover:text-accent">
                <Arrow />
              </span>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}

export function Contact() {
  const [form, setForm] = useState(emptyEnquiry);
  const [submission, setSubmission] = useState({ phase: 'idle' });
  const [time, setTime] = useState(null);
  const attempt = useRef(null);
  const activeRequest = useRef(null);
  const pending = submission.phase === 'pending';

  useEffect(() => () => {
    const active = activeRequest.current;
    activeRequest.current = null;
    if (active) {
      window.clearTimeout(active.timeout);
      active.controller.abort();
    }
  }, []);

  useEffect(() => {
    const format = new Intl.DateTimeFormat('en-GB', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
      timeZone: 'Asia/Dubai',
    });
    const tick = () => setTime(format.format(new Date()));
    tick();
    const id = window.setInterval(tick, 30000);
    return () => window.clearInterval(id);
  }, []);

  const update = (field) => (event) => {
    if (activeRequest.current) return;
    const value = field === 'consent' ? event.target.checked : event.target.value;
    // Any edit makes a new enquiry; an unchanged retry keeps the exact serialized payload.
    attempt.current = null;
    setSubmission({ phase: 'idle' });
    setForm((current) => ({ ...current, [field]: value }));
  };

  const onSubmit = async (event) => {
    event.preventDefault();
    if (activeRequest.current || !event.currentTarget.reportValidity()) return;
    const payload = { ...form, name: form.name.trim(), email: form.email.trim(), message: form.message.trim() };
    if (!payload.name || payload.name.length > 120 || payload.email.length > 190
      || payload.message.length < 20 || payload.message.length > 10000
      || !projectTypes.includes(payload.type) || payload.consent !== true) {
      setSubmission({ phase: 'error', message: enquiryErrors[422] });
      return;
    }

    const active = { controller: new AbortController(), timeout: null, timedOut: false };
    activeRequest.current = active; // Synchronous guard, including before React re-renders.
    setSubmission({ phase: 'pending' });
    let savedReference;
    try {
      if (!attempt.current) {
        attempt.current = JSON.stringify({ ...payload, requestId: globalThis.crypto.randomUUID() });
      }
      active.timeout = window.setTimeout(() => {
        active.timedOut = true;
        active.controller.abort();
      }, enquiryTimeoutMs);
      const response = await fetch('/api/enquiries.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: attempt.current,
        signal: active.controller.signal,
      });
      const result = await response.json();
      if (activeRequest.current !== active) return;
      if (response.status !== 201 || result?.ok !== true
        || typeof result.reference !== 'string' || !/^[a-f0-9]{32}$/i.test(result.reference)) {
        setSubmission({ phase: 'error', message: enquiryErrors[response.status] || uncertainEnquiry });
        return;
      }
      savedReference = result.reference;
      attempt.current = null;
      setForm(emptyEnquiry);
      setSubmission({ phase: 'success', reference: savedReference });
    } catch {
      if (activeRequest.current !== active) return;
      setSubmission({
        phase: 'error',
        message: active.timedOut ? `The request timed out. ${uncertainEnquiry}` : uncertainEnquiry,
      });
    } finally {
      window.clearTimeout(active.timeout);
      if (activeRequest.current === active) activeRequest.current = null;
    }
    // Telemetry cannot turn a durable save into a failed submission.
    if (savedReference) trackEnquiry(payload.type);
  };

  return (
    <section id="contact" className="bg-band text-band-fg">
      <div className="mx-auto max-w-[1180px] px-5 pb-20 pt-16 md:py-24">
        <div className="flex flex-col items-start justify-between gap-8 border-b border-band-fg/20 pb-12 md:flex-row md:items-center md:pb-16">
          <div className="min-w-0">
            <Kicker tone="dark">How to contact me</Kicker>
            <h2 className="mt-5 font-serif text-[clamp(3.2rem,7vw,6rem)] font-normal leading-none tracking-[-0.025em]">
              Ready to <em className="italic text-hl-a">ship?</em>
            </h2>
            <p className="mt-5 text-sm leading-relaxed text-band-fg/85 md:text-base">
              Email me at <span className="break-all text-band-fg">hasanabbassorathiya12@gmail.com</span>
            </p>
            <p className="mt-2 text-sm text-band-fg/75">A new product, a team to join, or a system to improve. Let&apos;s talk.</p>
            <Link
              to="/resume"
              onClick={() => trackResume('contact')}
              className="mt-3 inline-flex items-center gap-2 text-sm font-medium text-band-fg underline decoration-band-fg/30 underline-offset-4 transition-colors hover:decoration-band-fg"
            >
              Hiring for a role? Explore my experience
              <span aria-hidden="true">↗</span>
            </Link>
          </div>
          <div className="flex shrink-0 flex-col items-start gap-2 md:items-end">
            <a
              href="mailto:hasanabbassorathiya12@gmail.com"
              onClick={() => trackCta('email', 'contact-primary')}
              className="group inline-flex min-h-14 items-center justify-center rounded-full bg-accent-solid px-8 py-4 text-base font-medium text-on-accent transition-colors hover:bg-accent-solid/90"
            >
              Email me <span aria-hidden="true" className="ml-5 text-xl">↗</span>
            </a>
            {bookingUrl && (
              <a
                href={bookingUrl}
                target="_blank"
                rel="noreferrer"
                onClick={() => trackCta('booking', 'contact')}
                className="inline-flex min-h-11 items-center font-mono text-[10px] uppercase tracking-[0.16em] text-band-fg/70 underline-offset-4 transition-colors hover:text-band-fg hover:underline"
              >
                Prefer a call? Book a time ↗
              </a>
            )}
          </div>
        </div>
        <div className="grid items-start gap-12 pt-12 lg:grid-cols-[0.88fr_1.12fr] lg:gap-16">
        <div className="flex flex-col">
          <h3 className="font-serif text-3xl leading-tight">How to work with me</h3>
          <p className="mt-5 max-w-[48ch] text-[15px] leading-[1.8] text-band-fg/85">
            I work best with teams that have a product in motion and need senior mobile or AI ownership,
            not just another ticket-taker. Starting from scratch? I can help shape the UI, build the app
            and backend, and stay accountable through launch.
          </p>

          <ol className="mt-9 flex flex-col gap-7">
            {[
              ['01', 'Tell me the scope', 'What are you building, what is broken, and when does it need to be live?'],
              ['02', 'We discuss the fit', 'Questions, a rough approach, and whether I am the right fit for the work.'],
              ['03', 'We start with a written plan', 'Scope, milestones, and a price before any work begins.'],
            ].map(([index, title, copy]) => (
              <li key={index} className="flex gap-4">
                <span className="font-serif text-xl leading-none text-hl-a">{index}</span>
                <div>
                  <p className="text-sm font-medium text-band-fg">{title}</p>
                  <p className="mt-1 text-sm leading-[1.65] text-band-fg/80">{copy}</p>
                </div>
              </li>
            ))}
          </ol>

          <div className="mt-9 flex flex-col gap-2.5 border-t border-band-fg/10 pt-6">
            {channels.map(([label, value, href]) => (
              <a
                key={label}
                href={href}
                target={href.startsWith('http') ? '_blank' : undefined}
                rel={href.startsWith('http') ? 'noreferrer' : undefined}
                onClick={() => {
                  if (href.startsWith('mailto:')) trackCta('email', 'contact');
                  else if (label === 'Résumé') trackResume('contact');
                  else trackOutbound(label, href);
                }}
                className="group flex items-baseline justify-between gap-4 text-sm"
              >
                <span className="font-mono text-[9px] uppercase tracking-[0.16em] text-band-fg/70">
                  {label}
                </span>
                <span className="text-right text-band-fg/70 transition-colors duration-300 group-hover:text-band-fg">
                  {value}
                </span>
              </a>
            ))}
          </div>

          <div className="mt-7 inline-flex w-fit items-center gap-2 rounded-full border border-band-fg/15 px-3.5 py-1.5 font-mono text-[9px] uppercase tracking-[0.14em] text-band-fg/55">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" aria-hidden="true" />
            Dubai · {time ? `${time} GST` : 'GST (UTC+4)'} · Available now
          </div>

          <noscript>
            <p className="mt-7 max-w-[46ch] rounded-xl border border-band-fg/20 px-4 py-3 text-sm leading-relaxed text-band-fg/85">
              JavaScript is off, so the enquiry form is hidden. Email{' '}
              <a href="mailto:hasanabbassorathiya12@gmail.com" className="underline underline-offset-2">
                hasanabbassorathiya12@gmail.com
              </a>{' '}
              directly and your message will reach the same inbox.
            </p>
          </noscript>
        </div>

        <form
          onSubmit={onSubmit}
          action="mailto:hasanabbassorathiya12@gmail.com"
          method="post"
          encType="text/plain"
          aria-busy={pending}
          className="flex flex-col gap-4 rounded-[1.75rem] bg-canvas p-6 text-text ring-1 ring-band-fg/10 shadow-[0_40px_120px_-60px_rgba(0,0,0,0.8)] md:p-8"
        >
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-1.5">
              <label htmlFor="contact-name" className="font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
                Name
              </label>
              <input
                id="contact-name"
                name="name"
                type="text"
                required
                maxLength={120}
                disabled={pending}
                autoComplete="name"
                value={form.name}
                onChange={update('name')}
                placeholder="Your name"
                className="rounded-xl border border-ink/15 bg-surface px-4 py-3 text-sm text-text placeholder:text-text-muted focus:border-accent focus:outline-none"
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="contact-email" className="font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
                Email
              </label>
              <input
                id="contact-email"
                name="email"
                type="email"
                required
                maxLength={190}
                disabled={pending}
                autoComplete="email"
                value={form.email}
                onChange={update('email')}
                placeholder="you@company.com"
                className="rounded-xl border border-ink/15 bg-surface px-4 py-3 text-sm text-text placeholder:text-text-muted focus:border-accent focus:outline-none"
              />
            </div>
          </div>

          <div className="flex flex-col gap-1.5">
            <label htmlFor="contact-type" className="font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
              What do you need?
            </label>
            <select
              id="contact-type"
              name="type"
              required
              disabled={pending}
              value={form.type}
              onChange={update('type')}
              className="rounded-xl border border-ink/15 bg-surface px-4 py-3 text-sm text-text focus:border-accent focus:outline-none"
            >
              {projectTypes.map((type) => (
                <option key={type} value={type}>
                  {type}
                </option>
              ))}
            </select>
          </div>

          <div className="flex flex-col gap-1.5">
            <label htmlFor="contact-message" className="font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
              Project
            </label>
            <textarea
              id="contact-message"
              name="message"
              rows="5"
              required
              minLength={20}
              maxLength={10000}
              disabled={pending}
              aria-describedby="contact-message-help"
              value={form.message}
              onChange={update('message')}
              placeholder="What are you building? What is the deadline? Anything already in production?"
              className="resize-y rounded-xl border border-ink/15 bg-surface px-4 py-3 text-sm leading-relaxed text-text placeholder:text-text-muted focus:border-accent focus:outline-none"
            />
            <p id="contact-message-help" className="text-xs leading-relaxed text-text-muted">20–10,000 characters.</p>
          </div>

          <div hidden aria-hidden="true">
            <input
              name="website"
              type="text"
              tabIndex={-1}
              autoComplete="off"
              disabled={pending}
              value={form.website}
              onChange={update('website')}
            />
          </div>
          <div className="flex flex-col gap-2">
            <label htmlFor="contact-consent" className="flex items-start gap-3 text-sm leading-relaxed">
              <input
                id="contact-consent"
                name="consent"
                type="checkbox"
                required
                disabled={pending}
                checked={form.consent}
                onChange={update('consent')}
                aria-describedby="contact-privacy"
                className="mt-1 h-4 w-4 shrink-0 accent-accent-solid focus-visible:outline focus-visible:outline-offset-2"
              />
              I agree to my enquiry being stored so you can respond.
            </label>
            <p id="contact-privacy" className="text-xs leading-relaxed text-text-muted">
              Your name, email and project details are stored privately to review and respond to your enquiry. No marketing.{' '}
              <Link to="/privacy" className="underline decoration-ink/25 underline-offset-2 hover:text-accent">
                Privacy notice
              </Link>
            </p>
          </div>

          <button
            type="submit"
            disabled={pending}
            className="group mt-1 inline-flex items-center justify-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:bg-accent-solid/90 active:scale-[0.99] disabled:cursor-wait disabled:opacity-60"
          >
            {pending ? 'Sending…' : 'Send message'}
            <ArrowBadge tone="dark" />
          </button>
          <p className="text-xs leading-relaxed text-text-muted">
            Prefer email?{' '}
            <a href="mailto:hasanabbassorathiya12@gmail.com" className="text-accent underline decoration-accent/40 underline-offset-4">
              Email me directly
            </a>.
          </p>
          <p role="status" aria-atomic="true" className={submission.phase === 'success' || pending ? 'rounded-xl border border-ink/10 bg-surface px-4 py-3 text-xs leading-relaxed text-text-muted' : 'sr-only'}>
            {pending ? 'Sending your enquiry… Please wait for confirmation.' : null}
            {submission.phase === 'success' ? <>Enquiry saved. Reference: <span className="break-all font-mono">{submission.reference}</span>. Your details are stored for review.</> : null}
          </p>
          {submission.phase === 'error' ? (
            <p role="alert" className="rounded-xl border border-ink/20 bg-surface px-4 py-3 text-xs leading-relaxed text-text">
              {submission.message}
            </p>
          ) : null}
        </form>
        </div>
      </div>
    </section>
  );
}
