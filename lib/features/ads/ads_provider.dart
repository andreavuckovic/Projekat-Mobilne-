import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_provider.dart';
import '../auth/auth_state.dart';
import 'ad_model.dart';

import 'dart:typed_data';


final adsProvider = NotifierProvider<AdsController, List<Ad>>(AdsController.new);

class AdsController extends Notifier<List<Ad>> {
  final _uuid = const Uuid();

  @override
  List<Ad> build() {
    return const [
      Ad(
        id: '1',
        title: 'iPhone 11 64GB',
        description: 'Odlično stanje, uz kutiju.',
        category: AdCategory.elektronika,
        price: 220,
        ownerId: 'demoOwner1',
      ),
      Ad(
        id: '2',
        title: 'Kauč na razvlačenje',
        description: 'Preuzimanje Novi Beograd.',
        category: AdCategory.namestaj,
        price: 80,
        ownerId: 'demoOwner2',
      ),
    ];
  }

  void addAd({
    required String title,
    required String description,
    required AdCategory category,
    required double price,
    List<Uint8List> images = const [],
  }) {
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn) return;

    final newAd = Ad(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      price: price,
      ownerId: auth.user!.id,
      images: images,
    );

    state = [newAd, ...state];
  }

  void deleteAdAsOwnerOrAdmin(String adId) {
    final auth = ref.read(authProvider);
    final ad = state.where((a) => a.id == adId).firstOrNull;
    if (ad == null) return;

    final canDelete = auth.role == UserRole.admin || (auth.user?.id == ad.ownerId);
    if (!canDelete) return;

    state = state.where((a) => a.id != adId).toList();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
