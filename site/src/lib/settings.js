import { useSyncExternalStore } from 'react';

// Public settings (GA4 id, Discord invite, contact email…) shared by runtime UI.
const listeners = new Set();
const state = { values: {}, loaded: false };
let started = false;

function emit() {
  listeners.forEach((listener) => listener());
}

function subscribe(listener) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function loadSettings() {
  if (started || typeof window === 'undefined') return;
  started = true;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 5000);
  fetch('/api/index.php?entity=settings', {
    signal: controller.signal,
    headers: { Accept: 'application/json' },
  })
    .then((res) => (res.ok ? res.json() : Promise.reject(new Error(String(res.status)))))
    .then((payload) => {
      if (payload && typeof payload.data === 'object' && !Array.isArray(payload.data)) {
        state.values = payload.data;
      }
      state.loaded = true;
    })
    .catch(() => {
      state.loaded = true;
    })
    .finally(() => {
      clearTimeout(timer);
      emit();
    });
}

const snapshot = () => state.values;

export function useSettings() {
  return useSyncExternalStore(subscribe, snapshot, snapshot);
}
