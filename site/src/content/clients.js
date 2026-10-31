export const clients = [
  {
    slug: 'evlab',
    name: 'EVLAB',
    kicker: 'Chalhoub Group · Mobility',
    type: 'Electric mobility platform',
    role: 'Mobile Engineering Lead',
    dates: '07/2023 — 01/2026',
    location: 'Dubai, UAE',
    website: 'https://www.ev-lab.io',
    logo: '/media/clients/evlab.png',
    metric: 'End-to-end',
    metricLabel: 'mobile ownership',
    summary:
      'An electric mobility platform for rentals, leasing, and marketplace — with mobile delivery owned end to end, from architecture to production support.',
    challenge:
      'EVLAB carries three business models at once — daily rentals, long-term leasing, and a marketplace — inside one product and one brand. The mobile apps had to serve all three without splitting into separate codebases, while meeting Chalhoub Group standards for security, release management, and production support.',
    did: [
      'Led mobile engineering for the EVLAB platform across iOS and Android.',
      'Architected Flutter apps on Clean Architecture with Riverpod, SOLID boundaries, and reusable components.',
      'Integrated secure REST APIs, authentication, cloud services, analytics, and third-party SDKs.',
      'Coordinated Mobile, Backend, Product, UX/UI, QA, DevOps, and business teams through delivery.',
      'Implemented Codemagic CI/CD, reducing manual release effort, and owned release management and production support.',
    ],
    outcome:
      'Mobile shipped as one platform instead of three parallel apps: shared architecture, shared components, and a release process the wider team could run. Ownership covered the full lifecycle — planning, development, testing, store releases, and production support — through the end of the engagement in January 2026.',
    decisions: [
      {
        title: 'One Flutter codebase for rentals, leasing and marketplace',
        rationale:
          'All three models share accounts, payments and authentication, so separate apps would have tripled release overhead and split the customer record. The product shipped as one app with modular boundaries instead.',
        tradeoff:
          'More feature-flag and navigation discipline up front, and a shared release train for every business unit.',
      },
      {
        title: 'Clean Architecture with Riverpod instead of a lighter state layer',
        rationale:
          'Chalhoub Group standards and a multi-team delivery expected testable domain logic, clear dependency boundaries and components other engineers could reuse.',
        tradeoff:
          'More structure than a small app needs, and onboarding has to explain the boundaries, not just the screens.',
      },
      {
        title: 'Owned CI/CD and release management, not a handoff',
        rationale:
          'Codemagic pipelines, store submission and production support stayed with mobile engineering, so release quality and incident response had one owner.',
        tradeoff:
          'Pipeline maintenance and on-call responsibility stayed on the mobile side as well.',
      },
    ],
    stack: ['Flutter', 'Dart', 'Clean Architecture', 'Riverpod', 'REST APIs', 'Codemagic', 'iOS', 'Android'],
    facts: [
      ['Engagement', 'Jul 2023 — Jan 2026'],
      ['Role', 'Mobile Engineering Lead'],
      ['Platforms', 'iOS · Android'],
      ['Based in', 'Dubai, UAE'],
    ],
    links: {
      website: 'https://www.ev-lab.io',
      store: 'https://apps.apple.com/app/id1635102548',
    },
  },
  {
    slug: 'good2go-loans',
    name: 'Good2Go Loans',
    kicker: 'Beedev Solutions · FinTech',
    type: 'Digital lending',
    role: 'Senior Flutter Developer',
    dates: '08/2019 — 03/2021',
    location: 'Australia · remote',
    website: 'https://www.goodtogoloans.com.au',
    logo: '/media/clients/good2go.png',
    metric: '50K+',
    metricLabel: 'users in New Zealand',
    summary:
      'A digital lending app used by 50,000+ people across New Zealand — onboarding, authentication, account journeys, and store releases owned end to end.',
    challenge:
      'Lending products earn trust in the first few minutes. Identity, eligibility, and account access have to be clear, fast, and correct on the phones people actually carry — and the app has to satisfy financial-product review on both stores, release after release.',
    did: [
      'Built onboarding, authentication, account journeys, notifications, and API integrations.',
      'Designed a scalable Flutter codebase on Clean Architecture and SOLID principles.',
      'Owned Android and iOS deployment, monitoring, and continuous improvement.',
      'Worked directly with the lending team on product changes and release requirements.',
    ],
    outcome:
      'The product reached 50,000+ users across New Zealand, and the architecture became the base the team kept extending rather than rewriting. Releases stayed predictable on both platforms for the life of the engagement.',
    decisions: [
      {
        title: 'Clean Architecture and SOLID boundaries from the first release',
        rationale:
          'Lending rules, eligibility checks and identity requirements change with regulation and product policy. Keeping domain logic away from UI code made those changes local instead of app-wide.',
        tradeoff:
          'More files and interfaces than a screen-first build, and the team had to agree on the boundaries.',
      },
      {
        title: 'Authentication and account access treated as core journeys',
        rationale:
          'Trust is won or lost in the first minutes of a lending product. Errors, retries and session expiry received as much design attention as the happy path.',
        tradeoff:
          'Closer coordination with backend and compliance, and slower iteration on those flows.',
      },
      {
        title: 'Own both store pipelines through production',
        rationale:
          'Shipping Android and iOS ourselves kept release timing and rollback decisions with the team that wrote the code.',
        tradeoff:
          'Release engineering and store review work never sat with QA or a separate release team.',
      },
    ],
    stack: ['Flutter', 'Dart', 'Clean Architecture', 'SOLID', 'REST APIs', 'Push notifications', 'iOS', 'Android'],
    facts: [
      ['Engagement', 'Aug 2019 — Mar 2021'],
      ['Role', 'Senior Flutter Developer'],
      ['Reach', '50,000+ users'],
      ['Market', 'New Zealand'],
    ],
    links: {
      website: 'https://www.goodtogoloans.com.au',
      store: 'https://apps.apple.com/app/id1542316639',
    },
  },
  {
    slug: 'nakheel-marinas',
    name: 'Nakheel Marinas',
    kicker: 'Belong Interactive · Hospitality',
    type: 'Marina & lifestyle',
    role: 'Lead Senior Software Engineer (Mobile)',
    dates: '08/2022 — 06/2023',
    location: 'Dubai, UAE',
    website: 'https://www.nakheelmarinas.com',
    logo: '/media/clients/nakheel.png',
    metric: '15K+',
    metricLabel: 'first-month downloads',
    summary:
      'A marina and lifestyle app shipped with a Flutter team under a fixed release train — 15,000+ downloads in its first month.',
    challenge:
      'Hospitality apps ship against deadlines that do not move: a season opens, a marina is announced, a campaign goes live. The build needed a team of Flutter engineers working to one architecture and one standard, with authentication, notifications, analytics, and third-party services integrated on schedule.',
    did: [
      'Led the Flutter team on architecture, standards, code review, and production delivery.',
      'Ran sprint planning, task breakdown, estimation, and delivery coordination.',
      'Integrated REST APIs, authentication, analytics, notifications, and third-party services.',
      'Shipped the app on the fixed release train and supported it in production.',
    ],
    outcome:
      'The app launched to 15,000+ downloads in its first month and gave the Belong Interactive team a delivery pattern for the hospitality apps that followed.',
    stack: ['Flutter', 'Dart', 'REST APIs', 'Authentication', 'Analytics', 'Push notifications', 'iOS', 'Android'],
    facts: [
      ['Engagement', 'Aug 2022 — Jun 2023'],
      ['Role', 'Lead Senior Software Engineer (Mobile)'],
      ['Launch', '15,000+ first-month downloads'],
      ['Based in', 'Dubai, UAE'],
    ],
    links: {
      website: 'https://www.nakheelmarinas.com',
    },
  },
];

export const clientBySlug = (slug) => clients.find((client) => client.slug === slug);
