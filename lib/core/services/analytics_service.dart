/// Analytics service
/// Tracks user behavior and app events
import 'package:flutter/foundation.dart';
import 'package:portfolio/core/services/firebase_service.dart';
import 'package:portfolio/core/services/supabase_service.dart';

class AnalyticsService {
  AnalyticsService._();

  /// Track page view
  static Future<void> trackPageView({
    required String pagePath,
    String? pageTitle,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Log to Firebase Analytics
      await FirebaseService.logScreenView(
        screenName: pagePath,
        screenClass: pageTitle,
      );

      // Store in Supabase for custom analytics
      // Check if table exists first (gracefully handle missing tables)
      try {
        await SupabaseService.client.from('page_views').insert({
          'page_path': pagePath,
          'page_title': pageTitle,
          'additional_data': additionalData,
        });
      } catch (e) {
        // Table might not exist yet - this is okay during development
        // Run migration 003_analytics_and_config.sql to create the table
        if (e.toString().contains('page_views')) {
          debugPrint(
            'Analytics table not found. Run migration 003_analytics_and_config.sql',
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      // Silently fail - analytics should not break the app
      debugPrint('Analytics error: $e');
    }
  }

  /// Track custom event
  static Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      // Log to Firebase Analytics
      await FirebaseService.logEvent(
        name: eventName,
        parameters: eventData?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      // Store in Supabase
      // Check if table exists first (gracefully handle missing tables)
      try {
        await SupabaseService.client.from('custom_events').insert({
          'event_name': eventName,
          'event_data': eventData,
        });
      } catch (e) {
        // Table might not exist yet - this is okay during development
        if (e.toString().contains('custom_events')) {
          debugPrint(
            'Analytics table not found. Run migration 003_analytics_and_config.sql',
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Track work view
  static Future<void> trackWorkView(String workId) async {
    await trackEvent(eventName: 'work_viewed', eventData: {'work_id': workId});
  }

  /// Track blog view
  static Future<void> trackBlogView(String blogId) async {
    await trackEvent(eventName: 'blog_viewed', eventData: {'blog_id': blogId});
  }

  /// Track contact form submission
  static Future<void> trackContactSubmission() async {
    await trackEvent(eventName: 'contact_form_submitted');
  }

  /// Track button click
  static Future<void> trackButtonClick({
    required String buttonName,
    String? location,
  }) async {
    await trackEvent(
      eventName: 'button_clicked',
      eventData: {'button_name': buttonName, 'location': location},
    );
  }

  /// Track download
  static Future<void> trackDownload({
    required String fileType,
    required String fileName,
  }) async {
    await trackEvent(
      eventName: 'file_downloaded',
      eventData: {'file_type': fileType, 'file_name': fileName},
    );
  }

  /// Set user ID for analytics
  static Future<void> setUserId(String? userId) async {
    try {
      await FirebaseService.analytics?.setUserId(id: userId);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userType,
    String? subscriptionTier,
  }) async {
    try {
      if (userType != null) {
        await FirebaseService.setUserProperty(
          name: 'user_type',
          value: userType,
        );
      }
      if (subscriptionTier != null) {
        await FirebaseService.setUserProperty(
          name: 'subscription_tier',
          value: subscriptionTier,
        );
      }
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}
