import React from 'react';
import { useReveal, useCountUp } from '../lib/motion';

const stats = [
  { label: 'Years shipping', value: 7, suffix: '+' },
  { label: 'Apps in production', value: 15, suffix: '' },
  { label: 'Users reached', value: 100, suffix: 'K+' },
  { label: 'Public repos', value: 52, suffix: '' },
];

function StatCell({ stat, index, onScreen }) {
  const value = useCountUp(stat.value, onScreen);
  return (
    <div className={`flex flex-col gap-2 px-6 py-10 ${index > 0 ? 'border-l border-[var(--border)]' : ''}`}>
      <span className="font-mono text-[clamp(1.8rem,4vw,3rem)] font-medium text-accent">
        {value}
        {stat.suffix}
      </span>
      <span className="text-sm text-text-muted">{stat.label}</span>
    </div>
  );
}

export function Stats() {
  const { ref, shown } = useReveal();
  return (
    <section className="border-y border-[var(--border)] bg-surface/40">
      <div ref={ref} className="mx-auto grid max-w-[1360px] grid-cols-2 md:grid-cols-4">
        {stats.map((stat, index) => (
          <StatCell key={stat.label} stat={stat} index={index} onScreen={shown} />
        ))}
      </div>
    </section>
  );
}
