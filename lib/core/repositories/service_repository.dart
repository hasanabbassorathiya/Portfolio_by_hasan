/// Service repository
/// Handles service-related database operations
import '../../models/service/service_model.dart';
import 'base_repository.dart';

class ServiceRepository extends BaseRepository {
  static const String _tableName = 'services';

  /// Get all active services
  Future<List<ServiceModel>> getActiveServices() async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => ServiceModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  /// Get all services (including inactive)
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => ServiceModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }
}
