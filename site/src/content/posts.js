import cleanArch from './posts/clean-architecture-flutter-teams.md?raw';
import system from './posts/portfolio-as-a-system.md?raw';
import rag from './posts/rag-that-survives-real-users.md?raw';
import riverpod from './posts/riverpod-patterns-production.md?raw';
import aiTrust from './posts/shipping-ai-features-flutter-trust.md?raw';
import startup from './posts/flutter-startup-time.md?raw';
import localization from './posts/localization-4-6-star-app.md?raw';
import gde from './posts/from-shipping-apps-to-gde.md?raw';
import leadership from './posts/leading-mobile-delivery-ev.md?raw';
import { readingTime, plainText } from '../lib/markdown';

const raw = [
  {
    slug: 'portfolio-as-a-system',
    title: 'Why I rebuilt my portfolio as a system, not a page',
    dek: 'One canonical profile, content as data, prerendered metadata, and audits that gate a deploy — the boring structure that keeps a portfolio true as it grows.',
    category: 'Build in public',
    date: '2026-10-28',
    tags: ['Build in public', 'Web', 'Architecture'],
    body: system,
  },
  {
    slug: 'rag-that-survives-real-users',
    title: 'RAG that survives real users',
    dek: 'Chunking by structure, hybrid retrieval, reranking, validated citations, and the operations work that keeps an AI answer trustworthy after launch.',
    category: 'AI',
    date: '2026-10-28',
    tags: ['AI', 'RAG', 'Architecture'],
    body: rag,
  },
  {
    slug: 'clean-architecture-flutter-teams',
    title: 'Clean Architecture that survives team changes',
    dek: 'Most Flutter architectures are diagrams. This is the version I ship: feature-first boundaries, typed failures, and tests that protect the seams.',
    category: 'Flutter',
    date: '2026-10-21',
    tags: ['Flutter', 'Architecture', 'Testing'],
    featured: true,
    body: cleanArch,
  },
  {
    slug: 'riverpod-patterns-production',
    title: 'Riverpod patterns I use in production — and three I avoid',
    dek: 'Six patterns that survived real apps, from AsyncNotifier screen state to route-scoped providers, plus the habits that quietly make Riverpod codebases hard to change.',
    category: 'Flutter',
    date: '2026-10-07',
    tags: ['Flutter', 'Riverpod', 'Architecture'],
    body: riverpod,
  },
  {
    slug: 'shipping-ai-features-flutter-trust',
    title: 'Shipping AI features in a Flutter app without breaking trust',
    dek: 'Latency budgets, streaming, citations, prompt versioning, and failure states — the unglamorous work that makes an AI feature safe to ship.',
    category: 'AI',
    date: '2026-09-24',
    tags: ['AI', 'Flutter', 'Product'],
    body: aiTrust,
  },
  {
    slug: 'flutter-startup-time',
    title: 'Flutter startup time: what actually moves the needle',
    dek: 'A practical process for measuring cold start, cutting the main() budget, and avoiding the optimizations that do not survive a release build.',
    category: 'Performance',
    date: '2026-09-10',
    tags: ['Flutter', 'Performance', 'DevTools'],
    body: startup,
  },
  {
    slug: 'localization-4-6-star-app',
    title: 'Localization lessons from a 4.6-star app',
    dek: 'What building a Gujarati-first app with five languages taught me about scripts, RTL, plurals, content operations, and store listings.',
    category: 'Build in public',
    date: '2026-08-27',
    tags: ['Localization', 'Flutter', 'Duas and Aamal'],
    body: localization,
  },
  {
    slug: 'from-shipping-apps-to-gde',
    title: 'From shipping apps to GDE: the work that actually compounds',
    dek: 'I am not a Google Developer Expert yet. This is the deliberate 12-month plan I am running — and the parts of public work that actually count.',
    category: 'Career',
    date: '2026-08-13',
    tags: ['Career', 'GDE', 'Community'],
    body: gde,
  },
  {
    slug: 'leading-mobile-delivery-ev',
    title: 'Three operating rules from leading mobile delivery at an EV company',
    dek: 'Release trains, a device matrix, and a written decision log — how mobile delivery changed shape when I stopped being the senior developer and became the lead.',
    category: 'Leadership',
    date: '2026-07-30',
    tags: ['Leadership', 'Mobile', 'Delivery'],
    body: leadership,
  },
];

export const formatDate = (iso) =>
  new Intl.DateTimeFormat('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    timeZone: 'UTC',
  }).format(new Date(iso));

export const posts = raw
  .map((post) => ({
    ...post,
    minutes: readingTime(post.body),
    excerpt: plainText(post.body).slice(0, 180).trim() + '…',
    dateLabel: formatDate(post.date),
  }))
  .sort((a, b) => b.date.localeCompare(a.date));

export const categories = ['All', ...Array.from(new Set(posts.map((p) => p.category)))];

export const featuredPost = posts.find((p) => p.featured) ?? posts[0];

export const getPost = (slug) => posts.find((p) => p.slug === slug);

export function getRelated(post, count = 2) {
  return posts
    .filter((p) => p.slug !== post.slug)
    .sort((a, b) => {
      const score = (p) => (p.category === post.category ? 2 : 0) + p.tags.filter((t) => post.tags.includes(t)).length;
      return score(b) - score(a);
    })
    .slice(0, count);
}

export function getAdjacent(post) {
  const index = posts.findIndex((p) => p.slug === post.slug);
  return {
    previous: posts[index + 1] ?? null,
    next: posts[index - 1] ?? null,
  };
}
