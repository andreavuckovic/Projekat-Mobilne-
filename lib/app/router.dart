import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_state.dart'; 

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/manage_ads_screen.dart';
import '../features/admin/manage_users_screen.dart';
import '../features/ads/home_screen.dart';
import '../features/ads/ad_details_screen.dart';
import '../features/ads/add_ad_screen.dart';
import '../features/ads/edit_ad_screen.dart';
import '../features/ads/my_ads_screen.dart';
import '../shared/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(
            location: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/add',
            builder: (_, __) => const AddAdScreen(),
          ),
          GoRoute(
            path: '/my-ads',
            builder: (_, __) => const MyAdsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/ad/:id',
        builder: (_, st) => AdDetailsScreen(adId: st.pathParameters['id']!),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (_, st) => EditAdScreen(adId: st.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/ads',
        builder: (_, __) => const ManageAdsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (_, __) => const ManageUsersScreen(),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final isAdmin = auth.isAdmin; 

      final loc = state.uri.toString();

      final goingLogin = loc == '/login';
      final goingRegister = loc == '/register';

      final goingAdmin = loc.startsWith('/admin');
      final goingAdd = loc == '/add';
      final goingEdit = loc.startsWith('/edit/');
      final goingMyAds = loc == '/my-ads';

      if (!loggedIn && (goingAdd || goingEdit || goingMyAds || goingAdmin)) {
        return '/login';
      }

      if (goingAdmin && !isAdmin) {
        return '/';
      }

      if (loggedIn && (goingLogin || goingRegister)) {
        return '/';
      }

      return null;
    },
  );
});
 