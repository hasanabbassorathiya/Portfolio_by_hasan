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
    return SocialLinkModel(
      id: map['id'] as String,
      profileId: map['profile_id'] as String?,
      platform: map['platform'] as String,
      url: map['url'] as String,
      iconUrl: map['icon_url'] as String?,
      orderIndex: map['order_index'] as int? ?? 0,
    );
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
