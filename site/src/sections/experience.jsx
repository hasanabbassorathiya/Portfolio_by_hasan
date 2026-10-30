import React from 'react';
import { useReveal } from '../lib/motion';
import { useExperiences } from '../lib/live-content';

export function Experience() {
  const roles = useExperiences();
  const { ref, style } = useReveal(0);
  return (
    <section id="work" className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(4rem,10vw,9rem)]">
      <div ref={ref} style={style}>
        <p className="mb-3 font-mono text-xs uppercase tracking-[0.25em] text-accent">7+ years</p>
        <h2 className="mb-4 font-display text-[clamp(1.9rem,4.2vw,3.1rem)] tracking-[-0.025em]">
          Where I&apos;ve <em className="font-serif font-normal italic text-accent">shipped</em>
        </h2>
        <p className="mb-12 max-w-[60ch] leading-[1.7] text-text-muted">
          Enterprise mobility, fintech, e-commerce, streaming, and community platforms — usually
          owning delivery from architecture to the store.
        </p>
      </div>
      <ol className="flex flex-col">
        {roles.map((role) => (
          <li
            key={role.company}
            className="group grid grid-cols-1 gap-x-8 gap-y-3 rounded-xl border-t border-[var(--border)] px-0 py-7 transition-colors hover:border-accent/30 md:grid-cols-[9.5rem_1fr] md:px-4 md:hover:bg-surface/40"
          >
            <div className="flex flex-col gap-1 pt-1">
              <span className="font-mono text-[11px] text-text-muted">{role.period}</span>
              <span className="font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted">{role.location}</span>
            </div>
            <div className="flex flex-col gap-2">
              <div className="flex flex-wrap items-baseline gap-x-3">
                <h3 className="font-display text-xl transition-colors group-hover:text-accent">{role.company}</h3>
                <span className="text-sm text-text-muted">{role.role}</span>
              </div>
              <p className="max-w-[68ch] text-[0.95rem] leading-[1.7] text-text">{role.summary}</p>
              <ul className="flex max-w-[70ch] flex-col gap-1.5">
                {role.points.map((point) => (
                  <li key={point} className="flex items-start gap-2.5 text-sm leading-[1.65] text-text-muted">
                    <span className="mt-[0.55rem] h-1 w-1 shrink-0 rounded-full bg-accent/70" aria-hidden="true" />
                    {point}
                  </li>
                ))}
              </ul>
            </div>
          </li>
        ))}
      </ol>
    </section>
  );
}
