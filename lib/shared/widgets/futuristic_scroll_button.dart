import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:portfolio/shared/constants/colors.dart';

class FuturisticScrollButton extends StatefulWidget {
  final PageController pageController;
  final int totalPages;

  const FuturisticScrollButton({
    Key? key,
    required this.pageController,
    required this.totalPages,
  }) : super(key: key);

  @override
  _FuturisticScrollButtonState createState() => _FuturisticScrollButtonState();
}

class _FuturisticScrollButtonState extends State<FuturisticScrollButton> {
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Listen to page changes to update button visibility/icon
    widget.pageController.addListener(_updatePageIndex);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_updatePageIndex);
    super.dispose();
  }

  void _updatePageIndex() {
    if (widget.pageController.page != null) {
      setState(() {
        _currentPageIndex = widget.pageController.page!.round();
      });
    }
  }

  // Method to scroll to the next page
  void _scrollToNextPage() {
    if (_currentPageIndex < widget.totalPages - 1) {
      widget.pageController.nextPage(
        duration: const Duration(
          milliseconds: 800,
        ), // Increased duration for slower scroll
        curve: Curves.easeInOutCubic, // Use a different curve for smoother feel
      );
    }
  }

  // Method to scroll to the previous page
  void _scrollToPreviousPage() {
    if (_currentPageIndex > 0) {
      widget.pageController.previousPage(
        duration: const Duration(
          milliseconds: 800,
        ), // Increased duration for slower scroll
        curve: Curves.easeInOutCubic, // Use a different curve for smoother feel
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if scrolling up or down is possible
    final bool canScrollUp = _currentPageIndex > 0;
    final bool canScrollDown = _currentPageIndex < widget.totalPages - 1;

    // Determine the icon and action based on scroll possibility
    IconData icon;
    VoidCallback? onTap;

    if (canScrollDown) {
      icon = Iconsax.arrow_down_1_copy;
      onTap = _scrollToNextPage;
    } else if (canScrollUp) {
      icon = Iconsax.arrow_up_1_copy;
      onTap = _scrollToPreviousPage;
    } else {
      // No scrolling possible (only one page or at the start/end and no more pages)
      icon = Iconsax.arrow_down_1_copy; // Default icon
      onTap = null; // Disable tap
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap != null ? 1.0 : 0.5, // Reduce opacity when disabled
        duration: const Duration(milliseconds: 300), // Animation duration
        child: Container(
          padding: const EdgeInsets.all(12.0), // Adjust padding as needed
          decoration: BoxDecoration(
            color: AppColors.primaryColor, // Futuristic color
            shape: BoxShape.circle, // Circular shape
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.5),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ), // Glowing effect
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white, // Icon color
            size: 24.0, // Icon size
          ),
        ),
      ),
    );
  }
}
