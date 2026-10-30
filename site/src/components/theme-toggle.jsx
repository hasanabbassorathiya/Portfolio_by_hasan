import React, { useSyncExternalStore } from 'react';
import { getTheme, setTheme, onThemeChange } from '../lib/theme';

const subscribe = (callback) => onThemeChange(callback);
const getServerSnapshot = () => 'light';

export function ThemeToggle({ className = '' }) {
  const theme = useSyncExternalStore(subscribe, getTheme, getServerSnapshot);
  const isDark = theme === 'dark';
  const next = isDark ? 'light' : 'dark';

  return (
    <button
      type="button"
      onClick={() => setTheme(next)}
      aria-label={`Switch to ${next} theme`}
      aria-pressed={isDark}
      title={`Switch to ${next} theme`}
      className={`relative flex h-10 w-10 shrink-0 items-center justify-center overflow-hidden rounded-full border border-ink/15 text-text transition-colors duration-300 hover:border-ink/30 ${className}`}
    >
      <svg
        aria-hidden="true"
        viewBox="0 0 20 20"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.2"
        strokeLinecap="round"
        className={`absolute h-[17px] w-[17px] transition-all duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] ${
          isDark ? 'rotate-90 scale-50 opacity-0' : 'rotate-0 scale-100 opacity-100'
        }`}
      >
        <circle cx="10" cy="10" r="3.4" />
        <path d="M10 2.4v1.4M10 16.2v1.4M2.4 10h1.4M16.2 10h1.4M4.6 4.6l1 1M14.4 14.4l1 1M15.4 4.6l-1 1M5.6 14.4l-1 1" />
      </svg>
      <svg
        aria-hidden="true"
        viewBox="0 0 20 20"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.2"
        strokeLinecap="round"
        strokeLinejoin="round"
        className={`absolute h-[17px] w-[17px] transition-all duration-500 ease-[cubic-bezier(0.22,1,0.36,1)] ${
          isDark ? 'rotate-0 scale-100 opacity-100' : '-rotate-90 scale-50 opacity-0'
        }`}
      >
        <path d="M16.2 12.4A6.6 6.6 0 0 1 7.6 3.8a6.9 6.9 0 1 0 8.6 8.6Z" />
      </svg>
    </button>
  );
}
