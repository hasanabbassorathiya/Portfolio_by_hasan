class AppBlogData {
  AppBlogData._();

  static const List<Map<String, dynamic>> posts = [
    {
      'id': '1',
      'title': 'Building Scalable Flutter Apps with Clean Architecture',
      'slug': 'scalable-flutter-clean-architecture',
      'excerpt': 'A deep dive into structuring Flutter applications using Clean Architecture, Riverpod, and SOLID principles for enterprise-grade scalability.',
      'category': 'Engineering',
      'readTime': '8 min read',
      'publishedAt': '2025-12-01',
      'tags': ['flutter', 'architecture', 'clean-code'],
    },
    {
      'id': '2',
      'title': 'From Monolith to Modular: Migrating a Large Flutter Codebase',
      'slug': 'monolith-to-modular-flutter',
      'excerpt': 'How we decomposed a 100K+ line Flutter application into modular packages without downtime, and the lessons learned along the way.',
      'category': 'Engineering',
      'readTime': '12 min read',
      'publishedAt': '2025-10-15',
      'tags': ['flutter', 'refactoring', 'architecture'],
    },
    {
      'id': '3',
      'title': 'AI Integration in Mobile Apps: A Practical Guide',
      'slug': 'ai-integration-mobile-apps',
      'excerpt': 'Exploring practical approaches to integrating LLMs, on-device ML, and agentic workflows into production Flutter applications.',
      'category': 'AI',
      'readTime': '10 min read',
      'publishedAt': '2025-09-20',
      'tags': ['ai', 'flutter', 'llm'],
    },
  ];
}
