enum UserRole { guest, user, admin }

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

  UserRole get role => user?.role ?? UserRole.guest;
  bool get isLoggedIn => user != null;
}
