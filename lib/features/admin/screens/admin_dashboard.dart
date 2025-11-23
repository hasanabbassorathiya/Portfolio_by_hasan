/// Admin dashboard
/// Main control panel for managing portfolio content
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/shared/constants/colors.dart';
import 'package:portfolio/shared/constants/textstyles.dart';
import 'package:portfolio/shared/constants/utils.dart';
import 'package:portfolio/shared/routes/app_routes.dart';
import 'package:portfolio/features/admin/screens/blogs/admin_blogs.dart';
import 'package:portfolio/features/admin/screens/works/admin_works.dart';
import 'package:portfolio/features/admin/screens/experiences/admin_experiences.dart';
import 'package:portfolio/features/admin/screens/testimonials/admin_testimonials.dart';
import 'package:portfolio/features/admin/screens/profile/admin_profile.dart';
import 'package:portfolio/features/admin/screens/services/admin_services.dart';
import 'package:portfolio/features/admin/screens/contacts/admin_contacts.dart';
import 'package:portfolio/features/admin/screens/social_links/admin_social_links.dart';
import 'package:portfolio/features/admin/screens/analytics/admin_analytics.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<AdminScreen> _screens = [
    AdminScreen(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      widget: const _DashboardOverview(),
    ),
    AdminScreen(
      title: 'Analytics',
      icon: Icons.analytics_outlined,
      widget: const AdminAnalyticsScreen(),
    ),
    AdminScreen(
      title: 'Blogs',
      icon: Icons.article_outlined,
      widget: const AdminBlogsScreen(),
    ),
    AdminScreen(
      title: 'Works',
      icon: Icons.work_outline,
      widget: const AdminWorksScreen(),
    ),
    AdminScreen(
      title: 'Experiences',
      icon: Icons.business_outlined,
      widget: const AdminExperiencesScreen(),
    ),
    AdminScreen(
      title: 'Testimonials',
      icon: Icons.format_quote_outlined,
      widget: const AdminTestimonialsScreen(),
    ),
    AdminScreen(
      title: 'Services',
      icon: Icons.build_outlined,
      widget: const AdminServicesScreen(),
    ),
    AdminScreen(
      title: 'Profile',
      icon: Icons.person_outline,
      widget: const AdminProfileScreen(),
    ),
    AdminScreen(
      title: 'Social Links',
      icon: Icons.link,
      widget: const AdminSocialLinksScreen(),
    ),
    AdminScreen(
      title: 'Contacts',
      icon: Icons.mail_outline,
      widget: const AdminContactsScreen(),
    ),
  ];

  Future<void> _logout() async {
    try {
      await SupabaseService.auth.signOut();
      if (mounted) {
        context.go(AppRoutes.adminLogin);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: isSmall ? 80 : 280,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo/Header
                Container(
                  padding: EdgeInsets.all(isSmall ? 16 : 24),
                  child:
                      isSmall
                          ? const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                          )
                          : Text(
                            'Admin Panel',
                            style: AppStyles.heading(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
                const Divider(color: Colors.white24),
                // Navigation
                Expanded(
                  child: ListView.builder(
                    itemCount: _screens.length,
                    itemBuilder: (context, index) {
                      final screen = _screens[index];
                      final isSelected = _selectedIndex == index;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.white.withOpacity(0.1),
                        leading: Icon(screen.icon, color: Colors.white),
                        title:
                            isSmall
                                ? null
                                : Text(
                                  screen.title,
                                  style: AppStyles.body(
                                    color: Colors.white,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
                // Logout button
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title:
                      isSmall
                          ? null
                          : Text(
                            'Logout',
                            style: AppStyles.body(color: Colors.white),
                          ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          // Main content
          Expanded(child: _screens[_selectedIndex].widget),
        ],
      ),
    );
  }
}

class AdminScreen {
  final String title;
  final IconData icon;
  final Widget widget;

  AdminScreen({required this.title, required this.icon, required this.widget});
}

/// Dashboard overview widget
class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: AppStyles.heading(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          AppUtils().vSpace(size: 32),
          // Stats cards
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
              _StatCard(
                title: 'Total Blogs',
                value: '0',
                icon: Icons.article_outlined,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Total Works',
                value: '0',
                icon: Icons.work_outline,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Experiences',
                value: '0',
                icon: Icons.business_outlined,
                color: Colors.orange,
              ),
              _StatCard(
                title: 'Testimonials',
                value: '0',
                icon: Icons.format_quote_outlined,
                color: Colors.purple,
              ),
              _StatCard(
                title: 'Unread Messages',
                value: '0',
                icon: Icons.mail_outline,
                color: Colors.red,
              ),
            ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          AppUtils().vSpace(size: 16),
          Text(
            value,
            style: AppStyles.heading(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          AppUtils().vSpace(size: 4),
          Text(title, style: AppStyles.body(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
