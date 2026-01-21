import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_state.dart';

final usersProvider = NotifierProvider<UsersController, List<AppUser>>(UsersController.new);

class UsersController extends Notifier<List<AppUser>> {
  @override
  List<AppUser> build() {
    return const [
      AppUser(id: 'u1', email: 'user@test.com', displayName: 'Andrea', role: UserRole.user),
      AppUser(id: 'u2', email: 'mila@test.com', displayName: 'Mila', role: UserRole.user),
      AppUser(id: 'a1', email: 'admin@test.com', displayName: 'Admin', role: UserRole.admin),
    ];
  }

  void deleteUser(String id) {
    state = state.where((u) => u.id != id).toList();
  }

  void setRole(String id, UserRole role) {
    state = [
      for (final u in state)
        if (u.id == id)
          AppUser(id: u.id, email: u.email, displayName: u.displayName, role: role)
        else
          u,
    ];
  }
}
