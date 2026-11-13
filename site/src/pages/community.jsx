import React, { useId, useState } from 'react';
import { trackCommunity, trackCta, trackSubscribe } from '../lib/analytics';
import { SITE_NAME, SITE_URL, useSeo } from '../lib/seo';
import { useSettings } from '../lib/settings';
import { Arrow, ArrowBadge, Check, Kicker } from '../sections/ref-ui';

const offers = [
  {
    title: 'Teardowns, not think-pieces',
    body: 'Real screens, real architecture, real trade-offs. Bring a screen or a schema and leave with specific feedback.',
    points: ['Flutter and native architecture reviews', 'Release and store-review war stories', 'What actually broke in production'],
  },
  {
    title: 'People who have shipped',
    body: 'Engineers from Dubai and beyond who have taken apps through launch, scale, and the quiet year after.',
    points: ['iOS, Android and Flutter practitioners', 'AI and automation builders', 'Designers and indie founders'],
  },
  {
    title: 'Leads and collaborations',
    body: 'Contract work, senior roles, and projects that need a second pair of hands. Shared openly, no recruiter spam.',
    points: ['Referrals between members first', 'Feedback before an app goes live', 'Co-building small products'],
  },
];

const steps = [
  { title: 'Join the server', body: 'One link, no application form. Introduce yourself in #introductions with what you build and what you are stuck on.' },
  { title: 'Bring one problem', body: 'A bug that will not reproduce, a release that slipped, a store rejection. That is the price of admission.' },
  { title: 'Give one answer', body: 'Answer someone else first. The room works when the people ahead of you are the ones replying.' },
];

const audience = [
  'Mobile engineers working in Flutter, Swift or Kotlin',
  'AI builders shipping features people actually use',
  'Designers who want engineering context before handoff',
  'Indie founders maintaining an app after launch',
];

const inputClass =
  'w-full rounded-lg border border-[var(--border)] bg-canvas px-4 py-3 text-sm text-text placeholder:text-text-muted focus:border-accent focus:outline-none disabled:opacity-60';

function SignupForm() {
  const id = useId();
  const [form, setForm] = useState({ name: '', email: '', whatsapp: '' });
  const [consent, setConsent] = useState(false);
  const [trap, setTrap] = useState('');
  const [state, setState] = useState('idle');
  const set = (key) => (event) => setForm((f) => ({ ...f, [key]: event.target.value }));

  const submit = async (event) => {
    event.preventDefault();
    if (state === 'sending') return;
    setState('sending');
    try {
      const res = await fetch('/api/subscribe.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...form, source: 'community', consent, website: trap }),
      });
      if (!res.ok) throw new Error(String(res.status));
      setState('done');
      trackSubscribe('community');
      trackCta('community-signup', 'community-page');
    } catch {
      setState('error');
    }
  };

  if (state === 'done') {
    return (
      <p role="status" className="rounded-[1.4rem] border border-ink/10 bg-surface p-6 text-sm leading-[1.7] text-text">
        You&apos;re on the list. The next community note lands in your inbox — one click
        unsubscribes, and your details are deleted with it.
      </p>
    );
  }

  return (
    <form onSubmit={submit} className="rounded-[1.4rem] border border-ink/10 bg-surface p-6 md:p-7">
      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <label htmlFor={`${id}-name`} className="mb-1.5 block text-xs font-medium text-text">Name</label>
          <input
            id={`${id}-name`}
            type="text"
            required
            maxLength={120}
            autoComplete="name"
            placeholder="Your name"
            value={form.name}
            onChange={set('name')}
            disabled={state === 'sending'}
            className={inputClass}
          />
        </div>
        <div>
          <label htmlFor={`${id}-email`} className="mb-1.5 block text-xs font-medium text-text">Email</label>
          <input
            id={`${id}-email`}
            type="email"
            required
            autoComplete="email"
            inputMode="email"
            placeholder="you@example.com"
            value={form.email}
            onChange={set('email')}
            disabled={state === 'sending'}
            className={inputClass}
          />
        </div>
      </div>
      <div className="mt-4">
        <label htmlFor={`${id}-whatsapp`} className="mb-1.5 block text-xs font-medium text-text">
          WhatsApp <span className="font-normal text-text-muted">(optional)</span>
        </label>
        <input
          id={`${id}-whatsapp`}
          type="tel"
          autoComplete="tel"
          inputMode="tel"
          placeholder="+971 50 123 4567"
          value={form.whatsapp}
          onChange={set('whatsapp')}
          disabled={state === 'sending'}
          className={inputClass}
        />
      </div>
      <div className="mt-4 flex items-start gap-2.5">
        <input
          id={`${id}-consent`}
          type="checkbox"
          required
          checked={consent}
          onChange={(event) => setConsent(event.target.checked)}
          disabled={state === 'sending'}
          className="mt-0.5 h-4 w-4 shrink-0 accent-[#1d3cff]"
        />
        <label htmlFor={`${id}-consent`} className="text-xs leading-[1.6] text-text-muted">
          I agree to receive community emails and to the{' '}
          <a href="/privacy" className="text-text underline decoration-accent/50 underline-offset-4">privacy policy</a>.
          WhatsApp is only used if you ask for a quicker reply.
        </label>
      </div>
      <div style={{ position: 'absolute', left: '-9999px', width: 1, height: 1, overflow: 'hidden' }} aria-hidden="true">
        <label htmlFor={`${id}-website`}>Website</label>
        <input
          id={`${id}-website`}
          name="website"
          tabIndex={-1}
          autoComplete="off"
          value={trap}
          onChange={(event) => setTrap(event.target.value)}
        />
      </div>
      <button
        type="submit"
        disabled={state === 'sending'}
        className="mt-5 inline-flex min-h-11 items-center rounded-full bg-accent-solid px-6 py-2.5 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90 disabled:opacity-60"
      >
        {state === 'sending' ? 'Joining…' : 'Join the list'}
      </button>
      {state === 'error' && (
        <p role="alert" className="mt-3 text-xs leading-[1.6] text-text-muted">
          Something went wrong. Please try again in a moment.
        </p>
      )}
    </form>
  );
}

export function CommunityPage() {
  const settings = useSettings();
  const invite = (settings.discord_invite || '').trim();
  const open = settings.community_enabled !== '0';
  const canJoin = open && invite !== '';

  useSeo({
    title: `Community · Mobile builders · ${SITE_NAME}`,
    description:
      'A community for mobile engineers, AI builders, designers and indie founders: architecture reviews, release war stories, app feedback and referrals. Join the Discord or ask for an invite.',
    path: '/community',
    jsonLd: {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      name: 'Community',
      url: `${SITE_URL}/community`,
      description: 'A community for mobile engineers, AI builders, designers and indie founders.',
      about: { '@type': 'Thing', name: 'Mobile engineering community' },
      isPartOf: { '@type': 'WebSite', url: SITE_URL },
    },
  });

  return (
    <main className="pt-28 md:pt-32">
      <header className="mx-auto max-w-[1180px] px-5 pb-14 pt-8 md:pb-20 md:pt-12">
        <Kicker>Community · Builders in Dubai and online</Kicker>
        <div className="mt-6 grid gap-8 lg:grid-cols-[1.15fr_0.85fr] lg:items-end lg:gap-16">
          <h1 className="max-w-[16ch] font-serif text-[clamp(2.9rem,6.6vw,5.6rem)] font-normal leading-[0.98] tracking-[-0.025em] text-text">
            A room for people who <em className="italic text-accent">ship mobile apps.</em>
          </h1>
          <div>
            <p className="max-w-[54ch] text-[16px] leading-[1.8] text-text-muted">
              Flutter and native engineers, AI builders, designers and indie founders comparing
              notes on the parts nobody blogs about — architecture calls, release weeks, store
              reviews, and keeping an app alive long after launch.
            </p>
            <div className="mt-7 flex flex-wrap items-center gap-x-6 gap-y-3">
              {canJoin ? (
                <a
                  href={invite}
                  target="_blank"
                  rel="noreferrer"
                  onClick={() => {
                    trackCommunity('discord');
                    trackCta('community', 'community-hero');
                  }}
                  className="group inline-flex min-h-11 items-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90"
                >
                  Join the Discord
                  <ArrowBadge tone="dark" />
                </a>
              ) : (
                <a
                  href="#signup"
                  onClick={() => trackCta('community-signup', 'community-hero')}
                  className="group inline-flex min-h-11 items-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90"
                >
                  Join the list
                  <ArrowBadge tone="dark" />
                </a>
              )}
              <a href="#how" className="group inline-flex min-h-11 items-center gap-2 text-sm font-medium text-text rule-link">
                How it works
                <Arrow />
              </a>
            </div>
            {!canJoin && (
              <p className="mt-4 max-w-[52ch] text-xs leading-relaxed text-text-muted">
                {open
                  ? 'The Discord invite is being set up. Join the list below and you will get it first.'
                  : 'The room is opening soon. Join the list below to be added when doors open.'}
              </p>
            )}
          </div>
        </div>
      </header>

      <section aria-label="What the community is for" className="border-y border-ink/10 bg-surface/40">
        <div className="mx-auto max-w-[1180px] px-5 py-14 md:py-20">
          <div className="grid gap-6 md:grid-cols-3">
            {offers.map((offer) => (
              <article key={offer.title} className="rounded-[1.4rem] border border-ink/10 bg-surface p-6">
                <h2 className="font-serif text-2xl leading-tight text-text">{offer.title}</h2>
                <p className="mt-3 text-sm leading-[1.7] text-text-muted">{offer.body}</p>
                <ul className="mt-5 space-y-2.5">
                  {offer.points.map((point) => (
                    <li key={point} className="flex gap-2.5 text-sm leading-[1.6] text-text">
                      <Check />
                      {point}
                    </li>
                  ))}
                </ul>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section id="how" aria-labelledby="how-title" className="mx-auto max-w-[1180px] px-5 py-16 md:py-24">
        <div className="grid gap-10 lg:grid-cols-[0.9fr_1.1fr] lg:gap-16">
          <div>
            <Kicker>How it works</Kicker>
            <h2 id="how-title" className="mt-5 max-w-[16ch] font-serif text-[clamp(2.3rem,4.6vw,3.8rem)] leading-[1.02] tracking-[-0.015em] text-text">
              Three steps. <em className="italic text-hl-a">No lurkers.</em>
            </h2>
            <p className="mt-5 max-w-[46ch] text-sm leading-[1.75] text-text-muted">
              Building alone means relearning lessons someone else already paid for. This is the
              shortcut — not a course, not a newsletter, a room with people who answer.
            </p>
            <p className="mt-4 max-w-[46ch] text-sm leading-[1.75] text-text-muted">
              It is not for selling services to each other. Members who only broadcast get nudged
              toward the door.
            </p>
          </div>
          <ol className="space-y-4">
            {steps.map((step, index) => (
              <li key={step.title} className="flex gap-5 rounded-[1.4rem] border border-ink/10 bg-surface p-6">
                <span aria-hidden="true" className="font-mono text-xs text-accent">0{index + 1}</span>
                <div>
                  <h3 className="text-base font-medium text-text">{step.title}</h3>
                  <p className="mt-1.5 text-sm leading-[1.7] text-text-muted">{step.body}</p>
                </div>
              </li>
            ))}
          </ol>
        </div>
      </section>

      <section id="signup" aria-labelledby="signup-title" className="mx-auto max-w-[1180px] px-5 pb-16 md:pb-24 scroll-mt-28">
        <div className="grid gap-10 lg:grid-cols-[0.9fr_1.1fr] lg:gap-16">
          <div>
            <Kicker>Stay in the loop</Kicker>
            <h2 id="signup-title" className="mt-5 max-w-[16ch] font-serif text-[clamp(2.3rem,4.6vw,3.8rem)] leading-[1.02] tracking-[-0.015em] text-text">
              Get the notes, <em className="italic text-hl-a">first.</em>
            </h2>
            <p className="mt-5 max-w-[46ch] text-sm leading-[1.75] text-text-muted">
              One email when a teardown, an app or a community note ships. Your name and
              optional WhatsApp stay in my private database — used to reply, never sold,
              never spammed.
            </p>
            <p className="mt-4 max-w-[46ch] text-sm leading-[1.75] text-text-muted">
              Unsubscribe anytime; the link in every email deletes your details for good.
            </p>
          </div>
          <SignupForm />
        </div>
      </section>

      <section aria-labelledby="who-title" className="border-t border-band-fg/15 bg-band">
        <div className="mx-auto grid max-w-[1180px] gap-10 px-5 py-16 md:py-24 lg:grid-cols-[1fr_1fr] lg:gap-16">
          <div>
            <Kicker tone="dark">Who it is for</Kicker>
            <h2 id="who-title" className="mt-5 max-w-[15ch] font-serif text-[clamp(2.3rem,4.6vw,3.8rem)] leading-[1.02] tracking-[-0.015em] text-band-fg">
              Builders who <em className="italic text-hl-a">ship.</em>
            </h2>
          </div>
          <div>
            <ul className="space-y-3">
              {audience.map((item) => (
                <li key={item} className="flex gap-3 text-[15px] leading-[1.7] text-band-fg/85">
                  <span aria-hidden="true" className="mt-2.5 h-1 w-1 shrink-0 rounded-full bg-hl-a" />
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>
    </main>
  );
}
