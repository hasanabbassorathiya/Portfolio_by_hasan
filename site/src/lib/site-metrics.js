import { useApps, useClients, useExperiences, useProfile } from './live-content';

const MONTHS = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
const PLATFORM_ORDER = ['iOS', 'Android', 'Web', 'Android TV'];

function parsePeriod(value) {
  const text = String(value ?? '');
  const numeric = text.match(/(\d{1,2})\/((?:19|20)\d{2})/);
  if (numeric) {
    const month = Number(numeric[1]);
    if (month >= 1 && month <= 12) return { year: Number(numeric[2]), month };
  }
  const named = text.match(/\b([A-Za-z]{3})[a-z]*\s+((?:19|20)\d{2})\b/);
  if (named) {
    const month = MONTHS.indexOf(named[1].toLowerCase()) + 1;
    if (month > 0) return { year: Number(named[2]), month };
  }
  const year = text.match(/\b(?:19|20)\d{2}\b/);
  return year ? { year: Number(year[0]), month: 1 } : null;
}

function earliestStart(experiences) {
  return experiences
    .map((role) => parsePeriod(role?.period))
    .filter(Boolean)
    .sort((a, b) => a.year - b.year || a.month - b.month)[0] ?? null;
}

function platformUnion(apps) {
  const seen = new Set();
  for (const app of apps) {
    for (const platform of Array.isArray(app?.platforms) ? app.platforms : []) {
      const name = String(platform || '').trim();
      if (name) seen.add(name);
    }
  }
  return [...seen].sort((a, b) => {
    const ia = PLATFORM_ORDER.indexOf(a);
    const ib = PLATFORM_ORDER.indexOf(b);
    if (ia === -1 && ib === -1) return a.localeCompare(b);
    if (ia === -1) return 1;
    if (ib === -1) return -1;
    return ia - ib;
  });
}

// Every public count comes from here: app rows, client rows, experience dates,
// and the profile kv store. Nothing on the site should restate these by hand.
export function computeMetrics({ apps = [], clients = [], experiences = [], profile = {} } = {}, now = new Date()) {
  const start = earliestStart(experiences);
  const years = start
    ? Math.max(0, now.getFullYear() - start.year - (now.getMonth() + 1 < start.month ? 1 : 0))
    : null;
  const platforms = platformUnion(apps);
  const usersReached = typeof profile.users_reached === 'string' ? profile.users_reached.trim() : '';

  const metrics = {
    years,
    yearsLabel: years === null ? '' : `${years}+`,
    appsCount: apps.length,
    clientsCount: clients.length,
    platforms,
    platformsLabel: platforms.join(' · '),
    users: usersReached,
    startYear: start?.year ?? null,
    rangeLabel: start ? `${start.year} — ${now.getFullYear()}` : '',
    clientMetrics: {},
    clientLabels: {},
  };

  for (const client of clients) {
    if (client?.slug && client.metric) metrics.clientMetrics[client.slug] = client.metric;
    if (client?.slug && client.metricLabel) metrics.clientLabels[client.slug] = client.metricLabel;
  }

  metrics.tokens = {
    years: metrics.yearsLabel,
    apps: String(metrics.appsCount),
    clients: String(metrics.clientsCount),
    platforms: metrics.platformsLabel,
    users: metrics.users,
  };

  return metrics;
}

export function useSiteMetrics() {
  const apps = useApps();
  const clients = useClients();
  const experiences = useExperiences();
  const profile = useProfile();
  return computeMetrics({ apps, clients, experiences, profile });
}

export function interpolate(text, metrics) {
  if (typeof text !== 'string') return text;
  return text.replace(/\{\{([a-z_]+)(?::([a-z0-9-]+))?(?:\|([^}]*))?\}\}/g, (match, key, slug, fallback) => {
    let value;
    if (key === 'client_metric' && slug) value = metrics.clientMetrics?.[slug];
    else if (key === 'client_label' && slug) value = metrics.clientLabels?.[slug];
    else value = metrics.tokens?.[key];
    if (value) return value;
    return fallback !== undefined ? fallback : match;
  });
}

export function tickerLine(metrics) {
  return [
    metrics.yearsLabel && `${metrics.yearsLabel} years`,
    `${metrics.appsCount} ${metrics.appsCount === 1 ? 'app' : 'apps'}`,
    metrics.users && `${metrics.users} users`,
  ]
    .filter(Boolean)
    .join(' · ');
}

export function platformLine(metrics) {
  return [`${metrics.appsCount} ${metrics.appsCount === 1 ? 'app' : 'apps'}`, metrics.platformsLabel]
    .filter(Boolean)
    .join(' · ');
}
