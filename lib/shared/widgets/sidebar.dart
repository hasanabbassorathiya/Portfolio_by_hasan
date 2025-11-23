import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:logger/logger.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/links.dart';
import 'package:portfolio/shared/routes/app_routes.dart';
import 'package:portfolio/shared/widgets/menu_item.dart';
import 'package:portfolio/shared/widgets/social_buttons.dart';

import '../../models/menu/menu.dart';

// Initialize logger
final logger = Logger();

class AppSidebar extends StatefulWidget {
  final String currentLocation;
  final Function(String) onMenuItemTap;

  const AppSidebar({
    super.key,
    required this.currentLocation,
    required this.onMenuItemTap,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  List<AppMenu> menu = [
    AppMenu(title: "HOME", path: AppRoutes.home),
    AppMenu(title: "About", path: AppRoutes.about),
    AppMenu(title: "Services", path: AppRoutes.services),
    AppMenu(title: "Works", path: AppRoutes.works),
    AppMenu(title: "Blogs", path: AppRoutes.blogs),
    AppMenu(title: "Contact", path: AppRoutes.contact),
  ];

  @override
  Widget build(BuildContext context) {
    final String currentRoute = widget.currentLocation;
    return Drawer(
      child: Container(
        color: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Initials
            Column(
              children: [
                Text(
                  "HS",
                  style: GoogleFonts.ibmPlexSerif(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bgColor,
                    height: 1.6,
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            // Menu Items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Cast to List<Widget>
                  spacing: 10.0,
                  children:
                      [
                        ...menu.map((e) {
                          return MenuItem(
                            title: e.title,
                            isSelected: currentRoute == e.path,
                            onTap: () {
                              widget.onMenuItemTap(e.path);
                            },
                          );
                        }).toList(),
                      ].cast<Widget>(),
                ),
              ),
            ),

            // Social Buttons and Copyright
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SocialButtons(
                  icon: Iconsax.instagram_copy,
                  link: AppLinks.instagram,
                ),
                SizedBox(height: 20.0),
                SocialButtons(icon: Iconsax.code_1, link: AppLinks.github),
                SizedBox(height: 30.0),
                Text(
                  'Copyright ©${DateTime.now().year}',
                  style: GoogleFonts.ibmPlexSans().copyWith(
                    color: AppColors.bgColor,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Hasan Abbas Sorathiya.',
                  style: GoogleFonts.ibmPlexSans().copyWith(
                    color: AppColors.bgColor,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'All right reserved.',
                  style: GoogleFonts.ibmPlexSans().copyWith(
                    color: AppColors.bgColor,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
