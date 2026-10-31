import React from 'react';
import { resume } from '../content/resume';
import { useExperiences, useSkillGroups } from '../lib/live-content';
import { interpolate, useSiteMetrics } from '../lib/site-metrics';
import { Link } from '../lib/router';
import { SITE_NAME, SITE_URL, personJsonLd, useSeo } from '../lib/seo';
import { trackCta, trackResume } from '../lib/analytics';

const PDF_PATH = '/hasan-abbas-sorathiya-resume.pdf';

const formatUpdated = (iso) =>
  new Date(`${iso}T00:00:00Z`).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  });

function ContactLink({ href, children, external = false }) {
  return (
    <a
      href={href}
      {...(external ? { target: '_blank', rel: 'noreferrer' } : {})}
      className="underline decoration-[#16130f]/25 underline-offset-2 transition-colors hover:text-[#1d3cff] hover:decoration-[#1d3cff]"
    >
      {children}
    </a>
  );
}

function Section({ title, children }) {
  return (
    <section className="mt-7">
      <h2 className="resume-section-title font-mono text-[10px] uppercase tracking-[0.2em] text-[#1d3cff]">
        {title}
      </h2>
      {children}
    </section>
  );
}

export function ResumePage() {
  const experiences = useExperiences();
  const skills = useSkillGroups();
  const metrics = useSiteMetrics();
  useSeo({
    title: `Résumé · ${SITE_NAME} · Senior Software & AI Engineer`,
    description:
      `Résumé for Hasan Abbas Sorathiya: ${metrics.yearsLabel} years of mobile engineering, Flutter architecture, AI integration and automation, and full-stack delivery. Web version of the downloadable PDF.`,
    path: '/resume',
    jsonLd: personJsonLd,
  });

  return (
    <main className="pt-28 pb-24 md:pt-32 print:pt-0 print:pb-0">
      <div className="mx-auto max-w-[880px] px-5 print:max-w-none print:px-0">
        <div className="mb-5 flex flex-wrap items-center justify-between gap-3 print:hidden">
          <Link
            to="/"
            className="inline-flex min-h-11 items-center text-sm text-text-muted transition-colors hover:text-text"
          >
            ← Portfolio
          </Link>
          <div className="flex flex-wrap items-center gap-2">
            <a
              href={PDF_PATH}
              download
              onClick={() => trackResume('resume-page')}
              className="inline-flex min-h-11 items-center rounded-full bg-accent-solid px-5 text-sm font-medium text-on-accent transition-colors hover:bg-accent-solid/90"
            >
              Download PDF
            </a>
            <a
              href={`mailto:${resume.email}?subject=Let%27s%20work%20together`}
              onClick={() => trackCta('email', 'resume')}
              className="inline-flex min-h-11 items-center rounded-full border border-ink/15 px-5 text-sm text-text transition-colors hover:border-ink/40"
            >
              Email me
            </a>
          </div>
        </div>

        <article className="resume-sheet rounded-[1.4rem] border border-ink/10 bg-[#fbf8f2] px-6 py-8 text-[#16130f] shadow-[0_30px_80px_-60px_rgba(20,17,13,0.5)] sm:px-10 sm:py-12">
          <header className="border-b border-[#16130f]/15 pb-6">
            <h1 className="font-serif text-[clamp(2.1rem,5vw,2.9rem)] font-normal leading-[1.02] tracking-[-0.02em]">
              {resume.name}
            </h1>
            <p className="mt-2 text-[15px] font-medium text-[#16130f]">{resume.title}</p>
            <p className="mt-0.5 text-[12.5px] text-[#16130f]/70">{resume.subtitle}</p>
            <ul className="mt-4 flex flex-wrap gap-x-4 gap-y-1.5 text-[12.5px] text-[#16130f]/80">
              <li>{resume.location}</li>
              <li>
                <ContactLink href={`mailto:${resume.email}`}>{resume.email}</ContactLink>
              </li>
              <li>
                <ContactLink href={resume.phoneHref}>{resume.phone}</ContactLink>
              </li>
              <li>
                <ContactLink href={resume.website} external>
                  {resume.websiteLabel}
                </ContactLink>
              </li>
              <li>
                <ContactLink href={resume.linkedin} external>
                  {resume.linkedinLabel}
                </ContactLink>
              </li>
              <li>
                <ContactLink href={resume.github} external>
                  {resume.githubLabel}
                </ContactLink>
              </li>
            </ul>
          </header>

          <Section title="Profile">
            <div className="mt-3 space-y-2 border-t border-[#16130f]/10 pt-4 text-[13px] leading-[1.65] text-[#16130f]/85">
              {resume.summary.map((paragraph) => (
                <p key={paragraph.slice(0, 40)}>{interpolate(paragraph, metrics)}</p>
              ))}
            </div>
          </Section>

          <Section title="Experience">
            <ol className="mt-1 border-t border-[#16130f]/10">
              {experiences.map((role) => (
                <li
                  key={role.company}
                  className="resume-role grid gap-1.5 border-b border-[#16130f]/10 py-4 sm:grid-cols-[9.5rem_1fr] sm:gap-6"
                >
                  <div className="font-mono text-[10.5px] uppercase leading-[1.6] tracking-[0.04em] text-[#16130f]/70">
                    <p>{role.period}</p>
                    <p>{role.location}</p>
                  </div>
                  <div>
                    <h3 className="text-[15px] font-semibold leading-snug text-[#16130f]">
                      {role.company}
                      <span className="font-normal text-[#16130f]/70"> — {role.role}</span>
                    </h3>
                    <p className="mt-1 text-[12.5px] leading-[1.6] text-[#16130f]/75">{interpolate(role.summary, metrics)}</p>
                    <ul className="mt-1.5 list-disc space-y-1 pl-4 text-[12px] leading-[1.55] text-[#16130f]/75">
                      {role.points.map((point) => (
                        <li key={point}>{interpolate(point, metrics)}</li>
                      ))}
                    </ul>
                  </div>
                </li>
              ))}
            </ol>
          </Section>

          <Section title="Skills">
            <dl className="mt-1 border-t border-[#16130f]/10">
              {skills.map((group) => (
                <div
                  key={group.label}
                  className="resume-block grid gap-1 border-b border-[#16130f]/10 py-2.5 sm:grid-cols-[9.5rem_1fr] sm:gap-6"
                >
                  <dt className="font-mono text-[10px] uppercase tracking-[0.1em] text-[#16130f]/70">
                    {group.label}
                  </dt>
                  <dd className="text-[12.5px] leading-[1.55] text-[#16130f]/80">
                    {group.items.join(' · ')}
                  </dd>
                </div>
              ))}
            </dl>
          </Section>

          <Section title="Selected products">
            <ul className="mt-2 grid gap-x-10 gap-y-4 border-t border-[#16130f]/10 pt-4 sm:grid-cols-2">
              {resume.apps.map((app) => (
                <li key={app.name} className="resume-block">
                  <p className="text-[13px] font-medium leading-snug">
                    <ContactLink href={app.href} external>
                      {app.name}
                    </ContactLink>
                    <span className="font-normal text-[#16130f]/70"> — {app.role}</span>
                  </p>
                  <p className="mt-1 text-[12px] leading-[1.55] text-[#16130f]/70">{interpolate(app.detail, metrics)}</p>
                  <p className="mt-1 font-mono text-[9.5px] uppercase tracking-[0.08em] text-[#16130f]/70">
                    {interpolate(app.note, metrics)}
                  </p>
                </li>
              ))}
            </ul>
          </Section>

          <Section title="Open source">
            <ul className="mt-2 grid gap-x-10 gap-y-3 border-t border-[#16130f]/10 pt-4 sm:grid-cols-2">
              {resume.openSource.map((project) => (
                <li key={project.name} className="resume-block">
                  <p className="text-[13px] font-medium leading-snug">
                    <ContactLink href={project.href} external>
                      {project.name}
                    </ContactLink>
                  </p>
                  <p className="mt-0.5 text-[12px] leading-[1.55] text-[#16130f]/70">{project.detail}</p>
                </li>
              ))}
            </ul>
          </Section>

          <Section title="Education & certifications">
            <div className="mt-2 grid gap-6 border-t border-[#16130f]/10 pt-4 sm:grid-cols-2">
              <div className="resume-block">
                <h3 className="text-[13.5px] font-semibold">{resume.education.degree}</h3>
                <p className="mt-0.5 text-[12.5px] text-[#16130f]/70">
                  {resume.education.school} · {resume.education.year}
                </p>
                <p className="mt-1.5 text-[12px] leading-[1.55] text-[#16130f]/70">
                  {resume.education.detail}
                </p>
                <p className="mt-4 font-mono text-[10px] uppercase tracking-[0.1em] text-[#16130f]/70">
                  Languages
                </p>
                <p className="mt-1 text-[12.5px] text-[#16130f]/80">{resume.languages.join(' · ')}</p>
              </div>
              <div className="resume-block">
                <h3 className="text-[13.5px] font-semibold">Certifications</h3>
                <ul className="mt-1.5 list-disc space-y-1 pl-4 text-[12.5px] leading-[1.55] text-[#16130f]/75">
                  {resume.certifications.map((certification) => (
                    <li key={certification}>{certification}</li>
                  ))}
                </ul>
              </div>
            </div>
          </Section>

          <div className="mt-8 flex flex-wrap items-center justify-between gap-2 border-t border-[#16130f]/15 pt-4 font-mono text-[9.5px] uppercase tracking-[0.08em] text-[#16130f]/70">
            <span>Updated {formatUpdated(resume.updated)}</span>
            <span>
              Web version ·{' '}
              <ContactLink href={`${SITE_URL}/resume`} external>
                {SITE_URL.replace('https://', '')}/resume
              </ContactLink>
            </span>
          </div>
        </article>

        <div className="mt-6 flex flex-wrap items-center justify-between gap-3 print:hidden">
          <p className="max-w-[46ch] text-xs leading-relaxed text-text-muted">
            The PDF is generated from this page, so the dates, roles, and technologies match the
            website. Prefer email? {resume.email}
          </p>
          <a
            href={PDF_PATH}
            download
            onClick={() => trackResume('resume-page-footer')}
            className="inline-flex min-h-11 items-center rounded-full border border-ink/15 px-5 text-sm text-text transition-colors hover:border-ink/40"
          >
            Download PDF ↓
          </a>
        </div>
      </div>
    </main>
  );
}
