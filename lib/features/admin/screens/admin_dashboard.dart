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
import 'dart:async';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  Timer? _refreshTimer;

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

  @override
  void initState() {
    super.initState();
    // Refresh dashboard stats every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // Trigger refresh in dashboard overview if it's visible
      if (_selectedIndex == 0 && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      if (SupabaseService.isInitialized) {
        await SupabaseService.auth!.signOut();
      }
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
                          // Pass refresh callback to dashboard overview
                          if (index == 0 && _screens[0].widget is _DashboardOverview) {
                            // Force refresh when switching to dashboard
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
                // Go to Portfolio button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go(AppRoutes.home);
                      },
                      icon: const Icon(Icons.public, size: 18),
                      label: Text(
                        'Go to Portfolio',
                        style: AppStyles.body(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
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

/// Dashboard overview widget with real-time data
class _DashboardOverview extends StatefulWidget {
  const _DashboardOverview();

  @override
  State<_DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<_DashboardOverview> {
  int _blogCount = 0;
  int _workCount = 0;
  int _experienceCount = 0;
  int _testimonialCount = 0;
  int _unreadMessagesCount = 0;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      setState(() => _isLoading = true);
      
      // Load all stats in parallel
      final results = await Future.wait([
        _loadBlogCount(),
        _loadWorkCount(),
        _loadExperienceCount(),
        _loadTestimonialCount(),
        _loadUnreadMessagesCount(),
      ]);

      if (mounted) {
        setState(() {
          _blogCount = results[0];
          _workCount = results[1];
          _experienceCount = results[2];
          _testimonialCount = results[3];
          _unreadMessagesCount = results[4];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<int> _loadBlogCount() async {
    try {
      if (!SupabaseService.isInitialized) return 0;
      final response = await SupabaseService.requiredClient
          .from('blogs')
          .select('id');
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _loadWorkCount() async {
    try {
      if (!SupabaseService.isInitialized) return 0;
      final response = await SupabaseService.requiredClient
          .from('works')
          .select('id');
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _loadExperienceCount() async {
    try {
      if (!SupabaseService.isInitialized) return 0;
      final response = await SupabaseService.requiredClient
          .from('experiences')
          .select('id');
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _loadTestimonialCount() async {
    try {
      if (!SupabaseService.isInitialized) return 0;
      final response = await SupabaseService.requiredClient
          .from('testimonials')
          .select('id');
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _loadUnreadMessagesCount() async {
    try {
      if (!SupabaseService.isInitialized) return 0;
      final response = await SupabaseService.requiredClient
          .from('contact_messages')
          .select('id')
          .eq('is_read', false);
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get parent state to access screen navigation
    final parentState = context.findAncestorStateOfType<_AdminDashboardState>();
    
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard Overview',
                  style: AppStyles.heading(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStats,
                  tooltip: 'Refresh Stats',
                ),
              ],
            ),
            AppUtils().vSpace(size: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              // Stats cards
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _StatCard(
                    title: 'Total Blogs',
                    value: '$_blogCount',
                    icon: Icons.article_outlined,
                    color: Colors.blue,
                    onTap: () {
                      parentState?.setState(() {
                        parentState._selectedIndex = 2; // Blogs is index 2
                      });
                    },
                  ),
                  _StatCard(
                    title: 'Total Works',
                    value: '$_workCount',
                    icon: Icons.work_outline,
                    color: Colors.green,
                    onTap: () {
                      parentState?.setState(() {
                        parentState._selectedIndex = 3; // Works is index 3
                      });
                    },
                  ),
                  _StatCard(
                    title: 'Experiences',
                    value: '$_experienceCount',
                    icon: Icons.business_outlined,
                    color: Colors.orange,
                    onTap: () {
                      parentState?.setState(() {
                        parentState._selectedIndex = 4; // Experiences is index 4
                      });
                    },
                  ),
                  _StatCard(
                    title: 'Testimonials',
                    value: '$_testimonialCount',
                    icon: Icons.format_quote_outlined,
                    color: Colors.purple,
                    onTap: () {
                      parentState?.setState(() {
                        parentState._selectedIndex = 5; // Testimonials is index 5
                      });
                    },
                  ),
                  _StatCard(
                    title: 'Unread Messages',
                    value: '$_unreadMessagesCount',
                    icon: Icons.mail_outline,
                    color: Colors.red,
                    onTap: () {
                      parentState?.setState(() {
                        parentState._selectedIndex = 9; // Contacts is index 9
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered && widget.onTap != null
                  ? widget.color
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered && widget.onTap != null
                    ? widget.color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered && widget.onTap != null ? 15 : 10,
                offset: Offset(0, _isHovered && widget.onTap != null ? 6 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(widget.icon, color: widget.color, size: 32),
                  if (widget.onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: _isHovered ? widget.color : AppColors.textSecondary,
                    ),
                ],
              ),
              AppUtils().vSpace(size: 16),
              Text(
                widget.value,
                style: AppStyles.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _isHovered && widget.onTap != null
                      ? widget.color
                      : null,
                ),
              ),
              AppUtils().vSpace(size: 4),
              Text(
                widget.title,
                style: AppStyles.body(
                  color: AppColors.textSecondary,
                  fontWeight: _isHovered && widget.onTap != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
