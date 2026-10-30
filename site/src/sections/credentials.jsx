import React from 'react';
import { Link } from '../lib/router';
import { useReveal } from '../lib/motion';

const certifications = [
  'Google Flutter Developer Certification',
  'AI & NLP Fundamentals Certification',
  'Advanced Android Development Certification',
  'Project Management Foundations (PMP)',
  'Digital Marketing Strategy Certification',
];

export function Credentials() {
  const { ref, style } = useReveal(0);
  return (
    <section ref={ref} style={style} className="border-t border-[var(--border)] bg-deep">
      <div className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] py-[clamp(4rem,8vw,7rem)]">
        <p className="mb-3 font-mono text-xs uppercase tracking-[0.25em] text-accent">Credentials</p>
        <h2 className="mb-10 font-display text-[clamp(1.8rem,4vw,3rem)] tracking-[-0.02em]">
          Trained, certified, <em className="font-serif font-normal italic text-accent">still learning</em>
        </h2>

        <div className="grid gap-10 lg:grid-cols-2 lg:gap-16">
          <div className="flex flex-col gap-4">
            <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-text-muted">Education</p>
            <div className="rounded-2xl border border-[var(--border)] bg-surface p-6">
              <h3 className="font-display text-xl">BSc Information Technology</h3>
              <p className="mt-1 text-sm text-text-muted">University of Mumbai · 2019</p>
              <p className="mt-4 text-sm leading-[1.7] text-text-muted">
                Final project: an AI-powered customer support chatbot built with Python,
                TensorFlow, and NLP pipelines — the start of the AI work I do today.
              </p>
            </div>
            <div className="rounded-2xl border border-accent/25 bg-surface p-6">
              <p className="font-mono text-[10px] uppercase tracking-[0.18em] text-accent">In progress</p>
              <h3 className="mt-2 font-display text-xl">Working toward Flutter GDE</h3>
              <p className="mt-2 text-sm leading-[1.7] text-text-muted">
                Publishing consistently, speaking at meetups, and maintaining open source on the
                path to Google Developer Expert recognition.
              </p>
              <Link to="/blog/from-shipping-apps-to-gde" className="mt-4 inline-block font-mono text-xs text-accent hover:underline">
                Read the plan →
              </Link>
            </div>
          </div>

          <div className="flex flex-col gap-4">
            <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-text-muted">Certifications</p>
            <ul className="flex flex-col divide-y divide-[var(--border)] border-y border-[var(--border)]">
              {certifications.map((certification, index) => (
                <li key={certification} className="flex items-baseline gap-4 py-4">
                  <span className="font-mono text-[10px] text-accent">0{index + 1}</span>
                  <span className="leading-[1.6] text-text">{certification}</span>
                </li>
              ))}
            </ul>
            <p className="font-mono text-[10px] uppercase leading-relaxed tracking-[0.14em] text-text-muted">
              Domain depth: Jafari prayer-time calculation · moon-sighting adjustment ·
              Jafari toolkit implementation
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
