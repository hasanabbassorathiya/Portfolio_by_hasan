import React, { useEffect, useMemo, useState } from 'react';
import { Link } from '../lib/router';
import { Markdown } from '../components/markdown';
import { usePosts, relatedPosts, adjacentPosts } from '../lib/live-content';
import { parseBlocks } from '../lib/markdown';
import { useSeo, SITE_URL, personJsonLd } from '../lib/seo';
import { trackCta } from '../lib/analytics';
import { Subscribe } from '../components/subscribe';
import { NotFoundPage } from './not-found';

function ShareRow({ post }) {
  const [copied, setCopied] = useState(false);
  const url = `${SITE_URL}/blog/${post.slug}`;

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      setTimeout(() => setCopied(false), 1800);
    } catch {
      setCopied(false);
    }
  };

  return (
    <div className="flex flex-wrap items-center gap-2">
      <a
        href={`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`}
        target="_blank"
        rel="noreferrer"
        className="rounded-full border border-[var(--border)] px-4 py-2 font-mono text-[11px] uppercase tracking-[0.12em] text-text-muted transition-colors hover:border-accent/50 hover:text-text"
      >
        Share on LinkedIn
      </a>
      <a
        href={`https://twitter.com/intent/tweet?text=${encodeURIComponent(post.title)}&url=${encodeURIComponent(url)}`}
        target="_blank"
        rel="noreferrer"
        className="rounded-full border border-[var(--border)] px-4 py-2 font-mono text-[11px] uppercase tracking-[0.12em] text-text-muted transition-colors hover:border-accent/50 hover:text-text"
      >
        Post on X
      </a>
      <button
        type="button"
        onClick={copy}
        className="rounded-full border border-[var(--border)] px-4 py-2 font-mono text-[11px] uppercase tracking-[0.12em] text-text-muted transition-colors hover:border-accent/50 hover:text-text"
      >
        {copied ? 'Copied' : 'Copy link'}
      </button>
    </div>
  );
}

export function PostPage({ slug }) {
  const posts = usePosts();
  const post = posts.find((entry) => entry.slug === slug);
  const seo = post?.seo ?? {};
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const onScroll = () => {
      const max = document.documentElement.scrollHeight - window.innerHeight;
      setProgress(max > 0 ? Math.min(100, (window.scrollY / max) * 100) : 0);
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, [slug]);

  const headings = useMemo(
    () => (post ? parseBlocks(post.body).filter((b) => b.type === 'h2') : []),
    [post]
  );

  useSeo({
    title: post ? seo.title || `${post.title} · Hasan Abbas Sorathiya` : 'Essay not found',
    description: post ? seo.description || post.dek : 'Essay not found.',
    path: `/blog/${slug}`,
    type: 'article',
    image: seo.image || (post ? `/og/${post.slug}.png` : '/og/blog.png'),
    published: post?.date,
    tags: post?.tags,
    noindex: seo.noindex === true,
    jsonLd: post
      ? [
          personJsonLd,
          {
            '@context': 'https://schema.org',
            '@type': 'BlogPosting',
            headline: post.title,
            description: post.dek,
            datePublished: post.date,
            dateModified: post.date,
            author: {
              '@type': 'Person',
              name: 'Hasan Abbas Sorathiya',
              url: SITE_URL,
            },
            publisher: {
              '@type': 'Person',
              name: 'Hasan Abbas Sorathiya',
              url: SITE_URL,
            },
            mainEntityOfPage: `${SITE_URL}/blog/${post.slug}`,
            image: `${SITE_URL}/og/${post.slug}.png`,
            keywords: post.tags.join(', '),
            articleSection: post.category,
          },
        ]
      : null,
  });

  if (!post) return <NotFoundPage />;

  const { previous, next } = adjacentPosts(posts, post);
  const related = relatedPosts(posts, post, 2);

  return (
    <main className="pt-[68px]">
      <div className="fixed left-0 right-0 top-[68px] z-30 h-[2px] bg-transparent">
        <div className="h-full bg-accent transition-[width] duration-150" style={{ width: `${progress}%` }} />
      </div>

      <article>
        <header className="border-b border-[var(--border)] bg-deep">
          <div className="mx-auto flex max-w-[1120px] flex-col gap-6 px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,6vw,5rem)]">
            <nav className="flex items-center gap-2 font-mono text-[11px] uppercase tracking-[0.16em] text-text-muted" aria-label="Breadcrumb">
              <Link to="/blog" className="hover:text-accent">Writing</Link>
              <span aria-hidden="true">/</span>
              <span className="text-accent">{post.category}</span>
            </nav>
            <h1 className="max-w-[24ch] font-serif text-[clamp(2rem,5vw,3.8rem)] leading-[1.06] tracking-[-0.03em]">
              {post.title}
            </h1>
            <p className="max-w-[64ch] text-[1.05rem] leading-[1.7] text-text-muted">{post.dek}</p>
            <div className="flex flex-wrap items-center gap-x-5 gap-y-2 border-t border-[var(--border)] pt-5 font-mono text-[11px] uppercase tracking-[0.14em] text-text-muted">
              <span className="flex items-center gap-2">
                <img src="/hasan.webp" alt="" className="h-7 w-7 rounded-full object-cover" loading="lazy" />
                Hasan Abbas Sorathiya
              </span>
              <time dateTime={post.date}>{post.dateLabel}</time>
              <span>{post.minutes} min read</span>
            </div>
          </div>
        </header>

        <div className="mx-auto grid max-w-[1120px] gap-12 px-[clamp(1.25rem,5vw,4rem)] py-[clamp(2.5rem,6vw,5rem)] lg:grid-cols-[minmax(0,1fr)_240px]">
          <div className="min-w-0">
            <div className="prose-hs">
              <Markdown source={post.body} />
            </div>

            <div className="mt-12 flex flex-wrap items-center gap-2 border-t border-[var(--border)] pt-8">
              {post.tags.map((tag) => (
                <span key={tag} className="rounded-full border border-[var(--border)] px-3 py-1 font-mono text-[10px] uppercase tracking-[0.12em] text-text-muted">
                  {tag}
                </span>
              ))}
            </div>

            <div className="mt-8">
              <ShareRow post={post} />
            </div>

            <div className="mt-10">
              <Subscribe source={`post:${post.slug}`} variant="stack" />
            </div>

            <div className="mt-12 flex flex-col gap-4 rounded-2xl border border-accent/25 bg-surface p-6 md:flex-row md:items-center md:justify-between md:p-8">
              <div className="flex items-center gap-4">
                <img src="/hasan.webp" alt="Hasan Abbas Sorathiya" className="h-14 w-14 rounded-full object-cover" loading="lazy" />
                <div>
                  <p className="font-serif text-lg">Hasan Abbas Sorathiya</p>
                  <p className="text-sm text-text-muted">
                    Senior mobile &amp; AI engineer in Dubai. I build iOS, Android and Flutter products, and write about the parts that were hard.
                  </p>
                </div>
              </div>
              <a
                href="mailto:hasanabbassorathiya12@gmail.com?subject=Let%27s%20work%20together"
                onClick={() => trackCta('email', 'post')}
                className="shrink-0 rounded-lg bg-accent-solid px-5 py-3 text-center font-medium text-on-accent transition hover:brightness-110"
              >
                Work with me
              </a>
            </div>

            <nav className="mt-12 grid gap-4 border-t border-[var(--border)] pt-8 sm:grid-cols-2" aria-label="Adjacent essays">
              {previous ? (
                <Link to={`/blog/${previous.slug}`} className="group flex flex-col gap-1">
                  <span className="font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted">Previous</span>
                  <span className="font-serif text-lg leading-snug transition-colors group-hover:text-accent">{previous.title}</span>
                </Link>
              ) : <span />}
              {next && (
                <Link to={`/blog/${next.slug}`} className="group flex flex-col gap-1 sm:text-right">
                  <span className="font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted">Next</span>
                  <span className="font-serif text-lg leading-snug transition-colors group-hover:text-accent">{next.title}</span>
                </Link>
              )}
            </nav>
          </div>

          <aside className="hidden lg:block">
            <div className="sticky top-[100px] flex flex-col gap-6">
              <div className="flex flex-col gap-3 border-t border-[var(--border)] pt-4">
                <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-accent">On this page</p>
                {headings.map((heading) => (
                  <a
                    key={heading.id}
                    href={`#${heading.id}`}
                    className="text-sm leading-snug text-text-muted transition-colors hover:text-text"
                  >
                    {heading.text}
                  </a>
                ))}
              </div>
              <div className="flex flex-col gap-3 border-t border-[var(--border)] pt-4">
                <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-accent">Elsewhere</p>
                <a href="https://www.linkedin.com/in/hasanabbassorathiya/" target="_blank" rel="noreferrer" className="text-sm text-text-muted hover:text-text">LinkedIn ↗</a>
                <a href="https://github.com/hasanabbassorathiya" target="_blank" rel="noreferrer" className="text-sm text-text-muted hover:text-text">GitHub ↗</a>
              </div>
            </div>
          </aside>
        </div>
      </article>

      {related.length > 0 && (
        <section className="border-t border-[var(--border)] bg-deep">
          <div className="mx-auto grid max-w-[1120px] gap-8 px-[clamp(1.25rem,5vw,4rem)] py-[clamp(3rem,6vw,5rem)] md:grid-cols-2">
            <div className="flex flex-col justify-between gap-4">
              <p className="font-mono text-xs uppercase tracking-[0.22em] text-accent">Keep reading</p>
              <p className="max-w-[30ch] font-serif text-[clamp(1.5rem,3vw,2.2rem)] leading-tight">
                More notes from production
              </p>
              <Link to="/blog" className="w-fit font-mono text-xs text-text-muted underline decoration-accent/40 underline-offset-4 hover:text-text">
                All essays →
              </Link>
            </div>
            <div className="flex flex-col">
              {related.map((item) => (
                <Link
                  key={item.slug}
                  to={`/blog/${item.slug}`}
                  className="group flex flex-col gap-2 border-t border-[var(--border)] py-5 last:border-b"
                >
                  <span className="font-mono text-[10px] uppercase tracking-[0.16em] text-text-muted">
                    {item.category} · {item.minutes} min
                  </span>
                  <span className="font-serif text-xl leading-snug transition-colors group-hover:text-accent">
                    {item.title}
                  </span>
                </Link>
              ))}
            </div>
          </div>
        </section>
      )}
    </main>
  );
}
