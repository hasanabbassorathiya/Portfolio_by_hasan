/// Work repository
/// Handles all work/project-related database operations
import '../../models/work/work_model.dart';
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
      return (response as List)
          .map((json) => WorkModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch works: $e');
    }
  }

  /// Get work by ID
  Future<WorkModel?> getWorkById(String id, {String? locale}) async {
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
      throw Exception('Failed to fetch featured works: $e');
    }
  }

  /// Subscribe to work changes
  /// Note: Real-time subscriptions can be implemented here if needed
  Stream<List<WorkModel>> subscribeToWorks() {
    // TODO: Implement real-time subscriptions when needed
    return Stream.value([]);
  }
}
