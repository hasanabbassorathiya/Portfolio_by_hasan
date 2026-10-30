import React, { useEffect, useRef, useState } from 'react';
import { trackCta } from '../lib/analytics';

const WORD = 'hire';

export function HireEgg() {
  const [open, setOpen] = useState(false);
  const buffer = useRef('');

  useEffect(() => {
    const onKey = (e) => {
      if (e.metaKey || e.ctrlKey || e.altKey) return;
      const el = e.target;
      if (!el) return;
      const tag = el.tagName;
      if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || el.isContentEditable) return;
      if (e.key.length !== 1) return;
      buffer.current = (buffer.current + e.key.toLowerCase()).slice(-WORD.length);
      if (buffer.current === WORD) {
        buffer.current = '';
        setOpen(true);
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  useEffect(() => {
    if (!open) return undefined;
    const onKey = (e) => {
      if (e.key === 'Escape') setOpen(false);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open]);

  if (!open) return null;

  return (
    <div
      role="status"
      aria-live="polite"
      className="fixed bottom-4 right-4 z-50 w-[min(24rem,calc(100vw-2rem))] rounded-xl border border-accent/40 bg-canvas/95 p-5 shadow-2xl backdrop-blur-md print:hidden"
    >
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="font-mono text-[10px] uppercase tracking-[0.22em] text-accent">Easter egg</p>
          <p className="mt-2 font-display text-lg leading-snug">You typed the magic word.</p>
          <p className="mt-1 text-sm leading-relaxed text-text-muted">
            I&apos;m taking on senior Flutter &amp; AI roles and consulting work.
          </p>
        </div>
        <button
          type="button"
          onClick={() => setOpen(false)}
          aria-label="Dismiss easter egg"
          className="-mr-1 -mt-1 grid h-8 w-8 shrink-0 place-items-center rounded-md text-text-muted transition-colors hover:bg-[var(--border)] hover:text-text"
        >
          <span aria-hidden="true" className="text-lg leading-none">×</span>
        </button>
      </div>
      <a
        href="mailto:hasanabbassorathiya12@gmail.com?subject=Let%27s%20work%20together"
        onClick={() => trackCta('hire', 'easter-egg')}
        className="mt-4 inline-flex rounded-lg bg-accent-solid px-4 py-2 font-body text-sm font-medium text-on-accent transition hover:brightness-110 active:translate-y-px"
      >
        Email me →
      </a>
    </div>
  );
}
