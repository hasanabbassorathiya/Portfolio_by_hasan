import React from 'react';
import { Link } from '../lib/router';
import { SITE_NAME, useSeo } from '../lib/seo';
import { Kicker } from '../sections/ref-ui';

const EMAIL = 'hasanabbassorathiya12@gmail.com';
const UPDATED = '12 November 2026';

function Section({ id, title, children }) {
  return (
    <section aria-labelledby={id} className="border-t border-ink/10 pt-7">
      <h2
        id={id}
        className="font-mono text-[10px] uppercase tracking-[0.2em] text-accent"
      >
        {title}
      </h2>
      <div className="mt-3 space-y-3 text-[15px] leading-[1.8] text-text-muted">{children}</div>
    </section>
  );
}

export function PrivacyPage() {
  useSeo({
    title: `Privacy · What this site stores · ${SITE_NAME}`,
    description:
      'What hasanabbassorathiya.tech stores when you send an enquiry or subscribe to essays, why it is stored, how long it is kept, and how to have it removed.',
    path: '/privacy',
  });

  return (
    <main className="pt-28 pb-24 md:pt-32">
      <div className="mx-auto max-w-[820px] px-5">
        <Kicker>Privacy · Plain language</Kicker>
        <h1 className="mt-5 max-w-[20ch] font-serif text-[clamp(2.6rem,6vw,4.4rem)] font-normal leading-[1.02] tracking-[-0.025em] text-text">
          What this site <em className="italic text-accent">stores.</em>
        </h1>
        <p className="mt-5 max-w-[60ch] text-[16px] leading-[1.8] text-text-muted">
          This site has no visitor accounts, no advertising trackers and no data resale. It measures
          visits with a first-party, cookieless beacon and optional Google Analytics, but only after
          you accept analytics in the cookie banner. It stores personal data only when you choose to
          send an enquiry or sign up for essays. This page explains exactly what that is.
        </p>

        <div className="mt-10 space-y-7">
          <Section id="who" title="Who runs this site">
            <p>
              {SITE_NAME}, Dubai, UAE. For anything on this page — including a request to delete
              your data — email{' '}
              <a
                href={`mailto:${EMAIL}?subject=Privacy%20request`}
                className="underline decoration-ink/25 underline-offset-2 transition-colors hover:text-accent"
              >
                {EMAIL}
              </a>
              .
            </p>
          </Section>

          <Section id="enquiry" title="If you send an enquiry">
            <p>The form stores your name, email address, the type of help you selected and your message. It also records when you ticked the consent box, a version label for the consent text, a reference number, and a one-way hash used to detect accidental duplicate submissions.</p>
            <p>
              The server also stores a keyed hash of your IP address — never the raw address — so
              automated spam can be rate-limited. The enquiry is kept in a private database on the
              hosting account and readable only through the site owner&apos;s password-protected
              admin.
            </p>
            <p>It is used to reply to you and to keep track of the conversation. It is not added to any mailing list, and no marketing is sent unless you separately sign up for essays.</p>
          </Section>

          <Section id="newsletter" title="If you sign up for essays or the community">
            <p>The essay form stores only your email address, the page you signed up from and a one-way hash of your IP address. The community form additionally stores the name and optional WhatsApp number you type, plus when you ticked the consent box and a version label for the consent text. If you receive a subscriber email, its unsubscribe link deletes your row — including name and WhatsApp — immediately. You can also email me to be removed.</p>
          </Section>

          <Section id="analytics" title="Visit measurement">
            <p>Measurement is consent-first: the beacon and Google Analytics stay off until you accept analytics in the cookie banner. If you decline, nothing is loaded and no events are sent. Your choice is kept in your browser&apos;s localStorage and can be changed any time from &ldquo;Cookie settings&rdquo; in the footer.</p>
            <p>Once accepted, the public site sends page views and anonymous interaction events — section views, button clicks, résumé opens, store-link clicks and the selected enquiry type — to its own endpoint at <span className="font-mono text-[13px]">/api/track.php</span>. No name, email address or message text is ever sent to it.</p>
            <p>Each visit gets a random session ID kept in your browser&apos;s sessionStorage. The server derives a daily keyed hash from your IP address and browser string to count unique visitors and limit abuse; the raw IP address is never stored. It also records coarse device, browser and operating-system categories, a country code when the network provides one, the referring host, and campaign labels from <span className="font-mono text-[13px]">utm_</span> parameters if present.</p>
            <p>If your browser sends Do Not Track or Global Privacy Control, analytics is declined by default and nothing is loaded. Raw events are deleted after 180 days; daily aggregate counts with no visitor identifier are kept for traffic reporting.</p>
          </Section>

          <Section id="not-collected" title="What is not collected">
            <p>No visitor accounts, no passwords, no payment details, no advertising or cross-site tracking pixels, and no data sold or shared with list brokers. The light/dark preference, the boot animation flag and your analytics consent choice are stored in your own browser (localStorage and sessionStorage) and are never sent to the server.</p>
            <p>Google Analytics 4 is optional and only runs after you accept analytics and it has been configured. When it does, it records page views with IP anonymisation, and the first-party beacon described above continues to be the primary measurement. Visitors who decline or block analytics scripts are not tracked in any other way.</p>
          </Section>

          <Section id="cookies" title="Cookies">
            <p>The public site sets no cookies of its own; visit measurement uses sessionStorage, not cookies. The owner-only admin area uses a login session cookie after authentication. If you accept analytics and Google Analytics is configured, it sets its own first-party cookies (<span className="font-mono text-[13px]">_ga</span> and <span className="font-mono text-[13px]">_ga_&lt;id&gt;</span>) to distinguish sessions, with IP anonymisation enabled. Newsletter unsubscribe links carry a random token in the URL so the right address is removed.</p>
          </Section>

          <Section id="retention" title="How long it is kept">
            <p>Enquiries are kept until they have been handled and reviewed, with no automatic deletion, so a conversation is not lost mid-thread. Subscriber rows — email, and name or WhatsApp where you provided them — are kept until you unsubscribe. Raw analytics events are deleted after 180 days; daily aggregates contain no visitor identifier. Ask me to delete an enquiry or address at any time and it is removed; the only reason to keep anything longer would be a legal obligation.</p>
          </Section>

          <Section id="third-parties" title="Where it is processed">
            <p>The site and its database run on Hostinger web hosting. If configured, Brevo processes newsletter delivery: your email address and list membership are shared with Brevo so the emails you asked for can be sent. If configured, Google Analytics processes page-view data as described above. Links to LinkedIn, GitHub, the app stores, pub.dev and other external sites are governed by those sites&apos; own privacy policies.</p>
          </Section>

          <Section id="choices" title="Your choices">
            <p>You can ask for a copy of what is stored about you, ask for a correction, or ask for deletion — email{' '}
              <a
                href={`mailto:${EMAIL}?subject=Privacy%20request`}
                className="underline decoration-ink/25 underline-offset-2 transition-colors hover:text-accent"
              >
                {EMAIL}
              </a>{' '}
              and it will be handled directly. Withdrawing consent for an enquiry means the
              conversation stops and the record is deleted. You can change your analytics choice at
              any time from &ldquo;Cookie settings&rdquo; in the footer; declining stops all further
              measurement.
            </p>
          </Section>

          <Section id="changes" title="Changes to this notice">
            <p>If what the site stores changes, this page is updated first. Last updated {UPDATED}.</p>
          </Section>
        </div>

        <div className="mt-12 flex flex-wrap items-center gap-4 border-t border-ink/10 pt-6">
          <Link
            to="/"
            className="inline-flex min-h-11 items-center rounded-full border border-ink/15 px-5 text-sm text-text transition-colors hover:border-ink/40"
          >
            ← Back to the site
          </Link>
          <a
            href={`mailto:${EMAIL}`}
            className="inline-flex min-h-11 items-center text-sm text-text-muted underline decoration-ink/25 underline-offset-4 transition-colors hover:text-accent"
          >
            Ask a privacy question
          </a>
        </div>
      </div>
    </main>
  );
}
