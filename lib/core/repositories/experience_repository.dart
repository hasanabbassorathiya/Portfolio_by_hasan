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
    try {
      return ExperienceModel(
        id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        company: map['company']?.toString() ?? 'Unknown Company',
        position: map['position']?.toString() ?? 'Unknown Position',
        description: map['description']?.toString(),
        startDate: map['start_date'] \!= null && map['start_date'].toString().isNotEmpty 
            ? DateTime.tryParse(map['start_date'].toString()) ?? DateTime.now() 
            : DateTime.now(),
        endDate: map['end_date'] \!= null && map['end_date'].toString().isNotEmpty
                ? DateTime.tryParse(map['end_date'].toString())
                : null,
        isCurrent: map['is_current'] == true || map['is_current'] == 1 || map['is_current'] == '1',
        orderIndex: int.tryParse(map['order_index']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      print("Error parsing ExperienceModel: $e, map: $map");
      rethrow;
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
          .select('*')
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
