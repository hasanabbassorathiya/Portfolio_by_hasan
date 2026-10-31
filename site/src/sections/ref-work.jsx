import React from 'react';
import { Link } from '../lib/router';
import { useApps, useClients } from '../lib/live-content';
import { trackOpen, trackOutbound } from '../lib/analytics';
import { Arrow, ArrowBadge, Kicker, SectionHead } from './ref-ui';

function AppCard({ app }) {
  const metric = app.metrics[0] ?? ['Shipped', 'in production'];
  const iconOnly = ['petassy', 'pool-inspection'].includes(app.slug) || (!app.cover && !app.screenshots[0]);
  return (
    <Link
      to={`/apps/${app.slug}`}
      onClick={() => trackOpen(app.slug)}
      className="group flex min-h-[300px] flex-col overflow-hidden rounded-[1.4rem] border border-band-fg/10 bg-band-soft transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:-translate-y-1 hover:border-band-fg/25"
    >
      <div className="relative h-36 shrink-0 overflow-hidden border-b border-band-fg/10 bg-band">
        <img
          src={iconOnly ? app.icon : app.cover || app.screenshots[0]}
          alt=""
          loading="lazy"
          className={`${iconOnly ? 'mx-auto h-28 w-28 p-3 object-contain' : 'h-full w-full object-cover object-top'} transition duration-700 ease-[cubic-bezier(0.22,1,0.36,1)] group-hover:scale-[1.04]`}
        />
        {!iconOnly && <div
          aria-hidden="true"
          className="absolute inset-0 bg-gradient-to-t from-band/90 via-band/15 to-transparent"
        />}
        <span className="absolute bottom-3 left-5 font-mono text-[9px] uppercase tracking-[0.18em] text-band-fg/65">
          {app.platforms.join(' · ')}
        </span>
      </div>
      <div className="flex flex-1 flex-col p-5">
        <div className="flex items-start justify-between gap-3">
          <h3 className="text-lg font-semibold tracking-[-0.01em] text-band-fg">{app.name}</h3>
          <span className="text-band-fg/60 transition-colors duration-300 group-hover:text-band-fg">
            <Arrow />
          </span>
        </div>
        <p className="mt-2 flex-1 text-sm leading-[1.6] text-band-fg/55">{app.tagline}</p>
        <div className="mt-5 flex items-end justify-between gap-3 border-t border-band-fg/10 pt-3">
          <span className="font-serif text-2xl leading-none text-band-fg">{metric[0]}</span>
          <span className="text-right text-xs text-band-fg/60">{metric[1]}</span>
        </div>
      </div>
    </Link>
  );
}

function ExtraCard({ item }) {
  return (
    <article className="group flex min-h-[300px] flex-col overflow-hidden rounded-[1.4rem] border border-band-fg/10 bg-transparent transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:border-band-fg/25">
      <Link
        to={`/work/${item.slug}`}
        onClick={() => trackOpen(item.slug)}
        className="relative flex h-36 shrink-0 items-center gap-4 overflow-hidden border-b border-band-fg/10 bg-[radial-gradient(circle_at_30%_20%,rgba(255,255,255,0.09),transparent_65%)] px-6"
      >
        <span className="flex h-14 w-14 items-center justify-center rounded-2xl border border-band-fg/15 bg-[#f7f3e9] p-2.5">
          <img
            src={item.logo}
            alt={`${item.name} logo`}
            loading="lazy"
            className="h-full w-full rounded-lg object-contain"
          />
        </span>
        <span className="font-serif text-2xl leading-none tracking-[-0.02em] text-band-fg/80 transition-colors duration-300 group-hover:text-band-fg">
          {item.name}
        </span>
      </Link>
      <div className="flex flex-1 flex-col p-5">
        <Kicker tone="dark">{item.kicker}</Kicker>
        <h3 className="mt-3 font-serif text-2xl leading-none text-band-fg">
          <Link to={`/work/${item.slug}`} onClick={() => trackOpen(item.slug)} className="transition-colors duration-300 hover:text-band-fg/80">
            {item.name}
          </Link>
        </h3>
        <p className="mt-3 flex-1 text-sm leading-[1.6] text-band-fg/55">{item.summary}</p>
        <div className="mt-5 flex items-end justify-between gap-3 border-t border-band-fg/10 pt-3">
          <span className="font-serif text-2xl leading-none text-band-fg">{item.metric}</span>
          <span className="text-right text-xs text-band-fg/60">{item.metricLabel}</span>
        </div>
        <div className="mt-3 flex flex-wrap items-center justify-between gap-x-4 gap-y-2 text-xs">
          <Link
            to={`/work/${item.slug}`}
            onClick={() => trackOpen(item.slug)}
            className="group/link inline-flex items-center gap-1.5 font-medium text-band-fg/80 transition-colors duration-300 hover:text-band-fg"
          >
            Case study
            <Arrow className="h-3.5 w-3.5" />
          </Link>
          <a
            href={item.website}
            target="_blank"
            rel="noreferrer"
            onClick={() => trackOutbound(item.name, item.website)}
            className="text-band-fg/60 transition-colors duration-300 hover:text-band-fg"
          >
            {item.website.replace(/^https?:\/\/(www\.)?/, '').replace(/\/$/, '')} ↗
          </a>
        </div>
      </div>
    </article>
  );
}

export function Work() {
  const apps = useApps();
  const clients = useClients();
  const [featured, ...rest] = apps;

  return (
    <section id="work" className="bg-band text-band-fg">
      <div className="mx-auto max-w-[1180px] px-5 py-24 md:py-32">
        <SectionHead
          tone="dark"
          kicker="Selected work"
          title={
            <>
              Named work, with the <em className="italic text-hl-a">numbers</em>
            </>
          }
          blurb={`${apps.length} app profiles and ${clients.length} client engagements, with the engineering decisions, role boundaries and public links behind the work.`}
          action={
            <Link
              to="/work"
              className="group inline-flex items-center rounded-full border border-band-fg/25 py-1.5 pl-4 pr-1.5 text-sm text-band-fg transition-colors duration-300 hover:border-band-fg/60"
            >
              All work &amp; case studies
              <ArrowBadge />
            </Link>
          }
        />

        {featured && <Link
          to={`/apps/${featured.slug}`}
          className="group mt-12 grid overflow-hidden rounded-[1.75rem] border border-band-fg/12 bg-band-soft transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:border-band-fg/30 lg:grid-cols-[1.05fr_1fr]"
        >
          <div className="relative min-h-[260px] overflow-hidden bg-band lg:min-h-[380px]">
            <img
              src={featured.screenshots[0] || featured.cover || featured.icon}
              alt={`${featured.name} app screen`}
              loading="lazy"
              className="h-full w-full object-cover object-top transition duration-700 ease-[cubic-bezier(0.22,1,0.36,1)] group-hover:scale-[1.03]"
            />
            <div
              aria-hidden="true"
              className="absolute inset-0 bg-gradient-to-t from-band/60 via-transparent to-transparent"
            />
          </div>

          <div className="flex flex-col justify-center p-7 md:p-10">
            <Kicker tone="dark">Featured case study</Kicker>
            <h3 className="mt-4 font-serif text-[clamp(2.2rem,4vw,3.4rem)] leading-none tracking-[-0.015em] text-band-fg">
              {featured.name}
            </h3>
            <p className="mt-4 max-w-[44ch] text-[15px] leading-[1.7] text-band-fg/60">
              {featured.summary || featured.tagline}
            </p>

            <div className="mt-7 flex flex-wrap items-center gap-x-8 gap-y-3 border-t border-band-fg/10 pt-5">
              <div>
                <p className="font-serif text-3xl leading-none text-hl-a">
                  {featured.rating ? `${featured.rating.value.toFixed(1)}★` : 'Shipped'}
                </p>
                <p className="mt-1 font-mono text-[9px] uppercase tracking-[0.14em] text-band-fg/60">
                  {featured.rating
                    ? `${featured.rating.source || 'App Store'} · ${featured.rating.count.toLocaleString('en-US')} ${featured.rating.noun || 'ratings'}`
                    : 'in production'}
                </p>
              </div>
              <div>
                <p className="font-serif text-3xl leading-none text-band-fg">
                  {featured.platforms?.length ?? 1}
                </p>
                <p className="mt-1 font-mono text-[9px] uppercase tracking-[0.14em] text-band-fg/60">
                  platforms shipped
                </p>
              </div>
              <div>
                <p className="font-serif text-3xl leading-none text-band-fg">
                  {featured.year}
                </p>
                <p className="mt-1 font-mono text-[9px] uppercase tracking-[0.14em] text-band-fg/60">
                  {featured.role}
                </p>
              </div>
            </div>

            <span className="mt-7 inline-flex items-center gap-2 text-sm font-medium text-band-fg rule-link w-fit">
              Read the case study
              <Arrow />
            </span>
          </div>
        </Link>}

        <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {rest.map((app) => (
            <AppCard key={app.slug} app={app} />
          ))}
          {clients.map((item) => (
            <ExtraCard key={item.slug} item={item} />
          ))}
        </div>

        <p className="mt-8 font-mono text-[9px] uppercase tracking-[0.14em] text-band-fg/60">
          Ratings are public App Store and Google Play data · client metrics come from the named delivery records
        </p>
      </div>
    </section>
  );
}

export function Receipts() {
  const apps = useApps();
  const clients = useClients();
  const duas = apps.find((app) => app.slug === 'duas-and-aamal');
  const good2go = clients.find((client) => client.slug === 'good2go-loans');
  const market = good2go?.facts?.find?.(([label]) => label === 'Market')?.[1];

  return (
    <section id="receipts" className="mx-auto max-w-[1180px] px-5 py-24 md:py-32">
      <SectionHead
        kicker="Signals"
        title={
          <>
            Receipts, not <em className="italic text-hl-a">testimonials</em>
          </>
        }
        blurb="No invented quotes. Public store ratings and shipped outcomes you can verify."
        action={
          <span className="font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
            Store ratings from the app catalogue
          </span>
        }
      />

      <div className="mt-12 grid gap-4 md:grid-cols-2">
        {duas?.rating && <article className="group rounded-[1.6rem] border border-ink/10 bg-surface p-7 transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:-translate-y-1 hover:border-ink/25 md:p-8">
          <div className="flex items-start justify-between gap-4">
            <span className="font-serif text-6xl leading-none tracking-[-0.02em] text-accent">{duas.rating.value.toFixed(1)}★</span>
            <span className="font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted">
              Duas and Aamal
            </span>
          </div>
          <p className="mt-7 max-w-[48ch] text-[15px] leading-[1.72] text-text/80">
            A Gujarati-first religious companion with five languages, offline content, Jafari
            prayer times, and an Android TV layout — rated {duas.rating.value.toFixed(1)} across{' '}
            {duas.rating.count.toLocaleString('en-US')} public {duas.rating.source || 'Google Play'}{' '}
            {duas.rating.noun || 'reviews'}.
          </p>
          <div className="mt-7 flex flex-wrap items-center gap-5 border-t border-ink/10 pt-4 text-sm">
            <Link
              to="/apps/duas-and-aamal"
              onClick={() => trackOpen('duas-and-aamal')}
              className="group/link inline-flex items-center gap-2 font-medium text-text rule-link"
            >
              Read the case study
              <Arrow />
            </Link>
            <a
              href="https://play.google.com/store/apps/details?id=app.duasandaamal.com"
              target="_blank"
              rel="noreferrer"
              className="text-text-muted transition-colors duration-300 hover:text-text"
            >
              View on Google Play ↗
            </a>
          </div>
        </article>}

        {good2go && <article className="group rounded-[1.6rem] border border-ink/10 bg-surface p-7 transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:-translate-y-1 hover:border-ink/25 md:p-8">
          <div className="flex items-start justify-between gap-4">
            <span className="font-serif text-6xl leading-none tracking-[-0.02em] text-hl-a">{good2go.metric}</span>
            <span className="font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted">
              {good2go.name}
            </span>
          </div>
          <p className="mt-7 max-w-[48ch] text-[15px] leading-[1.72] text-text/80">
            At {good2go.name}, the mobile work connected onboarding, secure account access, and
            lending journeys in one Flutter app. The product reached {good2go.metric}{' '}
            {good2go.metricLabel}, with an architecture the team could keep extending instead of
            starting again.
          </p>
          <div className="mt-7 flex flex-wrap items-center gap-5 border-t border-ink/10 pt-4 text-sm">
            <Link
              to={`/work/${good2go.slug}`}
              onClick={() => trackOpen(good2go.slug)}
              className="inline-flex items-center gap-2 font-medium text-text rule-link"
            >
              Read the case study
              <Arrow />
            </Link>
            <span className="text-text-muted">
              {good2go.type}
              {market ? ` · ${market}` : ''}
            </span>
          </div>
        </article>}
      </div>
    </section>
  );
}
