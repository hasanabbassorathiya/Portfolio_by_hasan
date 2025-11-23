/// Blog repository
/// Handles all blog-related database operations
import '../../models/blog/blog_model.dart';
import '../services/performance_service.dart';
import 'base_repository.dart';

class BlogRepository extends BaseRepository {
  static const String _tableName = 'blogs';

  /// Get all published blogs
  Future<List<BlogModel>> getAllBlogs({
    String? locale,
    int? limit,
    int? offset,
  }) async {
    return await PerformanceService.measureDatabaseQuery(
      _tableName,
      () async {
        try {
          dynamic queryBuilder = client
              .from(_tableName)
              .select()
              .eq('is_published', true)
              .order('published_at', ascending: false);

          if (limit != null) {
            queryBuilder = queryBuilder.limit(limit);
          }
          if (offset != null) {
            queryBuilder = queryBuilder.range(offset, offset + (limit ?? 10) - 1);
          }

          final response = await queryBuilder;
          return (response as List)
              .map((json) => BlogModel.fromMap(json as Map<String, dynamic>))
              .toList();
        } catch (e) {
          throw Exception('Failed to fetch blogs: $e');
        }
      },
    );
  }

  /// Get blog by ID
  Future<BlogModel?> getBlogById(String id, {String? locale}) async {
    try {
      final response =
          await client
              .from(_tableName)
              .select()
              .eq('id', id)
              .eq('is_published', true)
              .single();

      return BlogModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// Get blog by slug
  Future<BlogModel?> getBlogBySlug(String slug, {String? locale}) async {
    try {
      final response =
          await client
              .from(_tableName)
              .select()
              .eq('slug', slug)
              .eq('is_published', true)
              .single();

      return BlogModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// Get featured blogs
  Future<List<BlogModel>> getFeaturedBlogs({int limit = 3}) async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_published', true)
          .order('published_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => BlogModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured blogs: $e');
    }
  }

  /// Subscribe to blog changes
  /// Note: Real-time subscriptions can be implemented here if needed
  Stream<List<BlogModel>> subscribeToBlogs() {
    // TODO: Implement real-time subscriptions when needed
    return Stream.value([]);
  }
}
