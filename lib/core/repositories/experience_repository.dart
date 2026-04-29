/// Experience repository
/// Handles all experience-related database operations
import 'package:flutter/foundation.dart';
import 'base_repository.dart';

class ExperienceModel {
  final String id;
  final String company;
  final String position;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final int orderIndex;

  ExperienceModel({
    required this.id,
    required this.company,
    required this.position,
    this.description,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.orderIndex,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    try {
      return ExperienceModel(
        id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        company: map['company']?.toString() ?? 'Unknown Company',
        position: map['position']?.toString() ?? 'Unknown Position',
        description: map['description']?.toString(),
        startDate: (DateTime.tryParse(map['start_date']?.toString() ?? '') ?? DateTime.now()),
        endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date'].toString()) : null,
        isCurrent: map['is_current'] == true || map['is_current'] == 1 || map['is_current'] == '1',
        orderIndex: int.tryParse(map['order_index']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      debugPrint("Error parsing ExperienceModel: $e, map: $map");
      // Return a dummy object to prevent the whole list from breaking
      return ExperienceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        company: 'Error loading item',
        position: '',
        startDate: DateTime.now(),
        isCurrent: false,
        orderIndex: 999,
      );
    }
  }
}

class ExperienceRepository extends BaseRepository {
  static const String _tableName = 'experiences';

  /// Get all experiences
  Future<List<ExperienceModel>> getAllExperiences() async {
    try {
      final response = await client
          .from(_tableName)
          .select('id, company, position, description, start_date, end_date, is_current, order_index')
          .order('order_index', ascending: true);

      debugPrint('Raw Experiences Response: $response');

      return (response as List)
          .map((json) => ExperienceModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch experiences: $e');
      throw Exception('Failed to fetch experiences: $e');
    }
  }
}
