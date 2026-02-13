import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/auth/auth_state.dart';

class UsersRepository {
  final FirebaseFirestore _db;
  UsersRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  Future<void> upsertUser({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final ref = _col.doc(uid);
 
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

      if (!snap.exists) {
        tx.set(ref, {
          'email': email,
          'displayName': displayName,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.set(
          ref,
          {
            'email': email,
            'displayName': displayName,
          },
          SetOptions(merge: true),
        );
      }
    });
  }

 Future<UserRole> getRole(String uid) async {
  final doc = await _col.doc(uid).get();
  if (!doc.exists) return UserRole.user;
  final data = doc.data() ?? {};
  final role = (data['role'] as String?) ?? 'user';
  if (role == 'admin') return UserRole.admin;
  if (role == 'inactive') return UserRole.inactive;
  return UserRole.user;
} 
}
