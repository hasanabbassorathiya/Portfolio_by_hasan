import React from 'react';
import { Link } from '../lib/router';
import { useSeo } from '../lib/seo';

export function NotFoundPage() {
  useSeo({
    title: 'Page not found · Hasan Abbas Sorathiya',
    description: 'This page does not exist. Head back to the portfolio or read the writing.',
    path: '/404',
    noindex: true,
  });

  return (
    <main className="mx-auto flex min-h-[80vh] max-w-[1360px] flex-col justify-center gap-6 px-[clamp(1.25rem,5vw,4rem)] pt-[68px]">
      <p className="font-mono text-xs uppercase tracking-[0.25em] text-accent">404</p>
      <h1 className="max-w-[20ch] font-serif text-[clamp(2.4rem,6vw,4rem)] leading-[1.05] tracking-[-0.03em]">
        This page went <em className="font-serif italic font-normal text-accent">offline</em>.
      </h1>
      <p className="max-w-[52ch] leading-[1.7] text-text-muted">
        The link may be old, or the page may have moved. The work and the writing are still here.
      </p>
      <div className="flex flex-wrap gap-3">
        <Link to="/" className="rounded-lg bg-accent-solid px-5 py-3 font-medium text-on-accent">
          Back to the portfolio
        </Link>
        <Link to="/apps" className="rounded-lg border border-[var(--border)] px-5 py-3 text-text hover:border-accent/50">
          See the apps
        </Link>
        <Link to="/blog" className="rounded-lg border border-[var(--border)] px-5 py-3 text-text hover:border-accent/50">
          Read the writing
        </Link>
      </div>
    </main>
  );
}
