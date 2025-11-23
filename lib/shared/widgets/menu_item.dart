import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/widgets/line.dart';

class MenuItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final Function()? onTap;

  const MenuItem({
    super.key,
    required this.title,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isSelected) StrikeLine(),
          Text(
            widget.title.toUpperCase(),
            style:
                widget.isSelected
                    ? GoogleFonts.ibmPlexSans(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: AppColors.bgColor,
                    )
                    : GoogleFonts.ibmPlexSans(
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                      color: AppColors.bgColor,
                    ),
          ),
        ],
      ),
    );
  }
}
