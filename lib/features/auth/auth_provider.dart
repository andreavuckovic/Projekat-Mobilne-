import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';
import 'auth_state.dart';

final authRepoProvider = Provider((_) => AuthRepository());

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
 
    state = const AuthState.guest();


    ref.read(authRepoProvider).authChanges().listen((user) {
      if (user == null) {
        state = const AuthState.guest();
      } else {
        state = AuthState(
          user: AppUser( 
            id: user.uid,
            email: user.email ?? '',
            displayName: user.email?.split('@').first ?? 'Korisnik',
            role: UserRole.user, 
          ),
        );
      } 
    });

    return state;
  } 

  Future<void> login(String email, String password) => 
      ref.read(authRepoProvider).login(email, password);
 
  Future<void> register(String email, String password) =>
      ref.read(authRepoProvider).register(email, password);

  Future<void> logout() => ref.read(authRepoProvider).logout();
}
