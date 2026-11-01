import { formatDate } from '../content/posts';
import { readingTime, plainText } from './markdown';

// Row → view-model mappers shared by runtime hydration (live-content.jsx) and
// the optional live prerender (scripts/prerender-meta.mjs), so both paths
// produce identical objects.

export function decode(value, fallback) {
  if (value === null || value === undefined || value === '') return fallback;
  if (typeof value !== 'string') return value;
  try {
    return JSON.parse(value);
  } catch {
    return fallback;
  }
}

function seedFor(seeds, slug) {
  return Array.isArray(seeds) ? seeds.find((item) => item.slug === slug) : undefined;
}

export function mapApp(row, seed) {
  const ratingValue = Number(row.rating_value);
  return {
    ...seed,
    slug: row.slug,
    name: row.name,
    tagline: row.tagline ?? seed?.tagline ?? '',
    role: row.role ?? '',
    year: row.year ?? '',
    platforms: decode(row.platforms, []),
    genre: row.genre ?? '',
    icon: row.icon || seed?.icon || '',
    screenshots: decode(row.screenshots, seed?.screenshots ?? []),
    rating: ratingValue > 0
      ? {
          value: ratingValue,
          count: Number(row.rating_count) || 0,
          source: seed?.rating?.source,
          noun: seed?.rating?.noun,
        }
      : undefined,
    stack: decode(row.stack, []),
    links: { ...(seed?.links ?? {}), ...decode(row.links, {}) },
    summary: row.summary ?? '',
    features: decode(row.features, []),
    story: row.story ?? '',
    metrics: decode(row.metrics, []),
    seo: {
      title: row.seo_title || '',
      description: row.seo_description || '',
      image: row.seo_image || '',
      noindex: Number(row.noindex) === 1,
    },
    aso: {
      subtitle: row.aso_subtitle || '',
      keywords: row.aso_keywords || '',
      category: row.aso_category || '',
      ageRating: row.aso_age_rating || '',
      promoText: row.aso_promo_text || '',
    },
  };
}

export function mapClient(row, seed) {
  return {
    ...seed,
    slug: row.slug,
    name: row.name,
    kicker: row.kicker ?? '',
    type: row.type ?? '',
    role: row.role ?? '',
    dates: row.period ?? seed?.dates ?? '',
    location: row.location ?? '',
    website: row.website ?? '',
    logo: row.logo || seed?.logo || '',
    metric: row.metric ?? '',
    metricLabel: row.metric_label ?? '',
    summary: row.summary ?? '',
    challenge: row.challenge ?? '',
    did: decode(row.what_i_did, []),
    outcome: row.outcome ?? '',
    stack: decode(row.stack, []),
    facts: decode(row.facts, []),
    links: {
      website: row.website || seed?.links?.website,
      store: row.store_url || seed?.links?.store,
    },
    seo: {
      title: row.seo_title || '',
      description: row.seo_description || '',
      image: row.seo_image || '',
      noindex: Number(row.noindex) === 1,
    },
  };
}

export function mapPost(row, seed) {
  const body = row.body ?? '';
  const date = String(row.post_date ?? '').slice(0, 10);
  return {
    ...seed,
    slug: row.slug,
    title: row.title,
    dek: row.dek ?? '',
    category: row.category ?? '',
    date,
    tags: decode(row.tags, []),
    body,
    featured: seed?.featured ?? false,
    minutes: Number(row.minutes) > 0 ? Number(row.minutes) : readingTime(body),
    excerpt: `${plainText(body).slice(0, 180).trim()}…`,
    dateLabel: date ? formatDate(date) : '',
    seo: {
      title: row.seo_title || '',
      description: row.seo_description || '',
      image: row.seo_image || '',
      noindex: Number(row.noindex) === 1,
    },
  };
}

export const mapApps = (rows, seeds) => rows.map((row) => mapApp(row, seedFor(seeds, row.slug)));
export const mapClients = (rows, seeds) => rows.map((row) => mapClient(row, seedFor(seeds, row.slug)));
export const mapPosts = (rows, seeds) =>
  rows
    .map((row) => mapPost(row, seedFor(seeds, row.slug)))
    .sort((a, b) => b.date.localeCompare(a.date));

export function mapExperience(row) {
  const points = decode(row.points, []);
  return {
    company: row.company,
    role: row.position,
    period: row.period,
    location: row.location ?? '',
    summary: row.summary || row.highlight || '',
    points: Array.isArray(points) && points.length ? points : row.highlight ? [row.highlight] : [],
  };
}

export const mapExperiences = (rows) => rows.map(mapExperience);

export function groupSkills(rows) {
  const groups = new Map();
  for (const row of rows) {
    if (!row || typeof row.grp !== 'string' || typeof row.name !== 'string') continue;
    if (!groups.has(row.grp)) groups.set(row.grp, []);
    groups.get(row.grp).push(row.name);
  }
  return [...groups.entries()].map(([label, items]) => ({ label, items }));
}

export function mapProfile(rows) {
  const profile = {};
  for (const row of rows) {
    if (!row || typeof row.k !== 'string' || typeof row.v !== 'string') continue;
    if (row.v === '') continue;
    profile[row.k] = row.v;
  }
  return profile;
}
