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
  });

  /// Create a work model from a map
  factory WorkModel.fromMap(Map<String, dynamic> map) {
    return WorkModel(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      imageAsset: map['image_url'] as String? ?? map['imageAsset'] as String? ?? '',
      description: map['description'] as String,
      projectUrl: map['project_url'] as String? ?? map['projectUrl'] as String?,
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      client: map['client'] as String?,
      year: map['year'] as String?,
      role: map['role'] as String?,
      technologies:
          (map['technologies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      challenge: map['challenge'] as String?,
      solution: map['solution'] as String?,
      images:
          (map['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
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
