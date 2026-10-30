import React from 'react';
import { Link } from '../lib/router';
import { useReveal } from '../lib/motion';
import { trackCta } from '../lib/analytics';

const talks = [
  {
    title: 'Riverpod without the ceremony',
    blurb:
      'How I structure state so a small team can ship weekly — and the three patterns I retired after seeing them in production.',
    tag: 'Flutter architecture',
    essay: '/blog/riverpod-patterns-production',
  },
  {
    title: 'AI features users trust',
    blurb:
      'Guardrails, evaluation, and latency budgets for shipping RAG and agents inside a mobile product instead of a demo.',
    tag: 'AI in production',
    essay: '/blog/shipping-ai-features-flutter-trust',
  },
  {
    title: 'Localization that earns 4.9 stars',
    blurb:
      'A Gujarati-first prayer app in five languages — what offline content and proper prayer-time math taught me about retention.',
    tag: 'Product & growth',
    essay: '/blog/localization-4-6-star-app',
  },
];

export function Speaking() {
  const { ref, style } = useReveal(0);
  return (
    <section id="speaking" ref={ref} style={style} className="border-t border-[var(--border)]">
      <div className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(4rem,8vw,7rem)]">
        <div className="grid gap-12 lg:grid-cols-[0.85fr_1.15fr] lg:gap-20">
          <div className="flex flex-col gap-5">
            <p className="font-mono text-xs uppercase tracking-[0.25em] text-accent">Speaking</p>
            <h2 className="max-w-[14ch] font-display text-[clamp(2rem,4.5vw,3.4rem)] leading-[1.04] tracking-[-0.03em]">
              The <em className="font-serif font-normal italic text-accent">talks</em> I can give
            </h2>
            <p className="max-w-[46ch] leading-[1.75] text-text-muted">
              Every essay on this site started as a problem in production. These are the versions I
              can bring to your meetup, conference, or engineering team — remote or in person across
              the UAE.
            </p>
            <p className="font-mono text-[10px] uppercase leading-relaxed tracking-[0.16em] text-text-muted">
              20–40 minutes · English or Hindi · Abstracts and slides on request
            </p>
            <div className="flex flex-wrap gap-3">
              <a
                href="mailto:hasanabbassorathiya12@gmail.com?subject=Speaking%20invitation"
                onClick={() => trackCta('email', 'speaking')}
                className="rounded-lg bg-accent-solid px-6 py-3 font-medium text-on-accent transition hover:brightness-110"
              >
                Invite me to speak
              </a>
              <Link
                to="/blog/from-shipping-apps-to-gde"
                className="rounded-lg border border-[var(--border)] px-6 py-3 text-text transition hover:border-accent/50 hover:text-accent"
              >
                The GDE plan →
              </Link>
            </div>
          </div>

          <ul className="flex flex-col divide-y divide-[var(--border)] border-y border-[var(--border)]">
            {talks.map((talk, index) => (
              <li key={talk.title} className="group py-6">
                <div className="flex items-baseline gap-4">
                  <span className="font-mono text-[11px] text-accent/90">0{index + 1}</span>
                  <div className="flex flex-col gap-2">
                    <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                      <h3 className="font-display text-xl leading-snug">{talk.title}</h3>
                      <span className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted">
                        {talk.tag}
                      </span>
                    </div>
                    <p className="max-w-[58ch] text-sm leading-[1.7] text-text-muted">{talk.blurb}</p>
                    <Link
                      to={talk.essay}
                      className="w-fit font-mono text-[11px] uppercase tracking-[0.12em] text-text-muted transition-colors hover:text-accent"
                    >
                      Read the essay →
                    </Link>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}
