import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_state.dart';

final adminUsersStreamProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  final col = FirebaseFirestore.instance.collection('users');
  return col.snapshots().map((snap) {
    return snap.docs.map((d) {
      final data = d.data();
      final roleStr = (data['role'] as String?) ?? 'user';

      final role = switch (roleStr) {
        'admin' => UserRole.admin,
        'inactive' => UserRole.inactive,
        _ => UserRole.user,
      };

      return AppUser(
        id: d.id,
        email: (data['email'] as String?) ?? '',
        displayName: (data['displayName'] as String?) ?? '',
        role: role,
      );
    }).toList();
  });
}); 

final adminUsersActionsProvider =
    NotifierProvider<AdminUsersActions, AsyncValue<void>>(AdminUsersActions.new);

class AdminUsersActions extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> deleteUser(String uid) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      ref.invalidate(adminUsersStreamProvider);
    });
  }

  Future<void> setRole(String uid, UserRole role) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'role': role.name},
        SetOptions(merge: true),
      );
      ref.invalidate(adminUsersStreamProvider);
    });
  }
}
