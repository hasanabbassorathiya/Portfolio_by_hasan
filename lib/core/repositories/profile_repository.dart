/// Profile repository
/// Handles profile-related database operations
import '../../models/profile/profile_model.dart';
import 'base_repository.dart';

class ProfileRepository extends BaseRepository {
  static const String _tableName = 'profiles';

  /// Get profile
  Future<ProfileModel?> getProfile() async {
    try {
      final response = await client.from(_tableName).select().maybeSingle();
      if (response == null) return null;
      return ProfileModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Update profile
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await client
          .from(_tableName)
          .update(profile.toMap())
          .eq('id', profile.id);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
