import React, { useId, useState } from 'react';
import { trackSubscribe } from '../lib/analytics';

const EMAIL = 'hasanabbassorathiya12@gmail.com';

export function Subscribe({ source = 'site', variant = 'panel' }) {
  const id = useId();
  const [email, setEmail] = useState('');
  const [trap, setTrap] = useState('');
  const [state, setState] = useState('idle');

  const submit = async (event) => {
    event.preventDefault();
    if (state === 'sending') return;
    setState('sending');
    try {
      const res = await fetch('/api/subscribe.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, source, website: trap }),
      });
      if (!res.ok) throw new Error(String(res.status));
      setState('done');
      trackSubscribe(source);
    } catch {
      setState('error');
    }
  };

  const form = state === 'done' ? (
    <p role="status" className="text-sm leading-[1.7] text-text">
      You&apos;re on the list. I&apos;ll email you when the next essay ships.
    </p>
  ) : (
    <form onSubmit={submit} className="flex flex-col gap-2">
      <div className={variant === 'plain' ? 'flex flex-col gap-2' : 'flex flex-col gap-2 sm:flex-row'}>
        <label htmlFor={id} className="sr-only">Email address</label>
        <input
          id={id}
          type="email"
          required
          autoComplete="email"
          inputMode="email"
          placeholder="you@example.com"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          disabled={state === 'sending'}
          className="min-w-0 flex-1 rounded-lg border border-[var(--border)] bg-canvas px-4 py-3 text-sm text-text placeholder:text-text-muted focus:border-accent focus:outline-none disabled:opacity-60"
        />
        <button
          type="submit"
          disabled={state === 'sending'}
          className="rounded-lg bg-accent-solid px-5 py-3 font-medium text-on-accent transition hover:brightness-110 disabled:opacity-60"
        >
          {state === 'sending' ? 'Joining…' : 'Notify me'}
        </button>
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
      {state === 'error' ? (
        <p role="alert" className="text-sm leading-[1.6] text-text-muted">
          That didn&apos;t go through. Email{' '}
          <a href={`mailto:${EMAIL}?subject=Subscribe`} className="text-text underline decoration-accent/50 underline-offset-4">
            {EMAIL}
          </a>{' '}
          and I&apos;ll add you.
        </p>
      ) : (
        <p className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted">
          No spam · Unsubscribe anytime
        </p>
      )}
    </form>
  );

  if (variant === 'plain') return <div className="flex flex-col gap-3">{form}</div>;

  const copy = (
    <>
      <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-accent">The next one</p>
      <h2 className="mt-2 font-display text-[clamp(1.35rem,2.4vw,1.9rem)] leading-tight">
        Get new essays by email
      </h2>
      <p className="mt-2 max-w-[52ch] text-sm leading-[1.7] text-text-muted">
        One email when a new essay or app ships. No newsletter treadmill, no noise.
      </p>
    </>
  );

  return (
    <div className="rounded-2xl border border-accent/25 bg-surface p-6 md:p-8">
      {variant === 'stack' ? (
        <div className="flex flex-col gap-5">
          <div>{copy}</div>
          <div className="max-w-[32rem]">{form}</div>
        </div>
      ) : (
        <div className="grid gap-6 lg:grid-cols-[1fr_minmax(0,24rem)] lg:items-center">
          <div>{copy}</div>
          {form}
        </div>
      )}
    </div>
  );
}
