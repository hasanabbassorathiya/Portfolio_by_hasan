import React from 'react';
import { Link } from '../lib/router';
import { useApps } from '../lib/live-content';
import { useReveal } from '../lib/motion';

function StorePills({ links }) {
  const items = [
    links.ios && { label: 'App Store', href: links.ios },
    links.android && { label: 'Google Play', href: links.android },
    links.web && { label: 'Web', href: links.web },
  ].filter(Boolean);

  return (
    <div className="flex flex-wrap gap-2">
      {items.map((item) => (
        <a
          key={item.label}
          href={item.href}
          target="_blank"
          rel="noreferrer"
          className="rounded-full border border-accent/50 px-3.5 py-2 font-mono text-[11px] text-accent transition-colors hover:bg-accent-solid hover:text-on-accent"
        >
          {item.label} ↗
        </a>
      ))}
    </div>
  );
}

export function FeaturedReel() {
  const apps = useApps();
  const header = useReveal(0);
  const featuredCard = useReveal(80);
  const grid = useReveal(160);
  const [featured, ...rest] = apps;

  return (
    <section id="apps" className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(4rem,9vw,8rem)]">
      <div ref={header.ref} style={header.style} className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <p className="mb-3 font-mono text-xs uppercase tracking-[0.25em] text-accent">Selected apps</p>
          <h2 className="font-display text-[clamp(1.9rem,4.4vw,3.2rem)] tracking-[-0.025em]">
            Apps people <em className="font-serif font-normal italic text-accent">actually use</em>
          </h2>
        </div>
        <p className="max-w-[38ch] text-sm leading-[1.7] text-text-muted">
          Published under my own developer account and built for clients — education, streaming,
          community, commerce, and enterprise mobility.
        </p>
      </div>

      <article
        ref={featuredCard.ref}
        style={featuredCard.style}
        className="mt-10 overflow-hidden rounded-[1.75rem] border border-[var(--border)] bg-surface"
      >
        <div className="grid gap-0 lg:grid-cols-[1.05fr_0.95fr]">
          <div className="flex flex-col justify-between gap-8 p-7 md:p-10">
            <div className="flex flex-col gap-5">
              <div className="flex items-center gap-4">
                <img
                  src={featured.icon}
                  alt={`${featured.name} icon`}
                  className="h-16 w-16 rounded-2xl border border-accent/30 object-cover"
                  loading="lazy"
                />
                <div>
                  <p className="font-mono text-[10px] uppercase tracking-[0.18em] text-accent">Own app · flagship</p>
                  <h3 className="font-display text-3xl leading-tight">{featured.name}</h3>
                  <p className="font-mono text-[11px] text-text-muted">
                    {featured.genre} · {featured.year}
                    {featured.rating ? ` · ★ ${featured.rating.value.toFixed(1)} (${featured.rating.count.toLocaleString('en-US')})` : ''}
                  </p>
                </div>
              </div>
              <p className="max-w-[52ch] text-[0.98rem] leading-[1.75] text-text-muted">{featured.summary}</p>
              <div className="flex flex-wrap gap-2">
                {featured.stack.map((item) => (
                  <span key={item} className="rounded-full border border-[var(--border)] px-3 py-1 font-mono text-[10px] text-text-muted">
                    {item}
                  </span>
                ))}
              </div>
            </div>
            <div className="flex flex-wrap items-center justify-between gap-4">
              <StorePills links={featured.links} />
              <Link to={`/apps/${featured.slug}`} className="font-mono text-xs text-text underline decoration-accent/50 underline-offset-4 hover:text-accent">
                Read the case study →
              </Link>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3 bg-deep p-6 md:p-8">
            {featured.screenshots.map((src, index) => (
              <div key={src} className="overflow-hidden rounded-xl border border-[var(--border)] bg-canvas p-1.5">
                <img
                  src={src}
                  alt={`${featured.name} screenshot ${index + 1}`}
                  className="w-full rounded-lg object-cover"
                  loading="lazy"
                />
              </div>
            ))}
          </div>
        </div>
      </article>

      <div ref={grid.ref} style={grid.style} className="mt-5 grid gap-5 md:grid-cols-2">
        {rest.map((app) => (
          <article
            key={app.slug}
            className="group flex flex-col gap-5 rounded-[1.5rem] border border-[var(--border)] bg-surface p-6 transition-colors hover:border-accent/40 md:p-7"
          >
            <div className="flex items-start justify-between gap-4">
              <div className="flex items-center gap-3.5">
                <img src={app.icon} alt="" className="h-12 w-12 rounded-xl border border-accent/25 object-cover" loading="lazy" />
                <div>
                  <h3 className="font-display text-xl leading-tight">
                    <Link to={`/apps/${app.slug}`} className="transition-colors group-hover:text-accent">
                      {app.name}
                    </Link>
                  </h3>
                  <p className="font-mono text-[10px] uppercase tracking-[0.12em] text-text-muted">
                    {app.genre} · {app.platforms.join(' / ')}
                  </p>
                </div>
              </div>
              {app.rating && (
                <span className="shrink-0 rounded-full border border-accent/40 px-2.5 py-1 font-mono text-[10px] text-accent">
                  ★ {app.rating.value.toFixed(1)}
                </span>
              )}
            </div>
            <p className="text-sm leading-[1.7] text-text-muted">{app.tagline}</p>
            <div className="mt-auto flex flex-wrap items-center justify-between gap-3 border-t border-[var(--border)] pt-4">
              <StorePills links={app.links} />
              <Link to={`/apps/${app.slug}`} className="font-mono text-[11px] text-text-muted transition-colors hover:text-accent">
                Case study →
              </Link>
            </div>
          </article>
        ))}
      </div>

      <div className="mt-8 flex flex-col items-start justify-between gap-4 border-t border-[var(--border)] pt-6 md:flex-row md:items-center">
        <p className="max-w-[60ch] text-sm leading-[1.7] text-text-muted">
          Enterprise work includes <span className="text-text">EVLAB</span> at Chalhoub Group,
          <span className="text-text"> Nakheel Marinas</span> at Belong Interactive, and
          <span className="text-text"> Good2Go Loans</span> serving 50K+ users in New Zealand.
        </p>
        <a
          href="https://apps.apple.com/ae/developer/hasan-abbas-sorathiya/id1734376366"
          target="_blank"
          rel="noreferrer"
          className="shrink-0 font-mono text-xs text-accent hover:underline"
        >
          All App Store listings ↗
        </a>
      </div>
    </section>
  );
}
