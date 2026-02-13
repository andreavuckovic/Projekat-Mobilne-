import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/backend/ad_images_provider.dart';
import '../../core/backend/image_compress.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_state.dart';
import 'ad_model.dart';
import 'ads_repo_provider.dart';

final adsStreamProvider = StreamProvider<List<Ad>>((ref) {
  final repo = ref.watch(adsRepoProvider);
  return repo.watchAll();
});

final myAdsStreamProvider = StreamProvider.family<List<Ad>, String>((ref, uid) {
  final repo = ref.watch(adsRepoProvider);
  return repo.watchMy(uid);
});

final adThumbProvider = StreamProvider.family<Uint8List?, String>((ref, adId) {
  final repo = ref.watch(adImagesRepoProvider);
  return repo.watchFirstImage(adId);
});

final adImagesProvider =
    StreamProvider.family<List<Uint8List>, String>((ref, adId) {
  final repo = ref.watch(adImagesRepoProvider);
  return repo.watchImages(adId);
});

final adsActionsProvider =
    NotifierProvider<AdsActionsController, AsyncValue<void>>(
        AdsActionsController.new);

class AdsActionsController extends Notifier<AsyncValue<void>> {
  final _uuid = const Uuid();

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addAd({
    required String title,
    required String description,
    required AdCategory category,
    required double price,
    required String contact,
    required String city,
    List<Uint8List> images = const [],
  }) async {
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adsRepoProvider);
      final imagesRepo = ref.read(adImagesRepoProvider);

      final draft = Ad(
        id: _uuid.v4(),
        title: title,
        description: description,
        category: category,
        price: price,
        ownerId: auth.user!.id,
        ownerName: auth.user!.displayName,
        contact: contact,
        city: city,
        imagesCount: images.length,
      );

      final docId = await repo.createAd(draft).timeout(const Duration(seconds: 15));

      if (images.isNotEmpty) {
        final compressed = ImageCompress.compressMany(images);
        await imagesRepo
            .replaceAllImages(adId: docId, images: compressed)
            .timeout(const Duration(seconds: 20));
        await repo
            .updateAd(draft.copyWith(id: docId, imagesCount: compressed.length))
            .timeout(const Duration(seconds: 15));
      } else {
        await repo.updateAd(draft.copyWith(id: docId)).timeout(const Duration(seconds: 15));
      }

      ref.invalidate(adsStreamProvider);
      ref.invalidate(myAdsStreamProvider(auth.user!.id));
      ref.invalidate(adThumbProvider(docId));
      ref.invalidate(adImagesProvider(docId));
    });
  }

  Future<void> updateAd({
  required Ad original,
  required String title,
  required String description,
  required AdCategory category,
  required double price,
  required String contact,
  required String city,
  required List<Uint8List> newImages,
}) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    final repo = ref.read(adsRepoProvider);
    final imagesRepo = ref.read(adImagesRepoProvider);

    var imagesCount = original.imagesCount;

    if (newImages.isNotEmpty) {
      final compressed = ImageCompress.compressMany(newImages);

      await imagesRepo
          .replaceAllImages(adId: original.id, images: compressed)
          .timeout(const Duration(seconds: 20));

      imagesCount = compressed.length;
    }

    final updated = original.copyWith(
      title: title,
      description: description,
      category: category,
      price: price,
      contact: contact,
      city: city,
      imagesCount: imagesCount,
    );

    await repo.updateAd(updated).timeout(const Duration(seconds: 15));

    ref.invalidate(adsStreamProvider);
    ref.invalidate(myAdsStreamProvider(original.ownerId));
    ref.invalidate(adThumbProvider(original.id));
    ref.invalidate(adImagesProvider(original.id));
  });
} 

  Future<void> deleteAdAsOwnerOrAdmin(Ad ad) async {
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn) return;

    final canDelete =
         auth.isAdmin || auth.user!.id == ad.ownerId; 
    if (!canDelete) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adsRepoProvider);
      await repo.deleteAd(ad.id).timeout(const Duration(seconds: 15));

      ref.invalidate(adsStreamProvider);
      ref.invalidate(myAdsStreamProvider(ad.ownerId));
      ref.invalidate(adThumbProvider(ad.id));
      ref.invalidate(adImagesProvider(ad.id));
    });
  }
}
