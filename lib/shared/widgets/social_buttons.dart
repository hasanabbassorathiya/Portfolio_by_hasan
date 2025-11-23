import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
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
        child: Icon(
          widget.icon,
          size: 24,
          color: _isHovering ? Colors.white : AppColors.primaryColor,
        ),
      ),
    );
  }
}
