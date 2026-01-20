import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';

import '../features/ads/home_screen.dart';
import '../features/ads/add_ad_screen.dart';
import '../features/ads/my_ads_screen.dart';

import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/manage_ads_screen.dart';
import '../features/admin/manage_users_screen.dart';

import '../shared/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Public: 
      if (loc == '/' || loc == '/login') return null;

      // User/Admin only:
      if (loc == '/add' || loc == '/my-ads') {
        if (auth.role == UserRole.guest) return '/login';
      }

      // Admin only:
      if (loc.startsWith('/admin')) {
        if (auth.role != UserRole.admin) return '/';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/add', builder: (context, state) => const AddAdScreen()),
          GoRoute(path: '/my-ads', builder: (context, state) => const MyAdsScreen()),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(path: 'ads', builder: (context, state) => const ManageAdsScreen()),
          GoRoute(path: 'users', builder: (context, state) => const ManageUsersScreen()),
        ],
      ),
    ],
  );
});
