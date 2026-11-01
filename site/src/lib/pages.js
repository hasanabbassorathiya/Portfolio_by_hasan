import { createElement, lazy } from 'react';
import { HomePage } from '../pages/home';
import { NotFoundPage } from '../pages/not-found';

const loaders = {
  home: async () => HomePage,
  '404': async () => NotFoundPage,
  blog: () => import('../pages/blog').then((m) => m.BlogPage),
  post: () => import('../pages/post').then((m) => m.PostPage),
  apps: () => import('../pages/apps').then((m) => m.AppsPage),
  app: () => import('../pages/app').then((m) => m.AppPage),
  work: () => import('../pages/work').then((m) => m.WorkPage),
  'case-study': () => import('../pages/case-study').then((m) => m.CaseStudyPage),
  services: () => import('../pages/services').then((m) => m.ServicesPage),
  service: () => import('../pages/service').then((m) => m.ServicePage),
  resources: () => import('../pages/resources').then((m) => m.ResourcesPage),
  community: () => import('../pages/community').then((m) => m.CommunityPage),
  activity: () => import('../pages/activity').then((m) => m.ActivityPage),
  resume: () => import('../pages/resume').then((m) => m.ResumePage),
  privacy: () => import('../pages/privacy').then((m) => m.PrivacyPage),
};

export const lazyPage = (name) =>
  lazy(() => loaders[name]().then((Component) => ({ default: Component })));

export async function loadPage(matched) {
  const load = loaders[matched.page] || loaders['404'];
  const Component = await load();
  return createElement(Component, matched.slug ? { slug: matched.slug } : {});
}
