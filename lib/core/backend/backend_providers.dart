import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_repository.dart';
import 'firestore_ads_repository.dart';


final adsRepositoryProvider = Provider<AdsRepository>((ref) {
  return FirestoreAdsRepository(FirebaseFirestore.instance);

});
