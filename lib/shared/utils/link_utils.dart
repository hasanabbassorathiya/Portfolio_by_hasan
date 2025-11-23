import 'package:url_launcher/url_launcher.dart';

class LinkUtils {
  /// Launches a URL.
  /// Handles various schemes like http, https, mailto, tel.
  static Future<void> launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri.toString());
    } else {
      // Handle error, e.g., show a snackbar
      // print('Could not launch $url');
      throw 'Could not launch $url';
    }
  }

  /// Launches an email.
  static Future<void> launchEmail(String emailAddress) async {
    final Uri uri = Uri.parse('mailto:$emailAddress');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri.toString());
    } else {
      throw 'Could not launch email to $emailAddress';
    }
  }

  /// Launches a phone call.
  static Future<void> launchPhone(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri.toString());
    } else {
      throw 'Could not launch phone call to $phoneNumber';
    }
  }

  /// Launches a website URL.
  static Future<void> launchWebsite(String websiteUrl) async {
    final Uri uri = Uri.parse(websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri.toString());
    } else {
      throw 'Could not launch website $websiteUrl';
    }
  }
}
