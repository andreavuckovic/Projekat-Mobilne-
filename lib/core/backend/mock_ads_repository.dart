import 'ads_repository.dart';
import '../../features/ads/ad_model.dart';

class MockAdsRepository implements AdsRepository {
  final List<Ad> _ads = [];

  @override
  Future<List<Ad>> getAllAds() async {
    return _ads;
  }

  @override
  Future<List<Ad>> getMyAds(String userId) async {
    return _ads.where((a) => a.ownerId == userId).toList(); 
  }

  @override
  Future<void> addAd(Ad ad) async {
    _ads.insert(0, ad);
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
