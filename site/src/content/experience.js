import { resume } from './resume';

// Timeline shown on the home and resume pages — overwritten at runtime by the
// CMS `experience` entity when rows exist.
export const experiences = resume.roles.map((role) => ({
  company: role.company,
  role: role.role,
  period: role.period,
  location: role.location,
  summary: role.summary,
  points: role.points,
}));

export const skillGroups = resume.skills.map((group) => ({
  label: group.label,
  items: group.items
    .split(' · ')
    .map((item) => item.trim())
    .filter(Boolean),
}));
