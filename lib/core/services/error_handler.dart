/// Global Error Handler
/// Centralized error handling with Crashlytics integration
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/core/services/firebase_service.dart';

class ErrorHandler {
  ErrorHandler._();

  /// Initialize global error handlers
  static void initialize() {
    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _recordError(
        details.exception,
        details.stack,
        reason: details.context?.toString(),
        fatal: true,
      );
    };

    // Platform errors (async errors outside Flutter)
    PlatformDispatcher.instance.onError = (error, stack) {
      _recordError(error, stack, fatal: true);
      return true; // Handled
    };
  }

  /// Record error to Crashlytics and log
  static Future<void> _recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      if (reason != null) {
        debugPrint('Reason: $reason');
      }
    }

    // Record to Crashlytics
    await FirebaseService.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Handle and record an error
  static Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    BuildContext? context,
    String? userMessage,
  }) async {
    await _recordError(error, stackTrace, reason: reason, fatal: fatal);

    // Show user-friendly message if context is provided
    if (context != null && userMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// Wrap a function with error handling
  static Future<T?> safeCall<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    String? errorMessage,
    BuildContext? context,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      await handleError(
        e,
        stackTrace,
        reason: errorMessage,
        context: context,
        userMessage: errorMessage ?? 'An error occurred. Please try again.',
      );
      return defaultValue;
    }
  }
}

