import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final fb = FirebaseAuth.instance.currentUser;
    if (fb == null) return const AuthState.guest();

    return AuthState(
      user: AppUser(
        id: fb.uid,
        email: fb.email ?? '',
        displayName: fb.email?.split('@').first ?? 'Korisnik',
        role: UserRole.user,
      ),
    );
  }

  Future<void> register(String email, String password) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final u = cred.user!;
    state = AuthState(
      user: AppUser(
        id: u.uid,
        email: u.email ?? email,
        displayName: (u.email ?? email).split('@').first,
        role: UserRole.user,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final u = cred.user!;
    state = AuthState(
      user: AppUser(
        id: u.uid,
        email: u.email ?? email,
        displayName: (u.email ?? email).split('@').first,
        role: UserRole.user,
      ),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const AuthState.guest();
  }
} 