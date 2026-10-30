import React from 'react';
import { affiliateDisclosure, featuredPackage, partners, resourceGroups } from '../content/resources';
import { Link } from '../lib/router';
import { SITE_NAME, useSeo } from '../lib/seo';
import { trackOutbound } from '../lib/analytics';
import { Arrow, ArrowBadge, Kicker } from '../sections/ref-ui';
import { ServiceEnquiry } from './services';

function ResourceLink({ item }) {
  const className =
    'group flex flex-col gap-1.5 border-b border-ink/10 py-5 transition-colors duration-300 hover:border-ink/30';
  const body = (
    <>
      <span className="flex items-baseline justify-between gap-4">
        <span className="text-[15px] font-medium leading-snug text-text transition-colors group-hover:text-accent">
          {item.name}
        </span>
        <span className="shrink-0 font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted">
          {item.label} ↗
        </span>
      </span>
      <span className="max-w-[54ch] text-sm leading-[1.7] text-text-muted">{item.detail}</span>
    </>
  );
  if (item.external) {
    return (
      <a
        href={item.href}
        target="_blank"
        rel="noreferrer"
        onClick={() => trackOutbound(item.name, item.href)}
        className={className}
      >
        {body}
      </a>
    );
  }
  return (
    <Link to={item.href} className={className}>
      {body}
    </Link>
  );
}

export function ResourcesPage() {
  useSeo({
    title: `Resources · Packages, code & reading · ${SITE_NAME}`,
    description:
      'Flutter packages and open-source code by Hasan Abbas Sorathiya, including stoolap_flutter on pub.dev, plus production essays on Flutter, AI, and full-stack delivery.',
    path: '/resources',
  });

  return (
    <main className="pt-28 md:pt-32">
      <header className="mx-auto max-w-[1180px] px-5 pb-14 pt-8 md:pb-20 md:pt-12">
        <Kicker>Resources · Use what I use</Kicker>
        <div className="mt-6 grid gap-7 lg:grid-cols-[1.15fr_0.85fr] lg:items-end lg:gap-16">
          <h1 className="max-w-[17ch] font-serif text-[clamp(3rem,7vw,5.8rem)] font-normal leading-[0.98] tracking-[-0.025em] text-text">
            Useful things,<br />
            no <em className="italic text-accent">filler.</em>
          </h1>
          <div>
            <p className="max-w-[54ch] text-[16px] leading-[1.8] text-text-muted">
              Packages I publish, code I keep in the open, and essays written from production work.
              The list stays short on purpose; every entry is something I would point a teammate to.
            </p>
            <p className="mt-4 max-w-[54ch] text-sm leading-[1.75] text-text-muted">
              Any commercial or referral links will be labelled as such, with the relationship
              disclosed before the link.
            </p>
          </div>
        </div>
      </header>

      <section aria-labelledby="featured-package" className="mx-auto max-w-[1180px] px-5 pb-16 md:pb-24">
        <div className="rounded-[1.75rem] bg-band p-7 text-band-fg md:p-10 lg:grid lg:grid-cols-[1.15fr_0.85fr] lg:gap-12">
          <div className="min-w-0">
            <Kicker tone="dark">Featured package · pub.dev</Kicker>
            <h2
              id="featured-package"
              className="mt-5 font-serif text-[clamp(2.2rem,5vw,3.9rem)] font-normal leading-[1.02] tracking-[-0.02em]"
            >
              {featuredPackage.name}
            </h2>
            <p className="mt-5 max-w-[54ch] text-[15px] leading-[1.8] text-band-fg/85">
              {featuredPackage.description}
            </p>
            <div className="mt-7 flex flex-wrap items-center gap-x-6 gap-y-3">
              <a
                href={featuredPackage.pubdev}
                target="_blank"
                rel="noreferrer"
                onClick={() => trackOutbound('stoolap_flutter', featuredPackage.pubdev)}
                className="group inline-flex min-h-12 items-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90"
              >
                View on pub.dev
                <ArrowBadge tone="dark" />
              </a>
              <a
                href={featuredPackage.repo}
                target="_blank"
                rel="noreferrer"
                onClick={() => trackOutbound('stoolap-flutter source', featuredPackage.repo)}
                className="group inline-flex min-h-11 items-center gap-2 text-sm text-band-fg underline decoration-band-fg/30 underline-offset-4 hover:decoration-band-fg"
              >
                Source on GitHub <Arrow />
              </a>
            </div>
          </div>
          <div className="mt-8 flex flex-col gap-4 rounded-2xl border border-band-fg/20 p-5 lg:mt-0 lg:self-center">
            <div>
              <p className="font-mono text-[9px] uppercase tracking-[0.16em] text-band-fg/65">Install</p>
              <code className="mt-2 block overflow-x-auto rounded-lg border border-band-fg/15 bg-canvas/10 px-3 py-2.5 font-mono text-xs text-band-fg">
                {featuredPackage.install}
              </code>
            </div>
            <ul className="flex flex-col gap-2 border-t border-band-fg/15 pt-4">
              {featuredPackage.points.map((point) => (
                <li key={point} className="flex gap-2.5 text-sm leading-[1.6] text-band-fg/85">
                  <span aria-hidden="true" className="text-hl-a">—</span>
                  {point}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      <section aria-label="Resource groups" className="mx-auto max-w-[1180px] px-5 pb-16 md:pb-24">
        {resourceGroups.map((group) => (
          <div
            key={group.title}
            className="grid gap-6 border-t border-ink/15 py-10 md:grid-cols-[0.38fr_0.62fr] md:gap-12 md:py-12"
          >
            <div>
              <h2 className="font-serif text-[clamp(1.8rem,3vw,2.4rem)] leading-[1.1] tracking-[-0.01em] text-text">
                {group.title}
              </h2>
              <p className="mt-3 max-w-[38ch] text-sm leading-[1.75] text-text-muted">{group.copy}</p>
            </div>
            <div className="flex flex-col">
              {group.items.map((item) => (
                <ResourceLink key={item.name} item={item} />
              ))}
            </div>
          </div>
        ))}

        {partners.length > 0 && (
          <div className="grid gap-6 border-t border-ink/15 py-10 md:grid-cols-[0.38fr_0.62fr] md:gap-12 md:py-12">
            <div>
              <h2 className="font-serif text-[clamp(1.8rem,3vw,2.4rem)] leading-[1.1] tracking-[-0.01em] text-text">
                Partner links
              </h2>
              <p className="mt-3 max-w-[38ch] text-sm leading-[1.75] text-text-muted">
                {affiliateDisclosure}
              </p>
            </div>
            <div className="flex flex-col">
              {partners.map((item) => (
                <ResourceLink key={item.name} item={{ ...item, external: true }} />
              ))}
            </div>
          </div>
        )}
      </section>

      <ServiceEnquiry
        prompt="Need something built, audited, or automated? Tell me what exists, what is blocking it, and what a useful outcome looks like. I will reply with whether the work is a fit."
        subject="Resource enquiry"
      />
    </main>
  );
}
