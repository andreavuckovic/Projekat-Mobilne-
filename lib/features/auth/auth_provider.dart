import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backend/users_repo_provider.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  StreamSubscription<User?>? _sub;

  @override
  AuthState build() {
    ref.onDispose(() {
      _sub?.cancel();
    });

    state = const AuthState.guest();

    final repo = ref.read(authRepositoryProvider);

    _sub = repo.authChanges().listen((user) async {
      if (user == null) {
        state = const AuthState.guest();
        return;
      }

      final usersRepo = ref.read(usersRepoProvider);
      final role = await usersRepo.getRole(user.uid);

      if (role == UserRole.inactive) {
        await repo.logout();
        state = const AuthState.guest();
        return;
      }

      state = AuthState(
        user: AppUser(
          id: user.uid,
          email: user.email ?? '',
          displayName:
              user.displayName ?? user.email?.split('@').first ?? 'User',
          role: role,
        ),
      );
    });

    return state;
  }

  Future<void> register(
      String email, String password, String displayName) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.register(email, password);

    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) return;

    await fbUser.updateDisplayName(displayName);

    final usersRepo = ref.read(usersRepoProvider);
    await usersRepo.upsertUser(
      uid: fbUser.uid,
      email: email,
      displayName: displayName,
    );

    final role = await usersRepo.getRole(fbUser.uid);

    if (role == UserRole.inactive) {
      await authRepo.logout();
      state = const AuthState.guest();
      throw Exception('Your account is deactivated.');
    }

    state = AuthState(
      user: AppUser(
        id: fbUser.uid,
        email: email,
        displayName: displayName,
        role: role,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.login(email, password);

    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) return;

    final usersRepo = ref.read(usersRepoProvider);
    final role = await usersRepo.getRole(fbUser.uid);

    if (role == UserRole.inactive) {
      await authRepo.logout();
      throw Exception('Your account is deactivated.');
    }
  }

  Future<void> logout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
  }
}
 