// Profile defaults — overwritten at runtime by the CMS `profile` entity.
export const profile = {
  name: 'Hasan Abbas Sorathiya',
  role: 'Senior Software & AI Engineer',
  kicker: 'Senior mobile & AI engineer · Dubai',
  availability: 'Available for new work',
  availability_detail: 'Immediate · remote-friendly',
  open_to: 'Open to senior roles · consulting · collaborations',
  // Owner-confirmed figure; set explicitly so experience dates cannot round it up.
  experience_years: 6,
  // {{years}}, {{apps}}, {{clients}} and {{platforms}} resolve from live CMS data.
  sub:
    'Senior mobile and AI engineer in Dubai. {{years}} years across fintech, mobility, hospitality, ' +
    'and community products — Flutter as my primary stack, iOS and Android delivery, and the AI ' +
    'systems behind the product. Built to keep working after launch.',
  caption: 'iOS · Android · Flutter · AI',
  location: 'Dubai, UAE',
  phone: '+971 58 960 2320',
  email: 'hasanabbassorathiya12@gmail.com',
  linkedin: 'https://www.linkedin.com/in/hasanabbassorathiya/',
  github: 'https://github.com/hasanabbassorathiya',
  youtube: 'https://www.youtube.com/channel/UCSGwYKSUJb7sX4-BI12WB_Q',
  instagram: 'https://www.instagram.com/hasanabbassorathiya/',
  medium: 'https://hasanabbassorathiya.medium.com/',
  certificate: 'https://udemy-certificate.s3.amazonaws.com/pdf/UC-d1d229bb-81e1-46bf-b8cd-123655f406cc.pdf',
  footnote: 'Ex-Chalhoub Group · Mobile Engineering Lead',
  education: 'BSc IT, University of Mumbai',
};

export const emailHref = (email) =>
  `mailto:${email}?subject=${encodeURIComponent("Let's work together")}`;
