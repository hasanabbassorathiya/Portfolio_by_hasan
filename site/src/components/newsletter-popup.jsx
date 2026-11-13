import React, { useEffect, useId, useRef, useState } from 'react';
import { getConsentState, trackCta, trackSubscribe } from '../lib/analytics';

// Delayed newsletter opt-in. Shows once the visitor has settled the consent
// banner, never stacks on top of it, and stays dismissed for 30 days (forever
// once subscribed). Storage is essential preference-keeping, not analytics.
const DELAY_MS = 45000;
const COOLDOWN_MS = 30 * 24 * 60 * 60 * 1000;
const KEY = 'hs-newsletter-popup';

function readState() {
  try {
    const raw = localStorage.getItem(KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function suppressed() {
  const state = readState();
  if (!state) return false;
  if (state.action === 'subscribe') return true;
  return typeof state.t === 'number' && Date.now() - state.t < COOLDOWN_MS;
}

function record(action) {
  try {
    localStorage.setItem(KEY, JSON.stringify({ t: Date.now(), action }));
  } catch {
    // storage unavailable; the choice still applies for this page view
  }
}

export function NewsletterPopup() {
  const id = useId();
  const [open, setOpen] = useState(false);
  const [email, setEmail] = useState('');
  const [trap, setTrap] = useState('');
  const [state, setState] = useState('idle');
  const dialogRef = useRef(null);
  const inputRef = useRef(null);
  const restoreRef = useRef(null);

  useEffect(() => {
    if (typeof window === 'undefined') return undefined;
    if (suppressed()) return undefined;
    let timer = null;
    let consentHandler = null;
    const onPrivacy = () => window.location.pathname === '/privacy';
    const show = () => {
      if (suppressed() || onPrivacy()) return;
      if (getConsentState() === null) {
        consentHandler = () => {
          window.removeEventListener('hs-consent-change', consentHandler);
          if (!suppressed() && !onPrivacy()) setOpen(true);
        };
        window.addEventListener('hs-consent-change', consentHandler);
        return;
      }
      setOpen(true);
    };
    timer = setTimeout(show, DELAY_MS);
    return () => {
      if (timer) clearTimeout(timer);
      if (consentHandler) window.removeEventListener('hs-consent-change', consentHandler);
    };
  }, []);

  const close = (action) => {
    record(action);
    setOpen(false);
    setState('idle');
    if (restoreRef.current && typeof restoreRef.current.focus === 'function') {
      restoreRef.current.focus();
    }
  };

  useEffect(() => {
    if (!open) return undefined;
    restoreRef.current = document.activeElement;
    const node = dialogRef.current;
    const focusTimer = setTimeout(() => inputRef.current?.focus(), 60);
    const onKey = (event) => {
      if (event.key === 'Escape') {
        event.preventDefault();
        close('dismiss');
        return;
      }
      if (event.key !== 'Tab' || !node) return;
      const focusables = node.querySelectorAll(
        'a[href], button:not([disabled]), input:not([disabled]), [tabindex]:not([tabindex="-1"])',
      );
      if (!focusables.length) return;
      const first = focusables[0];
      const last = focusables[focusables.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    };
    document.addEventListener('keydown', onKey);
    return () => {
      clearTimeout(focusTimer);
      document.removeEventListener('keydown', onKey);
    };
  }, [open]);

  if (!open) return null;

  const submit = async (event) => {
    event.preventDefault();
    if (state === 'sending') return;
    setState('sending');
    try {
      const res = await fetch('/api/subscribe.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, source: 'popup', website: trap }),
      });
      if (!res.ok) throw new Error(String(res.status));
      setState('done');
      trackSubscribe('popup');
      trackCta('newsletter-popup', 'popup');
      record('subscribe');
      setTimeout(() => setOpen(false), 2200);
    } catch {
      setState('error');
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-ink/40 p-4 backdrop-blur-sm sm:items-center print:hidden"
      onClick={() => close('dismiss')}
    >
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={`${id}-title`}
        aria-describedby={`${id}-desc`}
        onClick={(event) => event.stopPropagation()}
        className="relative w-[min(26rem,calc(100vw-2rem))] rounded-[1.4rem] border border-ink/10 bg-surface p-6 shadow-2xl sm:p-7"
      >
        <button
          type="button"
          onClick={() => close('dismiss')}
          aria-label="Close newsletter signup"
          className="absolute right-3 top-3 inline-flex h-9 w-9 items-center justify-center rounded-full text-text-muted transition-colors hover:bg-ink/5 hover:text-text"
        >
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none" aria-hidden="true">
            <path d="M3 3l10 10M13 3L3 13" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
          </svg>
        </button>

        {state === 'done' ? (
          <div role="status" className="py-2">
            <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-accent">You&apos;re in</p>
            <h2 id={`${id}-title`} className="mt-2 font-serif text-2xl leading-tight text-text">
              Thanks — see you in the next note.
            </h2>
            <p id={`${id}-desc`} className="mt-2 text-sm leading-[1.7] text-text-muted">
              One email when the next essay or app ships. Unsubscribe anytime.
            </p>
          </div>
        ) : (
          <>
            <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-accent">Newsletter</p>
            <h2 id={`${id}-title`} className="mt-2 max-w-[18ch] font-serif text-[1.7rem] leading-[1.08] tracking-[-0.01em] text-text">
              Get the next essay <em className="italic text-accent">first.</em>
            </h2>
            <p id={`${id}-desc`} className="mt-2.5 text-sm leading-[1.7] text-text-muted">
              One email when a new essay or app ships — Flutter, AI, and shipping software people
              keep using. No spam, unsubscribe anytime.
            </p>
            <form onSubmit={submit} className="mt-5 flex flex-col gap-2.5">
              <label htmlFor={`${id}-email`} className="sr-only">Email address</label>
              <input
                ref={inputRef}
                id={`${id}-email`}
                type="email"
                required
                autoComplete="email"
                inputMode="email"
                placeholder="you@example.com"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                disabled={state === 'sending'}
                className="w-full rounded-lg border border-[var(--border)] bg-canvas px-4 py-3 text-sm text-text placeholder:text-text-muted focus:border-accent focus:outline-none disabled:opacity-60"
              />
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
                className="inline-flex min-h-11 items-center justify-center rounded-full bg-accent-solid px-6 py-2.5 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90 disabled:opacity-60"
              >
                {state === 'sending' ? 'Joining…' : 'Notify me'}
              </button>
            </form>
            {state === 'error' && (
              <p role="alert" className="mt-3 text-xs leading-[1.6] text-text-muted">
                That didn&apos;t go through. Please try again in a moment.
              </p>
            )}
            <div className="mt-4 flex items-center justify-between gap-3">
              <button
                type="button"
                onClick={() => close('dismiss')}
                className="text-xs text-text-muted underline decoration-ink/25 underline-offset-4 transition-colors hover:text-text"
              >
                No thanks
              </button>
              <a
                href="/privacy"
                className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted transition-colors hover:text-accent"
              >
                Privacy
              </a>
            </div>
          </>
        )}
      </div>
    </div>
  );
}