import '../../features/ads/ad_model.dart';

abstract class AdsRepository {
  Future<List<Ad>> getAllAds();
  Future<List<Ad>> getMyAds(String userId);
  Future<void> addAd(Ad ad);
  Future<void> updateAd(Ad ad);
  Future<void> deleteAd(String adId);
}
 