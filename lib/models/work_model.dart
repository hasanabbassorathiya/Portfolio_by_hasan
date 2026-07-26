class WorkModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String? projectUrl;
  final String? client;
  final String? year;
  final String? role;
  final String? challenge;
  final String? solution;
  final List<String> tags;
  final List<String> technologies;
  final List<String> images;
  final int orderIndex;
  final bool isFeatured;
  final bool isActive;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final String? appIconUrl;

  const WorkModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.projectUrl,
    this.client,
    this.year,
    this.role,
    this.challenge,
    this.solution,
    this.tags = const [],
    this.technologies = const [],
    this.images = const [],
    this.orderIndex = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.playStoreUrl,
    this.appStoreUrl,
    this.appIconUrl,
  });

  factory WorkModel.fromMap(Map<String, dynamic> map) {
    return WorkModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      projectUrl: map['project_url']?.toString(),
      client: map['client']?.toString(),
      year: map['year']?.toString(),
      role: map['role']?.toString(),
      challenge: map['challenge']?.toString(),
      solution: map['solution']?.toString(),
      tags: _parseList(map['tags']),
      technologies: _parseList(map['technologies']),
      images: _parseList(map['images']),
      orderIndex: _parseInt(map['order_index']),
      isFeatured: _parseBool(map['is_featured']),
      isActive: _parseBool(map['is_active']),
      playStoreUrl: map['play_store_url']?.toString(),
      appStoreUrl: map['app_store_url']?.toString(),
      appIconUrl: map['app_icon_url']?.toString(),
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[{}"]'), '').trim();
      if (cleaned.isEmpty) return [];
      return cleaned.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value == 'true' || value == '1';
    return false;
  }
}
