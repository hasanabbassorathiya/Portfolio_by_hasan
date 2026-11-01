import React from 'react';
import { Link } from '../lib/router';
import { AppIcon } from '../components/app-icon';
import { useApps, useProfile } from '../lib/live-content';
import { interpolate, platformLine, tickerLine, useSiteMetrics } from '../lib/site-metrics';
import { trackCta, trackOutbound, trackResume } from '../lib/analytics';
import { Arrow, ArrowBadge, Kicker } from './ref-ui';

const socials = [
  {
    label: 'GitHub',
    key: 'github',
    filled: true,
    icon: (
      <path d="M12 .5C5.65.5.5 5.65.5 12c0 5.08 3.29 9.39 7.86 10.91.58.11.79-.25.79-.55v-2.1c-3.2.7-3.87-1.54-3.87-1.54-.52-1.33-1.28-1.68-1.28-1.68-1.05-.72.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.77 2.7 1.26 3.36.96.1-.75.4-1.26.73-1.55-2.55-.29-5.23-1.28-5.23-5.7 0-1.26.45-2.29 1.19-3.1-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.18 1.18a11 11 0 0 1 5.8 0c2.2-1.49 3.17-1.18 3.17-1.18.63 1.59.23 2.76.11 3.05.74.81 1.19 1.84 1.19 3.1 0 4.43-2.69 5.4-5.25 5.69.41.36.78 1.06.78 2.14v3.17c0 .31.21.67.8.55A11.5 11.5 0 0 0 23.5 12C23.5 5.65 18.35.5 12 .5Z" />
    ),
  },
  {
    label: 'LinkedIn',
    key: 'linkedin',
    filled: true,
    icon: (
      <path d="M20.45 20.45h-3.56v-5.57c0-1.33-.02-3.04-1.85-3.04-1.85 0-2.14 1.45-2.14 2.94v5.67H9.35V9h3.41v1.56h.05c.48-.9 1.64-1.85 3.37-1.85 3.6 0 4.27 2.37 4.27 5.46v6.28ZM5.34 7.43a2.06 2.06 0 1 1 0-4.13 2.06 2.06 0 0 1 0 4.13Zm1.78 13.02H3.55V9h3.57v11.45ZM22.22 0H1.77C.79 0 0 .77 0 1.72v20.56C0 23.23.79 24 1.77 24h20.45c.98 0 1.78-.77 1.78-1.72V1.72C24 .77 23.2 0 22.22 0Z" />
    ),
  },
  {
    label: 'Email',
    mailto: true,
    icon: (
      <>
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <path d="m3.5 6.5 8.5 6 8.5-6" />
      </>
    ),
  },
  {
    label: 'YouTube',
    key: 'youtube',
    filled: true,
    icon: (
      <path d="M23.5 6.2a3 3 0 0 0-2.1-2.1C19.5 3.5 12 3.5 12 3.5s-7.5 0-9.4.6A3 3 0 0 0 .5 6.2 31 31 0 0 0 0 12a31 31 0 0 0 .5 5.8 3 3 0 0 0 2.1 2.1c1.9.6 9.4.6 9.4.6s7.5 0 9.4-.6a3 3 0 0 0 2.1-2.1A31 31 0 0 0 24 12a31 31 0 0 0-.5-5.8ZM9.6 15.6V8.4L15.8 12l-6.2 3.6Z" />
    ),
  },
  {
    label: 'Instagram',
    key: 'instagram',
    icon: (
      <>
        <rect x="3.2" y="3.2" width="17.6" height="17.6" rx="5" />
        <circle cx="12" cy="12" r="4.1" />
        <circle cx="17.3" cy="6.7" r="1.05" fill="currentColor" stroke="none" />
      </>
    ),
  },
  {
    label: 'Medium',
    key: 'medium',
    filled: true,
    icon: (
      <path d="M13.54 12a6.8 6.8 0 0 1-6.77 6.82A6.8 6.8 0 0 1 0 12a6.8 6.8 0 0 1 6.77-6.82A6.8 6.8 0 0 1 13.54 12Zm7.42 0c0 3.54-1.51 6.42-3.38 6.42-1.87 0-3.39-2.88-3.39-6.42s1.52-6.42 3.39-6.42 3.38 2.88 3.38 6.42ZM24 12c0 3.17-.53 5.75-1.19 5.75-.66 0-1.19-2.58-1.19-5.75s.53-5.75 1.19-5.75C23.47 6.25 24 8.83 24 12Z" />
    ),
  },
  {
    label: 'Udemy certificate',
    key: 'certificate',
    icon: (
      <>
        <path d="M12 3.5 2.5 8l9.5 4.5L21.5 8 12 3.5Z" />
        <path d="M6.4 10.2v4.1c0 1.5 2.5 2.7 5.6 2.7s5.6-1.2 5.6-2.7v-4.1" />
        <path d="M21.5 8v5.2" />
      </>
    ),
  },
  {
    label: 'Résumé',
    href: '/resume',
    icon: (
      <>
        <path d="M6 2.5h8l4 4v15H6z" />
        <path d="M14 2.5v4h4M9 12h6M9 16h6" />
      </>
    ),
  },
];

const platforms = [
  { label: 'iOS delivery' },
  { label: 'Android delivery' },
  { label: 'Flutter', primary: true },
  { label: 'AI systems' },
];

export function Hero() {
  const apps = useApps();
  const profile = useProfile();
  const metrics = useSiteMetrics();
  const featured = apps.find((app) => app.slug === 'duas-and-aamal') ?? apps[0];
  const marqueeApps = apps.slice(0, 8);
  const socialLinks = socials
    .map((item) => {
      if (item.mailto) return { ...item, href: profile.email ? `mailto:${profile.email}` : '' };
      if (item.key) return { ...item, href: profile[item.key] };
      return item;
    })
    .filter((item) => item.href);

  return (
    <section id="top" className="relative overflow-hidden pb-0 pt-28 md:pt-36" aria-labelledby="hero-title">
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-x-0 top-0 h-[520px] bg-[radial-gradient(ellipse_at_72%_18%,rgba(29,60,255,0.09),transparent_58%)]"
      />

      <div className="relative mx-auto max-w-[1180px] px-5">
        <div className="rise flex flex-wrap items-center justify-between gap-3 border-b border-ink/10 pb-4">
          <Kicker>{profile.kicker}</Kicker>
          <p className="flex items-center gap-2 font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-600" aria-hidden="true" />
            {profile.availability}
            <span className="hidden text-ink/20 sm:inline">/</span>
            <span className="hidden sm:inline">{tickerLine(metrics)}</span>
          </p>
        </div>

        <div className="grid gap-10 pb-16 pt-10 md:gap-14 md:pb-24 md:pt-14 lg:grid-cols-12 lg:gap-8">
          <div className="lg:col-span-7">
            <h1
              id="hero-title"
              className="rise rise-1 max-w-[13ch] font-serif text-[clamp(2.85rem,5.8vw,5.35rem)] font-normal leading-[0.97] tracking-[-0.02em] text-text"
            >
              I build <em className="italic text-accent">Flutter apps</em> and AI systems that{' '}
              <em className="italic text-hl-a">survive production</em>.
            </h1>

            <p className="rise rise-2 mt-7 max-w-[54ch] text-[16px] leading-[1.72] text-text-muted md:text-[17px]">
              {interpolate(profile.sub, metrics)}
            </p>

            <ul className="rise rise-2 mt-6 flex flex-wrap items-center gap-2 font-mono text-[10px] uppercase tracking-[0.14em]">
              {platforms.map((item) => (
                <li
                  key={item.label}
                  className={
                    item.primary
                      ? 'rounded-full border border-accent/40 bg-accent/[0.06] px-3 py-1 text-accent'
                      : 'rounded-full border border-ink/10 px-3 py-1 text-text-muted'
                  }
                >
                  {item.label}
                </li>
              ))}
            </ul>

            <div className="rise rise-3 mt-8 flex flex-wrap items-center gap-x-7 gap-y-4">
              <a
                href="#contact"
                onClick={() => trackCta('contact', 'hero')}
                className="group inline-flex items-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:bg-accent-solid/90 active:scale-[0.98]"
              >
                Start a project
                <ArrowBadge tone="dark" />
              </a>
              <a
                href="#work"
                onClick={() => trackCta('work', 'hero')}
                className="group inline-flex items-center gap-2 py-2.5 text-sm font-medium text-text rule-link"
              >
                See selected work
                <Arrow />
              </a>
              <Link
                to="/resume"
                onClick={() => trackResume('hero-cta')}
                className="inline-flex items-center gap-2 py-2.5 text-sm font-medium text-text-muted transition-colors duration-300 hover:text-text"
              >
                Hiring? Explore my experience
                <Arrow />
              </Link>
            </div>

            <div className="rise rise-4 mt-10 flex flex-wrap items-center justify-between gap-5 border-t border-ink/10 pt-5">
              <div className="flex flex-wrap items-center gap-1">
                {socialLinks.map((item) => {
                  const external = item.href.startsWith('http');
                  return (
                    <a
                      key={item.label}
                      href={item.href}
                      target={external ? '_blank' : undefined}
                      rel={external ? 'noreferrer' : undefined}
                      aria-label={item.label}
                      onClick={() => {
                        if (item.label === 'Résumé') trackResume('hero');
                        else if (item.href.startsWith('mailto:')) trackCta('email', 'hero-icon');
                        else trackOutbound(item.label, item.href);
                      }}
                      className="inline-flex h-11 w-11 items-center justify-center rounded-full text-text-muted transition-colors duration-300 hover:text-accent"
                    >
                      <svg
                        aria-hidden="true"
                        viewBox="0 0 24 24"
                        className="h-[18px] w-[18px]"
                        fill={item.filled ? 'currentColor' : 'none'}
                        stroke={item.filled ? 'none' : 'currentColor'}
                        strokeWidth="1.4"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        {item.icon}
                      </svg>
                    </a>
                  );
                })}
              </div>
              <p className="font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted">
                {profile.open_to}
              </p>
            </div>
          </div>

          <div className="lg:col-span-5">
            <div className="relative mx-auto max-w-[430px] lg:ml-auto lg:mr-0">
              <div className="rounded-[2rem] border border-ink/10 bg-monogram p-2 shadow-[0_30px_80px_-50px_rgba(20,17,13,0.65)]">
                <div className="relative overflow-hidden rounded-[calc(2rem-0.5rem)] bg-deep">
                  <img
                    src="/hasan.webp"
                    alt={`Portrait of ${profile.name}`}
                    width="800"
                    height="800"
                    fetchpriority="high"
                    className="aspect-[4/5] w-full object-cover object-[center_18%]"
                  />
                  <div
                    aria-hidden="true"
                    className="absolute inset-x-0 bottom-0 h-40 bg-gradient-to-t from-band/80 via-band/20 to-transparent"
                  />
                  <div className="absolute inset-x-4 bottom-4 flex items-center justify-between gap-3 rounded-full border border-band-fg/15 bg-band/60 px-4 py-2.5 backdrop-blur-md">
                    <span className="text-xs font-medium text-band-fg">{profile.name}</span>
                    <span className="font-mono text-[9px] uppercase tracking-[0.16em] text-band-fg/60">
                      {profile.location}
                    </span>
                  </div>
                </div>
              </div>

              {featured && <div className="absolute -top-4 left-3 hidden items-center gap-2.5 rounded-2xl border border-ink/10 bg-surface/95 p-3 pr-4 shadow-[0_18px_40px_-28px_rgba(20,17,13,0.55)] backdrop-blur-sm md:-left-6 md:flex">
                <AppIcon
                  app={featured}
                  className="h-9 w-9 overflow-hidden rounded-[10px] border border-ink/10 object-cover"
                  textClassName="text-[11px]"
                />
                <div>
                  <p className="text-xs font-medium text-text">{featured.name}</p>
                  {featured.rating ? (
                    <p className="mt-0.5 font-mono text-[9px] uppercase tracking-[0.1em] text-text-muted">
                      ★ {featured.rating.value.toFixed(1)} · {featured.rating.count.toLocaleString('en-US')} {featured.rating.noun || 'ratings'}
                    </p>
                  ) : (
                    <p className="mt-0.5 text-xs text-text-muted">{featured.tagline}</p>
                  )}
                </div>
              </div>}

              <div className="absolute -bottom-3 right-3 hidden rounded-full border border-ink/10 bg-surface px-3.5 py-2 font-mono text-[9px] uppercase tracking-[0.16em] text-text shadow-[0_12px_30px_-22px_rgba(20,17,13,0.6)] md:-right-4 md:block">
                Available now
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="border-y border-ink/10 bg-surface/40">
        <div className="mx-auto flex max-w-[1180px] flex-wrap items-baseline justify-between gap-2 px-5 pt-5">
          <Kicker>Products in production</Kicker>
          <span className="font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted">
            {platformLine(metrics)}
          </span>
        </div>
        <div className="marquee marquee-fade mt-4 overflow-hidden pb-5">
          <div className="marquee-track flex w-max items-center">
            {[false, true].map((clone) => (
              <div
                key={clone ? 'clone' : 'primary'}
                aria-hidden={clone ? 'true' : undefined}
                className="flex items-center gap-10 pr-10"
              >
                {marqueeApps.map((app) => {
                  const href = app.links.ios || app.links.android || app.links.web || app.links.github || app.links.website;
                  if (!href) return null;
                  return (
                    <a
                      key={`${clone ? 'clone-' : ''}${app.slug}`}
                      href={href}
                      target="_blank"
                      rel="noreferrer"
                      tabIndex={clone ? -1 : undefined}
                      onClick={() => trackOutbound(app.name, href)}
                      className="flex items-center gap-3 whitespace-nowrap opacity-70 transition duration-300 hover:opacity-100"
                    >
                      <AppIcon
                        app={app}
                        className="h-8 w-8 overflow-hidden rounded-[9px] border border-ink/10 object-cover"
                        textClassName="text-[10px]"
                      />
                      <span className="text-sm font-medium text-text">{app.name}</span>
                    </a>
                  );
                })}
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
