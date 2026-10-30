import React from 'react';
import { Link } from '../lib/router';
import { useReveal } from '../lib/motion';
import { useProfile } from '../lib/live-content';
import { emailHref } from '../content/profile';
import { trackCta, trackOutbound, trackResume } from '../lib/analytics';

export function Hero() {
  const profile = useProfile();
  const kicker = useReveal(0);
  const name = useReveal(90);
  const sub = useReveal(180);
  const ctas = useReveal(270);
  const footnote = useReveal(340);

  const words = profile.name.trim().split(/\s+/);
  const surname = words.length > 1 ? words.pop() : '';
  const givenName = words.join(' ');
  const channels = [
    { label: 'GitHub', href: profile.github },
    { label: 'LinkedIn', href: profile.linkedin },
    { label: 'Résumé', href: '/resume' },
  ].filter((channel) => channel.href);

  return (
    <section className="relative min-h-[100dvh] overflow-hidden pt-[68px]">
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -right-40 top-24 h-[32rem] w-[32rem] rounded-full bg-accent/[0.04] blur-3xl"
      />
      <div className="mx-auto grid min-h-[calc(100dvh-68px)] max-w-[1360px] items-center gap-12 px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,7vw,5rem)] lg:grid-cols-[1.25fr_0.75fr]">
        <div className="flex flex-col gap-7">
          <p
            ref={kicker.ref}
            style={kicker.style}
            className="flex items-center gap-3 font-mono text-[11px] uppercase tracking-[0.24em] text-accent"
          >
            <span className="relative flex h-2 w-2" aria-hidden="true">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-accent opacity-60" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-accent" />
            </span>
            {profile.availability}
          </p>

          <h1
            ref={name.ref}
            style={name.style}
            className="max-w-[13ch] font-display text-[clamp(2.6rem,7vw,5.4rem)] font-semibold leading-[0.98] tracking-[-0.04em]"
          >
            {givenName}{' '}
            <em className="font-serif font-normal italic text-accent">{surname}</em>
          </h1>

          <p
            ref={sub.ref}
            style={sub.style}
            className="max-w-[56ch] text-[1.02rem] leading-[1.75] text-text-muted"
          >
            {profile.sub}
          </p>

          <div ref={ctas.ref} style={ctas.style} className="flex flex-wrap items-center gap-3">
            <a
              href={emailHref(profile.email)}
              onClick={() => trackCta('email', 'hero')}
              className="rounded-lg bg-accent-solid px-6 py-3.5 font-medium text-on-accent transition hover:brightness-110 active:translate-y-px"
            >
              Let&apos;s work together
            </a>
            <Link
              to="/blog"
              onClick={() => trackCta('writing', 'hero')}
              className="rounded-lg border border-[var(--border)] px-6 py-3.5 text-text transition hover:border-accent/50 hover:text-accent"
            >
              Read the writing
            </Link>
          </div>

          <div
            ref={footnote.ref}
            style={footnote.style}
            className="flex flex-wrap items-center gap-x-5 gap-y-2 border-t border-[var(--border)] pt-5 font-mono text-[11px] uppercase tracking-[0.14em] text-text-muted"
          >
            {channels.map((channel) => (
              <a
                key={channel.label}
                href={channel.href}
                target="_blank"
                rel="noreferrer"
                onClick={() =>
                  channel.label === 'Résumé'
                    ? trackResume('hero')
                    : trackOutbound(channel.label, channel.href)
                }
                className="transition-colors hover:text-accent"
              >
                {channel.label} ↗
              </a>
            ))}
            <span className="ml-auto hidden sm:inline">
              {profile.location} · {profile.phone}
            </span>
          </div>
        </div>

        <div className="relative mx-auto w-full max-w-[24rem]">
          <div className="overflow-hidden rounded-[1.75rem] border border-[var(--border)] bg-surface">
            <img
              src="/hasan.webp"
              alt={`Portrait of ${profile.name}`}
              width="800"
              height="800"
              className="aspect-[4/5] w-full object-cover object-[center_22%]"
              fetchpriority="high"
            />
            <div className="flex items-center justify-between gap-3 border-t border-[var(--border)] px-5 py-4">
              <div>
                <p className="font-display text-lg leading-tight">{profile.name}</p>
                <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted">
                  {profile.caption}
                </p>
              </div>
              <a
                href={profile.linkedin}
                target="_blank"
                rel="noreferrer"
                onClick={() => trackCta('linkedin', 'hero')}
                className="rounded-full border border-accent/40 px-3 py-1.5 font-mono text-[10px] uppercase tracking-[0.12em] text-accent transition hover:bg-accent-solid hover:text-on-accent"
              >
                Connect
              </a>
            </div>
          </div>
          <p className="mt-4 font-mono text-[10px] uppercase leading-relaxed tracking-[0.18em] text-text-muted">
            {profile.footnote}
            <br />
            {profile.education}
          </p>
        </div>
      </div>
    </section>
  );
}
