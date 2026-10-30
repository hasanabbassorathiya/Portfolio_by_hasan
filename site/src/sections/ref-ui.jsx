import React from 'react';

export function Kicker({ children, className = '', tone = 'light' }) {
  return (
    <p
      className={`flex items-center gap-2.5 font-mono text-[10px] uppercase tracking-[0.24em] ${
        tone === 'dark' ? 'text-band-fg/55' : 'text-text-muted'
      } ${className}`}
    >
      <span
        aria-hidden="true"
        className={`h-1.5 w-1.5 rounded-full ${tone === 'dark' ? 'bg-hl-a' : 'bg-accent'}`}
      />
      {children}
    </p>
  );
}

export function SectionHead({ kicker, title, blurb, action, className = '', tone = 'light' }) {
  return (
    <div className={`flex flex-col gap-7 md:flex-row md:items-end md:justify-between ${className}`}>
      <div className="flex max-w-[720px] flex-col gap-5">
        {kicker ? <Kicker tone={tone}>{kicker}</Kicker> : null}
        <h2
          className={`font-serif text-[clamp(2.3rem,4.8vw,4rem)] font-normal leading-[1.01] tracking-[-0.015em] ${
            tone === 'dark' ? 'text-band-fg' : 'text-text'
          }`}
        >
          {title}
        </h2>
        {blurb ? (
          <p
            className={`max-w-[62ch] text-[15px] leading-[1.72] ${
              tone === 'dark' ? 'text-band-fg/60' : 'text-text-muted'
            }`}
          >
            {blurb}
          </p>
        ) : null}
      </div>
      {action ? <div className="shrink-0">{action}</div> : null}
    </div>
  );
}

export function Arrow({ className = '' }) {
  return (
    <svg
      aria-hidden="true"
      viewBox="0 0 16 16"
      className={`h-4 w-4 transition-transform duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] group-hover:-translate-y-0.5 group-hover:translate-x-0.5 ${className}`}
      fill="none"
      stroke="currentColor"
      strokeWidth="1.3"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M4 12 12 4M5 4h7v7" />
    </svg>
  );
}

export function ArrowBadge({ tone = 'light' }) {
  return (
    <span
      aria-hidden="true"
      className={`ml-2 flex h-7 w-7 items-center justify-center rounded-full transition-transform duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] group-hover:translate-x-0.5 group-hover:-translate-y-px ${
        tone === 'dark' ? 'bg-on-accent/15 text-on-accent' : 'bg-band-fg/15 text-current'
      }`}
    >
      <svg
        viewBox="0 0 16 16"
        className="h-3.5 w-3.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.4"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M4 12 12 4M5 4h7v7" />
      </svg>
    </span>
  );
}

export function Check() {
  return (
    <svg
      aria-hidden="true"
      viewBox="0 0 16 16"
      className="mt-1 h-3 w-3 shrink-0 text-accent"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.6"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="m3 8.5 3 3 7-7" />
    </svg>
  );
}
