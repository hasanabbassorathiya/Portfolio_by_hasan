import React from 'react';
import { Link } from '../lib/router';
import { AppIcon } from '../components/app-icon';
import { useApps, useClients } from '../lib/live-content';
import { useSeo, SITE_URL, personJsonLd } from '../lib/seo';
import { Arrow, Check, Kicker } from '../sections/ref-ui';
import { trackCta, trackOutbound } from '../lib/analytics';

export function CaseStudyPage({ slug }) {
  const clients = useClients();
  const apps = useApps();
  const client = clients.find((entry) => entry.slug === slug);
  const seo = client?.seo ?? {};

  useSeo({
    title: client ? seo.title || `${client.name} · Case study · Hasan Abbas Sorathiya` : 'Case study not found',
    description: client ? seo.description || client.summary : 'Case study not found.',
    path: `/work/${slug}`,
    type: 'article',
    image: seo.image || '/og/work.png',
    noindex: !client || seo.noindex === true,
    jsonLd: client
      ? [
          personJsonLd,
          {
            '@context': 'https://schema.org',
            '@type': 'Article',
            headline: `${client.name} case study`,
            description: client.summary,
            url: `${SITE_URL}/work/${client.slug}`,
            author: { '@type': 'Person', name: 'Hasan Abbas Sorathiya', url: SITE_URL },
            about: {
              '@type': 'Organization',
              name: client.name,
              url: client.links.website,
            },
          },
        ]
      : null,
  });

  if (!client) {
    return (
      <main className="mx-auto flex min-h-[70vh] max-w-[1180px] flex-col justify-center gap-5 px-[clamp(1.25rem,5vw,4rem)] pt-[68px]">
        <p className="font-mono text-xs uppercase tracking-[0.25em] text-accent">Case study not found</p>
        <h1 className="font-serif text-4xl text-text">That engagement is not in the archive.</h1>
        <Link
          to="/work"
          className="w-fit rounded-full bg-accent-solid px-5 py-3 text-sm font-medium text-on-accent"
        >
          See all work
        </Link>
      </main>
    );
  }

  const others = clients.filter((item) => item.slug !== client.slug);
  const related = apps.slice(0, 3);

  return (
    <main className="pt-[68px]">
      <section className="border-b border-[var(--border)] bg-deep">
        <div className="mx-auto max-w-[1120px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,6vw,4.5rem)]">
          <nav
            aria-label="Breadcrumb"
            className="flex items-center gap-2 font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted"
          >
            <Link to="/work" className="transition-colors duration-300 hover:text-text">
              Work
            </Link>
            <span aria-hidden="true">/</span>
            <span className="text-text">{client.name}</span>
          </nav>

          <p className="mt-8 font-mono text-[10px] uppercase tracking-[0.18em] text-text-muted">
            {client.type} <span className="text-ink/25">·</span> {client.role}{' '}
            <span className="text-ink/25">·</span> {client.dates}
          </p>

          <h1 className="mt-4 font-serif text-[clamp(2.8rem,7vw,5.2rem)] leading-[0.96] tracking-[-0.025em] text-text">
            {client.name}
          </h1>
          <p className="mt-5 max-w-[62ch] text-[16px] leading-[1.75] text-text/80 md:text-[17px]">
            {client.summary}
          </p>

          <div className="mt-8 flex flex-wrap items-center gap-x-6 gap-y-3">
            <a
              href={client.links.website}
              target="_blank"
              rel="noreferrer"
              onClick={() => trackOutbound(client.name, client.links.website)}
              className="group inline-flex items-center rounded-full bg-band py-2 pl-5 pr-2 text-sm font-medium text-band-fg transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:bg-band/85 active:scale-[0.98]"
            >
              Visit {client.name}
              <span className="ml-2 flex h-7 w-7 items-center justify-center rounded-full bg-band-fg/10">
                <Arrow />
              </span>
            </a>
            <Link
              to="/#contact"
              onClick={() => trackCta('contact', `case:${client.slug}`)}
              className="text-sm text-text-muted transition-colors duration-300 hover:text-text"
            >
              Start a project like this →
            </Link>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-[1120px] px-[clamp(1.25rem,5vw,4rem)] pt-[clamp(2.5rem,5vw,4rem)]">
        <div className="rounded-[2rem] border border-ink/10 bg-surface/70 p-2 shadow-[0_30px_80px_-60px_rgba(20,17,13,0.5)]">
          <div className="relative overflow-hidden rounded-[calc(2rem-0.5rem)] bg-band px-7 py-10 text-band-fg md:px-12 md:py-14">
            <div
              aria-hidden="true"
              className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_78%_12%,rgba(255,255,255,0.09),transparent_55%)]"
            />
            <div className="relative flex flex-col justify-between gap-10 md:flex-row md:items-center md:gap-16">
              <div className="flex items-center gap-6">
                <span className="flex h-20 w-20 shrink-0 items-center justify-center rounded-2xl border border-band-fg/15 bg-[#f7f3e9] p-3 md:h-24 md:w-24">
                  <img src={client.logo} alt={`${client.name} logo`} className="h-full w-full rounded-xl object-contain" />
                </span>
                <div>
                  <p className="font-serif text-[clamp(1.8rem,3.4vw,2.6rem)] leading-none">{client.name}</p>
                  <p className="mt-2 font-mono text-[9px] uppercase tracking-[0.16em] text-band-fg/60">
                    {client.kicker}
                  </p>
                </div>
              </div>

              <dl className="grid grid-cols-2 gap-x-10 gap-y-5 border-t border-band-fg/10 pt-6 md:border-l md:border-t-0 md:pl-12 md:pt-0">
                {client.facts.map(([label, value]) => (
                  <div key={label}>
                    <dt className="font-mono text-[8.5px] uppercase tracking-[0.16em] text-band-fg/60">
                      {label}
                    </dt>
                    <dd className="mt-1.5 text-[13.5px] leading-snug text-band-fg/85">{value}</dd>
                  </div>
                ))}
              </dl>
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-[1120px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,6vw,5rem)]">
        <div className="grid gap-14 lg:grid-cols-[0.85fr_1.15fr] lg:gap-20">
          <div className="flex flex-col gap-10">
            <div>
              <Kicker>The brief</Kicker>
              <h2 className="mt-4 font-serif text-[clamp(1.8rem,3.2vw,2.5rem)] leading-[1.08] tracking-[-0.015em] text-text">
                Challenge
              </h2>
              <p className="mt-4 text-[15px] leading-[1.8] text-text/80">{client.challenge}</p>
            </div>

            <div>
              <Kicker>Stack</Kicker>
              <div className="mt-4 flex flex-wrap gap-2">
                {client.stack.map((item) => (
                  <span
                    key={item}
                    className="rounded-full border border-ink/15 px-3 py-1.5 font-mono text-[11px] text-text-muted"
                  >
                    {item}
                  </span>
                ))}
              </div>
            </div>

            {client.links.store && (
              <a
                href={client.links.store}
                target="_blank"
                rel="noreferrer"
                onClick={() => trackOutbound(`${client.name} App Store`, client.links.store)}
                className="group inline-flex w-fit items-center gap-2 font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted transition-colors duration-300 hover:text-text"
              >
                View on the App Store
                <Arrow className="h-3.5 w-3.5" />
              </a>
            )}
          </div>

          <div className="flex flex-col gap-12">
            <div>
              <Kicker>What I did</Kicker>
              <ul className="mt-5 flex flex-col divide-y divide-ink/10 border-y border-ink/10">
                {client.did.map((item) => (
                  <li key={item} className="flex items-start gap-3.5 py-4">
                    <Check />
                    <span className="text-[15px] leading-[1.7] text-text">{item}</span>
                  </li>
                ))}
              </ul>
            </div>

            {client.decisions?.length > 0 && (
              <div>
                <Kicker>Engineering decisions</Kicker>
                <ol className="mt-5 flex flex-col divide-y divide-ink/10 border-y border-ink/10">
                  {client.decisions.map((decision, index) => (
                    <li key={decision.title} className="grid gap-1.5 py-4 sm:grid-cols-[2rem_1fr] sm:gap-4">
                      <span className="font-mono text-[10px] text-accent">0{index + 1}</span>
                      <div>
                        <p className="text-[15px] font-medium leading-snug text-text">{decision.title}</p>
                        <p className="mt-1.5 text-[14px] leading-[1.7] text-text/75">{decision.rationale}</p>
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

            <div>
              <Kicker>Outcome</Kicker>
              <h2 className="mt-4 font-serif text-[clamp(1.8rem,3.2vw,2.5rem)] leading-[1.08] tracking-[-0.015em] text-text">
                {client.metric} <span className="text-text-muted">{client.metricLabel}</span>
              </h2>
              <p className="mt-4 text-[15px] leading-[1.8] text-text/80">{client.outcome}</p>
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-[1120px] px-[clamp(1.25rem,5vw,4rem)] pb-[clamp(3rem,6vw,5rem)]">
        <div className="flex flex-col items-start justify-between gap-6 rounded-[1.75rem] border border-ink/10 bg-surface p-8 md:flex-row md:items-center md:p-10">
          <div>
            <p className="font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
              Have a similar project?
            </p>
            <p className="mt-3 max-w-[42ch] font-serif text-[clamp(1.7rem,3vw,2.4rem)] leading-[1.1] tracking-[-0.015em] text-text">
              I can own the build from architecture to production support.
            </p>
          </div>
          <Link
            to="/#contact"
            onClick={() => trackCta('contact', `case-cta:${client.slug}`)}
            className="group inline-flex shrink-0 items-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:bg-accent-solid/90 active:scale-[0.98]"
          >
            Talk about your project
            <span className="ml-2 flex h-7 w-7 items-center justify-center rounded-full bg-on-accent/15">
              <Arrow />
            </span>
          </Link>
        </div>
      </section>

      <section className="border-t border-ink/10 bg-deep">
        <div className="mx-auto max-w-[1120px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,6vw,4.5rem)]">
          <div className="flex flex-wrap items-baseline justify-between gap-3">
            <Kicker>More work</Kicker>
            <Link to="/work" className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted hover:text-text">
              All work →
            </Link>
          </div>

          <div className="mt-7 grid gap-4 md:grid-cols-2">
            {others.map((item) => (
              <Link
                key={item.slug}
                to={`/work/${item.slug}`}
                className="group flex items-start gap-5 rounded-[1.4rem] border border-ink/10 bg-surface p-5 transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:-translate-y-0.5 hover:border-ink/25"
              >
                <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-ink/10 bg-[#f7f3e9] p-2">
                  <img src={item.logo} alt="" loading="lazy" className="h-full w-full rounded-md object-contain" />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="flex items-center justify-between gap-3">
                    <span className="font-serif text-xl leading-none text-text">{item.name}</span>
                    <Arrow className="h-3.5 w-3.5 text-text-muted group-hover:text-text" />
                  </span>
                  <span className="mt-2 block text-[13px] leading-[1.6] text-text-muted">{item.kicker}</span>
                </span>
              </Link>
            ))}
          </div>

          <div className="mt-4 grid gap-4 md:grid-cols-3">
            {related.map((app) => (
              <Link
                key={app.slug}
                to={`/apps/${app.slug}`}
                className="group flex items-center gap-3 rounded-xl border border-ink/10 bg-surface/70 p-3.5 transition-colors duration-300 hover:border-ink/25"
              >
                <AppIcon
                  app={app}
                  className="h-9 w-9 shrink-0 overflow-hidden rounded-lg border border-ink/10 object-cover"
                  textClassName="text-[11px]"
                />
                <span className="min-w-0">
                  <span className="block truncate text-[13px] font-medium text-text">{app.name}</span>
                  <span className="block truncate font-mono text-[8.5px] uppercase tracking-[0.12em] text-text-muted">
                    {app.genre}
                  </span>
                </span>
              </Link>
            ))}
          </div>
        </div>
      </section>
    </main>
  );
}
