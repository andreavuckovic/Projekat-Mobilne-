import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.guest();

  void loginAsUser(String email) {
    state = AuthState(
      user: AppUser(
        id: 'u1',
        email: email,
        displayName: 'Korisnik',
        role: UserRole.user,
      ),
    );
  }

  void loginAsAdmin(String email) {
    state = AuthState(
      user: AppUser(
        id: 'a1',
        email: email,
        displayName: 'Admin',
        role: UserRole.admin,
      ),
    );
  }

  void logout() {
    state = const AuthState.guest();
  }
}
