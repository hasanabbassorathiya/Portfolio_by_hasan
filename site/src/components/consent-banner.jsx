import React, { useEffect, useState } from 'react';
import { Link } from '../lib/router';
import { getConsentState, setConsent } from '../lib/analytics';

export function ConsentBanner() {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const sync = () => setVisible(getConsentState() === null);
    sync();
    const open = () => setVisible(true);
    window.addEventListener('hs-consent-open', open);
    return () => window.removeEventListener('hs-consent-open', open);
  }, []);

  if (!visible) return null;

  const choose = (choice) => {
    setConsent(choice);
    setVisible(false);
  };

  return (
    <section
      aria-label="Cookie consent"
      className="fixed bottom-4 left-1/2 z-50 w-[min(42rem,calc(100vw-2rem))] -translate-x-1/2 rounded-xl border border-accent/40 bg-canvas/95 p-5 shadow-2xl backdrop-blur-md print:hidden"
    >
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="max-w-[46ch]">
          <p className="font-mono text-[10px] uppercase tracking-[0.22em] text-accent">Analytics</p>
          <p className="mt-2 text-sm leading-relaxed text-text-muted">
            I measure visits with a cookieless, first-party beacon and optional Google Analytics to see
            which pages help people. Nothing loads until you choose. Change it any time from
            &ldquo;Cookie settings&rdquo; in the footer.{' '}
            <Link to="/privacy" className="underline decoration-ink/25 underline-offset-2 transition-colors hover:text-accent">
              What&rsquo;s measured
            </Link>
          </p>
        </div>
        <div className="flex shrink-0 items-center gap-3">
          <button
            type="button"
            onClick={() => choose('denied')}
            className="inline-flex min-h-11 items-center rounded-full border border-ink/15 px-5 text-sm text-text transition-colors hover:border-ink/40"
          >
            Decline
          </button>
          <button
            type="button"
            onClick={() => choose('granted')}
            className="inline-flex min-h-11 items-center rounded-full bg-accent-solid px-5 text-sm font-medium text-on-accent transition hover:brightness-110 active:translate-y-px"
          >
            Accept
          </button>
        </div>
      </div>
    </section>
  );
}