const KEY = 'hs-theme';
const EVENT = 'hs-theme-change';

export function getTheme() {
  return typeof document !== 'undefined' && document.documentElement.dataset.theme === 'dark' ? 'dark' : 'light';
}

export function getStoredTheme() {
  try {
    return localStorage.getItem(KEY);
  } catch {
    return null;
  }
}

export function applyTheme(theme, { persist = false } = {}) {
  const root = document.documentElement;
  root.dataset.theme = theme;
  root.style.colorScheme = theme;
  const meta = document.querySelector('meta[name="theme-color"]');
  if (meta) meta.setAttribute('content', theme === 'dark' ? '#12100c' : '#f3efe6');
  if (persist) {
    try {
      localStorage.setItem(KEY, theme);
    } catch {
      /* storage can be blocked; theme still applies for this page view */
    }
  }
  window.dispatchEvent(new CustomEvent(EVENT, { detail: theme }));
}

export function setTheme(theme) {
  applyTheme(theme, { persist: true });
}

export function onThemeChange(handler) {
  const local = (event) => handler(event.detail);
  const storage = (event) => {
    if (event.key === KEY) applyTheme(event.newValue === 'dark' ? 'dark' : 'light');
  };
  window.addEventListener(EVENT, local);
  window.addEventListener('storage', storage);
  return () => {
    window.removeEventListener(EVENT, local);
    window.removeEventListener('storage', storage);
  };
}

export function initTheme() {
  if (getStoredTheme()) return undefined;
  const query = window.matchMedia('(prefers-color-scheme: dark)');
  const sync = (event) => {
    if (!getStoredTheme()) applyTheme(event.matches ? 'dark' : 'light');
  };
  query.addEventListener?.('change', sync);
  return () => query.removeEventListener?.('change', sync);
}
