import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/shared/routes/app_routes.dart';
import 'package:portfolio/views/about/about.dart';
import 'package:portfolio/views/contact/contact.dart';
import 'package:portfolio/views/services/services.dart';
import 'package:portfolio/views/experiences/experiences.dart';
import 'package:portfolio/views/works/works.dart';
import 'package:portfolio/views/works/work_detail.dart';
import 'package:portfolio/views/blogs/blogs.dart';
import 'package:portfolio/views/blogs/blog_detail.dart';
import 'package:portfolio/features/admin/screens/admin_login.dart';
import 'package:portfolio/features/admin/screens/admin_dashboard.dart';
import 'package:portfolio/features/admin/screens/admin_reset_password.dart';
import 'package:portfolio/core/services/supabase_service.dart';
import 'package:portfolio/core/services/analytics_service.dart';

import '../../views/home/home.dart';
import 'package:portfolio/shared/widgets/main_layout_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppRouter {
  GoRouter appRouter = GoRouter(
    debugLogDiagnostics: kDebugMode,
    observers: [_AnalyticsRouteObserver()],
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
            path: AppRoutes.experiences,
            name: AppRoutes.experiences,
            builder: (context, goState) => const Experiences(),
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
        path: AppRoutes.adminResetPassword,
        name: 'admin-reset-password',
        builder: (context, goState) => const AdminResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'admin-dashboard',
        builder: (context, goState) => const AdminDashboard(),
      ),
      // Handle /admin route
      GoRoute(
        path: '/admin',
        redirect: (context, state) {
          
      
      dynamic session;
      try {
        if (Firebase.apps.isNotEmpty) {
          session = FirebaseAuth.instance.currentUser;
        }
      } catch(e) {
        session = null;
      }
      
      // Bypass auth for local testing if Firebase is not configured
      final bypassAuth = Firebase.apps.isEmpty;


          if (session != null || bypassAuth) {
            return AppRoutes.adminDashboard;
          } else {
            return AppRoutes.adminLogin;
          }
        },
      ),
    ],
    redirect: (context, state) {
      
      dynamic session;
      try {
        session = FirebaseAuth.instance.currentUser;
      } catch(e) {
        session = null;
      }

      final bypassAuth = Firebase.apps.isEmpty;
      final isAdminRoute = state.uri.path.startsWith('/admin');
      
      // Handle /admin route specifically
      if (state.uri.path == '/admin') {
        if (session != null) {
          return AppRoutes.adminDashboard;
        } else {
          return AppRoutes.adminLogin;
        }
      }

      // If accessing admin login while already logged in, redirect to dashboard
      if (state.uri.path == AppRoutes.adminLogin && session != null) {
        return AppRoutes.adminDashboard;
      }

      // Protect admin routes (except login and reset password)
      if (isAdminRoute &&
          state.uri.path != AppRoutes.adminLogin &&
          state.uri.path != AppRoutes.adminResetPassword) {
        if (session == null && !bypassAuth) {
          return AppRoutes.adminLogin;
        }
      }

      return null;
    },
  );
}

/// Route observer to track navigation events
class _AnalyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRouteChange(route, 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackRouteChange(previousRoute, 'pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRouteChange(newRoute, 'replace');
    }
  }

  void _trackRouteChange(Route<dynamic>? route, String action) {
    if (route == null) return;

    final routeName =
        route.settings.name ??
        route.settings.arguments?.toString() ??
        'unknown';
    final routePath =
        route.settings.arguments is Map
            ? (route.settings.arguments as Map)['path']?.toString()
            : null;

    // Only track non-admin routes
    if (routeName.contains('admin') ||
        (routePath?.contains('admin') ?? false)) {
      return;
    }

    AnalyticsService.trackEvent(
      eventName: 'navigation',
      eventData: {
        'action': action,
        'route_name': routeName,
        'route_path': routePath ?? routeName,
      },
    );
  }
}
