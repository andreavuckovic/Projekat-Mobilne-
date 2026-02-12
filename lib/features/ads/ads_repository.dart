import 'package:cloud_firestore/cloud_firestore.dart';

import 'ad_model.dart';

class AdsRepository {
  final FirebaseFirestore _db;

  AdsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('ads');

  Stream<List<Ad>> watchAll() {
    return _col
        .snapshots()
        .map((snap) => snap.docs.map(Ad.fromDoc).toList());
  }

  Stream<List<Ad>> watchMy(String ownerId) {
    return _col
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snap) => snap.docs.map(Ad.fromDoc).toList());
  }

  Future<void> add(Ad ad) async {
    await _col.add(ad.toMap());
  }

  Future<void> update(Ad ad) async {
    await _col.doc(ad.id).update({
      'title': ad.title,
      'description': ad.description,
      'category': ad.category.name,
      'price': ad.price,
      'ownerName': ad.ownerName,
      'contact': ad.contact,
      'city': ad.city,
      'imageUrls': ad.imageUrls,
    });
  }

  Future<void> delete(String adId) async {
    await _col.doc(adId).delete();
  }
}
