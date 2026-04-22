/// Base repository
/// Provides common functionality for all repositories

import '../services/supabase_service.dart';

abstract class BaseRepository {
  /// Get Supabase client
  dynamic get client {
    final client = SupabaseService.client;
    if (client == null) {
      throw Exception(
        'Supabase not initialized. Please configure SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }

  /// Get table reference
  dynamic getChannel(String channelName) {
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

