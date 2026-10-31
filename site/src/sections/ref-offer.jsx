import React from 'react';
import { Link } from '../lib/router';
import { services } from '../content/services';
import { useSiteMetrics } from '../lib/site-metrics';
import { Arrow, ArrowBadge, Check, Kicker, SectionHead } from './ref-ui';

const steps = [
  {
    index: '01',
    title: 'Scope in writing',
    copy: 'A short spec, milestones, and a price before work starts. No discovery theatre.',
  },
  {
    index: '02',
    title: 'Weekly demo',
    copy: 'Every week you see a running build and a written note of what changed.',
  },
  {
    index: '03',
    title: 'Ship to stores',
    copy: 'TestFlight and Play internal tracks from week one; release builds when you approve.',
  },
  {
    index: '04',
    title: 'Handover and support',
    copy: 'Code, docs, CI, and store access are yours. A support window is included.',
  },
];

const engagements = [
  {
    title: 'Project build',
    price: 'Fixed scope',
    copy: 'Milestones, weekly demos, one accountable engineer.',
    bestFor: 'Best for launching or rebuilding a Flutter app.',
  },
  {
    title: 'Embedded senior',
    price: 'Monthly',
    copy: 'Inside your team, inside your rituals, owning delivery.',
    bestFor: 'Best for teams that need mobile ownership now.',
  },
  {
    title: 'Advisory / audit',
    price: 'One-off',
    copy: 'A written review of architecture, releases, or an AI feature.',
    bestFor: 'Best for a second opinion before you commit.',
  },
];

const aiCards = [
  {
    area: 'Scaffolding',
    ai: 'AI drafts boilerplate, screens, and wiring.',
    owner: 'I own the architecture, boundaries, and naming.',
  },
  {
    area: 'Tests',
    ai: 'AI generates the first pass of test cases.',
    owner: 'I own coverage, flakiness, and what is allowed to ship.',
  },
  {
    area: 'Migrations',
    ai: 'AI maps dependency and API changes.',
    owner: 'I verify behavior and keep the rollback path intact.',
  },
  {
    area: 'Documentation',
    ai: 'AI writes the first draft of docs and release notes.',
    owner: 'I edit for accuracy and sign off on every claim.',
  },
];

export function Stats() {
  const metrics = useSiteMetrics();
  const stats = [
    metrics.yearsLabel && { value: metrics.yearsLabel, label: 'Years shipping' },
    metrics.appsCount > 0 && { value: String(metrics.appsCount), label: 'App profiles' },
    metrics.clientsCount > 0 && { value: String(metrics.clientsCount), label: 'Client engagements' },
    metrics.platforms.length > 0 && { value: String(metrics.platforms.length), label: 'Platforms shipped' },
  ].filter(Boolean);

  return (
    <section aria-label="Career at a glance" className="mx-auto max-w-[1180px] px-5">
      <div className="grid grid-cols-2 border-b border-ink/10 md:grid-cols-4">
        {stats.map((stat, index) => (
          <div
            key={stat.label}
            className={`flex flex-col gap-3 py-8 md:py-10 ${
              index % 2 === 1 ? 'border-l border-ink/10 pl-5 md:pl-8' : ''
            } ${index > 1 ? 'border-t border-ink/10 md:border-t-0' : ''} ${
              index > 0 ? 'md:border-l md:border-ink/10 md:pl-8' : ''
            }`}
          >
            <span className="font-serif text-[clamp(2.3rem,4.4vw,3.5rem)] leading-none tracking-[-0.01em] text-text">
              {stat.value}
            </span>
            <span className="font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
              {stat.label}
            </span>
          </div>
        ))}
      </div>
    </section>
  );
}

export function Services() {
  return (
    <section id="services" className="mx-auto max-w-[1180px] px-5 py-24 md:py-32">
      <SectionHead
        kicker="Services"
        title={
          <>
            From first build to <em className="italic text-accent">what comes next</em>
          </>
        }
        blurb="AI-assisted, senior-owned. Mobile apps, AI automation and full-stack products, with one engineer accountable for the work."
        action={<Link to="/services" className="group inline-flex items-center gap-2 text-sm font-medium text-text rule-link">All services <Arrow /></Link>}
      />

      <div className="mt-12 border-t border-ink/10">
        {services.filter((service) => service.featured).map((service) => (
          <Link
            key={service.slug}
            to={`/services/${service.slug}`}
            className="group grid gap-5 border-b border-ink/10 px-3 py-7 transition-[background-color,color,border-radius] duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:rounded-[1.4rem] hover:bg-ink hover:text-canvas md:grid-cols-[52px_1.05fr_0.95fr_auto] md:items-start md:gap-8 md:px-5 md:py-9"
          >
            <span className="font-mono text-[10px] tracking-[0.12em] text-text-muted transition-colors duration-500 group-hover:text-canvas/45">
              {service.index}
            </span>

            <div>
              <h3 className="font-serif text-[2rem] leading-[1.02] tracking-[-0.01em] text-text transition-colors duration-500 group-hover:text-canvas md:text-[2.5rem]">
                {service.title}
              </h3>
              <p className="mt-3 max-w-[40ch] text-sm leading-[1.7] text-text-muted transition-colors duration-500 group-hover:text-canvas/60">
                {service.copy}
              </p>
            </div>

            <ul className="flex flex-col gap-2">
              {service.points.map((point) => (
                <li
                  key={point}
                  className="flex gap-2.5 text-[13px] leading-snug text-text/80 transition-colors duration-500 group-hover:text-canvas/75"
                >
                  <Check />
                  {point}
                </li>
              ))}
            </ul>

            <div className="flex items-center justify-between gap-4 md:flex-col md:items-end md:gap-6">
              <span className="font-mono text-[9px] uppercase tracking-[0.16em] text-text-muted transition-colors duration-500 group-hover:text-canvas/50">
                {service.tag}
              </span>
              <span className="flex h-10 w-10 items-center justify-center rounded-full border border-ink/15 text-text transition-colors duration-500 group-hover:border-canvas/25 group-hover:bg-canvas group-hover:text-ink">
                <Arrow />
              </span>
            </div>
          </Link>
        ))}
      </div>
      <div className="mt-6 flex flex-wrap gap-x-6 gap-y-3">
        {services.filter((service) => !service.featured).map((service) => (
          <Link key={service.slug} to={`/services/${service.slug}`} className="inline-flex min-h-11 items-center gap-2 text-sm text-text underline decoration-ink/25 underline-offset-4 hover:text-accent">
            {service.title} <Arrow />
          </Link>
        ))}
      </div>

      <div className="mt-6 flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm text-text-muted">
          Project builds, embedded senior ownership, or a focused audit. Send the brief.
        </p>
        <a
          href="#contact"
          className="group inline-flex items-center gap-2 text-sm font-medium text-text rule-link"
        >
          Start a conversation
          <Arrow />
        </a>
      </div>
    </section>
  );
}

export function Process() {
  return (
    <section id="process" className="border-y border-ink/10 bg-surface">
      <div className="mx-auto max-w-[1180px] px-5 py-24 md:py-32">
        <SectionHead
          kicker="Process"
          title={
            <>
              Boring process.{' '}
              <em className="italic text-hl-a">Believable</em> deadlines.
            </>
          }
          blurb="Weekly demos, written scope, no surprises. The process is deliberately dull so the delivery is not."
        />

        <ol className="mt-14 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {steps.map((step) => (
            <li key={step.index} className="border-t border-ink/15 pt-5">
              <span className="font-serif text-4xl leading-none text-accent">{step.index}</span>
              <h3 className="mt-5 text-base font-semibold tracking-[-0.01em] text-text">{step.title}</h3>
              <p className="mt-2 text-sm leading-[1.65] text-text-muted">{step.copy}</p>
            </li>
          ))}
        </ol>

        <div className="mt-14 grid gap-4 md:grid-cols-3">
          {engagements.map((model) => (
            <div
              key={model.title}
              className="group flex flex-col rounded-[1.4rem] border border-ink/10 bg-canvas p-6 transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:-translate-y-1 hover:border-ink/25"
            >
              <div className="flex items-baseline justify-between gap-3">
                <h3 className="font-serif text-xl leading-none text-text">{model.title}</h3>
                <span className="font-mono text-[9px] uppercase tracking-[0.14em] text-accent">
                  {model.price}
                </span>
              </div>
              <p className="mt-3 flex-1 text-sm leading-[1.65] text-text-muted">{model.copy}</p>
              <p className="mt-4 border-t border-ink/10 pt-3 text-xs leading-relaxed text-text-muted">
                {model.bestFor}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export function AiWorkflow() {
  return (
    <section id="ai-workflow" className="mx-auto max-w-[1180px] px-5 py-24 md:py-32">
      <SectionHead
        kicker="AI workflow"
        title={
          <>
            AI-assisted, <em className="italic text-accent">senior-owned</em>
          </>
        }
        blurb="I use AI to compress the work that should be boring. Accountability stays with me."
      />

      <div className="mt-12 grid gap-px overflow-hidden rounded-[1.4rem] border border-ink/10 bg-ink/10 sm:grid-cols-2 lg:grid-cols-4">
        {aiCards.map((card) => (
          <article key={card.area} className="flex flex-col bg-surface p-6">
            <Kicker>{card.area}</Kicker>
            <p className="mt-5 text-sm leading-[1.65] text-text-muted">
              <span className="mb-1 block font-mono text-[9px] uppercase tracking-[0.18em] text-text-muted">
                AI drafts
              </span>
              {card.ai}
            </p>
            <div className="mt-auto border-t border-ink/10 pt-4">
              <span className="mb-1 block font-mono text-[9px] uppercase tracking-[0.18em] text-accent">
                I own
              </span>
              <p className="text-sm leading-[1.65] text-text/85">{card.owner}</p>
            </div>
          </article>
        ))}
      </div>

      <div className="mt-5 grid gap-3 sm:grid-cols-3">
        {[
          ['AI engagement scope', '/services/ai-integration-automation', 'Work I take on: RAG, assistants, agents and automation.'],
          ['RAG design write-up', '/blog/rag-that-survives-real-users', 'How retrieval, permissions and failure modes are handled.'],
          ['MCP server source', 'https://github.com/hasanabbassorathiya/wp-mcp-server', 'TypeScript integration exposing content operations through MCP.'],
        ].map(([label, href, copy]) => {
          const external = href.startsWith('http');
          const Tag = external ? 'a' : Link;
          return (
            <Tag
              key={label}
              {...(external ? { href, target: '_blank', rel: 'noreferrer' } : { to: href })}
              className="group rounded-[1.2rem] border border-ink/10 bg-surface p-5 transition duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] hover:-translate-y-0.5 hover:border-ink/25"
            >
              <span className="font-mono text-[9px] uppercase tracking-[0.18em] text-accent">{label}</span>
              <span className="mt-2 block text-sm leading-[1.6] text-text-muted">{copy}</span>
            </Tag>
          );
        })}
      </div>

      <div className="mt-5 flex flex-col gap-3 rounded-[1.4rem] border border-accent/25 bg-accent/[0.04] p-6 sm:flex-row sm:items-center sm:justify-between">
        <p className="max-w-[72ch] text-sm leading-[1.7] text-text/80">
          AI compresses the boring parts. It does not make product, security, or release decisions.
          Every line that ships has a human owner.
        </p>
        <span className="shrink-0 font-mono text-[9px] uppercase tracking-[0.18em] text-accent">
          Senior-owned
        </span>
      </div>
    </section>
  );
}
