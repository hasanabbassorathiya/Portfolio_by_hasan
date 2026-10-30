import React, { useState } from 'react';
import { Link } from '../lib/router';
import { usePosts } from '../lib/live-content';
import { parseBlocks } from '../lib/markdown';
import { useSeo, SITE_URL, personJsonLd } from '../lib/seo';
import { trackCta } from '../lib/analytics';
import { Subscribe } from '../components/subscribe';

function PostCard({ post, index }) {
  return (
    <article className="group relative flex flex-col gap-4 border-t border-[var(--border)] py-8 transition-colors hover:border-accent/40">
      <div className="flex flex-wrap items-center gap-3 font-mono text-[11px] uppercase tracking-[0.16em] text-text-muted">
        <span className="text-accent">{post.category}</span>
        <span aria-hidden="true">·</span>
        <time dateTime={post.date}>{post.dateLabel}</time>
        <span aria-hidden="true">·</span>
        <span>{post.minutes} min read</span>
        <span aria-hidden="true" className="ml-auto text-accent/90">0{index + 1}</span>
      </div>
      <h3 className="max-w-[34ch] font-serif text-[clamp(1.4rem,2.6vw,2rem)] leading-[1.2] tracking-[-0.015em]">
        <Link to={`/blog/${post.slug}`} className="transition-colors group-hover:text-accent">
          {post.title}
        </Link>
      </h3>
      <p className="max-w-[58ch] text-[0.95rem] leading-[1.7] text-text-muted">{post.dek}</p>
      <div className="mt-1 flex flex-wrap items-center gap-2">
        {post.tags.map((tag) => (
          <span key={tag} className="rounded-full border border-[var(--border)] px-3 py-1 font-mono text-[10px] uppercase tracking-[0.12em] text-text-muted">
            {tag}
          </span>
        ))}
      </div>
    </article>
  );
}

export function BlogPage() {
  const posts = usePosts();
  const featuredPost = posts.find((post) => post.featured) ?? posts[0];
  const categories = ['All', ...Array.from(new Set(posts.map((post) => post.category)))];
  const featuredSections = featuredPost
    ? parseBlocks(featuredPost.body)
        .filter((block) => block.type === 'h2')
        .slice(0, 3)
    : [];

  useSeo({
    title: 'Writing · Hasan Abbas Sorathiya',
    description:
      'Field notes on Flutter architecture, AI in production, localization, performance, and the work of becoming a Google Developer Expert.',
    path: '/blog',
    image: '/og/blog.png',
    jsonLd: [
      personJsonLd,
      {
        '@context': 'https://schema.org',
        '@type': 'Blog',
        name: 'Notes from production',
        url: `${SITE_URL}/blog`,
        author: { '@type': 'Person', name: 'Hasan Abbas Sorathiya' },
        blogPost: posts.map((post) => ({
          '@type': 'BlogPosting',
          headline: post.title,
          datePublished: post.date,
          url: `${SITE_URL}/blog/${post.slug}`,
        })),
      },
    ],
  });

  const [filter, setFilter] = useState('All');
  const visible =
    filter === 'All'
      ? posts.filter((post) => post.slug !== featuredPost?.slug)
      : posts.filter((post) => post.category === filter);

  return (
    <main className="pt-[68px]">
      <section className="border-b border-[var(--border)] bg-deep">
        <div className="mx-auto grid max-w-[1360px] gap-10 px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3.5rem,8vw,6rem)] lg:grid-cols-[1.3fr_0.7fr] lg:items-end">
          <div className="flex flex-col gap-5">
            <p className="font-mono text-xs uppercase tracking-[0.25em] text-accent">Writing</p>
            <h1 className="max-w-[16ch] font-serif text-[clamp(2.4rem,6vw,4.5rem)] leading-[1.02] tracking-[-0.03em]">
              Notes from <em className="font-serif italic font-normal text-accent">production</em>
            </h1>
            <p className="max-w-[60ch] text-[1.05rem] leading-[1.7] text-text-muted">
              No listicles. These are problems I hit in real Flutter and AI work — how we found
              them, what we changed, and what I would do differently next time.
            </p>
          </div>
          <div className="flex flex-col gap-5 border-t border-[var(--border)] pt-6 lg:border-l lg:border-t-0 lg:pl-8 lg:pt-0">
            <p className="font-mono text-[11px] uppercase tracking-[0.2em] text-text-muted">
              {posts.length} essays · publishing every two weeks
            </p>
            <div className="flex flex-col gap-2">
              <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-accent">By email</p>
              <p className="text-sm leading-[1.7] text-text-muted">
                New essays, no noise. Unsubscribe whenever.
              </p>
              <Subscribe source="blog-index" variant="plain" />
            </div>
            <p className="text-sm leading-[1.7] text-text-muted">
              Prefer a feed? Use{' '}
              <a className="text-text underline decoration-accent/50 underline-offset-4" href="/rss.xml">RSS</a>
              {' '}or follow on <a className="text-text underline decoration-accent/50 underline-offset-4" href="https://www.linkedin.com/in/hasanabbassorathiya/" target="_blank" rel="noreferrer">LinkedIn</a>.
            </p>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] pt-[clamp(2.5rem,5vw,4rem)]">
        {filter === 'All' && featuredPost && (
          <Link
            to={`/blog/${featuredPost.slug}`}
            className="group grid gap-10 border-y border-accent/25 bg-surface/50 px-1 py-10 transition-colors hover:bg-surface md:grid-cols-[1.15fr_0.85fr] md:px-8 md:py-12"
          >
            <div className="flex flex-col justify-between gap-8">
              <div className="flex flex-col gap-4">
                <p className="font-mono text-[11px] uppercase tracking-[0.2em] text-accent">
                  Featured essay · {featuredPost.category}
                </p>
                <h2 className="max-w-[18ch] font-serif text-[clamp(1.9rem,4vw,3rem)] leading-[1.1] tracking-[-0.02em] group-hover:text-accent">
                  {featuredPost.title}
                </h2>
                <p className="max-w-[52ch] leading-[1.7] text-text-muted">{featuredPost.dek}</p>
              </div>
              <div className="flex flex-wrap items-center gap-4 font-mono text-[11px] uppercase tracking-[0.16em] text-text-muted">
                <time dateTime={featuredPost.date}>{featuredPost.dateLabel}</time>
                <span aria-hidden="true">·</span>
                <span>{featuredPost.minutes} min read</span>
                <span className="ml-auto text-accent">Read the essay →</span>
              </div>
            </div>
            <div className="flex flex-col justify-between gap-6">
              <div>
                <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-text-muted">
                  Inside the essay
                </p>
                <ol className="mt-3 border-t border-[var(--border)]">
                  {featuredSections.map((section, i) => (
                    <li
                      key={section.text}
                      className="flex items-baseline gap-4 border-b border-[var(--border)] py-3.5"
                    >
                      <span className="font-mono text-[11px] text-accent/90">0{i + 1}</span>
                      <span className="text-[0.95rem] leading-snug text-text">{section.text}</span>
                    </li>
                  ))}
                </ol>
              </div>
              <div className="flex flex-wrap gap-2">
                {featuredPost.tags.map((tag) => (
                  <span
                    key={tag}
                    className="rounded-full border border-accent/30 px-3 py-1 font-mono text-[10px] uppercase tracking-[0.12em] text-accent"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </div>
          </Link>
        )}

        <div className="mt-12 flex flex-wrap items-center gap-2 border-b border-[var(--border)] pb-6">
          {categories.map((category) => (
            <button
              key={category}
              type="button"
              onClick={() => setFilter(category)}
              className={`rounded-full border px-4 py-2 font-mono text-[11px] uppercase tracking-[0.14em] transition-colors ${
                filter === category
                  ? 'border-accent-solid bg-accent-solid text-on-accent'
                  : 'border-[var(--border)] text-text-muted hover:border-accent/50 hover:text-text'
              }`}
              aria-pressed={filter === category}
            >
              {category}
            </button>
          ))}
          <span className="ml-auto font-mono text-[11px] text-text-muted">
            {visible.length} {filter === 'All' ? 'more essays' : visible.length === 1 ? 'essay' : 'essays'}
          </span>
        </div>

        {posts.length === 0 && (
          <p className="border-b border-[var(--border)] py-12 text-[1.05rem] leading-[1.7] text-text-muted">
            No essays published yet. Check back soon.
          </p>
        )}

        <div className="grid gap-x-14 md:grid-cols-2">
          {visible.map((post, index) => (
            <PostCard
              key={post.slug}
              post={post}
              index={index + (filter === 'All' ? 1 : 0)}
            />
          ))}
        </div>
      </section>

      <section className="mx-auto mt-[clamp(4rem,8vw,7rem)] max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)]">
        <div className="flex flex-col items-start gap-5 border-t border-[var(--border)] py-12 md:flex-row md:items-center md:justify-between">
          <div>
            <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">Work with me</p>
            <h2 className="mt-2 max-w-[24ch] font-serif text-[clamp(1.6rem,3vw,2.2rem)] leading-tight">
              Building a Flutter product, or adding AI to one?
            </h2>
          </div>
          <a
            href="mailto:hasanabbassorathiya12@gmail.com?subject=Project%20enquiry"
            onClick={() => trackCta('email', 'blog')}
            className="rounded-lg bg-accent-solid px-6 py-3 font-medium text-on-accent transition hover:brightness-110"
          >
            Start a conversation
          </a>
        </div>
      </section>
    </main>
  );
}
