import cleanArch from './posts/clean-architecture-flutter-teams.md?raw';
import system from './posts/portfolio-as-a-system.md?raw';
import rag from './posts/rag-that-survives-real-users.md?raw';
import riverpod from './posts/riverpod-patterns-production.md?raw';
import aiTrust from './posts/shipping-ai-features-flutter-trust.md?raw';
import startup from './posts/flutter-startup-time.md?raw';
import localization from './posts/localization-4-6-star-app.md?raw';
import gde from './posts/from-shipping-apps-to-gde.md?raw';
import leadership from './posts/leading-mobile-delivery-ev.md?raw';
import bonsai from './posts/run-bonsai-2-27b-locally.md?raw';
import qwen4 from './posts/qwen4-max-preview-what-changes.md?raw';
import msOutage from './posts/microsoft-365-outage-dependency-lessons.md?raw';
import nvidia from './posts/nvidia-ceo-transition-what-it-means.md?raw';
import { readingTime, plainText } from '../lib/markdown';

const raw = [
  {
    slug: 'run-bonsai-2-27b-locally',
    title: 'Run a 27B model on your laptop: Bonsai 2, locally',
    dek: 'Prism ML’s ternary-quantized Bonsai 2 squeezes a 27.8B model into about 6 GB. The exact local setup — which quant to pick, the llama.cpp fork you need, and the commands that actually run it.',
    category: 'Local LLM',
    date: '2026-11-13',
    tags: ['Local LLM', 'AI', 'Tutorial'],
    body: bonsai,
  },
  {
    slug: 'qwen4-max-preview-what-changes',
    title: 'Qwen4-Max is in preview: what actually changes for builders',
    dek: 'Alibaba opened Qwen4-Max-Preview on Nov 11 — the first Qwen4 model, aimed at coding and agentic work, with a reported 1M-token context. What is confirmed, what is only reported, and how to evaluate it.',
    category: 'AI',
    date: '2026-11-13',
    tags: ['AI', 'LLM', 'Qwen'],
    body: qwen4,
  },
  {
    slug: 'microsoft-365-outage-dependency-lessons',
    title: 'What the Microsoft 365 outage teaches about single-vendor dependency',
    dek: 'On Nov 12–13, Outlook, Teams, Word and Excel went down worldwide — servers, not a cyberattack. If your product leans on one cloud, here is the resilience checklist I keep coming back to.',
    category: 'Reliability',
    date: '2026-11-13',
    tags: ['Reliability', 'Architecture', 'Build in public'],
    body: msOutage,
  },
  {
    slug: 'nvidia-ceo-transition-what-it-means',
    title: 'Nvidia’s CEO transition: what we know, and what builders should watch',
    dek: 'Jensen Huang resigned as Nvidia CEO on Nov 12, with Colette Kress interim. The confirmed timeline, what is still unexplained, and how to think about vendor risk if your stack runs on CUDA.',
    category: 'AI',
    date: '2026-11-13',
    tags: ['AI', 'Industry', 'Nvidia'],
    body: nvidia,
  },
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
