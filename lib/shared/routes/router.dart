import 'package:go_router/go_router.dart';
import 'package:portfolio/shared/routes/app_routes.dart';
import 'package:portfolio/views/about/about.dart';
import 'package:portfolio/views/contact/contact.dart';
import 'package:portfolio/views/services/services.dart';
import 'package:portfolio/views/works/works.dart';
import 'package:portfolio/views/works/work_detail.dart';
import 'package:portfolio/views/blogs/blogs.dart';
import 'package:portfolio/views/blogs/blog_detail.dart';
import 'package:portfolio/features/admin/screens/admin_login.dart';
import 'package:portfolio/features/admin/screens/admin_dashboard.dart';
import 'package:portfolio/core/services/supabase_service.dart';

import '../../views/home/home.dart';
import 'package:portfolio/shared/widgets/main_layout_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppRouter {
  GoRouter appRouter = GoRouter(
    debugLogDiagnostics: kDebugMode,
    routes: [
      ShellRoute(
        builder:
            (context, state, child) =>
                MainLayoutShell(key: ValueKey(state.uri), child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.home,
            builder: (context, goState) => const Home(),
          ),
          GoRoute(
            path: AppRoutes.about,
            name: AppRoutes.about,
            builder: (context, goState) => const About(),
          ),
          GoRoute(
            path: AppRoutes.services,
            name: AppRoutes.services,
            builder: (context, goState) => const Services(),
          ),
          GoRoute(
            path: AppRoutes.works,
            name: AppRoutes.works,
            builder: (context, goState) => const Works(),
          ),
          GoRoute(
            path: AppRoutes.blogs,
            name: AppRoutes.blogs,
            builder: (context, goState) => const Blogs(),
          ),
          GoRoute(
            path: AppRoutes.contact,
            name: AppRoutes.contact,
            builder: (context, goState) => const Contact(),
          ),
        ],
      ),
      // Detail pages outside shell for full-page experience
      GoRoute(
        path: '/works/:id',
        name: 'work-detail',
        builder: (context, goState) {
          final id = goState.pathParameters['id']!;
          return WorkDetail(workId: id);
        },
      ),
      GoRoute(
        path: '/blogs/:id',
        name: 'blog-detail',
        builder: (context, goState) {
          final id = goState.pathParameters['id']!;
          return BlogDetail(blogId: id);
        },
      ),
      // Admin routes
      GoRoute(
        path: AppRoutes.adminLogin,
        name: 'admin-login',
        builder: (context, goState) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'admin-dashboard',
        builder: (context, goState) => const AdminDashboard(),
      ),
    ],
    redirect: (context, state) {
      final session = SupabaseService.auth.currentSession;
      final isAdminRoute = state.uri.path.startsWith('/admin');

      // If accessing admin login while already logged in, redirect to dashboard
      if (state.uri.path == AppRoutes.adminLogin && session != null) {
        return AppRoutes.adminDashboard;
      }

      // Protect admin routes (except login)
      if (isAdminRoute && state.uri.path != AppRoutes.adminLogin) {
        if (session == null) {
          return AppRoutes.adminLogin;
        }
      }

      return null;
    },
  );
}
