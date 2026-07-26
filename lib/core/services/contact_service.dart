import '../../../core/database/portfolio_repository.dart';
import '../../../core/services/brevo_service.dart';

class ContactService {
  static Future<bool> submit({
    required String name,
    required String email,
    required String message,
  }) async {
    final submission = {
      'id': 'contact_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email,
      'message': message,
      'submitted_at': DateTime.now().toIso8601String(),
      'status': 'unread',
    };

    await PortfolioRepository().saveContactSubmission(submission);
    await BrevoService.sendContactEmail(name: name, email: email, message: message);
    return true;
  }
}
