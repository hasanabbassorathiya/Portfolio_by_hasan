import React, { Suspense, useEffect, useRef } from 'react';
import './index.css';
import { initAnalytics, trackPageView } from './lib/analytics';
import { initSmoothScroll, scrollTo } from './lib/lenis';
import { loadLiveContent } from './lib/live-content';
import { loadSettings } from './lib/settings';
import { lazyPage } from './lib/pages';
import { RouteProvider, useRoute, matchRoute } from './lib/router';
import { SiteHeader } from './components/site-header';
import { SiteFooter } from './components/site-footer';
import { HireEgg } from './components/hire-egg';
import { HomePage } from './pages/home';
import { NotFoundPage } from './pages/not-found';

const BlogPage = lazyPage('blog');
const PostPage = lazyPage('post');
const AppsPage = lazyPage('apps');
const AppPage = lazyPage('app');
const WorkPage = lazyPage('work');
const CaseStudyPage = lazyPage('case-study');
const ServicesPage = lazyPage('services');
const ServicePage = lazyPage('service');
const ResourcesPage = lazyPage('resources');
const CommunityPage = lazyPage('community');
const ActivityPage = lazyPage('activity');
const ResumePage = lazyPage('resume');
const PrivacyPage = lazyPage('privacy');

export function App({ initialRoute, initialPage }) {
  return (
    <RouteProvider initialRoute={initialRoute}>
      <AppBody initialPage={initialPage} initialPath={initialRoute?.path} />
    </RouteProvider>
  );
}

function AppBody({ initialPage, initialPath }) {
  const route = useRoute();
  const matched = matchRoute(route.path);

  useEffect(() => {
    initAnalytics();
    initSmoothScroll();
    loadLiveContent();
    loadSettings();
  }, []);

  // The first path is covered by gtag's config page_view; only client-side changes are sent.
  // Lazy pages set document.title in their own effect, so the event waits a tick for it.
  const seenPath = useRef(null);
  const pageViewTimer = useRef(null);
  useEffect(() => {
    if (seenPath.current === null) {
      seenPath.current = route.path;
      return undefined;
    }
    if (seenPath.current === route.path) return undefined;
    seenPath.current = route.path;
    clearTimeout(pageViewTimer.current);
    pageViewTimer.current = setTimeout(() => trackPageView(route.path), 250);
    return () => clearTimeout(pageViewTimer.current);
  }, [route.path]);

  useEffect(() => {
    const anchor = route.hash ? route.hash.slice(1) : matched.anchor;
    if (matched.page === 'home' && anchor) {
      const timer = setTimeout(() => {
        const el = document.getElementById(anchor);
        if (el) scrollTo(el, { offset: -84 });
      }, 80);
      return () => clearTimeout(timer);
    }
    scrollTo(0, { immediate: true });
    return undefined;
  }, [route.path, route.hash, matched.page, matched.anchor]);

  let page;
  if (initialPage && route.path === initialPath) page = initialPage;
  else if (matched.page === 'home') page = <HomePage />;
  else if (matched.page === 'blog') page = <BlogPage />;
  else if (matched.page === 'post') page = <PostPage slug={matched.slug} />;
  else if (matched.page === 'apps') page = <AppsPage />;
  else if (matched.page === 'app') page = <AppPage slug={matched.slug} />;
  else if (matched.page === 'work') page = <WorkPage />;
  else if (matched.page === 'case-study') page = <CaseStudyPage slug={matched.slug} />;
  else if (matched.page === 'services') page = <ServicesPage />;
  else if (matched.page === 'service') page = <ServicePage slug={matched.slug} />;
  else if (matched.page === 'resources') page = <ResourcesPage />;
  else if (matched.page === 'community') page = <CommunityPage />;
  else if (matched.page === 'activity') page = <ActivityPage />;
  else if (matched.page === 'resume') page = <ResumePage />;
  else if (matched.page === 'privacy') page = <PrivacyPage />;
  else page = <NotFoundPage />;

  return (
    <>
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-50 focus:rounded-lg focus:bg-accent-solid focus:px-4 focus:py-2 focus:text-on-accent print:hidden"
      >
        Skip to content
      </a>
      <SiteHeader />
      <Suspense fallback={<div className="min-h-[70vh]" aria-busy="true" />}>
        <div id="main" tabIndex={-1} className="outline-none">{page}</div>
      </Suspense>
      <SiteFooter />
      <HireEgg />
    </>
  );
}
