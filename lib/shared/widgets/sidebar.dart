import 'package:firebase_auth/firebase_auth.dart';
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

  List<dynamic> _socialLinks = [];

  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
  }

  Future<void> _loadSocialLinks() async {
    try {
      final response = await SupabaseService.requiredClient.from('social_links').select().eq('is_active', true).order('order_index', ascending: true);
      if (mounted) {
        setState(() {
          _socialLinks = response as List;
        });
      }
    } catch(e) {
      // ignore
    }
  }

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
                final session = FirebaseAuth.instance.currentUser;
                final isLoggedIn = session != null;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isLoggedIn) ...[
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
                    ..._socialLinks.map((link) {
                      IconData iconData = Iconsax.link_1;
                      final platform = (link['platform'] as String).toLowerCase();
                      if (platform.contains('github')) iconData = Iconsax.code_1;
                      else if (platform.contains('linkedin')) iconData = Iconsax.link_2; // fallback
                      else if (platform.contains('twitter') || platform.contains('x')) iconData = Iconsax.message; // fallback
                      else if (platform.contains('instagram')) iconData = Iconsax.instagram_copy;
                      else if (platform.contains('email')) iconData = Iconsax.sms;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: SocialButtons(
                          icon: iconData,
                          link: link['url'],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10.0),
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
