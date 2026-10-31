// Analytics bootstrap. Two sinks, one gate:
// - first-party beacon → /api/track.php (always on unless DNT/GPC)
// - GA4 → deferred gtag, only when an ID is configured (build env or CMS settings)
// Nothing here may compete with LCP: GA loads on idle, the beacon is fire-and-forget.
const GA_ID = import.meta.env.VITE_GA4_ID;
const TRACK_URL = '/api/track.php';
const SESSION_KEY = 'hs-session';

let ready = false;
let gaReady = false;
let fpReady = false;
let session = '';
let lastPath = '/';
let enteredAt = 0;
let utm = {};
let hiddenSent = false;

function blockedByConsent() {
  if (typeof navigator === 'undefined') return true;
  return navigator.doNotTrack === '1' || window.doNotTrack === '1' || navigator.globalPrivacyControl === true;
}

function randomId() {
  const bytes = new Uint8Array(16);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (byte) => byte.toString(16).padStart(2, '0')).join('');
}

function sessionId() {
  try {
    const stored = sessionStorage.getItem(SESSION_KEY);
    if (stored && /^[a-f0-9]{32}$/.test(stored)) return stored;
    const created = randomId();
    sessionStorage.setItem(SESSION_KEY, created);
    return created;
  } catch {
    return randomId();
  }
}

function readUtm() {
  const params = new URLSearchParams(window.location.search);
  const values = {};
  for (const key of ['source', 'medium', 'campaign', 'term', 'content']) {
    const value = params.get(`utm_${key}`);
    if (value) values[key] = value.slice(0, 80);
  }
  return values;
}

function externalReferrer() {
  if (!document.referrer) return '';
  try {
    const host = new URL(document.referrer).hostname;
    return host === window.location.hostname ? '' : host;
  } catch {
    return '';
  }
}

function sendEvent(event, props = {}) {
  if (!fpReady) return;
  const payload = JSON.stringify({
    event,
    path: lastPath,
    session,
    referrer: externalReferrer(),
    utm: Object.keys(utm).length ? utm : undefined,
    props,
  });
  try {
    if (navigator.sendBeacon) {
      navigator.sendBeacon(TRACK_URL, new Blob([payload], { type: 'application/json' }));
      return;
    }
  } catch {
    // fall through to fetch
  }
  fetch(TRACK_URL, {
    method: 'POST',
    keepalive: true,
    headers: { 'Content-Type': 'application/json' },
    body: payload,
  }).catch(() => {});
}

function bootGa(id) {
  if (gaReady || !id || typeof window === 'undefined') return;
  gaReady = true;

  const w = window;
  w.dataLayer = w.dataLayer || [];
  w.gtag = function gtag() { w.dataLayer.push(arguments); };
  w.gtag('js', new Date());
  w.gtag('config', id, { anonymize_ip: true });

  const append = () => {
    if (document.getElementById('gtag-main')) return;
    const s = document.createElement('script');
    s.id = 'gtag-main';
    s.async = true;
    s.src = `https://www.googletagmanager.com/gtag/js?id=${id}`;
    document.head.appendChild(s);
  };
  if ('requestIdleCallback' in w) w.requestIdleCallback(append, { timeout: 4000 });
  else setTimeout(append, 2000);
}

async function loadSettings() {
  try {
    const res = await fetch('/api/index.php?entity=settings', { headers: { Accept: 'application/json' } });
    if (!res.ok) return {};
    const payload = await res.json();
    return payload && typeof payload.data === 'object' && !Array.isArray(payload.data) ? payload.data : {};
  } catch {
    return {};
  }
}

export function initAnalytics() {
  if (ready || typeof window === 'undefined') return;
  ready = true;
  if (blockedByConsent()) return;

  fpReady = true;
  session = sessionId();
  utm = readUtm();
  lastPath = window.location.pathname;
  enteredAt = Date.now();
  sendEvent('page_view', { title: document.title });

  const leave = () => {
    if (document.visibilityState !== 'hidden' || hiddenSent) return;
    hiddenSent = true;
    sendEvent('page_leave', { dwell_ms: Date.now() - enteredAt });
  };
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') hiddenSent = false;
    leave();
  });
  window.addEventListener('pagehide', leave);

  // Runtime settings win over the build-time ID so GA4 can be switched on
  // without a rebuild; the env var remains the offline fallback.
  loadSettings().then((settings) => bootGa(settings.ga4_id || GA_ID));
}

export function track(event, params = {}) {
  if (typeof window === 'undefined') return;
  if (gaReady) window.gtag('event', event, params);
  sendEvent(event, params);
}

// SPA route changes are invisible to GA4's automatic page_view; send one per path.
export function trackPageView(path) {
  if (typeof window === 'undefined') return;
  if (fpReady) {
    sendEvent('page_leave', { dwell_ms: Date.now() - enteredAt });
    hiddenSent = false;
  }
  lastPath = path;
  enteredAt = Date.now();
  if (gaReady) {
    window.gtag('event', 'page_view', {
      page_path: path,
      page_location: `${window.location.origin}${path}`,
      page_title: document.title,
    });
  }
  sendEvent('page_view', { title: document.title });
}

// Event hooks for the sections
export const trackOpen = (entity) => track('project_open', { entity });
export const trackCta = (kind, meta = '') => track('cta_click', { kind, meta });
export const trackSection = (name) => track('section_view', { section: name });
export const trackStore = (app, platform) => track('store_click', { app, platform });
export const trackOutbound = (label, href) => track('outbound_click', { label, href });
export const trackResume = (location) => track('resume_open', { location });
export const trackSubscribe = (source) => track('newsletter_signup', { source });
export const trackCommunity = (target) => track('community_join', { target });
// No name, email or message copy — only the selected enquiry type.
export const trackEnquiry = (type) => track('enquiry_submit', {
  type,
  category: type === 'Employment' ? 'recruitment' : type === 'Technical consultation' ? 'consulting' : 'project',
});
