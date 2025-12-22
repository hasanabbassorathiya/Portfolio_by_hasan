import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher.dart' show LaunchMode;

class LinkUtils {
  /// Launches a URL.
  /// Handles various schemes like http, https, mailto, tel.
  static Future<void> launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
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

  /// Launches an email.
  static Future<void> launchEmail(String emailAddress) async {
    try {
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
