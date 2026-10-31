import React from 'react';
import { Link } from '../lib/router';
import { useApps, useClients } from '../lib/live-content';
import { useSiteMetrics } from '../lib/site-metrics';
import { useSeo, SITE_URL, personJsonLd } from '../lib/seo';
import { Kicker, Arrow } from '../sections/ref-ui';
import { trackOpen, trackOutbound } from '../lib/analytics';

export function WorkPage() {
  const apps = useApps();
  const clients = useClients();
  const metrics = useSiteMetrics();
  const stats = [
    [String(metrics.clientsCount), 'Client engagements'],
    [String(metrics.appsCount), 'App profiles'],
    [String(metrics.platforms.length), 'Platforms'],
    [metrics.yearsLabel, 'Years in production'],
  ].filter(([value]) => value);
  useSeo({
    title: 'Work · Hasan Abbas Sorathiya',
    description:
      `Client engagements and app profiles: EVLAB at Chalhoub Group, Good2Go Loans, Nakheel Marinas, and ${metrics.appsCount} app profiles across ${metrics.platformsLabel}.`,
    path: '/work',
    type: 'website',
    image: '/og/work.png',
    jsonLd: [
      personJsonLd,
      {
        '@context': 'https://schema.org',
        '@type': 'CollectionPage',
        name: 'Work by Hasan Abbas Sorathiya',
        url: `${SITE_URL}/work`,
        description:
          'Client engagements and shipped products led by Hasan Abbas Sorathiya, a senior Flutter and AI engineer in Dubai.',
        mainEntity: {
          '@type': 'ItemList',
          numberOfItems: clients.length + apps.length,
          itemListElement: [
            ...clients.map((client, index) => ({
              '@type': 'ListItem',
              position: index + 1,
              name: client.name,
              url: `${SITE_URL}/work/${client.slug}`,
            })),
            ...apps.map((app, index) => ({
              '@type': 'ListItem',
              position: clients.length + index + 1,
              name: app.name,
              url: `${SITE_URL}/apps/${app.slug}`,
            })),
          ],
        },
      },
    ],
  });

  return (
    <main className="pt-[68px]">
      <section className="border-b border-[var(--border)] bg-deep">
        <div className="mx-auto max-w-[1180px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,7vw,6rem)]">
          <Kicker>Selected work · {metrics.rangeLabel}</Kicker>
          <div className="mt-7 grid gap-8 lg:grid-cols-[1.2fr_0.8fr] lg:items-end lg:gap-16">
            <h1 className="max-w-[24ch] font-serif text-[clamp(2.6rem,6.4vw,4.9rem)] leading-[0.98] tracking-[-0.02em] text-text">
              Client platforms and app profiles, with the{' '}
              <em className="italic text-accent">decisions</em> behind them.
            </h1>
            <p className="max-w-[48ch] text-[15px] leading-[1.78] text-text-muted">
              {metrics.yearsLabel} years of mobile delivery across fintech, mobility, hospitality,
              media, and education. Below are the engagements where I owned the outcome — the brief,
              the build, the release, and the production support after it.
            </p>
          </div>

          <dl className="mt-12 grid grid-cols-2 gap-x-6 gap-y-6 border-t border-ink/10 pt-7 sm:grid-cols-4">
            {stats.map(([value, label]) => (
              <div key={label}>
                <dt className="font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted">
                  {label}
                </dt>
                <dd className="mt-1.5 font-serif text-3xl leading-none text-text">{value}</dd>
              </div>
            ))}
          </dl>
        </div>
      </section>

      <section className="mx-auto max-w-[1180px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,7vw,5.5rem)]">
        <div className="flex flex-wrap items-baseline justify-between gap-3">
          <Kicker>Client engagements</Kicker>
          <span className="font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted">
            Dubai · Australia · New Zealand
          </span>
        </div>

        <div className="mt-6">
          {clients.map((client) => (
            <article
              key={client.slug}
              className="group grid gap-6 border-t border-ink/10 py-9 last:border-b md:grid-cols-[minmax(0,1fr)_auto] md:items-start md:gap-12"
            >
              <div className="flex flex-col gap-4 sm:flex-row sm:gap-7">
                <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl border border-ink/10 bg-[#f7f3e9] p-3 shadow-[inset_0_1px_1px_rgba(255,255,255,0.6)]">
                  <img
                    src={client.logo}
                    alt={`${client.name} logo`}
                    loading="lazy"
                    className="h-full w-full rounded-lg object-contain"
                  />
                </div>
                <div className="min-w-0">
                  <div className="flex flex-wrap items-baseline gap-x-4 gap-y-1">
                    <h2 className="font-serif text-[clamp(1.7rem,3vw,2.3rem)] leading-none tracking-[-0.015em] text-text">
                      <Link to={`/work/${client.slug}`} onClick={() => trackOpen(client.slug)} className="hover:text-accent">
                        {client.name}
                      </Link>
                    </h2>
                    <span className="font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted">
                      {client.kicker}
                    </span>
                  </div>
                  <p className="mt-3 max-w-[58ch] text-[14.5px] leading-[1.7] text-text-muted">
                    {client.summary}
                  </p>
                  <p className="mt-3 font-mono text-[9px] uppercase tracking-[0.14em] text-text-muted">
                    {client.role} · {client.dates}
                  </p>
                  <div className="mt-5 flex flex-wrap items-center gap-x-6 gap-y-3 text-sm">
                    <Link
                      to={`/work/${client.slug}`}
                      onClick={() => trackOpen(client.slug)}
                      className="group inline-flex items-center gap-2 font-medium text-text rule-link"
                    >
                      Read the case study
                      <Arrow />
                    </Link>
                    <a
                      href={client.links.website}
                      target="_blank"
                      rel="noreferrer"
                      onClick={() => trackOutbound(client.name, client.links.website)}
                      className="text-text-muted transition-colors duration-300 hover:text-text"
                    >
                      {client.website.replace(/^https?:\/\/(www\.)?/, '').replace(/\/$/, '')} ↗
                    </a>
                  </div>
                </div>
              </div>

              <div className="flex shrink-0 items-end justify-between gap-6 border-t border-ink/10 pt-4 md:min-w-[150px] md:flex-col md:items-end md:border-t-0 md:pt-0">
                <div className="text-right">
                  <p className="font-serif text-3xl leading-none text-text">{client.metric}</p>
                  <p className="mt-1.5 font-mono text-[9px] uppercase tracking-[0.14em] text-text-muted">
                    {client.metricLabel}
                  </p>
                </div>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section className="border-y border-ink/10 bg-surface/60">
        <div className="mx-auto max-w-[1180px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,5vw,4rem)]">
          <div className="flex flex-wrap items-baseline justify-between gap-3">
            <Kicker>Product case studies</Kicker>
            <Link to="/apps" className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted hover:text-text">
              See the full app catalogue →
            </Link>
          </div>
          <div className="mt-6 grid gap-x-8 gap-y-0 sm:grid-cols-2">
            {apps.map((app) => (
              <Link
                key={app.slug}
                to={`/apps/${app.slug}`}
                onClick={() => trackOpen(app.slug)}
                className="group flex items-center justify-between gap-4 border-t border-ink/10 py-4 transition-colors duration-300 hover:border-ink/30"
              >
                <span className="flex min-w-0 items-center gap-3">
                  <img src={app.icon} alt="" loading="lazy" className="h-8 w-8 rounded-[9px] border border-ink/10" />
                  <span className="truncate text-sm font-medium text-text">{app.name}</span>
                </span>
                <span className="flex shrink-0 items-center gap-3">
                  <span className="font-mono text-[9px] uppercase tracking-[0.12em] text-text-muted">
                    {app.year}
                  </span>
                  <span className="text-text-muted transition-colors duration-300 group-hover:text-text">
                    <Arrow className="h-3.5 w-3.5" />
                  </span>
                </span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-[1180px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,6vw,5rem)]">
        <div className="flex flex-col items-start justify-between gap-6 rounded-[1.75rem] border border-ink/10 bg-band p-8 text-band-fg md:flex-row md:items-center md:p-10">
          <div>
            <p className="font-mono text-[9px] uppercase tracking-[0.18em] text-band-fg/60">
              Have a similar project?
            </p>
            <p className="mt-3 max-w-[38ch] font-serif text-[clamp(1.7rem,3vw,2.4rem)] leading-[1.08] tracking-[-0.015em]">
              Bring the brief. I&apos;ll bring the delivery plan.
            </p>
          </div>
          <Link
            to="/#contact"
            className="group inline-flex shrink-0 items-center rounded-full bg-band-fg py-2.5 pl-5 pr-2.5 text-sm font-medium text-band transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:bg-band-fg/90 active:scale-[0.98]"
          >
            Start a conversation
            <Arrow />
          </Link>
        </div>
      </section>
    </main>
  );
}
