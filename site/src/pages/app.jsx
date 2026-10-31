import React from 'react';
import { Link } from '../lib/router';
import { useApps } from '../lib/live-content';
import { useSeo, SITE_URL, personJsonLd } from '../lib/seo';
import { trackCta, trackOutbound, trackStore } from '../lib/analytics';

export function AppPage({ slug }) {
  const apps = useApps();
  const app = apps.find((entry) => entry.slug === slug);
  const seo = app?.seo ?? {};

  useSeo({
    title: app ? seo.title || `${app.name} · Hasan Abbas Sorathiya` : 'App not found',
    description: app ? seo.description || app.summary : 'App not found.',
    path: `/apps/${slug}`,
    image: seo.image || app?.icon || '/og.png',
    noindex: !app || seo.noindex === true,
    jsonLd: app
      ? [
          personJsonLd,
          {
            '@context': 'https://schema.org',
            '@type': 'MobileApplication',
            name: app.name,
            description: app.summary,
            applicationCategory: app.genre,
            operatingSystem: app.platforms.join(', '),
            image: `${SITE_URL}${app.icon}`,
            ...(app.role === 'Publisher'
              ? { publisher: { '@type': 'Person', name: 'Hasan Abbas Sorathiya', url: SITE_URL } }
              : app.role?.startsWith('Creator')
                ? { author: { '@type': 'Person', name: 'Hasan Abbas Sorathiya', url: SITE_URL } }
                : {}),
            ...(app.rating
              ? {
                  aggregateRating: {
                    '@type': 'AggregateRating',
                    ratingValue: app.rating.value,
                    ratingCount: app.rating.count,
                    bestRating: 5,
                  },
                }
              : {}),
          },
        ]
      : null,
  });

  if (!app) {
    return (
      <main className="mx-auto flex min-h-[70vh] max-w-[1360px] flex-col justify-center gap-4 px-[clamp(1.25rem,5vw,4rem)] pt-[68px]">
        <p className="font-mono text-xs uppercase tracking-[0.25em] text-accent">App not found</p>
        <h1 className="font-serif text-4xl">That app is not in the showcase.</h1>
        <Link to="/apps" className="w-fit rounded-lg bg-accent-solid px-5 py-3 font-medium text-on-accent">
          See all apps
        </Link>
      </main>
    );
  }

  const others = apps.filter((a) => a.slug !== app.slug).slice(0, 3);

  return (
    <main className="pt-[68px]">
      <section className="border-b border-[var(--border)] bg-deep">
        <div className="mx-auto flex max-w-[1120px] flex-col gap-8 px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,6vw,5rem)]">
          <nav className="flex items-center gap-2 font-mono text-[11px] uppercase tracking-[0.16em] text-text-muted" aria-label="Breadcrumb">
            <Link to="/apps" className="hover:text-accent">Apps</Link>
            <span aria-hidden="true">/</span>
            <span className="text-accent">{app.name}</span>
          </nav>

          <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
            <div className="flex items-start gap-5">
              <img
                src={app.icon}
                alt={`${app.name} icon`}
                className="h-20 w-20 rounded-2xl border border-accent/30 object-cover shadow-lg md:h-24 md:w-24"
              />
              <div className="flex flex-col gap-3">
                <h1 className="font-serif text-[clamp(2rem,5vw,3.4rem)] leading-[1.05] tracking-[-0.03em]">
                  {app.name}
                </h1>
                <p className="max-w-[48ch] text-text-muted">{app.tagline}</p>
                <div className="flex flex-wrap items-center gap-x-4 gap-y-2 font-mono text-[11px] uppercase tracking-[0.14em] text-text-muted">
                  <span className="text-accent">{app.genre}</span>
                  {app.year && <span>{app.year}</span>}
                  <span>{app.platforms.join(' · ')}</span>
                  {app.rating && <span className="text-accent">★ {app.rating.value.toFixed(1)} ({app.rating.count.toLocaleString('en-US')})</span>}
                </div>
              </div>
            </div>

            <div className="flex flex-col gap-3">
              <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-text-muted">{app.role}</p>
              <div className="flex flex-wrap gap-2">
                {app.links.ios && (
                  <a
                    href={app.links.ios}
                    target="_blank"
                    rel="noreferrer"
                    onClick={() => trackStore(app.slug, 'ios')}
                    className="rounded-lg bg-accent-solid px-5 py-3 font-medium text-on-accent transition hover:brightness-110"
                  >
                    Download on iOS ↗
                  </a>
                )}
                {app.links.android && (
                  <a
                    href={app.links.android}
                    target="_blank"
                    rel="noreferrer"
                    onClick={() => trackStore(app.slug, 'android')}
                    className="rounded-lg border border-accent/50 px-5 py-3 text-accent transition hover:bg-accent-solid hover:text-on-accent"
                  >
                    Get it on Android ↗
                  </a>
                )}
                {app.links.web && (
                  <a
                    href={app.links.web}
                    target="_blank"
                    rel="noreferrer"
                    onClick={() => trackStore(app.slug, 'web')}
                    className="rounded-lg border border-[var(--border)] px-5 py-3 text-text-muted transition hover:border-accent/50 hover:text-text"
                  >
                    Open the web app ↗
                  </a>
                )}
                {app.links.github && (
                  <a
                    href={app.links.github}
                    target="_blank"
                    rel="noreferrer"
                    onClick={() => trackOutbound(`${app.name} source`, app.links.github)}
                    className="rounded-lg border border-[var(--border)] px-5 py-3 text-text-muted transition hover:border-accent/50 hover:text-text"
                  >
                    View source on GitHub ↗
                  </a>
                )}
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-[1120px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,6vw,5rem)]">
        <div className="grid gap-10 lg:grid-cols-[1.1fr_0.9fr] lg:gap-16">
          <div className="flex flex-col gap-10">
            <div className="flex flex-col gap-4">
              <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">The product</p>
              <p className="text-[1.05rem] leading-[1.8] text-text">{app.summary}</p>
              {app.attribution && <p className="border-l-2 border-accent/40 pl-4 leading-[1.8] text-text-muted">{app.attribution}</p>}
              {app.story && <p className="leading-[1.8] text-text-muted">{app.story}</p>}
            </div>

            <div className="flex flex-col gap-4">
              <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">What is inside</p>
              <ul className="flex flex-col divide-y divide-[var(--border)] border-y border-[var(--border)]">
                {app.features.map((feature) => (
                  <li key={feature} className="flex items-start gap-3 py-4">
                    <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-accent" aria-hidden="true" />
                    <span className="leading-[1.65] text-text">{feature}</span>
                  </li>
                ))}
              </ul>
            </div>

            {app.decisions?.length > 0 && (
              <div className="flex flex-col gap-4">
                <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">Engineering decisions</p>
                <ol className="flex flex-col divide-y divide-[var(--border)] border-y border-[var(--border)]">
                  {app.decisions.map((decision, index) => (
                    <li key={decision.title} className="grid gap-1.5 py-4 sm:grid-cols-[2rem_1fr] sm:gap-4">
                      <span className="font-mono text-[10px] text-accent">0{index + 1}</span>
                      <div>
                        <p className="font-medium leading-snug text-text">{decision.title}</p>
                        <p className="mt-1.5 text-sm leading-[1.7] text-text-muted">{decision.rationale}</p>
                        <p className="mt-1.5 text-[13px] leading-[1.7] text-text-muted">
                          <span className="font-mono text-[9px] uppercase tracking-[0.14em]">Trade-off</span>{' '}
                          {decision.tradeoff}
                        </p>
                      </div>
                    </li>
                  ))}
                </ol>
              </div>
            )}

            {app.stack?.length > 0 && (
              <div className="flex flex-col gap-3">
                <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">Stack</p>
                <div className="flex flex-wrap gap-2">
                  {app.stack.map((item) => (
                    <span key={item} className="rounded-full border border-[var(--border)] px-3 py-1.5 font-mono text-xs text-text-muted">
                      {item}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>

          <div className="flex flex-col gap-6">
            <div className="grid grid-cols-2 gap-3">
              {app.screenshots.map((src, index) => (
                <div
                  key={src}
                  className="overflow-hidden rounded-[1.4rem] border border-[var(--border)] bg-surface p-2"
                >
                  <img
                    src={src}
                    alt={`${app.name} screenshot ${index + 1}`}
                    className="w-full rounded-[1rem] object-cover"
                    loading={index === 0 ? 'eager' : 'lazy'}
                  />
                </div>
              ))}
            </div>
            {app.metrics?.length > 0 && (
              <div className="grid grid-cols-3 gap-3 border-t border-[var(--border)] pt-6">
                {app.metrics.map(([value, label]) => (
                  <div key={label} className="flex flex-col gap-1">
                    <span className="font-mono text-xl text-accent">{value}</span>
                    <span className="font-mono text-[10px] uppercase tracking-[0.12em] text-text-muted">{label}</span>
                  </div>
                ))}
              </div>
            )}
            <div className="rounded-2xl border border-accent/25 bg-surface p-5">
              <p className="font-serif text-lg">Work with Hasan</p>
              <p className="mt-2 text-sm leading-[1.7] text-text-muted">
                Available for senior Flutter and AI engineering work, including app rescues,
                architecture reviews, and 0-to-1 product builds.
              </p>
              <a
                href="mailto:hasanabbassorathiya12@gmail.com?subject=App%20project%20enquiry"
                onClick={() => trackCta('email', `app:${app.slug}`)}
                className="mt-4 inline-block rounded-lg bg-accent-solid px-4 py-2.5 text-sm font-medium text-on-accent transition hover:brightness-110"
              >
                Talk about a project
              </a>
            </div>
          </div>
        </div>
      </section>

      <section className="border-t border-[var(--border)] bg-deep">
        <div className="mx-auto max-w-[1120px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,6vw,5rem)]">
          <div className="flex items-center justify-between gap-4">
            <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">More apps</p>
            <Link to="/apps" className="font-mono text-xs text-text-muted hover:text-text">All apps →</Link>
          </div>
          <div className="mt-6 grid gap-4 md:grid-cols-3">
            {others.map((item) => (
              <Link
                key={item.slug}
                to={`/apps/${item.slug}`}
                className="group flex items-center gap-4 rounded-xl border border-[var(--border)] bg-surface p-4 transition-colors hover:border-accent/40"
              >
                <img src={item.icon} alt="" className="h-12 w-12 rounded-xl object-cover" loading="lazy" />
                <div className="min-w-0">
                  <p className="truncate font-serif text-lg group-hover:text-accent">{item.name}</p>
                  <p className="truncate font-mono text-[10px] uppercase tracking-[0.12em] text-text-muted">{item.genre}</p>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>
    </main>
  );
}
