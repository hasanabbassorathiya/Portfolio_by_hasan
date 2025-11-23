import 'package:flutter/material.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';

class AppButton extends StatefulWidget {
  final Function()? onTap;
  final String title;
  final IconData? icons;

  const AppButton({super.key, this.onTap, required this.title, this.icons});

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (value) {
        setState(() {
          _isHovering = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.291,
          minHeight: MediaQuery.sizeOf(context).width * 0.056,
        ),
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: _isHovering ? null : AppColors.primaryColor,
          gradient: _isHovering ? AppUtils().appGradient : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: AppStyles.button(color: AppColors.bgColor),
                ),
              ),
            ),
            if (widget.icons != null)
              Icon(widget.icons, size: 24.0, color: AppColors.bgColor),
          ],
        ),
      ),
    );
  }
}
