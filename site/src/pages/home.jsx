import React, { useEffect } from 'react';
import { trackSection } from '../lib/analytics';
import { Hero } from '../sections/ref-hero';
import { Stats, Services, Process, AiWorkflow } from '../sections/ref-offer';
import { Work, Receipts } from '../sections/ref-work';
import { About, WritingSection, Contact } from '../sections/ref-about';
import { useSeo, personJsonLd, SITE_URL } from '../lib/seo';

export function HomePage() {
  useSeo({
    path: '/',
    jsonLd: [
      personJsonLd,
      {
        '@context': 'https://schema.org',
        '@type': 'WebSite',
        name: 'Hasan Abbas Sorathiya',
        url: SITE_URL,
      },
    ],
  });

  useEffect(() => {
    const seen = new Set();
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          const id = entry.target.id;
          if (!entry.isIntersecting || seen.has(id)) return;
          seen.add(id);
          trackSection(id);
        });
      },
      { rootMargin: '-45% 0px -45% 0px', threshold: 0 }
    );
    document.querySelectorAll('main section[id]').forEach((section) => io.observe(section));
    return () => io.disconnect();
  }, []);

  return (
    <main>
      <Hero />
      <Stats />
      <Services />
      <Work />
      <Process />
      <AiWorkflow />
      <Receipts />
      <About />
      <WritingSection />
      <Contact />
    </main>
  );
}
