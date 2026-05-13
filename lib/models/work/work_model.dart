/// Work/Project model
/// Represents a work project with all its properties
class WorkModel {
  final String id;
  final String title;
  final String category;
  final String imageAsset;
  final String description;
  final String? projectUrl;
  final List<String> tags;
  final String? client;
  final String? year;
  final String? role;
  final List<String>? technologies;
  final String? challenge;
  final String? solution;
  final List<String>? images;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final String? appIconUrl;

  const WorkModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageAsset,
    required this.description,
    this.projectUrl,
    this.tags = const [],
    this.client,
    this.year,
    this.role,
    this.technologies,
    this.challenge,
    this.solution,
    this.images,
    this.playStoreUrl,
    this.appStoreUrl,
    this.appIconUrl,
  });

  /// Create a work model from a map
  factory WorkModel.fromMap(Map<String, dynamic> map) {
    return WorkModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String,
      category: map['category'] as String,
      imageAsset: map['image_url'] as String? ?? map['imageAsset'] as String? ?? '',
      description: map['description'] as String,
      projectUrl: map['project_url'] as String? ?? map['projectUrl'] as String?,
      tags:
          (map['tags'] is List)
              ? (map['tags'] as List<dynamic>).map((e) => e.toString()).toList()
              : (map['tags'] is String)
              ? (map['tags'] as String).split(',').map((e) => e.trim()).toList()
              : [],
      client: map['client'] as String?,
      year: map['year'] as String?,
      role: map['role'] as String?,
      technologies:
          (map['technologies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      challenge: map['challenge'] as String?,
      solution: map['solution'] as String?,
      images: () {
        final imagesData = map['images'];
        if (imagesData == null) return null;
        if (imagesData is List) {
          return imagesData.map((e) => e.toString()).toList();
        }
        if (imagesData is String) {
          // Handle comma-separated string
          return imagesData
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
        return null;
      }(),
      playStoreUrl: map['play_store_url'] as String?,
      appStoreUrl: map['app_store_url'] as String?,
      appIconUrl: map['app_icon_url'] as String?,
    );
  }

  /// Convert work model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imageAsset': imageAsset,
      'description': description,
      'projectUrl': projectUrl,
      'tags': tags,
      'client': client,
      'year': year,
      'role': role,
      'technologies': technologies,
      'challenge': challenge,
      'solution': solution,
      'images': images,
      'play_store_url': playStoreUrl,
      'app_store_url': appStoreUrl,
      'app_icon_url': appIconUrl,
    };
  }
}

/// Work repository for managing work/project data
class WorkRepository {
  static final List<WorkModel> _works = [
    WorkModel(
      id: '1',
      title: 'Bally Website Research',
      category: 'UX case study',
      imageAsset: 'assets/work1.png',
      description:
          'A comprehensive UX case study for Bally website redesign focusing on user experience and modern design principles.',
      projectUrl: 'YOUR_BALLY_PROJECT_URL',
      tags: ['UX Design', 'Research', 'Web Design'],
      client: 'Bally',
      year: '2022',
      role: 'Lead UX Designer',
      technologies: ['Figma', 'Adobe XD', 'User Research'],
      challenge:
          'The existing Bally website had poor user experience and low conversion rates. Users found it difficult to navigate and find products.',
      solution:
          'Conducted extensive user research, created user personas, and redesigned the website with a focus on intuitive navigation and improved product discovery.',
      images: ['assets/work1.png', 'assets/work2.png'],
    ),
    WorkModel(
      id: '2',
      title: 'Bally Website Research',
      category: 'UX case study',
      imageAsset: 'assets/work2.png',
      description:
          'A comprehensive UX case study for Bally website redesign focusing on user experience and modern design principles.',
      projectUrl: 'YOUR_BALLY_PROJECT_URL',
      tags: ['UX Design', 'Research', 'Web Design'],
      client: 'Bally',
      year: '2022',
      role: 'Lead UX Designer',
      technologies: ['Figma', 'Adobe XD', 'User Research'],
      challenge:
          'The existing Bally website had poor user experience and low conversion rates. Users found it difficult to navigate and find products.',
      solution:
          'Conducted extensive user research, created user personas, and redesigned the website with a focus on intuitive navigation and improved product discovery.',
      images: ['assets/work2.png', 'assets/work3.png'],
    ),
    WorkModel(
      id: '3',
      title: 'Bally Website Research',
      category: 'UX case study',
      imageAsset: 'assets/work3.png',
      description:
          'A comprehensive UX case study for Bally website redesign focusing on user experience and modern design principles.',
      projectUrl: 'YOUR_BALLY_PROJECT_URL',
      tags: ['UX Design', 'Research', 'Web Design'],
      client: 'Bally',
      year: '2022',
      role: 'Lead UX Designer',
      technologies: ['Figma', 'Adobe XD', 'User Research'],
      challenge:
          'The existing Bally website had poor user experience and low conversion rates. Users found it difficult to navigate and find products.',
      solution:
          'Conducted extensive user research, created user personas, and redesigned the website with a focus on intuitive navigation and improved product discovery.',
      images: ['assets/work3.png', 'assets/work4.png'],
    ),
    WorkModel(
      id: '4',
      title: 'Bally Website Research',
      category: 'UX case study',
      imageAsset: 'assets/work4.png',
      description:
          'A comprehensive UX case study for Bally website redesign focusing on user experience and modern design principles.',
      projectUrl: 'YOUR_BALLY_PROJECT_URL',
      tags: ['UX Design', 'Research', 'Web Design'],
      client: 'Bally',
      year: '2022',
      role: 'Lead UX Designer',
      technologies: ['Figma', 'Adobe XD', 'User Research'],
      challenge:
          'The existing Bally website had poor user experience and low conversion rates. Users found it difficult to navigate and find products.',
      solution:
          'Conducted extensive user research, created user personas, and redesigned the website with a focus on intuitive navigation and improved product discovery.',
      images: ['assets/work4.png', 'assets/work1.png'],
    ),
    WorkModel(
      id: '5',
      title: '14 Stars',
      category: 'Mobile App',
      imageAsset: 'assets/work_14stars.png',
      description: 'All in one Islamic App containing Hadiths, History, Nauhas, Manqabats, and Ashaars.',
      tags: ["Islamic","Education","Utility"],
      projectUrl: 'https://14stars.co.in/',
      appStoreUrl: 'https://apps.apple.com/in/app/14-stars/id1526359119',
      appIconUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/66/1b/c2/661bc225-866e-c687-f277-2c13d7e7d0a2/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/512x512bb.jpg',
      isActive: true,
      orderIndex: 5,
    ),
    WorkModel(
      id: '6',
      title: 'Automover',
      category: 'Logistics',
      imageAsset: 'assets/work_automover.png',
      description: 'Transportation Management System (TMS) for moving services.',
      tags: ["Logistics","TMS","Business"],
      projectUrl: 'https://www.automover.com.au/',
      appStoreUrl: 'https://apps.apple.com/in/app/automover/id1524264137',
      isActive: true,
      orderIndex: 6,
    ),
    WorkModel(
      id: '7',
      title: 'Pool Inspection Apps',
      category: 'Utility',
      imageAsset: 'assets/work_pool.png',
      description: 'System for registering notices & certificates, invoicing, and pool inspection management.',
      tags: ["Inspection","Business","Utility"],
      projectUrl: 'https://www.poolinspectionapps.com/',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=au.com.adaptify.poolinspection',
      appStoreUrl: 'https://apps.apple.com/us/app/pool-inspection-apps/id1528932146',
      isActive: true,
      orderIndex: 7,
    ),
    WorkModel(
      id: '8',
      title: 'Good2GO Loans',
      category: 'Finance',
      imageAsset: 'assets/work_good2go.png',
      description: 'Loan application and management platform.',
      tags: ["Finance","Banking"],
      playStoreUrl: 'https://play.google.com/store/apps/details?id=au.com.goodtogoloans.app',
      appStoreUrl: 'https://apps.apple.com/us/app/good-to-go-loans/id1542316639',
      isActive: true,
      orderIndex: 8,
    ),
    WorkModel(
      id: '9',
      title: 'Nutrabay',
      category: 'E-commerce',
      imageAsset: 'assets/work_nutrabay.png',
      description: 'Shop for health and fitness supplements.',
      tags: ["E-commerce","Health","Fitness"],
      projectUrl: 'https://nutrabay.com/',
      appStoreUrl: 'https://apps.apple.com/am/app/nutrabay-shop-supplements/id1583551779',
      isActive: true,
      orderIndex: 9,
    ),
    WorkModel(
      id: '10',
      title: 'EVLAB',
      category: 'Utility',
      imageAsset: 'assets/work_evlab.png',
      description: 'Electric Vehicle laboratory and management app.',
      tags: ["EV","Utility"],
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.smartdata.evie&hl=en',
      appStoreUrl: 'https://apps.apple.com/ae/app/evlab/id1635102548',
      isActive: true,
      orderIndex: 10,
    ),
    WorkModel(
      id: '11',
      title: 'Duas and Aamal',
      category: 'Education',
      imageAsset: 'assets/work_duas.png',
      description: 'Platform for spiritual enrichment through supplications, Aamal/Duas, and Ziarats in Gujarati.',
      tags: ["Spiritual","Education"],
      playStoreUrl: 'https://play.google.com/store/apps/details?id=app.duasandaamal.com&hl=en',
      appStoreUrl: 'https://apps.apple.com/ae/app/duas-and-aamal/id6478907381',
      isActive: true,
      orderIndex: 11,
    ),
    WorkModel(
      id: '12',
      title: 'Hoda',
      category: 'Spiritual',
      imageAsset: 'assets/work_hoda.png',
      description: 'Spiritual and practical guide for pilgrimage journeys.',
      tags: ["Spiritual","Travel"],
      playStoreUrl: 'https://play.google.com/store/apps/details?id=app.hoda.com&hl=en',
      appStoreUrl: 'https://apps.apple.com/ae/app/hoda/id6755375239',
      isActive: true,
      orderIndex: 12,
    ),
    WorkModel(
      id: '13',
      title: 'Fragrance of Mastership',
      category: 'Books',
      imageAsset: 'assets/work_fragrance.png',
      description: 'Spiritual book/content application.',
      tags: ["Books","Spiritual"],
      appStoreUrl: 'https://apps.apple.com/ae/app/fragrance-of-mastership/id6480333197',
      isActive: true,
      orderIndex: 13,
    ),
    WorkModel(
      id: '14',
      title: 'Lumio IPTV',
      category: 'Entertainment',
      imageAsset: 'assets/work_lumio.png',
      description: 'IPTV streaming application.',
      tags: ["Entertainment","Streaming"],
      playStoreUrl: 'https://play.google.com/store/apps/details?id=app.lumioiptv.com&hl=en',
      isActive: true,
      orderIndex: 14,
    ),
    WorkModel(
      id: '15',
      title: 'Kokoro Michi',
      category: 'Education',
      imageAsset: 'assets/work_kokoro.png',
      description: 'Educational/Spiritual application.',
      tags: ["Education"],
      playStoreUrl: 'https://play.google.com/store/apps/details?id=app.kokoromichi.com&hl=en',
      isActive: true,
      orderIndex: 15,
    ),
  ];

  /// Get all works
  static List<WorkModel> getAllWorks() {
    return _works;
  }

  /// Get work by ID
  static WorkModel? getWorkById(String id) {
    try {
      return _works.firstWhere((work) => work.id == id);
    } catch (e) {
      return null;
    }
  }
}
