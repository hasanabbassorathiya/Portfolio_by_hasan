/// Base repository
/// Provides common functionality for all repositories
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

abstract class BaseRepository {
  /// Get Supabase client
  SupabaseClient get client {
    final client = SupabaseService.client;
    if (client == null) {
      throw Exception(
        'Supabase not initialized. Please configure SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }

  /// Get table reference
  RealtimeChannel getChannel(String channelName) {
    return client.channel(channelName);
  }

  /// Subscribe to table changes
  /// Note: Real-time subscriptions can be implemented here if needed
  Stream<List<Map<String, dynamic>>> subscribeToTable(
    String tableName, {
    String? filter,
  }) {
    // TODO: Implement real-time subscriptions when needed
    // For now, return an empty stream
    return Stream.value([]);
  }
}

