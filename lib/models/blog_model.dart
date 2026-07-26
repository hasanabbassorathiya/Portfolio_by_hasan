class BlogModel {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String? excerpt;
  final String? imageUrl;
  final String author;
  final String? readTime;
  final String? category;
  final List<String> tags;
  final String? publishedAt;
  final bool isPublished;
  final String status;
  final int viewsCount;

  const BlogModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.excerpt,
    this.imageUrl,
    required this.author,
    this.readTime,
    this.category,
    this.tags = const [],
    this.publishedAt,
    this.isPublished = false,
    this.status = 'draft',
    this.viewsCount = 0,
  });

  factory BlogModel.fromMap(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      excerpt: map['excerpt']?.toString(),
      imageUrl: map['image_url']?.toString(),
      author: map['author']?.toString() ?? '',
      readTime: map['read_time']?.toString(),
      category: map['category']?.toString(),
      tags: _parseList(map['tags']),
      publishedAt: map['published_at']?.toString(),
      isPublished: map['is_published'] == true || map['is_published'] == 1,
      status: map['status']?.toString() ?? 'draft',
      viewsCount: map['views_count'] is int ? map['views_count'] : 0,
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
}
