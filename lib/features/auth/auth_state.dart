enum UserRole { user, admin, inactive }

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });
}

class AuthState {
  final AppUser? user;

  const AuthState({required this.user});
  const AuthState.guest() : user = null;

  bool get isLoggedIn => user != null;
  bool get isGuest => user == null;
  bool get isAdmin => user?.role == UserRole.admin;
  bool get isInactive => user?.role == UserRole.inactive;
}
 