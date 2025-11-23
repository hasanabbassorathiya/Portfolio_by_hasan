import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/constants/textstyles.dart';
import '../../shared/constants/colors.dart';

class ServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final String iconAsset;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconAsset,
    this.onTap,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.045 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.13 : 0.06),
                blurRadius: _hovering ? 32 : 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(
                _hovering ? 0.22 : 0.10,
              ),
              width: 2.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    widget.iconAsset,
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                widget.title,
                style: AppStyles.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.description,
                style: AppStyles.subheading(
                  fontSize: 15,
                ).copyWith(color: Colors.black.withOpacity(0.78), height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
