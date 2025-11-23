/// Contact repository
/// Handles contact form submissions
import 'base_repository.dart';

class ContactRepository extends BaseRepository {
  static const String _tableName = 'contact_messages';

  /// Submit a contact message
  Future<void> submitContactMessage({
    required String name,
    required String email,
    required String message,
    String? attachmentUrl,
  }) async {
    try {
      await client.from(_tableName).insert({
        'name': name,
        'email': email,
        'message': message,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      });
    } catch (e) {
      throw Exception('Failed to submit contact message: $e');
    }
  }
}
