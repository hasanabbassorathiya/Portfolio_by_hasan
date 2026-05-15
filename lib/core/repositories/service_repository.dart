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

      final services = <ServiceModel>[];
      if (response is List) {
        for (var i = 0; i < response.length; i++) {
          try {
            services.add(ServiceModel.fromMap(response[i] as Map<String, dynamic>));
          } catch (e) {
            debugPrint('ServiceRepository: Error parsing service at index $i: $e');
          }
        }
      }
      return services;
    } catch (e) {
      debugPrint('Failed to fetch services: $e');
      return [];
    }
  }

  /// Get all services (including inactive)
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('order_index', ascending: true);

      final services = <ServiceModel>[];
      if (response is List) {
        for (var i = 0; i < response.length; i++) {
          try {
            services.add(ServiceModel.fromMap(response[i] as Map<String, dynamic>));
          } catch (e) {
            debugPrint('ServiceRepository: Error parsing service at index $i: $e');
          }
        }
      }
      return services;
    } catch (e) {
      debugPrint('Failed to fetch services: $e');
      return [];
    }
  }
}
