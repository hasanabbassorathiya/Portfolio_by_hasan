/// Testimonial repository
/// Handles all testimonial-related database operations
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import 'base_repository.dart';

class TestimonialModel {
  final String id;
  final String clientName;
  final String? clientRole;
  final String? clientCompany;
  final String? clientImageUrl;
  final String quote;
  final int? rating;
  final int orderIndex;
  final bool isActive;

  TestimonialModel({
    required this.id,
    required this.clientName,
    this.clientRole,
    this.clientCompany,
    this.clientImageUrl,
    required this.quote,
    this.rating,
    required this.orderIndex,
    required this.isActive,
  });

  factory TestimonialModel.fromMap(Map<String, dynamic> map) {
    return TestimonialModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: map['client_name']?.toString() ?? 'Anonymous',
      clientRole: map['client_role']?.toString(),
      clientCompany: map['client_company']?.toString(),
      clientImageUrl: map['client_image_url']?.toString(),
      quote: map['quote']?.toString() ?? '',
      rating: map['rating'] is int ? map['rating'] as int : (int.tryParse(map['rating']?.toString() ?? '')),
      orderIndex: map['order_index'] is int ? map['order_index'] as int : (int.tryParse(map['order_index']?.toString() ?? '') ?? 0),
      isActive: map['is_active'] == true || map['is_active'] == 1 || map['is_active'] == 'true' || map['is_active'] == '1',
    );
  }
}

class TestimonialRepository extends BaseRepository {
  static const String _tableName = 'testimonials';

  /// Get all active testimonials
  Future<List<TestimonialModel>> getActiveTestimonials() async {
    // Return empty list if Supabase is not initialized
    if (!SupabaseService.isInitialized) {
      return [];
    }

    // Caching check
    final cacheKey = 'testimonials_active';
    final cached = getCached<List<TestimonialModel>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final testimonials = <TestimonialModel>[];
      if (response is List) {
        for (var i = 0; i < response.length; i++) {
          try {
            testimonials.add(TestimonialModel.fromMap(response[i] as Map<String, dynamic>));
          } catch (e) {
            debugPrint('TestimonialRepository: Error parsing testimonial at index $i: $e');
          }
        }
      }

      setCache(cacheKey, testimonials);
      return testimonials;
    } catch (e) {
      // Log error but return empty list instead of throwing
      debugPrint('Error fetching testimonials: $e');
      return [];
    }
  }
}
