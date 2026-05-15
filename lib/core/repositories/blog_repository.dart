/// Blog repository
/// Handles all blog-related database operations
import 'package:flutter/foundation.dart';
import '../../models/blog/blog_model.dart';
import '../services/performance_service.dart';
import '../services/supabase_service.dart';
import 'base_repository.dart';

class BlogRepository extends BaseRepository {
  static const String _tableName = 'blogs';

  /// Get all published blogs
  Future<List<BlogModel>> getAllBlogs({
    String? locale,
    int? limit,
    int? offset,
  }) async {
    // Return empty list if Supabase is not initialized
    if (!SupabaseService.isInitialized) {
      return [];
    }

    // Caching check
    final cacheKey = 'blogs_${limit ?? 'all'}_${offset ?? 'all'}';
    final cached = getCached<List<BlogModel>>(cacheKey);
    if (cached != null) return cached;

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
          debugPrint('BlogRepository: Received ${response is List ? response.length : "non-list"} results');

          final blogs = <BlogModel>[];
          if (response is List) {
            for (var i = 0; i < response.length; i++) {
              try {
                blogs.add(BlogModel.fromMap(response[i] as Map<String, dynamic>));
              } catch (e) {
                debugPrint('BlogRepository: Error parsing blog at index $i: $e');
              }
            }
          }

          setCache(cacheKey, blogs);
          return blogs;
        } catch (e) {
          // Log error but return empty list instead of throwing
          debugPrint('Error fetching blogs: $e');
          return [];
        }
      },
    );
  }

  /// Get blog by ID
  /// Also tries to fetch by slug if ID lookup fails
  Future<BlogModel?> getBlogById(String id, {String? locale}) async {
    if (!SupabaseService.isInitialized) {
      debugPrint('BlogRepository: Supabase not initialized');
      return null;
    }

    try {
      debugPrint('BlogRepository: Fetching blog with ID: $id');
      
      // First try with is_published check
      var response = await client
              .from(_tableName)
              .select()
              .eq('id', id)
              .eq('is_published', true)
          .maybeSingle();

      if (response != null) {
        debugPrint('BlogRepository: Blog found (published)');
        return BlogModel.fromMap(response);
      }

      // If not found as published, try without published check (for admin preview)
      debugPrint('BlogRepository: Blog not found as published, trying without published check');
      response = await client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        debugPrint('BlogRepository: Blog found (unpublished)');
        return BlogModel.fromMap(response);
      }

      // If ID lookup fails, try slug as fallback (in case URL uses slug instead of ID)
      debugPrint('BlogRepository: Blog not found with ID, trying slug: $id');
      response = await client
          .from(_tableName)
          .select()
          .eq('slug', id)
          .eq('is_published', true)
          .maybeSingle();

      if (response != null) {
        debugPrint('BlogRepository: Blog found by slug (published)');
      return BlogModel.fromMap(response);
      }

      debugPrint('BlogRepository: Blog not found with ID/slug: $id');
      return null;
    } catch (e, stackTrace) {
      debugPrint('BlogRepository: Error fetching blog by ID: $e');
      debugPrint('BlogRepository: Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get blog by slug
  Future<BlogModel?> getBlogBySlug(String slug, {String? locale}) async {
    if (!SupabaseService.isInitialized) {
      return null;
    }

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
    if (!SupabaseService.isInitialized) {
      return [];
    }

    // Caching check
    final cacheKey = 'featured_blogs_$limit';
    final cached = getCached<List<BlogModel>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_published', true)
          .order('published_at', ascending: false)
          .limit(limit);

      final blogs = <BlogModel>[];
      if (response is List) {
        for (var i = 0; i < response.length; i++) {
          try {
            blogs.add(BlogModel.fromMap(response[i] as Map<String, dynamic>));
          } catch (e) {
            debugPrint('BlogRepository: Error parsing featured blog at index $i: $e');
          }
        }
      }

      setCache(cacheKey, blogs);
      return blogs;
    } catch (e) {
      // Log error but return empty list instead of throwing
      debugPrint('Error fetching featured blogs: $e');
      return [];
    }
  }

  /// Subscribe to blog changes
  /// Note: Real-time subscriptions can be implemented here if needed
  Stream<List<BlogModel>> subscribeToBlogs() {
    // TODO: Implement real-time subscriptions when needed
    return Stream.value([]);
  }
}
