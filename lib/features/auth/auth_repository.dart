import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/backend/users_repository.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsersRepository _users = UsersRepository(FirebaseFirestore.instance);

  Stream<User?> authChanges() => _auth.authStateChanges();

  Future<void> register(String email, String password, {String displayName = ''}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _users.upsertUser(
      uid: cred.user!.uid, 
      email: email,
      displayName: displayName.isEmpty ? email.split('@').first : displayName,
    );
  }

 Future<void> login(String email, String password) async {
  final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

  final fb = cred.user!;
  await _users.upsertUser(
    uid: fb.uid,
    email: email,
    displayName: fb.displayName ?? email.split('@').first,
  );
}


  Future<void> logout() async => _auth.signOut();
}
 