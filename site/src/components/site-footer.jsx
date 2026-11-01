import React from 'react';
import { Link } from '../lib/router';
import { trackCta, trackOutbound } from '../lib/analytics';
import { useProfile, useSocialPosts } from '../lib/live-content';

export function SiteFooter() {
  const profile = useProfile();
  const activity = useSocialPosts();
  const profiles = [
    ['LinkedIn', profile.linkedin],
    ['GitHub', profile.github],
  ].filter(([, href]) => href);

  const elsewhere = [
    ['Résumé', '/resume'],
    ['YouTube', profile.youtube],
    ['Instagram', profile.instagram],
    ['Medium', profile.medium],
    ['Udemy certificate', profile.certificate],
    ['Buy me a coffee', 'https://buymeacoffee.com/hasanabbassorathiya'],
  ].filter(([, href]) => href);

  const stack = [
    ['React', 'https://react.dev'],
    ['Vite', 'https://vite.dev'],
    ['Tailwind CSS', 'https://tailwindcss.com'],
    ['PHP', 'https://www.php.net'],
    ['MySQL', 'https://www.mysql.com'],
    ['Directus', 'https://directus.io'],
  ];

  return (
    <footer className="border-t border-band-fg/15 bg-band text-band-fg print:hidden">
      <div className="mx-auto max-w-[1180px] px-5 pb-7 pt-12">
        <div className="flex flex-col justify-between gap-8 pb-9 md:flex-row md:items-center">
          <div className="max-w-[52ch]">
            <Link to="/" className="font-serif text-2xl leading-tight">Hasan Abbas Sorathiya</Link>
            <p className="mt-3 text-sm leading-relaxed text-band-fg/80">
              Dubai-based mobile, full-stack &amp; AI engineer, taking products from first build to production ownership.
            </p>
          </div>
          <div className="flex shrink-0 flex-wrap items-center gap-5">
            <a
              href={`mailto:${profile.email}`}
              onClick={() => trackCta('email', 'footer')}
              className="inline-flex min-h-12 items-center rounded-full bg-accent-solid px-6 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90"
            >
              Email Hasan <span aria-hidden="true" className="ml-3">↗</span>
            </a>
            {profiles.map(([label, href]) => (
              <a key={label} href={href} target="_blank" rel="noreferrer" onClick={() => trackOutbound(label, href)} className="inline-flex min-h-11 items-center text-sm text-band-fg/85 underline decoration-band-fg/25 underline-offset-4 hover:text-band-fg">
                {label}
              </a>
            ))}
          </div>
        </div>
        <div className="flex flex-col justify-between gap-5 border-t border-band-fg/15 pt-5 text-xs text-band-fg/70 md:flex-row md:items-center">
          <span>© {new Date().getFullYear()} Hasan Abbas Sorathiya · Dubai, UAE</span>
          <div className="flex flex-wrap items-center gap-x-5 gap-y-1">
            <span className="font-mono text-[10px] uppercase tracking-[0.12em]">Site</span>
            <Link to="/resources" className="inline-flex min-h-11 items-center hover:text-band-fg">Resources</Link>
            <Link to="/community" className="inline-flex min-h-11 items-center hover:text-band-fg">Community</Link>
            {activity.length > 0 && (
              <Link to="/activity" className="inline-flex min-h-11 items-center hover:text-band-fg">Activity</Link>
            )}
            <Link to="/privacy" className="inline-flex min-h-11 items-center hover:text-band-fg">Privacy</Link>
            <span className="font-mono text-[10px] uppercase tracking-[0.12em]">Elsewhere</span>
            {elsewhere.map(([label, href]) => {
              const external = href.startsWith('http');
              return (
                <a
                  key={label}
                  href={href}
                  target={external ? '_blank' : undefined}
                  rel={external ? 'noreferrer' : undefined}
                  onClick={external ? () => trackOutbound(label, href) : undefined}
                  className="inline-flex min-h-11 items-center hover:text-band-fg"
                >
                  {label}
                </a>
              );
            })}
          </div>
        </div>
        <div className="mt-4 flex flex-wrap items-center gap-x-5 gap-y-1 text-xs text-band-fg/70">
          <span className="font-mono text-[10px] uppercase tracking-[0.12em]">Built with</span>
          {stack.map(([label, href]) => (
            <a
              key={label}
              href={href}
              target="_blank"
              rel="noreferrer"
              onClick={() => trackOutbound(label, href)}
              className="inline-flex min-h-11 items-center hover:text-band-fg"
            >
              {label}
            </a>
          ))}
        </div>
      </div>
    </footer>
  );
}
