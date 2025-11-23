/// Experience repository
/// Handles all experience-related database operations
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
    return ExperienceModel(
      id: map['id'] as String,
      company: map['company'] as String,
      position: map['position'] as String,
      description: map['description'] as String?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate:
          map['end_date'] != null
              ? DateTime.parse(map['end_date'] as String)
              : null,
      isCurrent: map['is_current'] as bool? ?? false,
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }
}

class ExperienceRepository extends BaseRepository {
  static const String _tableName = 'experiences';

  /// Get all experiences
  Future<List<ExperienceModel>> getAllExperiences() async {
    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('order_index', ascending: true)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => ExperienceModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch experiences: $e');
    }
  }
}
