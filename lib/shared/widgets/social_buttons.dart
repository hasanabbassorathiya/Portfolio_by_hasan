import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/utils/link_utils.dart';
import 'package:portfolio/shared/constants/utils.dart';

class SocialButtons extends StatefulWidget {
  final IconData icon;
  final String link;

  const SocialButtons({super.key, required this.icon, required this.link});

  @override
  State<SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  bool _isHovering = false;

  /// Check if the icon is a FontAwesome icon by checking font family and package
  bool _isFontAwesomeIcon(IconData icon) {
    // FontAwesome icons use specific font families and package
    final fontFamily = icon.fontFamily;
    final fontPackage = icon.fontPackage;
    
    // Check font package first (most reliable)
    if (fontPackage == 'font_awesome_flutter') {
      return true;
    }
    
    // Check font family as fallback
    if (fontFamily != null) {
      return fontFamily.contains('FontAwesome') || 
             fontFamily.contains('FontAwesome6');
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isFontAwesome = _isFontAwesomeIcon(widget.icon);
    
    return InkWell(
      onTap: () {
        LinkUtils.launchUrl(widget.link);
      },
      onHover: (value) {
        setState(() {
          _isHovering = value;
        });
      },
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovering ? null : AppColors.bgColor,
          gradient: _isHovering ? AppUtils().appGradient : null,
        ),
        child: isFontAwesome
            ? FaIcon(
                widget.icon,
                size: 24,
                color: _isHovering ? Colors.white : AppColors.primaryColor,
              )
            : Icon(
                widget.icon,
                size: 24,
                color: _isHovering ? Colors.white : AppColors.primaryColor,
              ),
      ),
    );
  }
}
