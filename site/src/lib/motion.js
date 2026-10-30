import { useEffect, useRef, useState } from 'react';

// Scroll-reveal + count-up, transform/opacity only (DESIGN.md motion rules).
export function useReveal(delay = 0) {
  const ref = useRef(null);
  const [shown, setShown] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const reducedMotion =
      typeof window.matchMedia === 'function' &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reducedMotion || typeof IntersectionObserver === 'undefined') {
      setShown(true);
      return;
    }
    const inView = () => {
      const r = el.getBoundingClientRect();
      return r.top < window.innerHeight && r.bottom > 0;
    };
    // Throttled/background tabs can delay IO callbacks; reveal anything
    // already on screen immediately so above-the-fold content never sticks.
    if (inView()) setShown(true);
    const io = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting) {
          setShown(true);
          io.disconnect();
        }
      },
      { threshold: 0.15, rootMargin: '0px 0px -40px 0px' }
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);

  const style = {
    opacity: shown ? 1 : 0,
    transform: shown ? 'none' : 'translateY(16px)',
    transition: `opacity .7s ease ${delay}ms, transform .7s ease ${delay}ms`,
  };
  return { ref, style, shown };
}

// Springy count-up for the stats bar.
export function useCountUp(target, run, duration = 1200) {
  const [val, setVal] = useState(0);
  useEffect(() => {
    if (!run) return;
    if (
      typeof window.matchMedia === 'function' &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches
    ) {
      setVal(target);
      return;
    }
    let raf;
    const start = performance.now();
    const tick = (now) => {
      const p = Math.min((now - start) / duration, 1);
      setVal(Math.round(target * (1 - Math.pow(1 - p, 3))));
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [run, target, duration]);
  return val;
}