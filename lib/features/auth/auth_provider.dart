import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'auth_state.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  final _uuid = const Uuid();

  @override
  AuthState build() {
    return const AuthState.guest();
  }

  void loginAsUser(String email) {
    state = AuthState(
      user: AppUser(
        id: _uuid.v4(),
        email: email,
        displayName: 'Korisnik',
        role: UserRole.user,
      ),
    );
  }

  void loginAsAdmin(String email) {
    state = AuthState(
      user: AppUser(
        id: _uuid.v4(),
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
