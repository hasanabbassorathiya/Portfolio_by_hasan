import React from 'react';
import { trackCta, trackOutbound } from '../lib/analytics';
import { SITE_NAME, useSeo } from '../lib/seo';
import { useProfile, useSocialPosts } from '../lib/live-content';
import { Link } from '../lib/router';
import { Arrow, Kicker } from '../sections/ref-ui';

const PROVIDERS = {
  linkedin: 'LinkedIn',
  x: 'X',
  twitter: 'X',
  instagram: 'Instagram',
  facebook: 'Facebook',
  threads: 'Threads',
  tiktok: 'TikTok',
  youtube: 'YouTube',
  medium: 'Medium',
  mastodon: 'Mastodon',
  bluesky: 'Bluesky',
  reddit: 'Reddit',
  devto: 'DEV',
  hashnode: 'Hashnode',
  telegram: 'Telegram',
  pinterest: 'Pinterest',
};

const providerLabel = (key) => {
  if (!key) return 'Social';
  const known = PROVIDERS[key];
  if (known) return known;
  return key.replace(/[-_]/g, ' ').replace(/^\w/, (letter) => letter.toUpperCase());
};

export function ActivityPage() {
  const posts = useSocialPosts();
  const profile = useProfile();
  const channels = [
    ['LinkedIn', profile.linkedin],
    ['GitHub', profile.github],
    ['Instagram', profile.instagram],
    ['Medium', profile.medium],
    ['YouTube', profile.youtube],
  ].filter(([, href]) => href);

  useSeo({
    title: `Activity · Cross-posted updates · ${SITE_NAME}`,
    description:
      'Short updates cross-posted from LinkedIn, X, Instagram and Medium: releases, architecture notes, and what is shipping in the apps.',
    path: '/activity',
    // A syndicated feed adds nothing for search; it is here for visitors.
    noindex: true,
  });

  return (
    <main className="pt-28 md:pt-32">
      <header className="mx-auto max-w-[1180px] px-5 pb-14 pt-8 md:pb-20 md:pt-12">
        <Kicker>Activity · Cross-posted from social</Kicker>
        <div className="mt-6 grid gap-8 lg:grid-cols-[1.15fr_0.85fr] lg:items-end lg:gap-16">
          <h1 className="max-w-[16ch] font-serif text-[clamp(2.9rem,6.6vw,5.6rem)] font-normal leading-[0.98] tracking-[-0.025em] text-text">
            What I publish, <em className="italic text-accent">collected here.</em>
          </h1>
          <div>
            <p className="max-w-[54ch] text-[16px] leading-[1.8] text-text-muted">
              Releases, architecture notes and short lessons from production. Posts start on
              LinkedIn, X, Instagram or Medium and land in this feed automatically — no newsletter,
              no algorithmic detour.
            </p>
            <div className="mt-7 flex flex-wrap items-center gap-x-5 gap-y-2">
              {channels.map(([label, href]) => (
                <a
                  key={label}
                  href={href}
                  target="_blank"
                  rel="noreferrer"
                  onClick={() => trackOutbound(label, href)}
                  className="group inline-flex min-h-11 items-center gap-2 text-sm font-medium text-text rule-link"
                >
                  {label}
                  <Arrow />
                </a>
              ))}
            </div>
          </div>
        </div>
      </header>

      <section aria-labelledby="feed-title" className="border-t border-ink/10 bg-surface/40">
        <div className="mx-auto max-w-[1180px] px-5 py-14 md:py-20">
          <div className="flex flex-wrap items-baseline justify-between gap-3">
            <h2 id="feed-title" className="font-serif text-[clamp(1.9rem,3.4vw,2.6rem)] leading-tight text-text">
              Latest posts
            </h2>
            <span className="font-mono text-xs uppercase tracking-[0.12em] text-text-muted">
              {posts.length === 1 ? '1 post' : `${posts.length} posts`}
            </span>
          </div>

          {posts.length === 0 ? (
            <div className="mt-8 rounded-[1.4rem] border border-dashed border-ink/20 bg-surface p-8 md:p-10">
              <p className="max-w-[52ch] text-[15px] leading-[1.75] text-text">
                Nothing cross-posted yet. The first published post through the bridge will appear
                here automatically, newest first.
              </p>
              <p className="mt-3 max-w-[52ch] text-sm leading-[1.7] text-text-muted">
                Until then, the main channels above carry everything — and the{' '}
                <Link to="/blog" className="font-medium text-text rule-link">essays</Link> go deeper
                than a social post can.
              </p>
              <a
                href={`mailto:${profile.email}?subject=${encodeURIComponent('Say hello')}`}
                onClick={() => trackCta('email', 'activity-empty')}
                className="mt-6 inline-flex min-h-11 items-center gap-2 text-sm font-medium text-accent rule-link"
              >
                Email {profile.email}
                <Arrow />
              </a>
            </div>
          ) : (
            <ol className="mt-8 space-y-4">
              {posts.map((post) => (
                <li key={post.id} className="rounded-[1.4rem] border border-ink/10 bg-surface p-6 md:p-7">
                  <div className="flex flex-wrap items-center gap-x-3 gap-y-2">
                    <span className="rounded-full border border-accent/30 px-2.5 py-1 font-mono text-[10px] uppercase tracking-[0.12em] text-accent">
                      {providerLabel(post.provider)}
                    </span>
                    {post.channel && (
                      <span className="text-xs text-text-muted">{post.channel}</span>
                    )}
                    {post.dateLabel && (
                      <time dateTime={post.postedAt} className="ml-auto font-mono text-xs text-text-muted">
                        {post.dateLabel}
                      </time>
                    )}
                  </div>
                  {post.text && (
                    <p className="mt-4 whitespace-pre-line text-[15px] leading-[1.75] text-text">
                      {post.text}
                    </p>
                  )}
                  {post.image && (
                    <img
                      src={post.image}
                      alt=""
                      loading="lazy"
                      decoding="async"
                      className="mt-4 w-full rounded-xl border border-ink/10"
                    />
                  )}
                  {post.url && (
                    <a
                      href={post.url}
                      target="_blank"
                      rel="noreferrer"
                      onClick={() => trackOutbound(providerLabel(post.provider), post.url)}
                      className="mt-5 inline-flex min-h-11 items-center gap-2 text-sm font-medium text-accent rule-link"
                    >
                      View the original
                      <Arrow />
                    </a>
                  )}
                </li>
              ))}
            </ol>
          )}
        </div>
      </section>
    </main>
  );
}
