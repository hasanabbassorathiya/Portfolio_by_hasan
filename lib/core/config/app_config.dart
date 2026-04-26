/// Application configuration
/// Manages environment variables and app settings
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get tursoUrl {
    final fromEnv = dotenv.env['TURSO_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) {
      const fromBuild = String.fromEnvironment('TURSO_URL', defaultValue: '');
      if (fromBuild.isNotEmpty) return fromBuild;
    }
    return '';
  }

  static String get tursoToken {
    final fromEnv = dotenv.env['TURSO_TOKEN'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) {
      const fromBuild = String.fromEnvironment('TURSO_TOKEN', defaultValue: '');
      if (fromBuild.isNotEmpty) return fromBuild;
    }
    return '';
  }

  /// Supabase URL
  /// For web, also check for build-time environment variables
  static String get supabaseUrl {
    // Try dotenv first
    final fromEnv = dotenv.env['SUPABASE_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }
    
    // For web, try build-time constants (set via --dart-define)
    if (kIsWeb) {
      // These are set at build time via --dart-define
      const fromBuild = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      if (fromBuild.isNotEmpty) {
        return fromBuild;
      }
    }
    
    return '';
  }

  /// Supabase Anon Key
  /// For web, also check for build-time environment variables
  static String get supabaseAnonKey {
    // Try dotenv first
    final fromEnv = dotenv.env['SUPABASE_ANON_KEY'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }
    
    // For web, try build-time constants (set via --dart-define)
    if (kIsWeb) {
      // These are set at build time via --dart-define
      const fromBuild = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
      if (fromBuild.isNotEmpty) {
        return fromBuild;
      }
    }
    
    return '';
  }

  /// App Name
  static String get appName => dotenv.env['APP_NAME'] ?? 'Portfolio';

  /// Default Locale
  static String get defaultLocale => dotenv.env['DEFAULT_LOCALE'] ?? 'en';

  /// Supported Locales
  static List<String> get supportedLocales {
    final locales = dotenv.env['SUPPORTED_LOCALES'] ?? 'en';
    return locales.split(',').map((e) => e.trim()).toList();
  }

  /// Enable Analytics
  static bool get enableAnalytics =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';

  /// Enable Crash Reporting
  static bool get enableCrashReporting =>
      dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true';

  /// Initialize configuration
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // For web, .env might not be available as an asset
      // Use default values or environment variables
      // In production, set these via build-time environment variables
      if (kIsWeb) {
        // Try to get from window.location or use defaults
        // For now, we'll use empty strings and let the user set them
        // via environment variables at build time
      }
    }
  }
}
