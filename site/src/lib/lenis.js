import Lenis from 'lenis';

let lenis = null;

export function initSmoothScroll() {
  if (typeof window === 'undefined' || lenis) return lenis;
  if ('scrollRestoration' in window.history) window.history.scrollRestoration = 'manual';
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return null;

  lenis = new Lenis({
    lerp: 0.1,
    smoothWheel: true,
    wheelMultiplier: 1,
    touchMultiplier: 1.3,
    anchors: { offset: -84, duration: 1.1 },
  });

  const raf = (time) => {
    lenis?.raf(time);
    requestAnimationFrame(raf);
  };
  requestAnimationFrame(raf);
  return lenis;
}

export function scrollTo(target, options = {}) {
  if (lenis) {
    lenis.scrollTo(target, { duration: 1.1, ...options });
    return;
  }
  const behavior = window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth';
  if (typeof target === 'number') {
    window.scrollTo({ top: target, behavior });
    return;
  }
  const el = typeof target === 'string' ? document.querySelector(target) : target;
  el?.scrollIntoView({ behavior, block: 'start' });
}

export function stopScroll() {
  lenis?.stop();
}

export function startScroll() {
  lenis?.start();
}
