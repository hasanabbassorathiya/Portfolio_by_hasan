import React from 'react';
import { services } from '../content/services';
import { Link } from '../lib/router';
import { personJsonLd, SITE_NAME, useSeo } from '../lib/seo';
import { Arrow, ArrowBadge, Check, Kicker } from '../sections/ref-ui';

export function ServiceEnquiry({
  prompt = 'Tell me what you are building, what already exists and where you need help. Include the constraints that matter; the first step is to agree whether the work is a fit.',
  subject = 'Service enquiry',
}) {
  return (
    <section aria-labelledby="service-enquiry-title" className="border-t border-ink/10 bg-surface">
      <div className="mx-auto grid max-w-[1180px] gap-8 px-5 py-16 md:py-24 lg:grid-cols-[1fr_1fr] lg:gap-16">
        <div>
          <Kicker>Start with the brief</Kicker>
          <h2 id="service-enquiry-title" className="mt-5 max-w-[18ch] font-serif text-[clamp(2.2rem,4.5vw,3.8rem)] leading-[1.05] tracking-[-0.015em] text-text">
            Tell me what needs <em className="italic text-hl-a">building.</em>
          </h2>
        </div>
        <div className="min-w-0 lg:pt-8">
          <p className="max-w-[60ch] text-[15px] leading-[1.8] text-text-muted">{prompt}</p>
          <div className="mt-6 flex flex-wrap items-center gap-x-6 gap-y-3">
            <Link to="/#contact" className="group inline-flex min-h-11 items-center rounded-full bg-accent-solid py-2.5 pl-5 pr-2.5 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90">
              Discuss your project
              <ArrowBadge tone="dark" />
            </Link>
            <a href={`${personJsonLd.email}?subject=${encodeURIComponent(subject)}`} className="group inline-flex min-h-11 items-center gap-2 text-sm text-text underline decoration-ink/25 underline-offset-4 hover:decoration-current">
              Email Hasan directly <Arrow />
            </a>
          </div>
          <p className="mt-5 text-xs leading-relaxed text-text-muted">
            Scope, deliverables and commercial terms are agreed before work begins. No fixed timeline or outcome is implied by these service descriptions.
          </p>
        </div>
      </div>
    </section>
  );
}

export function ServicesPage() {
  useSeo({
    title: `Services · Flutter, AI & Full-Stack Development · ${SITE_NAME}`,
    description: 'Explore Flutter app development, AI and n8n automation, full-stack APIs, app audits, WordPress integrations and engineering-led UI/UX with Hasan Abbas Sorathiya.',
    path: '/services',
  });

  return (
    <main className="pt-28 md:pt-32">
      <header className="mx-auto max-w-[1180px] px-5 pb-14 pt-8 md:pb-20 md:pt-12">
        <Kicker>Services · Independent engineering</Kicker>
        <div className="mt-6 grid gap-7 lg:grid-cols-[1.15fr_0.85fr] lg:items-end lg:gap-16">
          <h1 className="max-w-[17ch] font-serif text-[clamp(3rem,7vw,5.8rem)] font-normal leading-[0.98] tracking-[-0.025em] text-text">
            A clear scope.<br />
            Something <em className="italic text-accent">worth building.</em>
          </h1>
          <div>
            <p className="max-w-[54ch] text-[16px] leading-[1.8] text-text-muted">
              Mobile apps for iOS and Android — native and Flutter — plus AI integrations, full-stack products and the work between them. Start a project from scratch, strengthen an existing product, or get a specialist second opinion.
            </p>
            <p className="mt-4 max-w-[54ch] text-sm leading-[1.75] text-text-muted">
              These are starting points for a conversation, not fixed packages. Each service sets out the possible deliverables, the boundaries and the work you can inspect.
            </p>
          </div>
        </div>
      </header>

      <section aria-label="Explore services" className="mx-auto max-w-[1180px] px-5 pb-16 md:pb-24">
        <div className="border-t border-ink/15">
          {services.map((service) => (
            <Link
              key={service.slug}
              to={`/services/${service.slug}`}
              className="group grid gap-5 border-b border-ink/10 px-3 py-8 transition-colors duration-300 hover:bg-ink hover:text-canvas focus-visible:bg-ink focus-visible:text-canvas md:grid-cols-[40px_minmax(0,1.15fr)_minmax(0,0.85fr)_44px] md:gap-7 md:px-5 md:py-10"
            >
              <span className="font-mono text-[11px] tracking-[0.12em] text-text-muted group-hover:text-canvas/65 group-focus-visible:text-canvas/65">{service.index}</span>
              <div className="min-w-0">
                <p className="font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted group-hover:text-canvas/65 group-focus-visible:text-canvas/65">{service.tag}</p>
                <h2 className="mt-3 font-serif text-[clamp(1.9rem,3.5vw,2.65rem)] leading-[1.08] tracking-[-0.01em] text-text group-hover:text-canvas group-focus-visible:text-canvas">{service.title}</h2>
                <p className="mt-4 max-w-[48ch] text-sm leading-[1.75] text-text-muted group-hover:text-canvas/75 group-focus-visible:text-canvas/75">{service.copy}</p>
              </div>
              <ul className="flex flex-col gap-3 md:pt-8">
                {service.points.map((point) => (
                  <li key={point} className="flex gap-2.5 text-[13px] leading-[1.6] text-text/80 group-hover:text-canvas/80 group-focus-visible:text-canvas/80">
                    <span className="text-current [&_svg]:text-current"><Check /></span>
                    {point}
                  </li>
                ))}
              </ul>
              <span aria-hidden="true" className="flex h-11 w-11 items-center justify-center rounded-full border border-ink/15 group-hover:border-canvas/30 group-focus-visible:border-canvas/30 md:mt-8">
                <Arrow />
              </span>
            </Link>
          ))}
        </div>
        <p className="mt-6 max-w-[78ch] text-sm leading-[1.75] text-text-muted">
          Not sure where your project fits? A product can need more than one of these. The brief comes first; the service boundary follows the problem, not the other way around.
        </p>
      </section>
      <ServiceEnquiry />
    </main>
  );
}
