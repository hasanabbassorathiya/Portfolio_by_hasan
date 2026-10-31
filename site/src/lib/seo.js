import { createContext, useContext } from 'react';

export const SeoContext = createContext(null);
export const SITE_URL = 'https://hasanabbassorathiya.tech';
export const SITE_NAME = 'Hasan Abbas Sorathiya';
const DEFAULT_TITLE = 'Hasan Abbas Sorathiya · Senior Software & AI Engineer';
const DEFAULT_DESCRIPTION =
  'Senior mobile & AI engineer in Dubai. Native iOS and Android, Flutter as my primary cross-platform stack, plus MERN full-stack, RAG and AI agents. Shipping production apps end to end.';

function upsertMeta(selector, attrs) {
  let el = document.head.querySelector(selector);
  if (!el) {
    el = document.createElement('meta');
    document.head.appendChild(el);
  }
  Object.entries(attrs).forEach(([k, v]) => el.setAttribute(k, v));
}

function upsertLink(rel, href) {
  let el = document.head.querySelector(`link[rel="${rel}"]`);
  if (!el) {
    el = document.createElement('link');
    el.setAttribute('rel', rel);
    document.head.appendChild(el);
  }
  el.setAttribute('href', href);
}

export function useSeo({
  title = DEFAULT_TITLE,
  description = DEFAULT_DESCRIPTION,
  path = '/',
  type = 'website',
  image = '/og.png',
  published,
  tags,
  noindex = false,
  jsonLd,
} = {}) {
  const collect = useContext(SeoContext);
  if (collect) collect({ title, description, path, type, image, published, tags, noindex, jsonLd });
  if (typeof document === 'undefined') return;
  const url = `${SITE_URL}${path}`;
  const socialImage = /^https?:\/\//i.test(image) ? image : `${SITE_URL}${image}`;
  document.title = title;

  upsertMeta('meta[name="description"]', { name: 'description', content: description });
  if (noindex) {
    upsertMeta('meta[name="robots"]', { name: 'robots', content: 'noindex, follow' });
  } else {
    document.head.querySelector('meta[name="robots"]')?.remove();
  }
  upsertLink('canonical', url);
  upsertMeta('meta[property="og:title"]', { property: 'og:title', content: title });
  upsertMeta('meta[property="og:description"]', { property: 'og:description', content: description });
  upsertMeta('meta[property="og:type"]', { property: 'og:type', content: type });
  upsertMeta('meta[property="og:url"]', { property: 'og:url', content: url });
  upsertMeta('meta[property="og:image"]', { property: 'og:image', content: socialImage });
  upsertMeta('meta[name="twitter:card"]', { name: 'twitter:card', content: 'summary_large_image' });
  upsertMeta('meta[name="twitter:title"]', { name: 'twitter:title', content: title });
  upsertMeta('meta[name="twitter:description"]', { name: 'twitter:description', content: description });
  upsertMeta('meta[name="twitter:image"]', { name: 'twitter:image', content: socialImage });
  if (published) {
    upsertMeta('meta[property="article:published_time"]', {
      property: 'article:published_time',
      content: published,
    });
  } else {
    document.head.querySelector('meta[property="article:published_time"]')?.remove();
  }
  document.head.querySelectorAll('meta[property="article:tag"]').forEach((n) => n.remove());
  if (tags?.length) {
    tags.forEach((tag) => {
      const el = document.createElement('meta');
      el.setAttribute('property', 'article:tag');
      el.setAttribute('content', tag);
      document.head.appendChild(el);
    });
  }

  const id = 'route-jsonld';
  document.head.querySelectorAll('script[type="application/ld+json"]').forEach((node) => node.remove());
  if (jsonLd) {
    const script = document.createElement('script');
    script.type = 'application/ld+json';
    script.id = id;
    script.textContent = JSON.stringify(jsonLd);
    document.head.appendChild(script);
  }
}

export const personJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'Person',
  '@id': `${SITE_URL}/#person`,
  name: SITE_NAME,
  jobTitle: 'Senior Software & AI Engineer',
  description: DEFAULT_DESCRIPTION,
  url: SITE_URL,
  image: `${SITE_URL}/hasan.png`,
  email: 'mailto:hasanabbassorathiya12@gmail.com',
  telephone: '+971589602320',
  address: { '@type': 'PostalAddress', addressLocality: 'Dubai', addressCountry: 'AE' },
  alumniOf: {
    '@type': 'CollegeOrUniversity',
    name: 'University of Mumbai',
  },
  hasCredential: [
    'Google Flutter Developer Certification',
    'AI & NLP Fundamentals Certification',
    'Advanced Android Development Certification',
    'Project Management Foundations (PMP)',
    'Digital Marketing Strategy Certification',
  ].map((name) => ({ '@type': 'EducationalOccupationalCredential', name })),
  knowsLanguage: ['English', 'Hindi', 'Gujarati', 'Urdu'],
  sameAs: [
    'https://www.linkedin.com/in/hasanabbassorathiya/',
    'https://github.com/hasanabbassorathiya',
    'https://www.instagram.com/hasanabbassorathiya',
    'https://play.google.com/store/apps/dev?id=5895887615343030170',
    'https://apps.apple.com/us/developer/hasan-abbas-sorathiya/id1734376366',
  ],
  knowsAbout: [
    'Flutter',
    'Dart',
    'Clean Architecture',
    'Riverpod',
    'AI Engineering',
    'RAG',
    'AI agents',
    'LangChain',
    'MCP',
    'MERN',
    'Node.js',
    'Firebase',
    'AWS',
  ],
};
