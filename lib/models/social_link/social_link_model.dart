/// Social link model
/// Represents a social media link
class SocialLinkModel {
  final String id;
  final String? profileId;
  final String platform;
  final String url;
  final String? iconUrl;
  final int orderIndex;

  SocialLinkModel({
    required this.id,
    this.profileId,
    required this.platform,
    required this.url,
    this.iconUrl,
    required this.orderIndex,
  });

  factory SocialLinkModel.fromMap(Map<String, dynamic> map) {
    try {
      return SocialLinkModel(
        id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        profileId: map['profile_id']?.toString(),
        platform: map['platform']?.toString() ?? 'unknown',
        url: map['url']?.toString() ?? '',
        iconUrl: map['icon_url']?.toString(),
        orderIndex: int.tryParse(map['order_index']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      print("Error parsing SocialLinkModel: $e, map: $map");
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'platform': platform,
      'url': url,
      'icon_url': iconUrl,
      'order_index': orderIndex,
    };
  }
}
