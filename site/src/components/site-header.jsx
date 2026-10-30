import React, { useEffect, useRef, useState } from 'react';
import { Link, useRoute } from '../lib/router';
import { stopScroll, startScroll } from '../lib/lenis';
import { trackCta } from '../lib/analytics';
import { ArrowBadge } from '../sections/ref-ui';
import { ThemeToggle } from './theme-toggle';

const links = [
  { label: 'Work', to: '/work' },
  { label: 'Services', to: '/services' },
  { label: 'Resources', to: '/resources' },
  { label: 'Community', to: '/community' },
  { label: 'Writing', to: '/#writing' },
  { label: 'About', to: '/#about' },
];

export function SiteHeader() {
  const route = useRoute();
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const toggleRef = useRef(null);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 12);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  useEffect(() => {
    setOpen(false);
  }, [route.path]);

  useEffect(() => {
    if (!open) return;
    const onKey = (e) => {
      if (e.key === 'Escape') {
        setOpen(false);
        toggleRef.current?.focus();
      }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open]);

  useEffect(() => {
    if (open) stopScroll();
    else startScroll();
    if (open) document.body.style.overflow = 'hidden';
    else document.body.style.overflow = '';
    return () => {
      startScroll();
      document.body.style.overflow = '';
    };
  }, [open]);

  return (
    <>
      <header className="fixed inset-x-0 top-3 z-40 px-4 md:top-4 print:hidden">
        <div
          className={`mx-auto flex h-14 max-w-[1180px] items-center justify-between rounded-full border border-ink/10 pl-3 pr-2 backdrop-blur-xl transition-all duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] md:h-[60px] md:pl-4 ${
            scrolled
              ? 'bg-surface/90 shadow-[0_18px_50px_-32px_rgba(20,17,13,0.55)]'
              : 'bg-canvas/70 shadow-[0_10px_40px_-36px_rgba(20,17,13,0.4)]'
          }`}
        >
          <Link to="/" className="flex items-center gap-2.5" aria-label="HS Hasan Abbas Sorathiya — home">
            <span className="flex h-8 w-8 items-center justify-center rounded-[10px] bg-ink font-mono text-[10px] tracking-[0.08em] text-canvas">
              HS{' '}
            </span>
            <span className="hidden text-[14px] font-medium tracking-[-0.01em] text-text sm:inline">
              Hasan Abbas Sorathiya
            </span>
            <span className="hidden text-[14px] font-medium text-text min-[400px]:inline sm:hidden">Hasan</span>
          </Link>

          <nav className="hidden items-center gap-1 lg:flex" aria-label="Primary">
            {links.map((link) => {
              const active = link.to.startsWith('/#')
                ? route.path === '/' && route.hash === link.to.slice(1)
                : route.path === link.to;
              return (
                <Link
                  key={link.label}
                  to={link.to}
                  aria-current={active ? 'page' : undefined}
                  className={`rounded-full px-3 py-2 text-[13px] transition-colors duration-300 ${
                    active ? 'bg-deep/70 text-text' : 'text-text-muted hover:text-text'
                  }`}
                >
                  {link.label}
                </Link>
              );
            })}
            <ThemeToggle className="ml-2" />
            <Link
              to="/#contact"
              onClick={() => trackCta('contact', 'header')}
              className="group ml-1 inline-flex items-center rounded-full bg-accent-solid py-1.5 pl-4 pr-1.5 text-[13px] font-medium text-on-accent transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:bg-accent-solid/90 active:scale-[0.98]"
            >
              Start a project
              <ArrowBadge tone="dark" />
            </Link>
          </nav>

          <div className="flex items-center gap-1.5 lg:hidden">
            <Link
              to="/#contact"
              onClick={() => {
                setOpen(false);
                trackCta('contact', 'header-mobile');
              }}
              className="inline-flex min-h-11 items-center whitespace-nowrap rounded-full bg-accent-solid px-3 text-xs font-medium text-on-accent transition-colors hover:bg-accent-solid/90"
            >
              Start a project
            </Link>
            <ThemeToggle />
            <button
              ref={toggleRef}
              type="button"
              className="flex h-10 w-10 items-center justify-center rounded-full border border-ink/15 text-text transition-colors duration-300 hover:border-ink/30"
              aria-expanded={open}
              aria-label={open ? 'Close menu' : 'Open menu'}
              onClick={() => setOpen((v) => !v)}
            >
              <span className="relative block h-3 w-5">
                <span
                  className={`absolute left-0 h-px w-full bg-current transition-transform duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] ${
                    open ? 'top-1.5 rotate-45' : 'top-0'
                  }`}
                />
                <span
                  className={`absolute left-0 top-1.5 h-px w-full bg-current transition-opacity duration-300 ${
                    open ? 'opacity-0' : 'opacity-100'
                  }`}
                />
                <span
                  className={`absolute left-0 h-px w-full bg-current transition-transform duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] ${
                    open ? 'top-1.5 -rotate-45' : 'top-3'
                  }`}
                />
              </span>
            </button>
          </div>
        </div>
      </header>

      {open && (
        <div className="fixed inset-0 z-30 overflow-y-auto bg-canvas pt-24 print:hidden lg:hidden">
          <nav className="mx-auto flex max-w-[1180px] flex-col px-5 pb-10" aria-label="Mobile">
            {links.map((link, index) => (
              <Link
                key={link.label}
                to={link.to}
                onClick={() => setOpen(false)}
                className="rise flex items-center justify-between border-b border-ink/10 py-4 font-serif text-[clamp(2rem,8vw,2.75rem)] leading-none text-text"
                style={{ animationDelay: `${80 + index * 55}ms` }}
              >
                {link.label}
                <span className="font-mono text-[10px] text-text-muted">0{index + 1}</span>
              </Link>
            ))}
            <Link
              to="/#contact"
              onClick={() => {
                setOpen(false);
                trackCta('contact', 'header-mobile');
              }}
              className="group mt-7 inline-flex items-center justify-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent"
            >
              Start a project
              <ArrowBadge tone="dark" />
            </Link>
            <div className="mt-8 flex flex-col gap-2 font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted">
              <span>Dubai, UAE · Available now</span>
              <a href="mailto:hasanabbassorathiya12@gmail.com" className="text-text normal-case tracking-normal">
                hasanabbassorathiya12@gmail.com
              </a>
            </div>
          </nav>
        </div>
      )}
    </>
  );
}
