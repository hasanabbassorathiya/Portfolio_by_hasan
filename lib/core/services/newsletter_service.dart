import '../../../core/database/portfolio_repository.dart';
import '../../../core/services/brevo_service.dart';

class NewsletterService {
  static Future<bool> subscribe(String email, {String? name}) async {
    final subscriber = {
      'id': 'sub_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'name': name ?? '',
      'source': 'website',
      'subscribed_at': DateTime.now().toIso8601String(),
      'is_active': 1,
    };

    await PortfolioRepository().saveSubscriber(subscriber);
    await BrevoService.addSubscriber(email: email, name: name);
    return true;
  }

  static Future<bool> unsubscribe(String email) async {
    await BrevoService.removeSubscriber(email);
    return true;
  }
}
