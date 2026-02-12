import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _st = FirebaseStorage.instance;

  Future<String> uploadAdImage({
    required String adId,
    required int index,
    required Uint8List bytes,
  }) async {
    final ref = _st.ref().child('ads/$adId/$index.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }
}
