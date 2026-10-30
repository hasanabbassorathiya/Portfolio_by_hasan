import React from 'react';
import { Link } from '../lib/router';
import { useReveal } from '../lib/motion';
import { trackCta, trackOutbound, trackResume } from '../lib/analytics';

const channels = [
  { label: 'Email', value: 'hasanabbassorathiya12@gmail.com', href: 'mailto:hasanabbassorathiya12@gmail.com' },
  { label: 'LinkedIn', value: '/in/hasanabbassorathiya', href: 'https://www.linkedin.com/in/hasanabbassorathiya/' },
  { label: 'GitHub', value: '@hasanabbassorathiya', href: 'https://github.com/hasanabbassorathiya' },
  { label: 'Phone', value: '+971 58 960 2320', href: 'tel:+971589602320' },
  { label: 'Résumé', value: 'hasanabbassorathiya.tech/resume', href: '/resume' },
  { label: 'Support the work', value: 'buymeacoffee.com', href: 'https://buymeacoffee.com/hasanabbassorathiya' },
];

export function Contact() {
  const { ref, style } = useReveal(0);
  return (
    <section id="contact" className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(5rem,12vw,9rem)]">
      <div ref={ref} style={style} className="grid gap-12 lg:grid-cols-[1.15fr_0.85fr] lg:gap-20">
        <div className="flex flex-col gap-6">
          <p className="font-mono text-xs uppercase tracking-[0.25em] text-accent">Available now</p>
          <h2 className="max-w-[14ch] font-display text-[clamp(2.6rem,7vw,5rem)] leading-[1.02] tracking-[-0.035em]">
            Let&apos;s build something <em className="font-serif font-normal italic text-accent">people keep</em>
          </h2>
          <p className="max-w-[56ch] leading-[1.75] text-text-muted">
            I am open to senior Flutter and AI engineering roles, consulting engagements, and
            product collaborations. If you are building in mobile, AI, or both, tell me what you
            are working on — I reply to every real message.
          </p>
          <div className="flex flex-wrap gap-3">
            <a
              href="mailto:hasanabbassorathiya12@gmail.com?subject=Let%27s%20work%20together"
              onClick={() => trackCta('email', 'contact')}
              className="rounded-lg bg-accent-solid px-7 py-4 font-medium text-on-accent transition hover:brightness-110 active:translate-y-px"
            >
              Email me
            </a>
            <a
              href="https://www.linkedin.com/in/hasanabbassorathiya/"
              target="_blank"
              rel="noreferrer"
              onClick={() => trackCta('linkedin', 'contact')}
              className="rounded-lg border border-[var(--border)] px-7 py-4 text-text transition hover:border-accent/50 hover:text-accent"
            >
              Message on LinkedIn
            </a>
          </div>
          <div className="mt-2 flex flex-col gap-2 border-t border-[var(--border)] pt-6">
            <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-text-muted">What I am looking for</p>
            <p className="max-w-[58ch] text-sm leading-[1.7] text-text">
              Senior or lead Flutter engineering · AI / GenAI product engineering ·
              full-stack (MERN) product roles. Dubai-based, open to remote and consulting.
            </p>
          </div>
          <p className="font-mono text-[11px] uppercase tracking-[0.14em] text-text-muted">
            Prefer reading first? <Link to="/blog" className="text-accent hover:underline">Start with the writing →</Link>
          </p>
        </div>

        <div className="flex flex-col justify-center">
          <ul className="flex flex-col divide-y divide-[var(--border)] border-y border-[var(--border)]">
            {channels.map((channel) => (
              <li key={channel.label}>
                <a
                  href={channel.href}
                  target={channel.href.startsWith('http') ? '_blank' : undefined}
                  rel={channel.href.startsWith('http') ? 'noreferrer' : undefined}
                  onClick={() => {
                    if (channel.href.startsWith('mailto:')) trackCta('email', 'contact-channel');
                    else if (channel.label === 'Résumé') trackResume('contact');
                    else trackOutbound(channel.label, channel.href);
                  }}
                  className="group flex items-center justify-between gap-4 py-4"
                >
                  <span className="font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted">
                    {channel.label}
                  </span>
                  <span className="text-right text-sm text-text transition-colors group-hover:text-accent">
                    {channel.value}
                  </span>
                </a>
              </li>
            ))}
          </ul>
          <p className="mt-5 font-mono text-[10px] uppercase leading-relaxed tracking-[0.16em] text-text-muted">
            Dubai, United Arab Emirates · Immediate availability · English, Hindi, Gujarati, Urdu
          </p>
        </div>
      </div>
    </section>
  );
}
