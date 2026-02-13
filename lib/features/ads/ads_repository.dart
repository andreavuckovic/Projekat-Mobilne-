import 'package:skriptarnica/features/ads/ad_model.dart';

abstract class AdsRepository {
  Stream<List<Ad>> watchAll();
  Stream<List<Ad>> watchMy(String ownerId);

  Future<String> createAd(Ad ad);

  Future<void> updateAd(Ad ad); 
  Future<void> deleteAd(String adId);
}
