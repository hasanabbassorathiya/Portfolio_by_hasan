import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/utils/link_utils.dart';
import 'package:portfolio/shared/constants/utils.dart';

class SocialButtons extends StatefulWidget {
  final dynamic icon;
  final String link;

  const SocialButtons({super.key, required this.icon, required this.link});

  @override
  State<SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
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
            color: _isHovering ? AppColors.primaryColor : AppColors.bgColor,
          ),
          child: Center(
            child: FaIcon(
              widget.icon,
              size: 16,
              color: _isHovering ? Colors.white : AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
