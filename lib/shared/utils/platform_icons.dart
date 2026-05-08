import 'package:font_awesome_flutter/font_awesome_flutter.dart';
/// Platform icons utility
/// Maps social media platforms to their FontAwesome icons
import 'package:flutter/material.dart';


class PlatformIcons {
  PlatformIcons._();

  /// Get icon for a platform
  static dynamic getIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'github':
        return FontAwesomeIcons.github;
      case 'behance':
        return FontAwesomeIcons.behance;
      case 'dribbble':
        return FontAwesomeIcons.dribbble;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'medium':
        return FontAwesomeIcons.medium;
      case 'dev':
      case 'dev.to':
        return FontAwesomeIcons.dev;
      case 'stackoverflow':
        return FontAwesomeIcons.stackOverflow;
      case 'reddit':
        return FontAwesomeIcons.reddit;
      case 'pinterest':
        return FontAwesomeIcons.pinterest;
      case 'snapchat':
        return FontAwesomeIcons.snapchat;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'discord':
        return FontAwesomeIcons.discord;
      case 'telegram':
        return FontAwesomeIcons.telegram;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      default:
        return FontAwesomeIcons.link;
    }
  }

  /// Get color for a platform
  static Color getColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'linkedin':
        return const Color(0xFF0077B5);
      case 'github':
        return const Color(0xFF181717);
      case 'behance':
        return const Color(0xFF1769FF);
      case 'dribbble':
        return const Color(0xFFEA4C89);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'medium':
        return const Color(0xFF000000);
      case 'dev':
      case 'dev.to':
        return const Color(0xFF000000);
      case 'stackoverflow':
        return const Color(0xFFF48024);
      case 'reddit':
        return const Color(0xFFFF4500);
      case 'pinterest':
        return const Color(0xFFBD081C);
      case 'snapchat':
        return const Color(0xFFFFFC00);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'discord':
        return const Color(0xFF5865F2);
      case 'telegram':
        return const Color(0xFF0088CC);
      case 'whatsapp':
        return const Color(0xFF25D366);
      default:
        return Colors.grey;
    }
  }

  /// Get display name for a platform
  static String getDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'dev':
      case 'dev.to':
        return 'Dev.to';
      default:
        return platform[0].toUpperCase() + platform.substring(1);
    }
  }
}

