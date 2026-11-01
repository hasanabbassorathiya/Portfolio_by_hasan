import React from 'react';

export function appInitials(name) {
  return String(name ?? '')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((word) => word[0])
    .join('')
    .toUpperCase() || '?';
}

export function AppIcon({ app, className = '', textClassName = 'text-[0.9em]', label, loading = 'lazy' }) {
  if (app?.icon) {
    return <img src={app.icon} alt={label ?? ''} loading={loading} className={className} />;
  }
  return (
    <span
      role={label ? 'img' : undefined}
      aria-label={label}
      aria-hidden={label ? undefined : 'true'}
      className={`flex shrink-0 items-center justify-center bg-[#f7f3e9] font-serif tracking-[-0.02em] text-[#2a241c] ${className}`}
    >
      <span className={textClassName}>{appInitials(app?.name)}</span>
    </span>
  );
}
