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
      id: map['id'] as String,
      clientName: map['client_name'] as String,
      clientRole: map['client_role'] as String?,
      clientCompany: map['client_company'] as String?,
      clientImageUrl: map['client_image_url'] as String?,
      quote: map['quote'] as String,
      rating: map['rating'] as int?,
      orderIndex: map['order_index'] as int? ?? 0,
      isActive: map['is_active'] as bool? ?? true,
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

    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => TestimonialModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Log error but return empty list instead of throwing
      debugPrint('Error fetching testimonials: $e');
      return [];
    }
  }
}
