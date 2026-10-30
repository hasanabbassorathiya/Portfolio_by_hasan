import React from 'react';
import { useReveal, useCountUp } from '../lib/motion';

const stats = [
  { label: 'Contributions · 12 months', value: 565 },
  { label: 'Public repositories', value: 52 },
  { label: 'Stars earned', value: 9 },
  { label: 'Followers', value: 10 },
];

const languages = ['Dart', 'TypeScript', 'Python', 'JavaScript', 'PHP', 'Rust (exploring)'];

function Stat({ stat, run }) {
  const value = useCountUp(stat.value, run);
  return (
    <div className="flex flex-col gap-1">
      <p className="font-mono text-[clamp(1.8rem,3.5vw,2.6rem)] font-bold leading-none text-text">{value}</p>
      <p className="font-mono text-xs text-text-muted">{stat.label}</p>
    </div>
  );
}

export function GitHubActivity() {
  const { ref, style, shown } = useReveal();
  return (
    <section
      ref={ref}
      style={style}
      className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,7vw,6rem)]"
    >
      <div className="mb-8 flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <p className="mb-3 font-mono text-xs uppercase tracking-[0.25em] text-accent">On GitHub</p>
          <h2 className="font-display text-[clamp(1.8rem,4vw,3rem)] tracking-[-0.02em]">
            Public <em className="font-serif font-normal italic text-accent">workbench</em>
          </h2>
        </div>
        <a
          href="https://github.com/hasanabbassorathiya"
          target="_blank"
          rel="noreferrer"
          className="w-fit rounded-full border border-[var(--border)] px-4 py-2 font-mono text-xs transition-colors hover:border-accent/60 hover:text-accent"
        >
          github.com/hasanabbassorathiya ↗
        </a>
      </div>

      <div className="grid gap-8 rounded-[1.5rem] border border-[var(--border)] bg-surface p-6 md:p-9 lg:grid-cols-[1.3fr_0.7fr] lg:items-center">
        <div className="flex flex-wrap gap-x-10 gap-y-8 md:gap-x-14">
          {stats.map((stat) => (
            <Stat key={stat.label} stat={stat} run={shown} />
          ))}
        </div>
        <div className="flex flex-col gap-3 border-t border-[var(--border)] pt-6 lg:border-l lg:border-t-0 lg:pl-8 lg:pt-0">
          <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-text-muted">Primary languages</p>
          <div className="flex flex-wrap gap-2">
            {languages.map((language) => (
              <span key={language} className="rounded-full border border-[var(--border)] px-3 py-1 font-mono text-[10px] text-text-muted">
                {language}
              </span>
            ))}
          </div>
          <p className="mt-2 text-sm leading-[1.7] text-text-muted">
            Most of my recent work is private client code. What is public — VPN, embedded SQL for
            Flutter, WordPress MCP tooling — is listed below.
          </p>
        </div>
      </div>
    </section>
  );
}
