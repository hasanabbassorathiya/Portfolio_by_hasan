import React from 'react';
import { Link } from '../lib/router';
import { usePosts } from '../lib/live-content';

export function WritingList() {
  const posts = usePosts();
  return posts.slice(0, 3).map((post, index) => (
    <Link
      key={post.slug}
      to={`/blog/${post.slug}`}
      className="group grid gap-4 border-t border-[var(--border)] py-7 transition-colors hover:border-accent/40 md:grid-cols-[7rem_1fr_9rem] md:items-baseline md:gap-8"
    >
      <span className="font-mono text-[11px] uppercase tracking-[0.14em] text-text-muted">
        {post.dateLabel}
      </span>
      <div className="flex flex-col gap-2">
        <h3 className="max-w-[36ch] font-display text-[clamp(1.25rem,2.4vw,1.75rem)] leading-snug transition-colors group-hover:text-accent">
          {post.title}
        </h3>
        <p className="max-w-[60ch] text-sm leading-[1.7] text-text-muted">{post.dek}</p>
      </div>
      <div className="flex items-center justify-between gap-3 md:flex-col md:items-end md:gap-1">
        <span className="font-mono text-[10px] uppercase tracking-[0.14em] text-accent">{post.category}</span>
        <span className="font-mono text-[10px] text-text-muted">{post.minutes} min · 0{index + 1}</span>
      </div>
    </Link>
  ));
}
