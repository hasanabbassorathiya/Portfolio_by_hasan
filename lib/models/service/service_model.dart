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
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      iconUrl: map['icon_url'] as String?,
      orderIndex: map['order_index'] as int? ?? 0,
      isActive: map['is_active'] as bool? ?? true,
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
