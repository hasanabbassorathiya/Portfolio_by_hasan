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

  const TestimonialModel({
    required this.id,
    required this.clientName,
    this.clientRole,
    this.clientCompany,
    this.clientImageUrl,
    required this.quote,
    this.rating,
    this.orderIndex = 0,
    this.isActive = true,
  });

  factory TestimonialModel.fromMap(Map<String, dynamic> map) {
    return TestimonialModel(
      id: map['id']?.toString() ?? '',
      clientName: map['client_name']?.toString() ?? '',
      clientRole: map['client_role']?.toString(),
      clientCompany: map['client_company']?.toString(),
      clientImageUrl: map['client_image_url']?.toString(),
      quote: map['quote']?.toString() ?? '',
      rating: map['rating'] is int ? map['rating'] : null,
      orderIndex: map['order_index'] is int ? map['order_index'] : 0,
      isActive: map['is_active'] == true || map['is_active'] == 1,
    );
  }
}
