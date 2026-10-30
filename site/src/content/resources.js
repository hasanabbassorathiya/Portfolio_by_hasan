export const featuredPackage = {
  name: 'stoolap_flutter',
  tag: 'Packages & code',
  description:
    'A pure-Rust embedded SQL database for Flutter with native vector search, MVCC transactions, and reactive streams. The bindings are published as a Dart package so an app can carry its database instead of depending on a hosted service.',
  install: 'flutter pub add stoolap_flutter',
  pubdev: 'https://pub.dev/packages/stoolap_flutter',
  repo: 'https://github.com/hasanabbassorathiya/stoolap-flutter',
  points: ['Vector search for on-device retrieval', 'MVCC transactions', 'Reactive streams for UI updates'],
};

export const resourceGroups = [
  {
    title: 'Packages & code',
    copy: 'Public work you can install, read, or fork. Repository names link to source; packages link to their registry listing.',
    items: [
      {
        name: 'stoolap_flutter',
        detail: 'Embedded SQL with vector search for Flutter apps.',
        href: 'https://pub.dev/packages/stoolap_flutter',
        label: 'pub.dev',
        external: true,
      },
      {
        name: 'wp-mcp-server',
        detail: 'MCP server for the WordPress REST API.',
        href: 'https://github.com/hasanabbassorathiya/wp-mcp-server',
        label: 'GitHub',
        external: true,
      },
      {
        name: 'BULBVPN',
        detail: 'Flutter VPN for networks where connectivity is restricted.',
        href: 'https://github.com/hasanabbassorathiya/BULBVPN',
        label: 'GitHub',
        external: true,
      },
      {
        name: 'claude-skills',
        detail: 'Claude Code skills and environment setup used for product work.',
        href: 'https://github.com/hasanabbassorathiya/claude-skills',
        label: 'GitHub',
        external: true,
      },
    ],
  },
  {
    title: 'Reading',
    copy: 'Essays written from production work — the problem, what changed, and what I would do differently.',
    items: [
      {
        name: 'Flutter startup time: what actually moves the needle',
        detail: 'Where the milliseconds go before the first frame.',
        href: '/blog/flutter-startup-time',
        label: 'Essay',
      },
      {
        name: 'RAG that survives real users',
        detail: 'Retrieval quality, failure modes, and operating a pipeline after launch.',
        href: '/blog/rag-that-survives-real-users',
        label: 'Essay',
      },
      {
        name: 'Clean Architecture that survives team changes',
        detail: 'Boundaries that still make sense when the team grows.',
        href: '/blog/clean-architecture-flutter-teams',
        label: 'Essay',
      },
      {
        name: 'Shipping AI features in a Flutter app without breaking trust',
        detail: 'Designing AI-assisted flows users can inspect and correct.',
        href: '/blog/shipping-ai-features-flutter-trust',
        label: 'Essay',
      },
    ],
  },
  {
    title: 'Working together',
    copy: 'How to scope mobile, AI, and full-stack work with me — as a new build, an embedded engineer, or a specialist review.',
    items: [
      {
        name: 'Services overview',
        detail: 'Six ways projects usually start.',
        href: '/services',
        label: 'Services',
      },
      {
        name: 'Flutter app development',
        detail: 'From a first release to production ownership.',
        href: '/services/flutter-app-development',
        label: 'Service',
      },
      {
        name: 'App audits & specialist consulting',
        detail: 'A second opinion on architecture, delivery, and release risk.',
        href: '/services/app-audit-consulting',
        label: 'Service',
      },
      {
        name: 'Start a conversation',
        detail: 'Describe the product, the constraint, and the deadline.',
        href: '/#contact',
        label: 'Contact',
      },
    ],
  },
];

// Add commercial entries only with the real referral URL plus a visible disclosure.
export const partners = [];

export const affiliateDisclosure =
  'Some links in this section are referral links. If you buy through them I may earn a commission at no extra cost to you. I only list tools I use and would recommend without the referral.';
