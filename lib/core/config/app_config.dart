/// Application configuration
/// Manages environment variables and app settings
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Web environment detected, skipping .env load.');
      return;
    }
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Warning: .env file not found.');
    }
  }

  static String? _getEnv(String key) {
    if (dotenv.isInitialized) {
      return dotenv.env[key];
    }
    return null;
  }

  static String get tursoUrl {
    String url = _getEnv('TURSO_URL') ?? '';
    if (url.isEmpty && kIsWeb) {
      url = const String.fromEnvironment('TURSO_URL', defaultValue: '');
    }

    if (url.startsWith('libsql://')) {
      url = url.replaceFirst('libsql://', 'https://');
    }

    // Ensure URL ends with /v2/pipeline for the HTTP API
    if (url.isNotEmpty && !url.contains('/v2/pipeline')) {
      if (!url.endsWith('/')) {
        url += '/';
      }
      url += 'v2/pipeline';
    }

    return url;
  }

  static String get tursoToken {
    final fromEnv = _getEnv('TURSO_TOKEN');
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
    final fromEnv = _getEnv('SUPABASE_URL');
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
    final fromEnv = _getEnv('SUPABASE_ANON_KEY');
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
  static String get appName => _getEnv('APP_NAME') ?? 'Portfolio';

  /// Default Locale
  static String get defaultLocale => _getEnv('DEFAULT_LOCALE') ?? 'en';

  /// Supported Locales
  static List<String> get supportedLocales {
    final locales = _getEnv('SUPPORTED_LOCALES') ?? 'en';
    return locales.split(',').map((e) => e.trim()).toList();
  }

  /// Enable Analytics
  static bool get enableAnalytics =>
      _getEnv('ENABLE_ANALYTICS')?.toLowerCase() == 'true';

  /// Enable Crash Reporting
  static bool get enableCrashReporting =>
      _getEnv('ENABLE_CRASH_REPORTING')?.toLowerCase() == 'true';
}
