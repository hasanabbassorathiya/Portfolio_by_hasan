import React, { Suspense, lazy, useEffect, useRef, useState } from 'react';
import { Link } from '../lib/router';
import { useReveal } from '../lib/motion';
import { Subscribe } from '../components/subscribe';

const WritingList = lazy(() =>
  import('./writing-list').then((m) => ({ default: m.WritingList }))
);

export function Writing() {
  const header = useReveal(0);
  const list = useReveal(120);
  const anchor = useRef(null);
  const [showList, setShowList] = useState(false);

  useEffect(() => {
    const el = anchor.current;
    if (!el || typeof IntersectionObserver === 'undefined') {
      setShowList(true);
      return;
    }
    const io = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting) {
          setShowList(true);
          io.disconnect();
        }
      },
      { rootMargin: '600px 0px' }
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);

  return (
    <section id="writing" className="border-y border-[var(--border)] bg-deep">
      <div className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(4rem,9vw,7rem)]">
        <div ref={header.ref} style={header.style} className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="mb-3 font-mono text-xs uppercase tracking-[0.25em] text-accent">Writing</p>
            <h2 className="max-w-[20ch] font-display text-[clamp(1.9rem,4.4vw,3.2rem)] leading-[1.1] tracking-[-0.025em]">
              Field notes on <em className="font-serif font-normal italic text-accent">shipping software</em>
            </h2>
          </div>
          <Link
            to="/blog"
            className="w-fit rounded-lg border border-[var(--border)] px-5 py-3 font-mono text-xs text-text-muted transition-colors hover:border-accent/50 hover:text-text"
          >
            All essays →
          </Link>
        </div>

        <div ref={list.ref} style={list.style} className="mt-10 flex flex-col">
          <div ref={anchor} className={showList ? '' : 'min-h-[30rem]'}>
            {showList && (
              <Suspense fallback={null}>
                <WritingList />
              </Suspense>
            )}
          </div>
        </div>

        <p className="mt-6 font-mono text-[11px] uppercase tracking-[0.16em] text-text-muted">
          New essays every two weeks · <a href="/rss.xml" className="text-accent underline decoration-accent/40 underline-offset-4 hover:decoration-accent">RSS</a>
        </p>

        <div className="mt-8">
          <Subscribe source="home-writing" />
        </div>
      </div>
    </section>
  );
}
