import React from 'react';
import { Link } from '../lib/router';
import { useReveal } from '../lib/motion';

export function CurrentlyBuilding() {
  const { ref, style } = useReveal();
  return (
    <section ref={ref} style={style} className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2rem,4vw,3rem)]">
      <div className="flex flex-col gap-6 rounded-[1.75rem] border border-[var(--border)] bg-surface p-8 md:flex-row md:items-center md:p-10">
        <span className="relative flex h-4 w-4 shrink-0" aria-hidden="true">
          <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-accent opacity-60" />
          <span className="relative inline-flex h-4 w-4 rounded-full bg-accent" />
        </span>
        <div className="flex flex-col gap-2">
          <p className="font-mono text-xs uppercase tracking-[0.25em] text-text-muted">Currently building</p>
          <h2 className="max-w-[52ch] font-display text-[clamp(1.4rem,3.2vw,2.2rem)] leading-[1.3]">
            Carvan-e-Hind v2 for the community, and AI agents that take real work off people&apos;s desks.
          </h2>
          <p className="max-w-[60ch] text-sm leading-[1.7] text-text-muted">
            Available in parallel for a senior Flutter, AI engineering, or full-stack role —
            Dubai-based, open to remote and consulting.
          </p>
        </div>
        <Link
          to="/#contact"
          className="shrink-0 rounded-lg border border-accent/50 px-5 py-3 text-center font-mono text-xs text-accent transition-colors hover:bg-accent-solid hover:text-on-accent md:ml-auto"
        >
          Start a conversation
        </Link>
      </div>
    </section>
  );
}
