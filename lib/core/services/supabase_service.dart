/// Supabase service
/// Provides centralized access to Supabase client
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient? _client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      final url = AppConfig.supabaseUrl;
      final anonKey = AppConfig.supabaseAnonKey;
      
      if (url.isEmpty || anonKey.isEmpty) {
        // For web, try to get from window.location or use empty initialization
        // This allows the app to load even if Supabase is not configured
        // Individual features will handle the error gracefully
        debugPrint('Supabase credentials not found. App will run in limited mode.');
        return;
      }
      
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _client = Supabase.instance.client;
    } catch (e) {
      // Gracefully handle initialization errors
      debugPrint('Supabase initialization failed: $e');
      debugPrint('App will continue without Supabase features.');
    }
  }

  /// Get Supabase client
  /// Returns null if Supabase is not initialized
  static SupabaseClient? get client => _client;

  /// Get Supabase client (throws if not initialized)
  /// Use this in admin features that require Supabase
  static SupabaseClient get requiredClient {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Please configure SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return _client!;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;

  /// Get storage client
  static SupabaseStorageClient? get storage => _client?.storage;

  /// Get auth client
  static GoTrueClient? get auth => _client?.auth;
}

