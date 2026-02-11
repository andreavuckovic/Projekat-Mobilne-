import 'package:cloud_firestore/cloud_firestore.dart';
import 'ad_model.dart';

class AdsRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('ads');

  Stream<List<Ad>> watchAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AdFirestore.fromDoc).toList());
  }

  Stream<List<Ad>> watchMy(String ownerId) {
    return _col
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AdFirestore.fromDoc).toList());
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
      'contact': ad.contact,
      'city': ad.city,
      'ownerName': ad.ownerName,
    });
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
