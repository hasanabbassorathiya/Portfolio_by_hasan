class ServiceModel {
  final String id;
  final String title;
  final String? description;
  final String? iconUrl;
  final int orderIndex;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.title,
    this.description,
    this.iconUrl,
    this.orderIndex = 0,
    this.isActive = true,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      iconUrl: map['icon_url']?.toString(),
      orderIndex: map['order_index'] is int ? map['order_index'] : 0,
      isActive: map['is_active'] == true || map['is_active'] == 1 || map['is_active'] == 'true',
    );
  }
}
