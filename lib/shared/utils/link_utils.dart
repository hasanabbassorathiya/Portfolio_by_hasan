import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher.dart' show LaunchMode;
import 'package:portfolio/core/services/analytics_service.dart';

class LinkUtils {
  /// Launches a URL.
  /// Handles various schemes like http, https, mailto, tel.
  static Future<void> launchUrl(
    String url, {
    String? linkType,
    String? linkName,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        // Track the link click
        final type = linkType ?? _detectLinkType(url);
        final name = linkName ?? _extractLinkName(url);
        AnalyticsService.trackEvent(
          eventName: 'link_clicked',
          eventData: {
            'url': url,
            'link_type': type,
            'link_name': name,
            'scheme': uri.scheme,
          },
        );

        final launched = await url_launcher.launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Open in new tab/window
        );
        if (!launched) {
          throw Exception('Could not launch $url');
        }
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Silently fail - don't break the app if URL launch fails
      debugPrint('Error launching URL $url: $e');
      rethrow;
    }
  }

  /// Detects the type of link based on URL
  static String _detectLinkType(String url) {
    final uri = Uri.parse(url);
    if (uri.scheme == 'mailto') return 'email';
    if (uri.scheme == 'tel') return 'phone';
    if (url.contains('facebook.com')) return 'social_facebook';
    if (url.contains('twitter.com') || url.contains('x.com')) {
      return 'social_twitter';
    }
    if (url.contains('instagram.com')) return 'social_instagram';
    if (url.contains('linkedin.com')) return 'social_linkedin';
    if (url.contains('github.com')) return 'social_github';
    if (url.contains('behance.net')) return 'social_behance';
    if (url.contains('dribbble.com')) return 'social_dribbble';
    if (url.contains('cv') || url.contains('resume')) return 'cv_download';
    return 'external_link';
  }

  /// Extracts a readable name from the URL
  static String _extractLinkName(String url) {
    final uri = Uri.parse(url);
    if (uri.scheme == 'mailto') return uri.path;
    if (uri.scheme == 'tel') return uri.path;
    final host = uri.host.replaceAll('www.', '');
    return host.split('.').first;
  }

  /// Launches an email.
  static Future<void> launchEmail(String emailAddress) async {
    try {
      // Track email click
      AnalyticsService.trackEvent(
        eventName: 'email_clicked',
        eventData: {'email': emailAddress},
      );

      final Uri uri = Uri.parse('mailto:$emailAddress');
      if (await url_launcher.canLaunchUrl(uri)) {
        final launched = await url_launcher.launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          throw Exception('Could not launch email to $emailAddress');
        }
      } else {
        throw Exception('Could not launch email to $emailAddress');
      }
    } catch (e) {
      debugPrint('Error launching email $emailAddress: $e');
      rethrow;
    }
  }

  /// Launches a phone call.
  static Future<void> launchPhone(String phoneNumber) async {
    try {
      // Track phone click
      AnalyticsService.trackEvent(
        eventName: 'phone_clicked',
        eventData: {'phone': phoneNumber},
      );

      final Uri uri = Uri.parse('tel:$phoneNumber');
      if (await url_launcher.canLaunchUrl(uri)) {
        final launched = await url_launcher.launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          throw Exception('Could not launch phone call to $phoneNumber');
        }
      } else {
        throw Exception('Could not launch phone call to $phoneNumber');
      }
    } catch (e) {
      debugPrint('Error launching phone $phoneNumber: $e');
      rethrow;
    }
  }

  /// Launches a website URL.
  static Future<void> launchWebsite(String websiteUrl) async {
    try {
      // Track website click
      AnalyticsService.trackEvent(
        eventName: 'website_clicked',
        eventData: {'url': websiteUrl},
      );

      final Uri uri = Uri.parse(websiteUrl);
      if (await url_launcher.canLaunchUrl(uri)) {
        final launched = await url_launcher.launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          throw Exception('Could not launch website $websiteUrl');
        }
      } else {
        throw Exception('Could not launch website $websiteUrl');
      }
    } catch (e) {
      debugPrint('Error launching website $websiteUrl: $e');
      rethrow;
    }
  }
}
