import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ads_repository.dart';
import 'mock_ads_repository.dart';

final adsRepositoryProvider = Provider<AdsRepository>((ref) {
  return MockAdsRepository();
});
 