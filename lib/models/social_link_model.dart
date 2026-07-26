class SocialLinkModel {
  final String id;
  final String platform;
  final String url;
  final int orderIndex;

  const SocialLinkModel({
    required this.id,
    required this.platform,
    required this.url,
    this.orderIndex = 0,
  });

  factory SocialLinkModel.fromMap(Map<String, dynamic> map) {
    return SocialLinkModel(
      id: map['id']?.toString() ?? '',
      platform: map['platform']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      orderIndex: map['order_index'] is int ? map['order_index'] : 0,
    );
  }
}
