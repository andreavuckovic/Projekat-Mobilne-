import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_state.dart';
import 'users_provider.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String name,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Brisanje korisnika'),
        content: Text('Da li želiš da obrišeš korisnika "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ne'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Da'),
          ),
        ],
      ),
    );

    if (ok == true) {
      ref.read(usersProvider.notifier).deleteUser(userId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Korisnici'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
            onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
           } else {
            context.go('/admin');
    }
  },
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final u = users[i];

          return Card(
            child: ListTile(
              title: Text(u.displayName),
              subtitle: Text('${u.email}\nUloga: ${u.role.name}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<UserRole>(
                    value: u.role,
                    items: UserRole.values
                        .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                        .toList(),
                    onChanged: (r) {
                      if (r == null) return;
                      ref.read(usersProvider.notifier).setRole(u.id, r);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, u.id, u.displayName),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
