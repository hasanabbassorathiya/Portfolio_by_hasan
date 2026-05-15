/// Service model
/// Represents a service offering
class ServiceModel {
  final String id;
  final String title;
  final String? description;
  final String? iconUrl;
  final int orderIndex;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.title,
    this.description,
    this.iconUrl,
    required this.orderIndex,
    required this.isActive,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? 'Unknown Service',
      description: map['description']?.toString(),
      iconUrl: map['icon_url']?.toString(),
      orderIndex: map['order_index'] is int ? map['order_index'] as int : (int.tryParse(map['order_index']?.toString() ?? '') ?? 0),
      isActive: map['is_active'] == true || map['is_active'] == 1 || map['is_active'] == 'true' || map['is_active'] == '1',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_url': iconUrl,
      'order_index': orderIndex,
      'is_active': isActive,
    };
  }
}
