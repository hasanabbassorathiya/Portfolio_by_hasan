import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/services/supabase_service.dart';
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
    AppMenu(title: "Experiences", path: AppRoutes.experiences),
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

            // Login/Admin Section
            Builder(
              builder: (context) {
                final session = SupabaseService.auth?.currentSession;
                final isLoggedIn = session != null;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoggedIn) ...[
                      // Dashboard button when logged in
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go(AppRoutes.adminDashboard);
                          },
                          icon: const Icon(Icons.dashboard, size: 18),
                          label: Text(
                            'Dashboard',
                            style: GoogleFonts.ibmPlexSans().copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bgColor,
                            foregroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                    ] else ...[
                      // Login button when not logged in
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go(AppRoutes.adminLogin);
                          },
                          icon: const Icon(Icons.login, size: 18),
                          label: Text(
                            'Login',
                            style: GoogleFonts.ibmPlexSans().copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bgColor,
                            foregroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                    // Social Buttons and Copyright
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
