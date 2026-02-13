import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backend/ads_repository.dart';
import '../../core/backend/firestore_ads_repository.dart';

final adsRepoProvider = Provider<AdsRepository>((ref) {
  return FirestoreAdsRepository(FirebaseFirestore.instance);
});
 