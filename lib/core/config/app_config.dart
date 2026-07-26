import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get tursoUrl {
    final raw = dotenv.env['TURSO_URL'] ?? const String.fromEnvironment('TURSO_URL', defaultValue: '');
    return raw
        .replaceAll('libsql://', 'https://')
        .replaceAll('http://', 'https://')
        .replaceAll(RegExp(r'/$'), '')
        .endsWith('/v2/pipeline')
        ? raw
            .replaceAll('libsql://', 'https://')
            .replaceAll('http://', 'https://')
            .replaceAll(RegExp(r'/$'), '')
        : '${raw.replaceAll('libsql://', 'https://').replaceAll('http://', 'https://').replaceAll(RegExp(r'/$'), '')}/v2/pipeline';
  }

  static String get tursoToken =>
      dotenv.env['TURSO_TOKEN'] ?? const String.fromEnvironment('TURSO_TOKEN', defaultValue: '');

  static String get brevoApiKey =>
      dotenv.env['BREVO_API_KEY'] ?? const String.fromEnvironment('BREVO_API_KEY', defaultValue: '');

  static int get brevoNewsletterListId {
    final raw = dotenv.env['BREVO_NEWSLETTER_LIST_ID'] ??
        const String.fromEnvironment('BREVO_NEWSLETTER_LIST_ID', defaultValue: '2');
    return int.tryParse(raw) ?? 2;
  }

  static String get calComUsername => 'hasanabbassorathiya';
  static String get buyMeACoffeeUrl => 'https://buymeacoffee.com/hasanabbassorathiya';
  static String get resumeUrl => 'https://flowcv.com/resume/pmesjl0q9sm9';
  static String get linkedInUrl => 'https://linkedin.com/in/hasanabbassorathiya';
  static String get email => 'hasanabbassorathiya12@gmail.com';

  static bool get isWeb => identical(0, 0.0);
}
