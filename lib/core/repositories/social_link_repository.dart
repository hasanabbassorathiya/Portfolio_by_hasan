/// Social link repository
/// Handles social link-related database operations
import '../../models/social_link/social_link_model.dart';
import 'base_repository.dart';

class SocialLinkRepository extends BaseRepository {
  static const String _tableName = 'social_links';

  /// Get all social links
  Future<List<SocialLinkModel>> getAllSocialLinks({String? profileId}) async {
    try {
      dynamic query = client.from(_tableName).select();

      if (profileId \!= null) {
        query = query.eq('profile_id', profileId);
      }

      query = query.order('order_index', ascending: true);

      final response = await query;
      return (response as List)
          .map((json) => SocialLinkModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Failed to fetch social links: $e');
      throw Exception('Failed to fetch social links: $e');
    }
  }
}
