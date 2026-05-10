/// Work repository
/// Handles all work/project-related database operations
import 'package:flutter/foundation.dart';
import '../../models/work/work_model.dart';
import '../services/supabase_service.dart';
import 'base_repository.dart';

class WorkRepository extends BaseRepository {
  static const String _tableName = 'works';

  /// Get all active works
  Future<List<WorkModel>> getAllWorks({
    String? locale,
    bool? featured,
    int? limit,
    int? offset,
  }) async {
    // Return empty list if Supabase is not initialized
    if (!SupabaseService.isInitialized) {
      return [];
    }

    // Caching check
    final cacheKey = 'works_${featured ?? false}_${limit ?? 'all'}_${offset ?? 'all'}';
    final cached = getCached<List<WorkModel>>(cacheKey);
    if (cached != null) return cached;

    try {
      // Build query: select first, then filters, then transforms
      // Use dynamic to handle type changes in the chain
      dynamic query = client.from(_tableName).select().eq('is_active', true);

      if (featured != null && featured) {
        query = query.eq('is_featured', true);
      }

      query = query.order('order_index', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      final works = (response as List)
          .map((json) => WorkModel.fromMap(json as Map<String, dynamic>))
          .toList();

      setCache(cacheKey, works);
      return works;
    } catch (e) {
      // Log error but return empty list instead of throwing
      debugPrint('Error fetching works: $e');
      return [];
    }
  }

  /// Get work by ID
  Future<WorkModel?> getWorkById(String id, {String? locale}) async {
    if (!SupabaseService.isInitialized) {
      return null;
    }

    try {
      final response =
          await client
              .from(_tableName)
              .select()
              .eq('id', id)
              .eq('is_active', true)
              .single();

      return WorkModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// Get featured works
  Future<List<WorkModel>> getFeaturedWorks({int limit = 4}) async {
    if (!SupabaseService.isInitialized) {
      return [];
    }

    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('order_index', ascending: true)
          .limit(limit);

      return (response as List)
          .map((json) => WorkModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Log error but return empty list instead of throwing
      debugPrint('Error fetching featured works: $e');
      return [];
    }
  }

  /// Subscribe to work changes
  /// Note: Real-time subscriptions can be implemented here if needed
  Stream<List<WorkModel>> subscribeToWorks() {
    // TODO: Implement real-time subscriptions when needed
    return Stream.value([]);
  }
}
