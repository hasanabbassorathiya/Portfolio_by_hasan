import React from 'react';
import { useReveal } from '../lib/motion';

const values = [
  ['01', 'Production over demos', 'Seven years of shipped apps: fintech, e-commerce, mobility, streaming, and religious content used daily.'],
  ['02', 'Depth over breadth', 'From prayer-time astronomy to Clean Architecture — I go deep on the systems people depend on.'],
  ['03', 'Community first', 'Gujarati-first UI, offline access, and content reviewed by the people it serves.'],
];

export function StoryFilm() {
  const heading = useReveal(0);
  const body = useReveal(140);
  const quote = useReveal(80);

  return (
    <section id="about" className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3.5rem,8vw,7rem)]">
      <div className="grid items-start gap-12 lg:grid-cols-2 lg:gap-16">
        <div className="flex flex-col gap-6">
          <p className="font-mono text-xs uppercase tracking-[0.25em] text-accent">The short version</p>
          <h2
            ref={heading.ref}
            style={heading.style}
            className="font-display text-[clamp(1.9rem,4.2vw,3.1rem)] font-semibold leading-[1.12] tracking-[-0.025em]"
          >
            Engineering with <em className="font-serif font-normal italic text-accent">intent</em>
          </h2>
          <div ref={body.ref} style={body.style} className="flex max-w-[54ch] flex-col gap-4 leading-[1.8] text-text-muted">
            <p>
              I am a Dubai-based Senior Software &amp; AI Engineer with 7+ years of experience
              building mobile and full-stack products. I have led mobile engineering at Chalhoub
              Group, shipped digital lending apps serving 50,000+ users in New Zealand, and built
              AI systems that reach production rather than staying in notebooks.
            </p>
            <p>
              My work spans two worlds that rarely meet: the discipline of mobile architecture —
              Clean Architecture, Riverpod, release engineering, crash-free sessions — and the
              fast, messy reality of LLM applications, RAG pipelines, and agents. I care about
              both the seam where they meet and the people on the other side of the screen.
            </p>
            <p>
              Outside client work I maintain open-source Flutter projects, write about the problems
              I actually hit, and build toward Google Developer Expert recognition in Flutter.
            </p>
          </div>
        </div>
        <div className="flex flex-col gap-8">
          <blockquote
            ref={quote.ref}
            style={quote.style}
            className="border-l-2 border-accent pl-6 font-serif text-[clamp(1.25rem,2.5vw,1.7rem)] italic leading-[1.5] text-text"
          >
            &ldquo;Engineering excellence is not just about code; it is about the impact it creates.&rdquo;
          </blockquote>
          <ul className="flex flex-col divide-y divide-[var(--border)] border-t border-[var(--border)]">
            {values.map(([number, title, description]) => (
              <li key={number} className="flex flex-col gap-1 py-5">
                <p className="font-mono text-xs text-accent">{number}</p>
                <h3 className="font-display text-lg font-semibold text-text">{title}</h3>
                <p className="text-sm leading-[1.65] text-text-muted">{description}</p>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}
