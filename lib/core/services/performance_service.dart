/// Performance Monitoring Service
/// Tracks app performance metrics using Firebase Performance
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:portfolio/core/services/firebase_service.dart';

class PerformanceService {
  PerformanceService._();

  /// Start a trace for performance monitoring
  static Trace? startTrace(String traceName) {
    try {
      return FirebaseService.performance?.newTrace(traceName);
    } catch (e) {
      debugPrint('Error starting trace: $e');
      return null;
    }
  }

  /// Start a trace and return a disposable object
  static Future<T> measurePerformance<T>(
    String traceName,
    Future<T> Function() operation,
  ) async {
    final trace = startTrace(traceName);
    trace?.start();

    try {
      final result = await operation();
      trace?.stop();
      return result;
    } catch (e) {
      trace?.stop();
      rethrow;
    }
  }

  /// Measure HTTP request performance
  static Future<T> measureHttpRequest<T>(
    String url,
    Future<T> Function() request,
  ) async {
    final trace = startTrace('http_request');
    trace?.start();

    // Add custom attributes
    trace?.setMetric('url', url.length);
    trace?.putAttribute('url', url);

    try {
      final result = await request();
      trace?.stop();
      return result;
    } catch (e) {
      trace?.putAttribute('error', e.toString());
      trace?.stop();
      rethrow;
    }
  }

  /// Measure database query performance
  static Future<T> measureDatabaseQuery<T>(
    String tableName,
    Future<T> Function() query,
  ) async {
    final trace = startTrace('database_query');
    trace?.start();

    trace?.putAttribute('table', tableName);

    try {
      final result = await query();
      trace?.stop();
      return result;
    } catch (e) {
      trace?.putAttribute('error', e.toString());
      trace?.stop();
      rethrow;
    }
  }

  /// Measure image load performance
  static Future<T> measureImageLoad<T>(
    String imageUrl,
    Future<T> Function() loadOperation,
  ) async {
    final trace = startTrace('image_load');
    trace?.start();

    trace?.putAttribute('image_url', imageUrl);

    try {
      final result = await loadOperation();
      trace?.stop();
      return result;
    } catch (e) {
      trace?.putAttribute('error', e.toString());
      trace?.stop();
      rethrow;
    }
  }

  /// Measure screen render performance
  static Future<T> measureScreenRender<T>(
    String screenName,
    Future<T> Function() renderOperation,
  ) async {
    final trace = startTrace('screen_render');
    trace?.start();

    trace?.putAttribute('screen', screenName);

    try {
      final result = await renderOperation();
      trace?.stop();
      return result;
    } catch (e) {
      trace?.putAttribute('error', e.toString());
      trace?.stop();
      rethrow;
    }
  }
}

