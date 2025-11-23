/// Supabase service
/// Provides centralized access to Supabase client
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient? _client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    final url = AppConfig.supabaseUrl;
    final anonKey = AppConfig.supabaseAnonKey;
    
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'Supabase credentials not found. Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env file or as environment variables.',
      );
    }
    
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Get storage client
  static SupabaseStorageClient get storage => client.storage;

  /// Get auth client
  static GoTrueClient get auth => client.auth;
}

