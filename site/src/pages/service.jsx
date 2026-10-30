import React from 'react';
import { serviceBySlug, services } from '../content/services';
import { Link } from '../lib/router';
import { personJsonLd, SITE_URL, useSeo } from '../lib/seo';
import { Arrow, Check, Kicker, SectionHead } from '../sections/ref-ui';
import { NotFoundPage } from './not-found';
import { ServiceEnquiry } from './services';

function EvidenceLink({ evidence }) {
  const className = 'group flex min-h-11 items-center justify-between gap-4 py-2 font-serif text-[1.6rem] leading-[1.2] text-band-fg underline decoration-band-fg/25 underline-offset-4 hover:decoration-band-fg';
  const content = <><span>{evidence.label}</span><Arrow className="shrink-0" /></>;
  return evidence.to
    ? <Link to={evidence.to} className={className}>{content}</Link>
    : <a href={evidence.href} className={className} target="_blank" rel="noopener noreferrer">{content}</a>;
}

function ServiceDetail({ service }) {
  const path = `/services/${service.slug}`;
  useSeo({
    title: service.seoTitle,
    description: service.seoDescription,
    path,
    jsonLd: {
      '@context': 'https://schema.org',
      '@type': 'Service',
      '@id': `${SITE_URL}${path}#service`,
      name: service.title,
      serviceType: service.title,
      description: service.seoDescription,
      url: `${SITE_URL}${path}`,
      provider: { '@id': personJsonLd['@id'] },
    },
  });

  return (
    <main className="pt-28 md:pt-32">
      <header className="mx-auto max-w-[1180px] px-5 pb-14 pt-4 md:pb-20 md:pt-8">
        <nav aria-label="Breadcrumb" className="flex flex-wrap items-center gap-x-3 font-mono text-[10px] uppercase tracking-[0.14em] text-text-muted">
          <Link to="/services" className="inline-flex min-h-11 items-center underline decoration-ink/20 underline-offset-4 hover:text-text">Services</Link>
          <span aria-hidden="true">/</span>
          <span aria-current="page" className="py-2 leading-relaxed">{service.title}</span>
        </nav>
        <Kicker className="mt-8">{service.index} · {service.tag}</Kicker>
        <h1 className="mt-5 max-w-[19ch] break-words font-serif text-[clamp(2.65rem,6.8vw,5.6rem)] font-normal leading-[1.01] tracking-[-0.025em] text-text">{service.title}</h1>
        <p className="mt-6 max-w-[62ch] text-[17px] leading-[1.8] text-text-muted">{service.copy}</p>
        <ul className="mt-8 flex flex-wrap gap-x-7 gap-y-3 border-t border-ink/10 pt-6">
          {service.points.map((point) => (
            <li key={point} className="flex gap-2.5 text-sm leading-[1.6] text-text/80"><Check />{point}</li>
          ))}
        </ul>
      </header>

      <section aria-labelledby="service-scope-title" className="border-y border-ink/10 bg-surface">
        <div className="mx-auto grid max-w-[1180px] gap-12 px-5 py-16 md:py-20 lg:grid-cols-2 lg:gap-20">
          <div>
            <Kicker>The scope</Kicker>
            <h2 id="service-scope-title" className="mt-5 font-serif text-[clamp(2rem,3.8vw,3rem)] leading-[1.08] text-text">What we can work on.</h2>
            <div className="mt-6 flex max-w-[60ch] flex-col gap-5 text-[15px] leading-[1.85] text-text-muted">
              {service.overview.map((paragraph) => <p key={paragraph}>{paragraph}</p>)}
            </div>
          </div>
          <div className="grid content-start gap-8">
            <div>
              <h3 className="font-mono text-[11px] uppercase tracking-[0.16em] text-text">A good fit for</h3>
              <ul className="mt-4 flex flex-col gap-4">
                {service.audience.for.map((item) => <li key={item} className="flex gap-3 text-sm leading-[1.75] text-text-muted"><Check /><span>{item}</span></li>)}
              </ul>
            </div>
            <div className="border-t border-ink/10 pt-6">
              <h3 className="font-mono text-[11px] uppercase tracking-[0.16em] text-text">Not a fit for</h3>
              <ul className="mt-4 flex list-disc flex-col gap-4 pl-4 text-sm leading-[1.75] text-text-muted marker:text-text-muted">
                {service.audience.notFor.map((item) => <li key={item}>{item}</li>)}
              </ul>
            </div>
          </div>
        </div>
      </section>

      <section aria-labelledby="service-deliverables-title" className="mx-auto grid max-w-[1180px] gap-10 px-5 py-16 md:py-24 lg:grid-cols-[0.8fr_1.2fr] lg:gap-20">
        <div>
          <Kicker>Deliverables</Kicker>
          <h2 id="service-deliverables-title" className="mt-5 max-w-[16ch] font-serif text-[clamp(2rem,3.8vw,3.2rem)] leading-[1.05] text-text">Work you can <em className="italic text-accent">inspect.</em></h2>
          <p className="mt-5 max-w-[42ch] text-sm leading-[1.8] text-text-muted">These are candidate deliverables. The written scope confirms which apply to your project, how they will be reviewed and who owns the next step.</p>
        </div>
        <ul className="divide-y divide-ink/10 border-y border-ink/10">
          {service.deliverables.map((item, index) => (
            <li key={item} className="flex gap-5 py-5">
              <span aria-hidden="true" className="pt-1 font-mono text-[10px] text-text-muted">{String(index + 1).padStart(2, '0')}</span>
              <span className="text-[15px] leading-[1.8] text-text">{item}</span>
            </li>
          ))}
        </ul>
      </section>

      <section aria-label="Working process" className="mx-auto max-w-[1180px] px-5 pb-16 md:pb-24">
        <SectionHead kicker="Process" title={<>From the brief to the <em className="italic text-hl-a">handoff.</em></>} />
        <ol className="mt-10 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {service.process.map((step, index) => (
            <li key={step.title} className="border-t border-ink/15 pt-5">
              <span aria-hidden="true" className="font-serif text-3xl text-accent">{String(index + 1).padStart(2, '0')}</span>
              <h3 className="mt-5 text-base font-semibold text-text">{step.title}</h3>
              <p className="mt-3 text-sm leading-[1.8] text-text-muted">{step.copy}</p>
            </li>
          ))}
        </ol>
      </section>

      <section aria-label="Related work and evidence" className="bg-band text-band-fg">
        <div className="mx-auto max-w-[1180px] px-5 py-16 md:py-20">
          <SectionHead tone="dark" kicker="Evidence, not promises" title="Look at the work." blurb="Public projects, repositories and engineering notes. Each link explains what it demonstrates; it is not a guarantee of results for your project." />
          <ul className="mt-10 grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {service.evidence.map((evidence) => (
              <li key={evidence.label} className="min-w-0 border-t border-band-fg/20 pt-4">
                <EvidenceLink evidence={evidence} />
                <p className="mt-3 max-w-[52ch] text-sm leading-[1.8] text-band-fg/75">{evidence.copy}</p>
              </li>
            ))}
          </ul>
        </div>
      </section>

      <section aria-labelledby="service-questions-title" className="mx-auto grid max-w-[1180px] gap-10 px-5 py-16 md:py-24 lg:grid-cols-[0.8fr_1.2fr] lg:gap-20">
        <div>
          <Kicker>Questions</Kicker>
          <h2 id="service-questions-title" className="mt-5 font-serif text-[clamp(2rem,3.8vw,3.2rem)] leading-[1.05] text-text">Before we start.</h2>
        </div>
        <div className="divide-y divide-ink/10 border-y border-ink/10">
          {service.questions.map(({ question, answer }) => (
            <div key={question} className="py-6">
              <h3 className="text-base font-medium leading-[1.6] text-text">{question}</h3>
              <p className="mt-3 text-[15px] leading-[1.85] text-text-muted">{answer}</p>
            </div>
          ))}
        </div>
      </section>

      <ServiceEnquiry prompt={service.enquiry} subject={`${service.title} enquiry`} />

      <nav aria-label="Other services" className="mx-auto max-w-[1180px] px-5 py-12 md:py-16">
        <Kicker>Another kind of help?</Kicker>
        <ul className="mt-5 grid gap-x-8 sm:grid-cols-2 lg:grid-cols-3">
          {services.filter((entry) => entry.slug !== service.slug).map((entry) => (
            <li key={entry.slug}>
              <Link to={`/services/${entry.slug}`} className="group flex min-h-11 items-center justify-between gap-3 border-b border-ink/10 py-4 text-sm leading-[1.6] text-text-muted hover:text-text">
                {entry.title}<Arrow className="shrink-0" />
              </Link>
            </li>
          ))}
        </ul>
        <Link to="/services" className="mt-6 inline-flex min-h-11 items-center text-sm text-text underline decoration-ink/25 underline-offset-4 hover:decoration-current">All services</Link>
      </nav>
    </main>
  );
}

export function ServicePage({ slug }) {
  const service = serviceBySlug(slug);
  return service ? <ServiceDetail service={service} /> : <NotFoundPage />;
}
