export const apps = [
  {
    slug: 'duas-and-aamal',
    name: 'Duas and Aamal',
    tagline: 'A daily companion for duas, aamal, and prayer — built Gujarati-first.',
    role: 'Creator · Flutter developer',
    year: '2023 — present',
    platforms: ['iOS', 'Android'],
    genre: 'Education',
    icon: '/media/apps/duas-and-aamal/icon.webp',
    screenshots: ['/media/apps/duas-and-aamal/shot1.webp', '/media/apps/duas-and-aamal/shot2.webp'],
    rating: { value: 5.0, count: 1072, source: 'Google Play', noun: 'reviews' },
    stack: ['Flutter', 'Dart', 'Firebase', 'Offline-first', '5 languages', 'Android TV'],
    links: {
      ios: 'https://apps.apple.com/ae/app/duas-and-aamal/id6478907381',
      android: 'https://play.google.com/store/apps/details?id=app.duasandaamal.com',
    },
    summary:
      'A complete Quran companion app: Quran with Gujarati translation, duas, aamal, ziyarats, Jafari prayer times with moon-sighting adjustment, tasbih, qibla, widgets, and offline content in five languages.',
    features: [
      'Quran with Gujarati translation and Arabic text',
      'Duas, aamal, and ziyarats with offline access',
      'Jafari prayer times with moon-sighting adjustment',
      'Tasbih counter, Qibla direction, home-screen widgets',
      'English, Urdu, Gujarati, Swahili, and Persian',
      'Prayer notifications, bookmarks, and an Android TV layout',
    ],
    story:
      'Most religious apps treat Gujarati as a translation afterthought. I built Duas and Aamal around the opposite assumption: Gujarati-speaking families should get a first-class experience, with Arabic text rendered correctly and prayer times calculated properly rather than approximated. The content pipeline runs through a small custom CMS (duas-crm), so updates ship without an app release. Five languages, offline access, and a 5.0-star rating on Google Play came from listening to the community that uses it daily.',
    decisions: [
      {
        title: 'Gujarati-first content model, not a translation layer',
        rationale:
          'Content is authored and structured per language with Arabic as the canonical text, so Gujarati, Urdu, Swahili and Persian are real editions rather than machine overlays.',
        tradeoff:
          'Every content update needs editorial workflow per language, and offline bundles are larger.',
      },
      {
        title: 'Offline-first delivery with a custom CMS',
        rationale:
          'The app is used in daily practice, often without reliable connectivity. Content ships with the app and updates through duas-crm without an app-store release.',
        tradeoff:
          'Sync, versioning and bundle size become first-class engineering problems.',
      },
      {
        title: 'Calculated Jafari prayer times with moon-sighting adjustment',
        rationale:
          'Fixed timestamps would have been simpler but wrong for the community this app serves. The calculation follows Jafari methodology and exposes how the result was derived.',
        tradeoff:
          'Domain-specific calculations need their own test fixtures and review, not just UI testing.',
      },
    ],
    metrics: [
      ['5.0★', 'Google Play rating'],
      ['1,072', 'Play reviews'],
      ['5', 'Languages'],
      ['Offline', 'Full content access'],
    ],
  },
  {
    slug: 'carvan-e-hind',
    name: 'Carvan-e-Hind',
    tagline: 'The community platform for Carvan-e-Hind Trust — events, media, and members.',
    role: 'Flutter developer & maintainer',
    year: '2024 — 2026',
    platforms: ['iOS', 'Android'],
    genre: 'Social Networking',
    icon: '/media/apps/carvan-e-hind/icon.webp',
    screenshots: ['/media/apps/carvan-e-hind/shot1.webp', '/media/apps/carvan-e-hind/shot2.webp'],
    rating: { value: 5.0, count: 4 },
    stack: ['Flutter', 'REST APIs', 'Firebase', 'Push notifications'],
    links: {
      ios: 'https://apps.apple.com/in/app/carvan-e-hind/id6745079091',
    },
    summary:
      'A community app for the Dawoodi Bohra community: announcements, events, media, and member engagement in one place, built and maintained end to end in Flutter.',
    features: [
      'Event discovery and community announcements',
      'Media library with offline-friendly downloads',
      'Member directory and engagement flows',
      'Push notifications for time-sensitive updates',
      'Android and iOS releases from a single codebase',
    ],
    story:
      'Community apps live or die on trust: the content has to be current, the notifications have to be relevant, and the app has to work on the phones people actually carry. I rebuilt the delivery around a predictable release train, moved content operations to a structured pipeline, and kept the UI simple enough for first-time smartphone users. The result is a 5-star rated app that the trust actually uses.',
    metrics: [
      ['5.0★', 'App Store rating'],
      ['2', 'Platforms'],
      ['Single', 'Flutter codebase'],
    ],
  },
  {
    slug: 'lumio-tv',
    name: 'Lumio TV',
    tagline: 'An IPTV player that behaves well on phones, tablets, and Android TV.',
    role: 'Lead developer',
    year: '2024',
    platforms: ['iOS', 'Android', 'Web', 'Android TV'],
    genre: 'Entertainment',
    icon: '/media/apps/lumio-tv/icon.webp',
    screenshots: ['/media/apps/lumio-tv/shot1.webp', '/media/apps/lumio-tv/shot2.webp'],
    stack: ['Flutter', 'M3U', 'Xtream Codes', 'EPG', 'Android TV'],
    links: {
      ios: 'https://apps.apple.com/us/app/lumio-tv-iptv-player/id6766064122',
      android: 'https://play.google.com/store/apps/details?id=app.lumio_iptv.com',
      web: 'https://lumiotv.web.app/',
    },
    summary:
      'A multi-provider IPTV client with M3U and Xtream support, live EPG, channel management, and resilient playback across mobile, web, and Android TV.',
    features: [
      'M3U playlists and Xtream Codes providers',
      'Live EPG guide with channel metadata',
      'Favorites, recents, and channel search',
      'Android TV focus navigation and remote support',
      'Resilient stream recovery and error states',
      'Shared Flutter core across iOS, Android, and web',
    ],
    story:
      'IPTV is a hostile environment: providers change formats, streams stall, and users expect television-grade reliability. I built Lumio TV around a tolerant parser, explicit playback states, and a remote-first TV interface, then reused the same core for mobile and web. The interesting engineering was not the player — it was making failure legible so users know whether the network, the provider, or the stream is the problem.',
    decisions: [
      {
        title: 'A tolerant parser for M3U and Xtream differences',
        rationale:
          'Providers publish inconsistent playlists and API responses. Parsing was isolated from playback and permissive where the format allows, so one provider quirk does not break the whole catalogue.',
        tradeoff:
          'More fixtures and edge cases to maintain, and some invalid input is accepted by design.',
      },
      {
        title: 'Explicit playback states instead of silent retries',
        rationale:
          'Users need to know whether the network, provider or stream failed. Buffering, retrying, ended and error states are distinct and visible rather than collapsed into a spinner.',
        tradeoff:
          'More UI states to design and test on every platform.',
      },
      {
        title: 'One shared Flutter core with a TV-first interaction layer',
        rationale:
          'Mobile, web and Android TV reuse the same catalogue and playback core, while focus navigation and remote input stay platform-specific.',
        tradeoff:
          'Each platform still needs its own interaction testing; sharing code does not share the remote control.',
      },
    ],
    metrics: [
      ['4', 'Platforms'],
      ['M3U + Xtream', 'Provider formats'],
      ['TV-first', 'Interaction model'],
    ],
  },
  {
    slug: '14-stars',
    name: '14 Stars',
    tagline: 'An all-in-one Islamic app for Quran, Hadith, Nauhas, and daily practice.',
    role: 'Flutter developer (contributed)',
    year: '2023',
    platforms: ['iOS'],
    genre: 'Education',
    icon: '/media/apps/14-stars/icon.webp',
    screenshots: ['/media/apps/14-stars/shot1.webp', '/media/apps/14-stars/shot2.webp'],
    rating: { value: 4.8, count: 12 },
    stack: ['Flutter', 'Audio playback', 'Calendar', 'Offline content'],
    links: {
      ios: 'https://apps.apple.com/ae/app/14-stars/id1526359119',
    },
    summary:
      'A comprehensive Islamic companion covering Quran, Hadith, Nauhas, Manqabats, Ziyarats, a calendar, Namaz timings, and Qibla direction.',
    features: [
      'Quran, Hadith, Nauhas, and Manqabats',
      'Ziyarats and religious calendar',
      'Namaz timings and Qibla direction',
      'Audio playback and offline reading',
      'Long-term maintenance across iOS releases',
    ],
    story:
      '14 Stars is a mature codebase with a large content surface and years of accumulated behavior. My contribution focused on stabilizing playback, improving content navigation, and keeping releases healthy across iOS versions. Working on a widely used app with an established audience is a different discipline from greenfield work: every change has to respect habits people already have.',
    metrics: [
      ['4.8★', 'App Store rating'],
      ['iOS', 'Platform'],
      ['Long-term', 'Maintenance'],
    ],
  },
  {
    slug: 'nutrabay',
    name: 'Nutrabay',
    tagline: 'Mobile commerce for one of India’s largest nutrition retailers.',
    role: 'Contributing mobile engineer',
    year: '2023',
    platforms: ['iOS', 'Android', 'Web'],
    genre: 'Health & Fitness',
    icon: '/media/apps/nutrabay/icon.webp',
    screenshots: ['/media/apps/nutrabay/shot1.webp', '/media/apps/nutrabay/shot2.webp'],
    stack: ['Flutter', 'E-commerce', 'REST APIs', 'Analytics'],
    links: {
      ios: 'https://apps.apple.com/ae/app/nutrabay-shop-supplements/id1583551779',
      android: 'https://play.google.com/store/apps/details?id=com.nutrabay',
    },
    summary:
      'A high-traffic nutrition e-commerce app covering catalogue browsing, offers, checkout, and order tracking across mobile and web.',
    features: [
      'Catalogue and category browsing at scale',
      'Cart, checkout, and payment flows',
      'Offers and promotional surfaces',
      'Order tracking and account management',
      'Analytics-driven merchandising surfaces',
    ],
    story:
      'E-commerce engineering is judged on conversion and crash-free sessions. On Nutrabay I worked on the mobile experience around product discovery and checkout, where small latency and layout decisions have direct revenue consequences. The lesson that stayed with me: in commerce, performance work is product work.',
    metrics: [
      ['3', 'Platforms'],
      ['E-commerce', 'Domain'],
      ['Checkout', 'Critical path'],
    ],
  },
  {
    slug: 'pool-inspection',
    name: 'Pool Inspection',
    tagline: 'Field-service inspections for pool compliance and safety audits.',
    role: 'Mobile developer',
    year: '2019 — 2020',
    platforms: ['iOS'],
    genre: 'Business',
    icon: '/media/apps/pool-inspection/icon.webp',
    sources: {
      icon: 'https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/45/dc/a4/45dca461-de2d-3649-2e91-b94a949c6150/AppIcon-0-0-1x_U007emarketing-0-8-0-85-220.png/512x512bb.png',
    },
    screenshots: ['/media/apps/pool-inspection/shot1.webp', '/media/apps/pool-inspection/shot2.webp'],
    stack: ['Flutter', 'Offline forms', 'Camera', 'PDF reports'],
    links: {
      ios: 'https://apps.apple.com/ae/app/pool-inspection-apps/id1528932146',
    },
    summary:
      'A field-service app for inspectors: structured checklists, photo evidence, and compliance reports generated on site, often without reliable connectivity.',
    features: [
      'Offline-first inspection forms',
      'Photo capture and evidence attachment',
      'Compliance checklists and scoring',
      'Generated PDF reports',
      'Sync when connectivity returns',
    ],
    story:
      'Inspectors work poolside, not in an office. That constraint shaped everything: forms must survive app restarts, photos must queue for upload, and the report has to be produced before leaving the property. Building offline-first workflows taught me more about state management than any tutorial — every edge case is a real user standing in the sun waiting for a screen to load.',
    metrics: [
      ['Offline', 'First-class'],
      ['On-site', 'PDF reports'],
      ['iOS', 'Platform'],
    ],
  },
  {
    slug: 'petassy',
    name: 'Petassy',
    tagline: 'Pet care in one app — appointments, a social feed, places, and reminders.',
    role: 'Creator · Flutter developer',
    year: '2023',
    platforms: ['iOS', 'Android'],
    genre: 'Lifestyle',
    icon: '/media/apps/petassy/icon.webp',
    cover: '/media/apps/petassy/cover.webp',
    screenshots: [],
    stack: ['Flutter', 'Dart', 'GetX', 'Firebase Auth', 'Cloud Firestore', 'Firebase Storage', 'FCM', 'Google Maps'],
    links: {},
    summary:
      'A Flutter pet-care platform with three in-app roles — pet parent, veterinarian, and nutritionist: pet profiles, appointment scheduling, a social feed called Expaw, real-time chat, nearby places on the map, and care reminders on Firebase.',
    features: [
      'Pet profiles with registration and editing',
      'Role-based flows for pet parents, vets, and nutritionists',
      'Expaw social feed with photo and video posts, likes, and comments',
      'Appointment scheduling with local notification reminders',
      'Real-time messaging between pet parents and professionals',
      'Nearby places, saved locations, and Google Maps integration',
      'Shopping section, profile, and settings',
    ],
    story:
      'Petassy started from a simple observation: pet care is scattered across chats, notes, and phone calls. I built it as a Flutter app around three roles that share one data model — pet parents, vets, and nutritionists — with Firebase Auth, Firestore, Storage, and Cloud Messaging behind it. The work that mattered was not the screens but keeping the same pet record coherent across a social feed, appointments, chat, and reminders, including Google Maps places and permission-gated flows. It is the project where I learned how much of product engineering is roles, permissions, and making the same entity legible in different contexts.',
    metrics: [
      ['3', 'In-app roles'],
      ['Real-time', 'Chat & feed'],
      ['Firebase', 'Auth, storage, push'],
    ],
  },
  {
    slug: 'blankspace',
    name: 'BlankSpace',
    tagline: 'A fill-in-the-blank party word game — think alike, score big.',
    role: 'Creator · Flutter developer',
    platforms: ['iOS', 'Android'],
    genre: 'Word game',
    icon: '/media/apps/blankspace/icon.webp',
    screenshots: [
      '/media/apps/blankspace/shot1.webp',
      '/media/apps/blankspace/shot2.webp',
      '/media/apps/blankspace/shot3.webp',
      '/media/apps/blankspace/shot4.webp',
      '/media/apps/blankspace/shot5.webp',
      '/media/apps/blankspace/shot6.webp',
    ],
    stack: ['Flutter', 'Dart', 'Riverpod', 'go_router', 'Supabase Realtime', 'Firebase Remote Config', 'RevenueCat', 'AdMob'],
    links: {
      android: 'https://play.google.com/store/apps/details?id=com.blankspaceparty.game',
    },
    summary:
      'A party word game built on a pure-Dart round engine: solo, pass-and-play, and online rooms, with bots, scoring, a local leaderboard, and an optional premium tier.',
    features: [
      'Solo, pass-and-play, and online rooms joined by room code',
      'Round engine that deals cue cards, locks answers, and scores matching answers',
      'Bot opponents and a local leaderboard',
      'Rewarded-ad peek and a RevenueCat premium paywall',
      'Word filtering before answers are scored',
      'Firebase Remote Config for tuning without a release',
    ],
    story:
      'BlankSpace is built as a pure-Dart game engine wrapped by a Flutter interface: the engine deals the round cue, tracks the writing phase, locks each seat, and scores the matches, so solo, pass-and-play, and online games run the same rules. Online rooms use Supabase with one realtime channel per room code, while monetisation is a RevenueCat paywall and a rewarded-ad peek. The interesting problem was keeping turn order and scoring identical whether the other seats are bots in the same room or people on another phone.',
    metrics: [
      ['3', 'Play modes'],
      ['Pure Dart', 'Round engine'],
      ['Realtime', 'Online rooms'],
    ],
    sources: {
      listings: ['https://play.google.com/store/apps/details?id=com.blankspaceparty.game'],
      icon: 'https://play-lh.googleusercontent.com/8px71-OeSep3V4ETBdoAnLjzYVD991W-BqICo8rCm5qW7bXFJ1xBb7IKdlVEBlxbH0NEB0ZXrB6tb3JgDDHOPA=s512',
      screenshots: [
        'https://play-lh.googleusercontent.com/HWHHruaro8Gt9H77Vw5s_ckm6U3xJGBKL8RQoVm24IcL-EPNMVovjx05VUdb1j-5SYGipAHGzXH-qvD0WcSN=w600',
        'https://play-lh.googleusercontent.com/Y_Hbz4yPVyCJbKyAJawzZDJ7qDQ_5X9VZixfP3nUMKaqWqBNNhECTbZy65vcM7S4d54lTWWJIB-bZ0Dnr_AIGQ=w600',
        'https://play-lh.googleusercontent.com/jtQrgmZVGDsuDmwR23t3mJLsrFbL8QPtdRx6vpxv27GtMM94qavLGXyR7xW4IJ14mt4MVwT5_p067rBthhWskMY=w600',
        'https://play-lh.googleusercontent.com/lYFY0qSUWRuLmopJZosTVRuixdDp0qLQ10U5kuFsdwlVfG-8KZbzRTQFFZEZXNAp08RdeZZh0UE3aho69Usu=w600',
        'https://play-lh.googleusercontent.com/JXRh6IawNBhRE_tecQsd2TAmpMfBpSrBcch0TxFI0K5hXRvWNF75tQ_edrXcXF5z11JXzs5XC1OmgtBVgXHFrw=w600',
        'https://play-lh.googleusercontent.com/-rdA4tfUUy3Zd2z1m5zv_RaK-3lpCFvM6TzHLzd8ealzeoMJlq3yMFJga3SFGh8f1jKECvN569BzXsZCRLZp0lg=w600',
      ],
    },
  },
  {
    slug: 'bulbvpn',
    name: 'BULB VPN',
    tagline: 'A V2Ray VPN client with subscription import, QR scanning, and live connection stats.',
    role: 'Creator · Flutter developer',
    platforms: ['iOS', 'Android'],
    genre: 'Utilities',
    icon: '/media/apps/bulbvpn/icon.webp',
    screenshots: [
      '/media/apps/bulbvpn/shot1.webp',
      '/media/apps/bulbvpn/shot2.webp',
      '/media/apps/bulbvpn/shot3.webp',
      '/media/apps/bulbvpn/shot4.webp',
      '/media/apps/bulbvpn/shot5.webp',
    ],
    stack: ['Flutter', 'Dart', 'Riverpod', 'go_router', 'flutter_vless', 'Firebase Remote Config', 'Analytics', 'Crashlytics', 'mobile_scanner'],
    links: {
      android: 'https://play.google.com/store/apps/details?id=app.bulbvpn.com',
      github: 'https://github.com/hasanabbassorathiya/BULBVPN',
    },
    summary:
      'A Flutter VPN client for iOS and Android: import subscriptions, configs, or QR codes, pick a server, and watch live connection state and traffic statistics.',
    features: [
      'VMess, VLESS, Trojan, and Shadowsocks configuration support through flutter_vless',
      'Import by subscription URL, pasted config, clipboard, or QR scan',
      'Server list with search, protocol filters, and favourites',
      'Live connection state with download, upload, and duration statistics',
      'Firebase Remote Config, Analytics, and Crashlytics wired in',
      'English, Spanish, and Portuguese localisation',
    ],
    story:
      'BULB VPN keeps the plugin at arm’s length: flutter_vless sits behind a VpnEngine abstraction, so connection state, statistics, and failures are modelled by the app instead of leaking plugin types into the UI. Users add servers by subscription URL, raw config, clipboard paste, or QR scan, and the app normalises them into one server model with search, protocol filters, and favourites. That structure made it possible to add live connection stats, remote-config defaults, and crash reporting without rewriting the connection flow.',
    metrics: [
      ['4', 'Protocols'],
      ['4', 'Import paths'],
      ['2', 'Platforms'],
    ],
    sources: {
      listings: ['https://play.google.com/store/apps/details?id=app.bulbvpn.com'],
      icon: 'https://play-lh.googleusercontent.com/oxp8AacP4LiAjVMA2A_inzJuf52FkdbuDcYAwHXGqCegG3EP4NXR4zSi7906Cs20qRZ5D6bxNvGTsAkLbAuyUQ=s512',
      screenshots: [
        'https://play-lh.googleusercontent.com/JxMX-D5gqXN4SkzQ8rHmiHAcc-Aqcg0O9a3-Gsfla9ENJ_FerJMxsNMAmLeVRlcoXDkw07PYQpQk_Up39XEPKA=w600',
        'https://play-lh.googleusercontent.com/ntmVQDG17BzhEUXFPNPDc7t0yS9VS9IiEx8hlcUevsoWPKBrhjc1KYFr57ci14XSYyMswrx9kefQQWgHL8jzGs8=w600',
        'https://play-lh.googleusercontent.com/LXxPQk5Nt07kwTSC_gUgweafvrIR4XNbl546KA1OpUcTnxlD4NLZ_lMFIKaLmCWDmle_760s8j768IgfEi9BO7Y=w600',
        'https://play-lh.googleusercontent.com/T-r52--ZMyliTi2Q32B8K-h2Urz3U5pDHmNhU8Y5k7KYS_qxHvxaQevD0UYnfNj35YkugSBMsC3zWIJx_nUDhQ=w600',
        'https://play-lh.googleusercontent.com/gJ-SIy7BY7zCekwpgT5A6uPKY1TQLy2m9XfESUMCyA7MLS_Z8yVje_eFTMCOyiIwKoNXQ-KEZD1Z5KufiJHA=w600',
      ],
    },
  },
  // Store descriptions establish product features, not implementation ownership.
  // Preserve original listing/CDN URLs so the downloaded assets remain traceable.
  {
    slug: 'hoda',
    name: 'Hoda',
    tagline: 'A bilingual pilgrimage companion, in French and English.',
    role: 'Publisher',
    platforms: ['iOS', 'Android'],
    genre: 'Books',
    icon: '/media/apps/hoda/icon.webp',
    screenshots: ['/media/apps/hoda/shot1.webp', '/media/apps/hoda/shot2.webp'],
    stack: [],
    links: {
      ios: 'https://apps.apple.com/ae/app/id6755375239',
      android: 'https://play.google.com/store/apps/details?id=app.hoda.com',
    },
    summary:
      'A French/English pilgrimage guide covering sacred sites, their history, Hajj and Umrah rituals, supplications with transliteration and translation, and the spiritual meaning of the Ziyarat of Arbaeen.',
    attribution:
      'My contribution is publishing Hoda under my developer account, not authorship of its content or a claim of full app development.',
    features: [
      'Practical pilgrimage guidance in French and English',
      'Pilgrimage sites in Iran, Iraq, Syria, Lebanon, Egypt, and Saudi Arabia',
      'Historical context and explanations of Hajj and Umrah rituals',
      'Supplications with transliteration and translation',
      'Spiritual guidance on the Ziyarat of Arbaeen',
    ],
    metrics: [],
    sources: {
      listings: ['https://apps.apple.com/ae/app/id6755375239', 'https://play.google.com/store/apps/details?id=app.hoda.com'],
      icon: 'https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/df/5c/b5/df5cb5c5-1e74-0b20-9477-b9f1d660f1b4/AppIcon-0-0-1x_U007emarketing-0-11-0-85-220.png/512x512bb.png',
      screenshots: [
        'https://is1-ssl.mzstatic.com/image/thumb/PurpleSource221/v4/7c/4d/d5/7c4dd5bb-2777-9590-09ca-88e62d7e385b/1.jpg/600x1300bb.webp',
        'https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/8f/97/78/8f9778e8-9201-30be-daf0-734ef6b2c66e/2.jpg/600x1300bb.webp',
      ],
    },
  },
  {
    slug: 'fragrance-of-mastership',
    name: 'Fragrance of Mastership',
    tagline: 'Dr. Shabeeb Rizvi’s collection of traditions, available as a book app.',
    role: 'Publisher',
    platforms: ['iOS'],
    genre: 'Books',
    icon: '/media/apps/fragrance-of-mastership/icon.webp',
    screenshots: ['/media/apps/fragrance-of-mastership/shot1.webp', '/media/apps/fragrance-of-mastership/shot2.webp'],
    stack: [],
    links: {
      ios: 'https://apps.apple.com/ae/app/id6480333197',
    },
    summary:
      'Fragrance of Mastership by Dr. Shabeeb Rizvi collects traditions on wilayat (mastership), Imam Ali and the eleven Imams, alongside traditions about Lady Fatima Zahra.',
    attribution:
      'The book is by Dr. Shabeeb Rizvi. My contribution is publishing the app under my developer account, not authorship of the book or a claim of full app development.',
    features: [
      'A collection of traditions on wilayat (mastership)',
      'Traditions concerning Imam Ali and the eleven Imams',
      'Traditions concerning Lady Fatima Zahra',
    ],
    metrics: [],
    sources: {
      listings: ['https://apps.apple.com/ae/app/id6480333197'],
      icon: 'https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/4b/d4/5d/4bd45d24-45f0-ccbd-3adb-2c77700d0ab1/AppIcon-0-0-1x_U007emarketing-0-7-0-0-85-220.png/512x512bb.png',
      screenshots: [
        'https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/21/60/30/21603000-8ea0-261c-e3bd-729a7594fcf6/99913b63-9210-4d69-94f8-4837f0abf9aa_1.png/600x1300bb.webp',
        'https://is1-ssl.mzstatic.com/image/thumb/PurpleSource211/v4/eb/0e/93/eb0e9312-188f-12a3-fe22-414f2f0911c9/9cf19c25-7b00-45c6-b37b-29410467a66f_2.png/600x1300bb.webp',
      ],
    },
  },
  {
    slug: 'wallmaster',
    name: 'WallMaster',
    tagline: 'Discover wallpapers and short videos for your phone.',
    role: 'Store listing',
    platforms: ['Android'],
    genre: 'Photography',
    icon: '/media/apps/wallmaster/icon.webp',
    screenshots: ['/media/apps/wallmaster/shot1.webp', '/media/apps/wallmaster/shot2.webp'],
    stack: [],
    links: {
      android: 'https://play.google.com/store/apps/details?id=com.hasanabbassorathiya.wallmaster',
    },
    summary:
      'An Android wallpaper and video app with search, popular tags, downloads, and sharing. Its Google Play description identifies Pexels as the source of its photo and video content.',
    attribution:
      'Listed under my Google Play developer account. This overview describes the public listing; technology choices and implementation responsibilities are not documented here.',
    features: [
      'Wallpaper discovery through search and popular tags',
      'Short videos to browse, play, and download',
      'Home-screen and lock-screen wallpaper selection',
      'Share favorite images with friends and family',
    ],
    metrics: [],
    sources: {
      listings: ['https://play.google.com/store/apps/details?id=com.hasanabbassorathiya.wallmaster'],
      icon: 'https://play-lh.googleusercontent.com/MF9HvcL-xLtrcj6TtIx_FxH-zN4OtF_cQ2e4_2LdfsZlVxJHor-Wtd0zu-vCpOmWNEQ_P6qL5hqSDxtsGDaCmg=s512',
      screenshots: [
        'https://play-lh.googleusercontent.com/L24j_slODUoncwsY_GGdUyDHoNBjz7FAtvwKCt47aqHz4j5FS2KsyCOzqGMVNCM-QxM_XYJirIhnLpES4bTg=w600',
        'https://play-lh.googleusercontent.com/9iHgx1sJ8RabJtoQmJJ3nVgO4lCWJF-l4VGZtks8K5B2tqFRQOzaDPZd8844MYtfCgJgreW66Q7U3vtlXUPl=w600',
      ],
    },
  },
  {
    slug: 'business-mind',
    name: 'Business Mind: Money Empire',
    tagline: 'An idle business simulation about building and growing an empire.',
    role: 'Store listing',
    platforms: ['Android'],
    genre: 'Simulation',
    icon: '/media/apps/business-mind/icon.webp',
    screenshots: ['/media/apps/business-mind/shot1.webp', '/media/apps/business-mind/shot2.webp'],
    stack: [],
    links: {
      android: 'https://play.google.com/store/apps/details?id=game.businessmind.hasanabbas',
    },
    summary:
      'An idle business tycoon game with businesses to run, employees and upgrades, simulated stock and crypto investments, real estate, and progress while away from the app.',
    attribution:
      'Listed under my Google Play developer account. This overview describes the public listing; technology choices and implementation responsibilities are not documented here.',
    features: [
      'Tap-to-earn businesses, employees, and upgrades',
      'Simulated stock market, crypto, and real-estate investing',
      'Offline earnings, daily challenges, and login streaks',
      'Legacy prestige progression and cloud saves',
    ],
    metrics: [],
    sources: {
      listings: ['https://play.google.com/store/apps/details?id=game.businessmind.hasanabbas'],
      icon: 'https://play-lh.googleusercontent.com/7fnhjBpS5NPLJtdhXiMG0ZinCghlxG82v2vSCyU46X3ySVSI9memDG9S30qCes71IWIktpiybVzoj9QU6COo=s512',
      screenshots: [
        'https://play-lh.googleusercontent.com/8l7A6ahUWHTmVdOf7ssCt570sGMLBDxCkfKo7H0IkX7rh5GwOwmQzda-pidhTbbyqlTipI_Wrd1YXmOo_CyJXA=w600',
        'https://play-lh.googleusercontent.com/KB-LTP68hA-4tklrlg0s6bTpvwwefVHc6g1H_W3xtz5PrSKwq8QJpnktq4CPHgdhet9FGf-dZ2oXdXP3cFJw=w600',
      ],
    },
  },
  {
    slug: 'klix',
    name: 'KLIX',
    tagline: 'A GCC shopping app for unique products, delivered within 24 hours.',
    role: 'Senior mobile engineer · Masaar',
    year: '2022',
    platforms: ['iOS', 'Android'],
    genre: 'Shopping',
    icon: '/media/apps/klix/icon.webp',
    screenshots: ['/media/apps/klix/shot1.webp', '/media/apps/klix/shot2.webp'],
    rating: { value: 4.4, count: 5, source: 'Google Play', noun: 'reviews' },
    stack: ['Flutter', 'Dart', 'E-commerce', 'Authentication'],
    links: {
      ios: 'https://apps.apple.com/hr/app/klix-%D9%83%D9%84%D9%8A%D9%83%D8%B3/id1593578496',
      android: 'https://play.google.com/store/apps/details?id=com.iklix.klix',
    },
    summary:
      'A cross-border storefront for shoppers across the GCC: unique products sourced from around the world, cash-on-delivery or card payment, and delivery inside 24 hours.',
    features: [
      'Unique products sourced from around the world',
      'Cash on delivery or credit card at checkout',
      'Delivery across GCC markets within 24 hours',
      'Browsing, cart, and checkout in one app',
      'iOS and Android releases from a single codebase',
    ],
    story:
      'Klix is the cross-border e-commerce app Masaar ran for GCC shoppers, importing products from Japan and Korea. I joined as senior mobile engineer and re-architected the Flutter application for scalability and maintainability, rebuilt secure authentication, and reworked the purchase journey; the UX and workflow changes contributed to roughly 25% better conversion. Cross-border retail lives or dies on trust at checkout and on the delivery promise, so that is where the rebuild concentrated.',
    metrics: [
      ['+25%', 'Conversion after UX rework'],
      ['2', 'Platforms'],
      ['24h', 'Delivery promise'],
    ],
    sources: {
      listings: [
        'https://play.google.com/store/apps/details?id=com.iklix.klix',
        'https://apps.apple.com/hr/app/klix-%D9%83%D9%84%D9%8A%D9%83%D8%B3/id1593578496',
      ],
      icon: 'https://play-lh.googleusercontent.com/t1vftX4XCQ9YsJBWwX5ntohIryL8khSG4aUr0-rKwHxYKk6xvj2daNNZY3OvSQutFhMOFzT9HuL5BaEVwvWuiv0=s512',
      screenshots: [
        'https://play-lh.googleusercontent.com/z9a5qtn0aqiGriGaQ4f-okDBxFi5pa53YYygPgCk0TjhUuIg4PU1RlSnf325vDTPdYhzE_FLer5ta_dyHZxffQ=w720',
        'https://play-lh.googleusercontent.com/wBOLRmNYUldgnnipl3wGssk6_XyhFLd5YpoloC585wX4Kgh0Fr3ZbRAyTu7CUHVEZh_IhPj2KfBjZuoGeoY02VM=w720',
      ],
    },
  },
  {
    slug: 'urban-ledger',
    name: 'Urban Ledger',
    tagline: 'Track. Remind. Collect. Split. — the digital ledger for UAE businesses.',
    role: 'Team lead · Vervali Systems',
    year: '2021',
    platforms: ['iOS', 'Android'],
    genre: 'Business',
    icon: '/media/apps/urban-ledger/icon.webp',
    screenshots: ['/media/apps/urban-ledger/shot1.webp', '/media/apps/urban-ledger/shot2.webp'],
    rating: { value: 5.0, count: 5, source: 'App Store', noun: 'ratings' },
    stack: ['Flutter', 'Dart', 'Payments', 'Fintech'],
    links: {
      ios: 'https://apps.apple.com/ae/app/urban-ledger/id1617320844',
      android: 'https://play.google.com/store/apps/details?id=com.ul.urbanledger&hl=en',
    },
    summary:
      'A digital ledger and collections app for UAE businesses: payment links, QR codes, tap-to-pay, staff contactless cards, VAT invoices, payment reminders, and Zolt split payments.',
    features: [
      'Payment links, QR codes, and tap-to-pay collection',
      'Digital ledger (khata) with SMS, WhatsApp, and email reminders',
      'VAT invoices carrying a payment link and QR code',
      'Staff contactless cards for field teams',
      'Zolt split payments on UAE credit cards',
    ],
    story:
      'Urban Ledger began as a digital ledger for UAE shopkeepers and grew into a collections platform: payment links, QR codes, tap-to-pay, and staff cards, all reconciled in one ledger. I led the Flutter build at Vervali Systems — payment flows, secure API communication, and validation logic — and mentored the team on architecture and code review. The product question was trust: a merchant has to believe the number on the screen matches the money in the bank, so every flow was designed around a record the user can check.',
    metrics: [
      ['5.0★', 'App Store rating'],
      ['2', 'Platforms'],
      ['UAE', 'Market'],
    ],
    sources: {
      listings: [
        'https://play.google.com/store/apps/details?id=com.ul.urbanledger',
        'https://apps.apple.com/ae/app/urban-ledger/id1617320844',
      ],
      icon: 'https://play-lh.googleusercontent.com/xBUvHBo1z2VGtOUMViKgXrvB1qvoxSlxOj69AUqAP3zvprCkKWmoj6k7LVdtZmGlCKObzNjiaTxLBTbwVk75zTE=s512',
      screenshots: [
        'https://play-lh.googleusercontent.com/RPVb1mUxK-4L0HZfqsVY_FSDs1TucLBhUcSDmUCryHhfAjILjQAkUMntTLRX40IGIvyeSYfRsppgCm1sbubXqA=w720',
        'https://play-lh.googleusercontent.com/B08wqJ0lS0iMG7A5HrG477-xwO-ExELk-463Yr57qBfWO1ogwcQzRntKrbo9Lq7-p4uzaZTrUJNYcgTwRcXK=w720',
      ],
    },
  },
  {
    slug: 'evlab',
    name: 'EVLAB',
    tagline: 'Electric mobility for rentals, leasing, and marketplace — one app for three business models.',
    role: 'Mobile Engineering Lead · Chalhoub Group',
    year: '2023 — 2026',
    platforms: ['iOS', 'Android'],
    genre: 'Mobility',
    icon: '/media/apps/evlab/icon.webp',
    screenshots: [],
    stack: ['Flutter', 'Dart', 'Clean Architecture', 'Riverpod', 'REST APIs', 'Codemagic'],
    links: {
      website: 'https://www.ev-lab.io',
    },
    summary:
      'An electric mobility platform for rentals, leasing, and marketplace, with the iOS and Android apps owned end to end — architecture, delivery, store releases, and production support.',
    features: [
      'Daily rentals, long-term leasing, and marketplace in one product',
      'One account, payment, and authentication flow across all three models',
      'Flutter apps on Clean Architecture with Riverpod',
      'Secure REST APIs, analytics, and third-party SDK integrations',
      'Codemagic CI/CD and store releases owned end to end',
    ],
    story:
      'EVLAB carries three business models — daily rentals, long-term leasing, and a marketplace — inside one brand. Splitting them into separate apps would have tripled release overhead and split the customer record, so the mobile product shipped as one Flutter codebase with modular boundaries. I led mobile engineering at Chalhoub Group: architecture, secure API integration, CI/CD with Codemagic, release management, and production support through January 2026.',
    metrics: [
      ['3', 'Business models'],
      ['2', 'Platforms'],
      ['2023–26', 'Engagement'],
    ],
  },
  {
    slug: 'good2go-loans',
    name: 'Good2Go Loans',
    tagline: 'Digital lending for New Zealand — onboarding, identity, and account access in one Flutter app.',
    role: 'Senior Flutter Developer · Beedev Solutions',
    year: '2019 — 2021',
    platforms: ['iOS', 'Android'],
    genre: 'Finance',
    icon: '/media/apps/good2go/icon.webp',
    screenshots: [],
    stack: ['Flutter', 'Dart', 'Clean Architecture', 'SOLID', 'REST APIs', 'Push notifications'],
    links: {
      website: 'https://www.goodtogoloans.com.au',
    },
    summary:
      'A digital lending app used by 50,000+ people across New Zealand — onboarding, authentication, account journeys, and store releases owned end to end.',
    features: [
      'Onboarding, identity, and eligibility journeys',
      'Authentication, session handling, and account access',
      'Account management and push notifications',
      'REST API integrations with the lending platform',
      'Android and iOS releases owned through production',
    ],
    story:
      'Lending products earn trust in the first few minutes, so identity, eligibility, and account access were treated as core journeys rather than form screens. I built the Flutter app on Clean Architecture and SOLID boundaries, integrated the lending APIs, and owned both store pipelines through production. The product reached 50,000+ users across New Zealand, and the architecture became the base the team kept extending.',
    metrics: [
      ['50K+', 'Users in New Zealand'],
      ['2', 'Platforms'],
      ['2019–21', 'Engagement'],
    ],
  },
  {
    slug: 'nakheel-marinas',
    name: 'Nakheel Marinas',
    tagline: 'A marina and lifestyle app delivered with a Flutter team on a fixed release train.',
    role: 'Lead Senior Software Engineer (Mobile) · Belong Interactive',
    year: '2022 — 2023',
    platforms: ['iOS', 'Android'],
    genre: 'Lifestyle',
    icon: '/media/apps/nakheel/icon.webp',
    screenshots: [],
    stack: ['Flutter', 'Dart', 'REST APIs', 'Authentication', 'Analytics', 'Push notifications'],
    links: {},
    summary:
      'A marina and lifestyle app shipped with a Flutter team under a fixed release train — 15,000+ downloads in its first month.',
    features: [
      'Marina and lifestyle content in one app',
      'Authentication, notifications, and analytics integrated on schedule',
      'Flutter architecture and standards shared across the team',
      'Code review and production delivery',
      'Fixed release train for a seasonal launch',
    ],
    story:
      'Hospitality apps ship against deadlines that do not move: a season opens, a marina is announced, a campaign goes live. I led the Flutter team on architecture, standards, code review, and delivery, and integrated authentication, notifications, analytics, and third-party services on schedule. The app launched to 15,000+ downloads in its first month.',
    metrics: [
      ['15K+', 'First-month downloads'],
      ['2', 'Platforms'],
      ['2022–23', 'Engagement'],
    ],
  },
  {
    slug: 'automover-tms',
    name: 'Automover TMS',
    tagline: 'Transport management for Australian fleet operators.',
    role: 'Full-stack engineer',
    year: '',
    platforms: ['Web'],
    genre: 'Logistics',
    icon: '/media/apps/automover-tms/icon.webp',
    screenshots: [],
    stack: [],
    links: {
      website: 'https://www.automover.com.au/',
    },
    summary: 'A transport management system for Australian fleet operators.',
    features: [],
    story: '',
    metrics: [],
  },
  {
    slug: 'kokoro-michi',
    name: 'Kokoro Michi',
    tagline: 'An Android wellness app for daily practice and habit building.',
    role: 'Mobile engineer',
    year: '',
    platforms: ['Android'],
    genre: 'Health & Fitness',
    icon: '',
    screenshots: [],
    stack: [],
    links: {},
    summary: 'An Android wellness app for daily practice and habit building.',
    features: [],
    story: '',
    metrics: [],
  },
  {
    slug: 'chuckleplay',
    name: 'ChucklePlay',
    tagline: 'A lightweight multi-platform IPTV player, open source on GitHub.',
    role: 'Creator · maintainer',
    year: '2026',
    platforms: ['Android', 'iOS', 'Web', 'Desktop'],
    genre: 'Entertainment',
    icon: '',
    screenshots: [],
    stack: ['Flutter', 'Dart', 'M3U', 'Xtream Codes'],
    links: {
      github: 'https://github.com/hasanabbassorathiya/ChucklePlay',
    },
    summary:
      'An open-source, lightweight multi-platform IPTV player built with Flutter — M3U and Xtream playlists, favourites and history, playlist switching, and remote-friendly navigation.',
    features: [
      'M3U and Xtream playlist import',
      'Favourites and watch history',
      'Playlist switching',
      'TV remote navigation',
      'Flutter builds for mobile, web, and desktop',
    ],
    story:
      'An MIT-licensed Flutter project first published in January 2026, with builds for Android, iOS, web, Linux, macOS, and Windows. Distribution is source-only: there are no tagged releases yet.',
    metrics: [
      ['2026', 'Published'],
      ['MIT', 'Licence'],
      ['Source', 'Distribution'],
    ],
  },
];

export const appBySlug = (slug) => apps.find((a) => a.slug === slug);

export const flagshipApps = apps.slice(0, 3);
