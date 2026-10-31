// Profile defaults — overwritten at runtime by the CMS `profile` entity.
export const profile = {
  name: 'Hasan Abbas Sorathiya',
  role: 'Senior Software & AI Engineer',
  kicker: 'Senior mobile & AI engineer · Dubai',
  availability: 'Available for new work',
  availability_detail: 'Immediate · remote-friendly',
  open_to: 'Open to senior roles · consulting · collaborations',
  // {{years}}, {{apps}}, {{users}}, {{clients}} and {{platforms}} resolve from live CMS data.
  users_reached: '100K+',
  sub:
    'Senior mobile and AI engineer in Dubai. {{years}} years, {{apps}} shipped apps, and {{users}} users ' +
    'across the UAE, Australia, and New Zealand — native iOS and Android, Flutter as my primary ' +
    'cross-platform stack, and the AI systems behind the product. Built to keep working after launch.',
  caption: 'iOS · Android · Flutter · AI',
  location: 'Dubai, UAE',
  phone: '+971 58 960 2320',
  email: 'hasanabbassorathiya12@gmail.com',
  linkedin: 'https://www.linkedin.com/in/hasanabbassorathiya/',
  github: 'https://github.com/hasanabbassorathiya',
  footnote: 'Ex-Chalhoub Group · Mobile Engineering Lead',
  education: 'BSc IT, University of Mumbai',
};

export const emailHref = (email) =>
  `mailto:${email}?subject=${encodeURIComponent("Let's work together")}`;
