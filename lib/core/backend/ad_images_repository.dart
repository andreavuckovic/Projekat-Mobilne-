import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdImagesRepository {
  final FirebaseFirestore _db;
  AdImagesRepository(this._db);

  CollectionReference<Map<String, dynamic>> _imagesCol(String adId) =>
      _db.collection('ads').doc(adId).collection('images');

  Stream<List<Uint8List>> watchImages(String adId) {
    return _imagesCol(adId)
        .orderBy('index')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              final bytes = data['bytes'] as Blob?;
              return bytes?.bytes;
            }).whereType<Uint8List>().toList());
  }

  Stream<Uint8List?> watchFirstImage(String adId) {
    return _imagesCol(adId)
        .orderBy('index')
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          final data = snap.docs.first.data();
          final b = data['bytes'] as Blob?;
          return b?.bytes;
        });
  }

  Future<void> replaceAllImages({
    required String adId,
    required List<Uint8List> images,
  }) async {
    final batch = _db.batch();
    final col = _imagesCol(adId);

    final existing = await col.get();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (var i = 0; i < images.length; i++) {
      final ref = col.doc();
      batch.set(ref, {
        'index': i,
        'bytes': Blob(images[i]),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
