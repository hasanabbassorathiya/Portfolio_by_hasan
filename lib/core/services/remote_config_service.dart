/// Remote Config Service
/// Manages dynamic app configuration via Firebase Remote Config and Supabase
import 'package:flutter/foundation.dart';
import 'package:portfolio/core/services/firebase_service.dart';
import 'package:portfolio/core/services/supabase_service.dart';

class RemoteConfigService {
  RemoteConfigService._();

  /// Get config value from Firebase Remote Config (with Supabase fallback)
  static Future<String> getString(
    String key, {
    String defaultValue = '',
  }) async {
    try {
      // Try Firebase Remote Config first
      final firebaseValue = FirebaseService.getConfigString(
        key,
        defaultValue: defaultValue,
      );
      if (firebaseValue.isNotEmpty && firebaseValue != defaultValue) {
        return firebaseValue;
      }

      // Fallback to Supabase remote_config table
      try {
        final response = await SupabaseService.client
            .from('remote_config')
            .select('value')
            .eq('key', key)
            .maybeSingle();

        if (response != null && response['value'] != null) {
          final value = response['value'];
          if (value is String) {
            return value;
          }
          return value.toString();
        }
      } catch (e) {
        debugPrint('Error fetching from Supabase remote_config: $e');
      }

      return defaultValue;
    } catch (e) {
      debugPrint('Error getting remote config: $e');
      return defaultValue;
    }
  }

  /// Get boolean config value
  static Future<bool> getBool(
    String key, {
    bool defaultValue = false,
  }) async {
    try {
      // Try Firebase Remote Config first
      final firebaseValue = FirebaseService.getConfigBool(
        key,
        defaultValue: defaultValue,
      );
      if (firebaseValue != defaultValue) {
        return firebaseValue;
      }

      // Fallback to Supabase
      try {
        final response = await SupabaseService.client
            .from('remote_config')
            .select('value')
            .eq('key', key)
            .maybeSingle();

        if (response != null && response['value'] != null) {
          final value = response['value'];
          if (value is bool) {
            return value;
          }
          if (value is String) {
            return value.toLowerCase() == 'true';
          }
        }
      } catch (e) {
        debugPrint('Error fetching from Supabase remote_config: $e');
      }

      return defaultValue;
    } catch (e) {
      debugPrint('Error getting remote config: $e');
      return defaultValue;
    }
  }

  /// Get number config value
  static Future<num> getNumber(
    String key, {
    num defaultValue = 0,
  }) async {
    try {
      // Try Firebase Remote Config first
      final firebaseValue = FirebaseService.getConfigNumber(
        key,
        defaultValue: defaultValue,
      );
      if (firebaseValue != defaultValue) {
        return firebaseValue;
      }

      // Fallback to Supabase
      try {
        final response = await SupabaseService.client
            .from('remote_config')
            .select('value')
            .eq('key', key)
            .maybeSingle();

        if (response != null && response['value'] != null) {
          final value = response['value'];
          if (value is num) {
            return value;
          }
          if (value is String) {
            return num.tryParse(value) ?? defaultValue;
          }
        }
      } catch (e) {
        debugPrint('Error fetching from Supabase remote_config: $e');
      }

      return defaultValue;
    } catch (e) {
      debugPrint('Error getting remote config: $e');
      return defaultValue;
    }
  }

  /// Set config value in Supabase (admin only)
  static Future<void> setConfig({
    required String key,
    required dynamic value,
    String? description,
  }) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) {
        throw Exception('Must be authenticated to set config');
      }

      await SupabaseService.client.from('remote_config').upsert({
        'key': key,
        'value': value,
        'description': description,
        'updated_by': user.id,
      });
    } catch (e) {
      debugPrint('Error setting remote config: $e');
      rethrow;
    }
  }

  /// Fetch and activate Firebase Remote Config
  static Future<bool> fetchAndActivate() async {
    try {
      return await FirebaseService.fetchAndActivateConfig();
    } catch (e) {
      debugPrint('Error fetching remote config: $e');
      return false;
    }
  }

  /// Check if maintenance mode is enabled
  static Future<bool> isMaintenanceMode() async {
    return await getBool('maintenance_mode', defaultValue: false);
  }

  /// Check if a feature is enabled
  static Future<bool> isFeatureEnabled(String featureName) async {
    return await getBool('feature_$featureName', defaultValue: false);
  }

  /// Get app version from remote config
  static Future<String> getAppVersion() async {
    return await getString('app_version', defaultValue: '1.0.0');
  }
}

