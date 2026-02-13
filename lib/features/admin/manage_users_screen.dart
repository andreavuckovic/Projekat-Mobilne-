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
      await ref.read(adminUsersActionsProvider.notifier).deleteUser(userId);
    }
  }

  String _roleLabel(UserRole role) {
  switch (role) {
    case UserRole.user:
      return 'User';
    case UserRole.admin:
      return 'Admin';
    case UserRole.inactive:
      return 'Inactive';
  }
}
 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersStreamProvider);

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
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Greška: $e')),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Nema korisnika.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final u = users[i];

              return Card(
                child: ListTile(
                  title: Text(u.displayName),
                  subtitle: Text('${u.email}\nRole: ${_roleLabel(u.role)}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<UserRole>(
                        value: u.role,
                        items: UserRole.values
                            .map(
                              (r) => DropdownMenuItem(
                                value: r, 
                                child: Text(_roleLabel(r)),
                              ),
                            )
                            .toList(),
                        onChanged: (r) async {
                          if (r == null) return;
                          await ref
                              .read(adminUsersActionsProvider.notifier)
                              .setRole(u.id, r);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, ref, u.id, u.displayName),
                      ), 
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
