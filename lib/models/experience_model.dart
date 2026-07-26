class ExperienceModel {
  final String id;
  final String company;
  final String position;
  final String? description;
  final String startDate;
  final String? endDate;
  final bool isCurrent;
  final int orderIndex;

  const ExperienceModel({
    required this.id,
    required this.company,
    required this.position,
    this.description,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.orderIndex = 0,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      id: map['id']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      position: map['position']?.toString() ?? '',
      description: map['description']?.toString(),
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString(),
      isCurrent: map['is_current'] == true || map['is_current'] == 1,
      orderIndex: map['order_index'] is int ? map['order_index'] : 0,
    );
  }
}
