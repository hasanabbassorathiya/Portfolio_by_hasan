import React from 'react';
import { Link } from '../lib/router';
import { shipped } from '../content/apps';
import { useApps } from '../lib/live-content';
import { useSeo, SITE_URL, personJsonLd } from '../lib/seo';
import { trackOpen, trackCta, trackOutbound } from '../lib/analytics';

function AppCard({ app }) {
  return (
    <Link
      to={`/apps/${app.slug}`}
      onClick={() => trackOpen(app.slug)}
      className="group flex flex-col gap-5 rounded-2xl border border-[var(--border)] bg-surface p-6 transition-colors hover:border-accent/45"
    >
      <div className="flex items-start justify-between gap-4">
        <img
          src={app.icon}
          alt={`${app.name} icon`}
          className="h-16 w-16 rounded-2xl border border-accent/25 object-cover"
          loading="lazy"
        />
        {app.rating && (
          <span className="rounded-full border border-accent/30 px-3 py-1 font-mono text-[10px] text-accent">
            ★ {app.rating.value.toFixed(1)} ({app.rating.count.toLocaleString('en-US')})
          </span>
        )}
      </div>
      <div className="flex flex-col gap-2">
        <h3 className="font-serif text-2xl leading-tight transition-colors group-hover:text-accent">
          {app.name}
        </h3>
        <p className="text-sm leading-[1.7] text-text-muted">{app.tagline}</p>
        <p className="font-mono text-[10px] uppercase tracking-[0.14em] text-accent">{app.role}</p>
      </div>
      <div className="mt-auto flex items-center justify-between gap-3 border-t border-[var(--border)] pt-4">
        <span className="font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted">
          {app.platforms.join(' · ')}
        </span>
        <span className="font-mono text-[11px] text-accent">View app →</span>
      </div>
    </Link>
  );
}

function ShippedRow({ app }) {
  const content = (
    <>
      <div className="flex min-w-0 flex-col gap-1">
        <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
          <span className="font-serif text-lg text-text">{app.name}</span>
          <span className="font-mono text-[10px] uppercase tracking-[0.14em] text-accent">{app.role}</span>
        </div>
        <p className="max-w-[70ch] text-sm leading-[1.65] text-text-muted">{app.note}</p>
      </div>
      <div className="flex shrink-0 items-center gap-4 md:flex-col md:items-end md:gap-1">
        <span className="font-mono text-[10px] uppercase tracking-[0.12em] text-text-muted">{app.platforms}</span>
        {app.href && <span className="font-mono text-[11px] text-accent">Open ↗</span>}
        {app.slug && <span className="font-mono text-[11px] text-accent">View app →</span>}
      </div>
    </>
  );

  const className =
    'flex flex-col gap-3 border-t border-[var(--border)] py-6 md:flex-row md:items-baseline md:justify-between md:gap-8';

  if (app.slug) {
    return (
      <Link
        to={`/apps/${app.slug}`}
        onClick={() => trackOpen(app.slug)}
        className={`${className} group transition-colors hover:border-accent/40`}
      >
        {content}
      </Link>
    );
  }
  if (app.href) {
    return (
      <a href={app.href} target="_blank" rel="noreferrer" className={`${className} group transition-colors hover:border-accent/40`}>
        {content}
      </a>
    );
  }
  return <div className={className}>{content}</div>;
}

export function AppsPage() {
  const apps = useApps();
  const otherShipped = shipped.filter((entry) => !entry.slug && !apps.some((app) => app.name === entry.name));
  const catalogue = [...apps, ...otherShipped];
  const platformCount = new Set(apps.flatMap((app) => app.platforms)).size;
  const description = `${catalogue.length} apps across personal products, client work, and publishing contributions, with ${apps.length} app profiles and store or source links.`;
  useSeo({
    title: 'Apps · Hasan Abbas Sorathiya',
    description,
    path: '/apps',
    image: '/og/apps.png',
    jsonLd: [
      personJsonLd,
      {
        '@context': 'https://schema.org',
        '@type': 'CollectionPage',
        name: 'App portfolio · Hasan Abbas Sorathiya',
        url: `${SITE_URL}/apps`,
        description,
        mainEntity: {
          '@type': 'ItemList',
          numberOfItems: catalogue.length,
          itemListElement: catalogue.map((app, index) => ({
            '@type': 'ListItem',
            position: index + 1,
            name: app.name,
            ...(app.slug
              ? { url: `${SITE_URL}/apps/${app.slug}` }
              : app.href
                ? { url: app.href }
                : {}),
          })),
        },
      },
    ],
  });

  return (
    <main className="pt-[68px]">
      <section className="border-b border-[var(--border)] bg-deep">
        <div className="mx-auto flex max-w-[1360px] flex-col gap-8 px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,7vw,5.5rem)]">
          <nav className="flex items-center gap-2 font-mono text-[11px] uppercase tracking-[0.16em] text-text-muted" aria-label="Breadcrumb">
            <Link to="/" className="hover:text-accent">Home</Link>
            <span aria-hidden="true">/</span>
            <span className="text-accent">Apps</span>
          </nav>

          <div className="flex flex-col gap-5">
            <h1 className="max-w-[24ch] font-serif text-[clamp(2.4rem,6vw,4.6rem)] leading-[1.02] tracking-[-0.03em]">
              {catalogue.length} apps. Different <em className="font-serif font-normal italic text-accent">contributions</em>.
            </h1>
            <p className="max-w-[70ch] text-[1.05rem] leading-[1.8] text-text-muted">
              Personal products, client work, and publishing contributions across iOS, Android, web, and Android TV.
              {' '}{apps.length} app profiles below describe the products and my role; publishing is credited separately from development.
            </p>
          </div>

          <div className="flex flex-wrap gap-x-10 gap-y-4 border-t border-[var(--border)] pt-6 font-mono text-[11px] uppercase tracking-[0.14em] text-text-muted">
            <span><span className="text-accent">{catalogue.length}</span> apps in the portfolio</span>
            <span><span className="text-accent">{apps.length}</span> app profiles</span>
            <span><span className="text-accent">{platformCount}</span> platforms</span>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,6vw,4.5rem)]">
        <div className="flex flex-col gap-3 pb-8">
          <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">App catalogue</p>
          <h2 className="font-serif text-[clamp(1.7rem,3.6vw,2.6rem)] tracking-[-0.02em]">
            {apps.length} app profiles — products and contributions
          </h2>
        </div>
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {apps.map((app) => (
            <AppCard key={app.slug} app={app} />
          ))}
        </div>
      </section>

      <section className="border-y border-[var(--border)] bg-deep">
        <div className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,6vw,4.5rem)]">
          <div className="flex flex-col gap-3 pb-6">
            <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">More work</p>
            <h2 className="font-serif text-[clamp(1.7rem,3.6vw,2.6rem)] tracking-[-0.02em]">
              {otherShipped.length} more entries — client work and open source
            </h2>
          </div>
          <div className="flex flex-col border-b border-[var(--border)]">
            {otherShipped.map((app) => (
              <ShippedRow key={app.name} app={app} />
            ))}
          </div>
          <p className="mt-6 font-mono text-[11px] uppercase tracking-[0.14em] text-text-muted">
            Some client apps are no longer listed on public stores.
          </p>
          <div className="mt-3 flex flex-wrap gap-x-6 gap-y-2 font-mono text-[11px] uppercase tracking-[0.14em]">
            <a
              href="https://apps.apple.com/ae/developer/hasan-abbas-sorathiya/id1734376366"
              target="_blank"
              rel="noreferrer"
              onClick={() => trackOutbound('App Store developer page', 'https://apps.apple.com/ae/developer/hasan-abbas-sorathiya/id1734376366')}
              className="text-accent transition-colors hover:text-text"
            >
              All iOS apps on the App Store ↗
            </a>
            <a
              href="https://play.google.com/store/apps/dev?id=5895887615343030170"
              target="_blank"
              rel="noreferrer"
              onClick={() => trackOutbound('Google Play developer page', 'https://play.google.com/store/apps/dev?id=5895887615343030170')}
              className="text-accent transition-colors hover:text-text"
            >
              All Android apps on Google Play ↗
            </a>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,6vw,4rem)]">
        <div className="flex flex-col gap-4 rounded-[1.75rem] border border-accent/25 bg-surface p-8 md:flex-row md:items-center md:justify-between md:p-10">
          <div className="flex flex-col gap-2">
            <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">Work with me</p>
            <h2 className="max-w-[36ch] font-serif text-[clamp(1.5rem,3vw,2.1rem)] leading-snug">
              An app that needs building, rescuing, or a second opinion?
            </h2>
            <p className="max-w-[58ch] text-sm leading-[1.7] text-text-muted">
              Available for senior Flutter and AI work — full-time, contract, or a focused architecture review.
            </p>
          </div>
          <a
            href="mailto:hasanabbassorathiya12@gmail.com?subject=App%20project%20enquiry"
            onClick={() => trackCta('email', 'apps')}
            className="shrink-0 rounded-lg bg-accent-solid px-6 py-3.5 text-center font-medium text-on-accent transition hover:brightness-110"
          >
            Talk about a project
          </a>
        </div>
      </section>
    </main>
  );
}
