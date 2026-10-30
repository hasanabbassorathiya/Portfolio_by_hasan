const token = (name) => `rgb(var(--${name}) / <alpha-value>)`;

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        canvas: token('canvas'),
        surface: token('surface'),
        deep: token('deep'),
        monogram: token('monogram'),
        accent: token('accent'),
        'accent-bright': token('accent-bright'),
        'accent-solid': token('accent-solid'),
        'on-accent': token('on-accent'),
        text: token('text'),
        'text-muted': token('text-muted'),
        ink: token('ink'),
        'ink-soft': token('ink-soft'),
        band: token('band'),
        'band-soft': token('band-soft'),
        'band-fg': token('band-fg'),
        'light-lav': token('light-lav'),
        'hl-a': token('hl-a'),
        'hl-b': token('hl-b'),
      },
      fontFamily: {
        display: ['Geist', 'sans-serif'],
        body: ['Geist', 'sans-serif'],
        mono: ['Geist Mono', 'monospace'],
        serif: ['Instrument Serif', 'serif'],
      },
    },
  },
  plugins: [],
};
