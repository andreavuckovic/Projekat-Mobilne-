import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Manage Ads'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/admin/ads'),
          ),
          ListTile(
            title: const Text('Manage Users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/admin/users'),
          ),
        ],
      ),
    );
  }
}
