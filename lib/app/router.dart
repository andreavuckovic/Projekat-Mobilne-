import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';

import '../features/ads/home_screen.dart';
import '../features/ads/add_ad_screen.dart';
import '../features/ads/my_ads_screen.dart';

import '../shared/main_shell.dart'; 


final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Public routes: 
      if (loc == '/' || loc == '/login') return null;

      // Protected (user/admin):
      if (loc == '/add' || loc == '/my-ads') {
        if (auth.role == UserRole.guest) return '/login';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/add',
            builder: (context, state) => const AddAdScreen(),
          ),
          GoRoute(
            path: '/my-ads',
            builder: (context, state) => const MyAdsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});