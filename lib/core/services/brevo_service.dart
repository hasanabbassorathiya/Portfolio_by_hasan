import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class BrevoService {
  static const _baseUrl = 'https://api.brevo.com/v3';

  static Map<String, String> get _headers => {
        'accept': 'application/json',
        'content-type': 'application/json',
        'api-key': AppConfig.brevoApiKey,
      };

  static Future<bool> sendContactEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    if (AppConfig.brevoApiKey.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/smtp/email'),
        headers: _headers,
        body: jsonEncode({
          'sender': {'name': 'Portfolio Contact', 'email': AppConfig.email},
          'to': [
            {'email': AppConfig.email, 'name': 'Hasan Abbas'}
          ],
          'replyTo': [
            {'email': email, 'name': name}
          ],
          'subject': 'Portfolio Contact: $name',
          'htmlContent': '''
            <h3>New contact from portfolio</h3>
            <p><strong>Name:</strong> $name</p>
            <p><strong>Email:</strong> $email</p>
            <p><strong>Message:</strong></p>
            <p>$message</p>
          ''',
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> addSubscriber({
    required String email,
    String? name,
  }) async {
    if (AppConfig.brevoApiKey.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/contacts'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'listIds': [AppConfig.brevoNewsletterListId],
          if (name != null && name.isNotEmpty)
            'attributes': {'FIRSTNAME': name},
        }),
      );
      return response.statusCode == 201 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeSubscriber(String email) async {
    if (AppConfig.brevoApiKey.isEmpty) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/contacts/${Uri.encodeComponent(email)}'),
        headers: _headers,
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
