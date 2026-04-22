/// Profile image widget
/// Displays profile image from database or fallback to asset
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:portfolio/core/repositories/profile_repository.dart';
import 'package:portfolio/shared/constants/assets.dart';

class ProfileImageWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? fallbackAsset;
  final Key? refreshKey; // Use this to force refresh by changing the key

  const ProfileImageWidget({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset,
    this.refreshKey,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  String? _profileImageUrl;
  bool _isLoading = true;
  int _refreshCounter = 0; // For cache busting

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
  void didUpdateWidget(ProfileImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if refreshKey changed or if widget key changed (force refresh)
    if (widget.refreshKey != oldWidget.refreshKey || 
        widget.key != oldWidget.key) {
      _loadProfileImage();
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      debugPrint('ProfileImageWidget: Loading profile image...');
      setState(() {
        _isLoading = true;
      });
      
      final repository = ProfileRepository();
      final profile = await repository.getProfile();
      if (mounted) {
        debugPrint('ProfileImageWidget: Profile loaded - avatarUrl: ${profile?.avatarUrl}');
        setState(() {
          _profileImageUrl = profile?.avatarUrl;
          _isLoading = false;
          _refreshCounter++; // Increment to force image reload
        });
        debugPrint('ProfileImageWidget: Image URL set to: $_profileImageUrl');
        debugPrint('ProfileImageWidget: Refresh counter: $_refreshCounter');
      }
    } catch (e) {
      debugPrint('ProfileImageWidget: Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final imageUrl = _profileImageUrl;
    final fallback = widget.fallbackAsset ?? AppAssets.user;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Add cache-busting parameter to force reload
      final cacheBustUrl = imageUrl.contains('?')
          ? '$imageUrl&_refresh=$_refreshCounter'
          : '$imageUrl?_refresh=$_refreshCounter';
      
      return Image.network(
        cacheBustUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        key: ValueKey('profile_image_$_refreshCounter'), // Force rebuild with new key
        errorBuilder: (context, error, stackTrace) {
          // Fallback to asset if network image fails
          return Image.asset(
            fallback,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }

    // Fallback to asset
    return Image.asset(
      fallback,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}

