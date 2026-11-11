import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/portfolio_repository.dart';
import '../../features/portfolio/screens/portfolio_screen.dart';
import '../../features/project_detail/screens/project_detail_screen.dart';
import '../../features/blog_detail/screens/blog_detail_screen.dart';
import '../../features/admin/screens/admin_login.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/admin_reset_password.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _AnalyticsObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) => _track(route);

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _track(newRoute);

  @override
  void didPop(Route route, Route? previousRoute) => _track(previousRoute);

  void _track(Route? route) {
    final path = route?.settings.name ?? '';
    if (path.isEmpty || path.startsWith('/admin')) return;
    PortfolioRepository().trackPageView(path);
  }
}

class AuthNotifier extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }
}

final authNotifier = AuthNotifier();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: authNotifier,
  observers: [_AnalyticsObserver()],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PortfolioScreen(),
    ),
    GoRoute(
      path: '/project/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ProjectDetailScreen(
        projectId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/blog/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlogDetailScreen(
        slug: state.pathParameters['slug']!,
      ),
    ),
    GoRoute(
      path: '/admin/login',
      parentNavigatorKey: _rootNavigatorKey,
      redirect: (context, state) {
        if (authNotifier.user != null) return '/admin';
        return null;
      },
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/reset-password',
      parentNavigatorKey: _rootNavigatorKey,
      redirect: (context, state) {
        if (authNotifier.user != null) return '/admin';
        return null;
      },
      builder: (context, state) => const AdminResetPasswordScreen(),
    ),
    GoRoute(
      path: '/admin',
      parentNavigatorKey: _rootNavigatorKey,
      redirect: (context, state) {
        final user = authNotifier.user;
        final publicAdminRoutes = ['/admin/login', '/admin/reset-password'];
        final isPublic = publicAdminRoutes.contains(state.matchedLocation);
        if (user == null && !isPublic) return '/admin/login';
        if (user != null && isPublic) return '/admin';
        return null;
      },
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
);
