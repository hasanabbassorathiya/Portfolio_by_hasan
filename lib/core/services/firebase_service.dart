/// Firebase service
/// Centralized Firebase initialization and access
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();

  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static FirebasePerformance? _performance;
  static FirebaseRemoteConfig? _remoteConfig;

  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      try {
        Firebase.app();
        // Already initialized, use existing instance
      } catch (e) {
        // Not initialized, try to initialize
        // For web, Firebase needs to be configured via index.html
        // If not configured, we'll skip Firebase initialization gracefully
        if (kIsWeb) {
          // Skip Firebase initialization for web if not configured
          // Firebase is optional - app works without it
          debugPrint('Firebase web not configured - skipping (optional)');
          return;
        }
        await Firebase.initializeApp();
      }

      // Initialize Analytics (only if Firebase is available)
      try {
        _analytics = FirebaseAnalytics.instance;
      } catch (e) {
        debugPrint('Firebase Analytics not available: $e');
      }

      // Initialize Crashlytics (only for non-web)
      if (!kIsWeb) {
        _crashlytics = FirebaseCrashlytics.instance;
        // Pass all uncaught errors to Crashlytics
        FlutterError.onError = (errorDetails) {
          _crashlytics?.recordFlutterFatalError(errorDetails);
        };
        // Pass uncaught async errors to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics?.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Initialize Performance Monitoring (only if available)
      try {
        _performance = FirebasePerformance.instance;
      } catch (e) {
        debugPrint('Firebase Performance not available: $e');
      }

      // Initialize Remote Config (only if available)
      try {
        _remoteConfig = FirebaseRemoteConfig.instance;
        await _remoteConfig?.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 10),
            minimumFetchInterval: const Duration(hours: 1),
          ),
        );
        await _remoteConfig?.setDefaults({
          'feature_new_design': false,
          'maintenance_mode': false,
          'app_version': '1.0.0',
        });
        await _remoteConfig?.fetchAndActivate();
      } catch (e) {
        debugPrint('Firebase Remote Config not available: $e');
      }
    } catch (e) {
      // Firebase is optional - app can work without it
      debugPrint('Firebase initialization skipped (optional): $e');
    }
  }

  /// Get Analytics instance (nullable - Firebase is optional)
  static FirebaseAnalytics? get analytics => _analytics;

  /// Get Crashlytics instance
  static FirebaseCrashlytics? get crashlytics => _crashlytics;

  /// Get Performance instance
  static FirebasePerformance? get performance => _performance;

  /// Get Remote Config instance
  static FirebaseRemoteConfig? get remoteConfig => _remoteConfig;

  /// Log custom event
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Error logging event: $e');
    }
  }

  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('Error logging screen view: $e');
    }
  }

  /// Set user property
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }

  /// Record error to Crashlytics
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics?.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('Error recording to Crashlytics: $e');
    }
  }

  /// Get Remote Config value
  static String getConfigString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig?.getString(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting config: $e');
      return defaultValue;
    }
  }

  /// Get Remote Config boolean
  static bool getConfigBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig?.getBool(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting config: $e');
      return defaultValue;
    }
  }

  /// Get Remote Config number
  static num getConfigNumber(String key, {num defaultValue = 0}) {
    try {
      return _remoteConfig?.getDouble(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting config: $e');
      return defaultValue;
    }
  }

  /// Fetch and activate Remote Config
  static Future<bool> fetchAndActivateConfig() async {
    try {
      return await _remoteConfig?.fetchAndActivate() ?? false;
    } catch (e) {
      debugPrint('Error fetching config: $e');
      return false;
    }
  }

  /// Check if Firebase is available
  static bool get isAvailable => _analytics != null;
}
