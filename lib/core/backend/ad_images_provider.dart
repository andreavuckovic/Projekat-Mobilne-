import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_images_repository.dart';

final adImagesRepoProvider = Provider<AdImagesRepository>((ref) {
  return AdImagesRepository(FirebaseFirestore.instance);
});
