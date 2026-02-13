import '../../features/ads/ad_model.dart';
import 'ads_repository.dart';

class MockAdsRepository implements AdsRepository {
  final List<Ad> _ads = [];

  @override
  Stream<List<Ad>> watchAll() async* {
    yield List<Ad>.from(_ads);
  }

  @override
  Stream<List<Ad>> watchMy(String ownerId) async* {
    yield _ads.where((a) => a.ownerId == ownerId).toList();
  }

  @override
  Future<String> createAd(Ad ad) async {
    final id = ad.id.isEmpty ? DateTime.now().microsecondsSinceEpoch.toString() : ad.id;
    final stored = ad.copyWith(id: id);
    _ads.insert(0, stored);
    return id;
  }

  @override
  Future<void> updateAd(Ad ad) async {
    final i = _ads.indexWhere((a) => a.id == ad.id);
    if (i != -1) _ads[i] = ad;
  }

  @override
  Future<void> deleteAd(String adId) async {
    _ads.removeWhere((a) => a.id == adId);
  }
}
 