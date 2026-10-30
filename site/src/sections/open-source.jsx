import React from 'react';
import { useReveal } from '../lib/motion';

const repos = [
  {
    name: 'stoolap-flutter',
    url: 'https://github.com/hasanabbassorathiya/stoolap-flutter',
    pubdev: 'https://pub.dev/packages/stoolap_flutter',
    lang: 'Dart · Rust',
    stars: 3,
    desc: 'High-performance embedded SQL database for Flutter with native vector search, MVCC transactions, and reactive streams.',
  },
  {
    name: 'BULBVPN',
    url: 'https://github.com/hasanabbassorathiya/BULBVPN',
    lang: 'Dart',
    desc: 'A secure Flutter VPN built for networks where connectivity is restricted — connection management, kill switch, and diagnostics.',
  },
  {
    name: 'wp-mcp-server',
    url: 'https://github.com/hasanabbassorathiya/wp-mcp-server',
    lang: 'TypeScript',
    desc: 'An MCP server for the WordPress REST API, letting AI agents manage content through typed tools instead of raw HTTP calls.',
  },
  {
    name: 'ChucklePlay',
    url: 'https://github.com/hasanabbassorathiya/ChucklePlay',
    lang: 'Dart',
    desc: 'A lightweight multi-platform IPTV player — the open-source companion to the streaming work in Lumio TV.',
  },
  {
    name: 'lumio_iptv',
    url: 'https://github.com/hasanabbassorathiya/lumio_iptv',
    lang: 'Dart',
    desc: 'The IPTV client implementation behind Lumio TV — M3U and Xtream sources, EPG guide data, and resilient playback.',
  },
  {
    name: 'Portfolio_by_hasan',
    url: 'https://github.com/hasanabbassorathiya/Portfolio_by_hasan',
    lang: 'Dart',
    desc: 'An earlier portfolio built in Dart — kept public as a record of how the presentation of the work has evolved.',
  },
  {
    name: 'claude-skills',
    url: 'https://github.com/hasanabbassorathiya/claude-skills',
    lang: 'Python',
    desc: 'My Claude Code skills and environment setup — the workflows I use to ship product code with AI assistance.',
  },
  {
    name: 'duas-crm',
    url: 'https://github.com/hasanabbassorathiya/duas-crm',
    lang: 'Python',
    desc: 'Content operations for Duas and Aamal: structured multilingual content, review status, and push-notification dispatch.',
  },
];

export function OpenSource() {
  const { ref, style } = useReveal(0);
  return (
    <section
      ref={ref}
      style={style}
      className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] pb-[clamp(3rem,8vw,6rem)]"
    >
      <p className="mb-3 font-mono text-xs uppercase tracking-[0.25em] text-accent">Open source</p>
      <h2 className="mb-10 font-display text-[clamp(1.8rem,4vw,3rem)] tracking-[-0.02em]">
        Code in the <em className="font-serif font-normal italic text-accent">open</em>
      </h2>
      <div className="grid gap-4 sm:grid-cols-2">
        {repos.map((repo) => (
          <article
            key={repo.name}
            className="flex flex-col gap-3 rounded-[1.25rem] border border-[var(--border)] bg-surface p-5 transition-colors hover:border-accent/40 md:p-6"
          >
            <div className="flex items-start justify-between gap-3">
              <a
                href={repo.url}
                target="_blank"
                rel="noreferrer"
                className="font-display text-lg font-semibold text-text transition-colors hover:text-accent"
              >
                {repo.name} ↗
              </a>
              <span className="shrink-0 rounded-full border border-[var(--border)] px-2.5 py-0.5 font-mono text-[10px] text-text-muted">
                {repo.lang}
              </span>
            </div>
            <p className="text-sm leading-[1.65] text-text-muted">{repo.desc}</p>
            {repo.pubdev && (
              <a
                href={repo.pubdev}
                target="_blank"
                rel="noreferrer"
                className="w-fit text-xs text-accent underline decoration-accent/40 underline-offset-4 transition-colors hover:decoration-accent"
              >
                Published on pub.dev ↗
              </a>
            )}
            <div className="mt-auto flex items-center gap-3 pt-1 font-mono text-[11px] text-text-muted">
              {repo.stars > 0 && <span className="text-accent">★ {repo.stars}</span>}
              <span>{repo.pubdev ? 'Package + source' : 'Public repository'}</span>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
