import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/auth_state.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _indexForLocation(String location) {
    if (location.startsWith('/add')) return 1;
    if (location.startsWith('/my-ads')) return 2;
    return 0;
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return 'Guest';
      case UserRole.user:
        return 'User';
      case UserRole.admin:
        return 'Admin';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // Stabilnije nego GoRouterState.of(context) u ShellRoute kontekstu:
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath; 
    final currentIndex = _indexForLocation(location);

    void goProtected(String path) {
      if (auth.role == UserRole.guest) {
        context.go('/login');
      } else {
        context.go(path);
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('QuickAds • ${_roleLabel(auth.role)}'),
        actions: [
          if (auth.role == UserRole.admin)
            IconButton(
              tooltip: 'Admin panel',
              onPressed: () => context.go('/admin'),
              icon: const Icon(Icons.admin_panel_settings),
            ),
          if (!auth.isLoggedIn)
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login'),
            )
          else
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/');
              },
              child: const Text('Logout'),
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/');
          if (i == 1) goProtected('/add');
          if (i == 2) goProtected('/my-ads');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_box), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'My Ads'),
        ],
      ),
    );
  }
}
 