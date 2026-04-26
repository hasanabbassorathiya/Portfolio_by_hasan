/// Blog post model
/// Represents a blog post with all its properties
class BlogModel {
  final String id;
  final String title;
  final String date;
  final String imageAsset;
  final String content;
  final String author;
  final List<String> tags;
  final String? readTime;
  final String? category;

  const BlogModel({
    required this.id,
    required this.title,
    required this.date,
    required this.imageAsset,
    required this.content,
    required this.author,
    this.tags = const [],
    this.readTime,
    this.category,
  });

  /// Create a blog model from a map
  factory BlogModel.fromMap(Map<String, dynamic> map) {
    // Handle both Supabase format and legacy format
    final publishedAt = map['published_at'] as String?;
    final createdAt = map['created_at'] as String?;
    
    // Format date from ISO string or use provided date
    String formattedDate = map['date'] as String? ?? '';
    if (publishedAt != null) {
      try {
        final date = (DateTime.tryParse(publishedAt.toString()) ?? DateTime.now());
        formattedDate = '${date.day} ${_getMonthName(date.month)}, ${date.year}';
      } catch (e) {
        formattedDate = publishedAt;
      }
    } else if (createdAt != null && formattedDate.isEmpty) {
      try {
        final date = (DateTime.tryParse(createdAt.toString()) ?? DateTime.now());
        formattedDate = '${date.day} ${_getMonthName(date.month)}, ${date.year}';
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    return BlogModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String,
      date: formattedDate,
      imageAsset: map['image_url'] as String? ?? map['imageAsset'] as String? ?? '',
      content: map['content'] as String,
      author: map['author'] as String? ?? 'Hasan Abbas Sorathiya',
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      readTime: map['read_time'] as String? ?? map['readTime'] as String?,
      category: map['category'] as String?,
    );
  }

  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Convert blog model to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'imageAsset': imageAsset,
      'content': content,
      'author': author,
      'tags': tags,
      'readTime': readTime,
      'category': category,
    };
  }
}

/// Blog repository for managing blog data
class BlogRepository {
  static final List<BlogModel> _blogs = [
    BlogModel(
      id: '1',
      title: '12 unique example of portfolio websites',
      date: '10 July, 2022',
      imageAsset: 'assets/blogs/blog1.png',
      author: 'Hasan Abbas Sorathiya',
      content: '''
# 12 Unique Examples of Portfolio Websites

Portfolio websites are essential for showcasing your work and skills. In this article, we'll explore 12 unique portfolio website examples that stand out from the crowd.

## Introduction

A well-designed portfolio website can make all the difference in attracting clients and opportunities. These examples demonstrate creative approaches to portfolio design.

## Key Features

1. **Minimalist Design** - Clean and focused layouts
2. **Interactive Elements** - Engaging user experiences
3. **Responsive Design** - Works on all devices
4. **Performance** - Fast loading times
5. **Accessibility** - Inclusive design practices

## Conclusion

These portfolio examples show that creativity and functionality can work together to create memorable experiences.
      ''',
      tags: ['Design', 'Portfolio', 'Web Development'],
      readTime: '5 min read',
      category: 'Design',
    ),
    BlogModel(
      id: '2',
      title: '12 unique example of portfolio websites',
      date: '10 July, 2022',
      imageAsset: 'assets/blogs/blog2-2bfb9d.png',
      author: 'Hasan Abbas Sorathiya',
      content: '''
# 12 Unique Examples of Portfolio Websites

Portfolio websites are essential for showcasing your work and skills. In this article, we'll explore 12 unique portfolio website examples that stand out from the crowd.

## Introduction

A well-designed portfolio website can make all the difference in attracting clients and opportunities. These examples demonstrate creative approaches to portfolio design.

## Key Features

1. **Minimalist Design** - Clean and focused layouts
2. **Interactive Elements** - Engaging user experiences
3. **Responsive Design** - Works on all devices
4. **Performance** - Fast loading times
5. **Accessibility** - Inclusive design practices

## Conclusion

These portfolio examples show that creativity and functionality can work together to create memorable experiences.
      ''',
      tags: ['Design', 'Portfolio', 'Web Development'],
      readTime: '5 min read',
      category: 'Design',
    ),
    BlogModel(
      id: '3',
      title: '12 unique example of portfolio websites',
      date: '10 July, 2022',
      imageAsset: 'assets/blogs/blog3.png',
      author: 'Hasan Abbas Sorathiya',
      content: '''
# 12 Unique Examples of Portfolio Websites

Portfolio websites are essential for showcasing your work and skills. In this article, we'll explore 12 unique portfolio website examples that stand out from the crowd.

## Introduction

A well-designed portfolio website can make all the difference in attracting clients and opportunities. These examples demonstrate creative approaches to portfolio design.

## Key Features

1. **Minimalist Design** - Clean and focused layouts
2. **Interactive Elements** - Engaging user experiences
3. **Responsive Design** - Works on all devices
4. **Performance** - Fast loading times
5. **Accessibility** - Inclusive design practices

## Conclusion

These portfolio examples show that creativity and functionality can work together to create memorable experiences.
      ''',
      tags: ['Design', 'Portfolio', 'Web Development'],
      readTime: '5 min read',
      category: 'Design',
    ),
  ];

  /// Get all blogs
  static List<BlogModel> getAllBlogs() {
    return _blogs;
  }

  /// Get blog by ID
  static BlogModel? getBlogById(String id) {
    try {
      return _blogs.firstWhere((blog) => blog.id == id);
    } catch (e) {
      return null;
    }
  }
}
