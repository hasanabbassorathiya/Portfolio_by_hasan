import React, { createContext, useContext, useEffect, useState } from 'react';
import { scrollTo } from './lenis';

const listeners = new Set();
const notify = () => listeners.forEach((fn) => fn());

const RouteContext = createContext(null);

const readRoute = () => ({
  path: typeof window === 'undefined' ? '/' : window.location.pathname.replace(/\/+$/, '') || '/',
  hash: typeof window === 'undefined' ? '' : window.location.hash,
});

export function navigate(to, { replace = false } = {}) {
  if (typeof window === 'undefined') return;
  const current = window.location.pathname + window.location.search + window.location.hash;
  if (to === current) {
    const target = document.getElementById(window.location.hash.slice(1));
    if (target) scrollTo(target, { offset: -84 });
    return;
  }
  window.history[replace ? 'replaceState' : 'pushState']({}, '', to);
  notify();
}

export function RouteProvider({ initialRoute, children }) {
  const [route, setRoute] = useState(() => initialRoute || readRoute());

  useEffect(() => {
    const update = () => setRoute(readRoute());
    listeners.add(update);
    window.addEventListener('popstate', update);
    return () => {
      listeners.delete(update);
      window.removeEventListener('popstate', update);
    };
  }, []);

  // A prerendered shell cannot know the URL fragment, so adopt it once hydrated.
  useEffect(() => {
    if (initialRoute && window.location.hash) setRoute(readRoute());
  }, [initialRoute]);

  return <RouteContext.Provider value={route}>{children}</RouteContext.Provider>;
}

export function useRoute() {
  const route = useContext(RouteContext);
  if (!route) throw new Error('useRoute must be used inside RouteProvider');
  return route;
}

export function matchRoute(path) {
  if (path === '/') return { page: 'home' };
  if (path === '/blog') return { page: 'blog' };
  if (path === '/apps') return { page: 'apps' };
  if (path === '/work') return { page: 'work' };
  if (path === '/services') return { page: 'services' };
  if (path === '/resources') return { page: 'resources' };
  if (path === '/community') return { page: 'community' };
  if (path === '/activity') return { page: 'activity' };
  if (path === '/resume') return { page: 'resume' };
  if (path === '/privacy') return { page: 'privacy' };
  const service = path.match(/^\/services\/([a-z0-9-]+)$/);
  if (service) return { page: 'service', slug: service[1] };
  const post = path.match(/^\/blog\/([a-z0-9-]+)$/);
  if (post) return { page: 'post', slug: post[1] };
  const app = path.match(/^\/apps\/([a-z0-9-]+)$/);
  if (app) return { page: 'app', slug: app[1] };
  const work = path.match(/^\/work\/([a-z0-9-]+)$/);
  if (work) return { page: 'case-study', slug: work[1] };
  return { page: '404' };
}

export function Link({ to, children, onClick, ...rest }) {
  const handle = (e) => {
    onClick?.(e);
    if (e.defaultPrevented) return;
    if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || e.button !== 0) return;
    e.preventDefault();
    navigate(to);
  };
  return (
    <a href={to} onClick={handle} {...rest}>
      {children}
    </a>
  );
}
