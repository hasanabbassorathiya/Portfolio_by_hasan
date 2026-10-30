import React from 'react';
import { useReveal } from '../lib/motion';
import { useSkillGroups } from '../lib/live-content';

export function Skills() {
  const groups = useSkillGroups();
  const { ref, style } = useReveal(0);
  return (
    <section ref={ref} style={style} className="mx-auto max-w-[1360px] px-[clamp(1.25rem,5vw,4rem)] pb-[clamp(3rem,8vw,6rem)]">
      <p className="mb-3 font-mono text-xs uppercase tracking-[0.25em] text-accent">Toolkit</p>
      <h2 className="mb-10 font-display text-[clamp(1.8rem,4vw,3rem)] tracking-[-0.02em]">
        The craft <em className="font-serif font-normal italic text-accent">stack</em>
      </h2>
      <div className="flex flex-col">
        {groups.map((group) => (
          <div key={group.label} className="flex flex-col gap-3 border-t border-[var(--border)] py-6 sm:flex-row sm:gap-8">
            <span className="shrink-0 pt-1 font-mono text-xs uppercase tracking-[0.18em] text-accent sm:w-44">
              {group.label}
            </span>
            <p className="font-mono text-sm leading-[2] text-text">
              {group.items.map((item, index) => (
                <span key={item}>
                  {item}
                  {index < group.items.length - 1 && <span className="text-accent/40"> · </span>}
                </span>
              ))}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
