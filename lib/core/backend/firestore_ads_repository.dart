import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/ads/ad_model.dart';
import 'ads_repository.dart';

class FirestoreAdsRepository implements AdsRepository {
  final FirebaseFirestore _db;
  FirestoreAdsRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('ads');

  int _tsMillis(Map<String, dynamic> data, String key) {
    final v = data[key];
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    return 0;
  }

  @override
  Stream<List<Ad>> watchAll() {
    return _col.snapshots().map((snap) {
      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final aData = a.data();
        final bData = b.data();
        final aTs = _tsMillis(aData, 'createdAt');
        final bTs = _tsMillis(bData, 'createdAt');
        return bTs.compareTo(aTs);
      });
      return docs.map(Ad.fromDoc).toList();
    });
  }

  @override
  Stream<List<Ad>> watchMy(String ownerId) {
    return _col.where('ownerId', isEqualTo: ownerId).snapshots().map((snap) {
      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final aData = a.data();
        final bData = b.data();
        final aTs = _tsMillis(aData, 'createdAt');
        final bTs = _tsMillis(bData, 'createdAt');
        return bTs.compareTo(aTs);
      });
      return docs.map(Ad.fromDoc).toList();
    });
  }

  @override
  Future<String> createAd(Ad ad) async {
    final data = Map<String, dynamic>.from(ad.toMap());
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    final doc = await _col.add(data);
    return doc.id;
  }

  @override
  Future<void> updateAd(Ad ad) async {
    await _col.doc(ad.id).update({
      'title': ad.title,
      'description': ad.description,
      'category': ad.category.name,
      'price': ad.price,
      'ownerId': ad.ownerId,
      'ownerName': ad.ownerName, 
      'contact': ad.contact,
      'city': ad.city,
      'imagesCount': ad.imagesCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteAd(String adId) async {
    await _col.doc(adId).delete();
  }
}
