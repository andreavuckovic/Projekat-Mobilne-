import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_repository.dart';

final adsRepoProvider = Provider<AdsRepository>((ref) {
  return AdsRepository(FirebaseFirestore.instance);
});
