import React from 'react';
import { createRoot, hydrateRoot } from 'react-dom/client';
import { App } from './App';
import { loadPage } from './lib/pages';
import { matchRoute } from './lib/router';
import { initTheme } from './lib/theme';

initTheme();

function hideBootFrame() {
  const boot = document.getElementById('boot');
  if (!boot) return;
  const reducedMotion =
    typeof window.matchMedia === 'function' &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reducedMotion || sessionStorage.getItem('hs-boot-seen')) {
    boot.classList.add('hidden');
  } else {
    sessionStorage.setItem('hs-boot-seen', '1');
    requestAnimationFrame(() => {
      setTimeout(() => boot.classList.add('hidden'), 150);
    });
  }
}

const root = document.getElementById('root');
if (root) {
  const path = window.location.pathname.replace(/\/+$/, '') || '/';
  const initialRoute = { path, hash: '' };
  loadPage(matchRoute(path)).then((initialPage) => {
    const app = React.createElement(App, { initialRoute, initialPage });
    // Only adopt server markup rendered for this exact route: CMS slugs and
    // unknown paths reuse other shells, and hydrating those would mismatch.
    if (root.firstElementChild && root.dataset.route === path) {
      hydrateRoot(root, app);
    } else {
      root.textContent = '';
      createRoot(root).render(app);
    }
    hideBootFrame();
  });
}
