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
        ownerName: 'Korisnik 1',
        contact: '060/123-456',
        city: 'Beograd - Vozdovac',
      ),
      Ad(
        id: '2',
        title: 'Kauč na razvlačenje',
        description: 'Preuzimanje Novi Beograd.',
        category: AdCategory.namestaj,
        price: 80,
        ownerId: 'demoOwner2',
        ownerName: 'Korisnik 2',
        contact: 'petarpetrovic15@gmail.com',
        city: 'Novi Sad', 
      ), 
    ];
  }

  void addAd({
    required String title,
    required String description,
    required AdCategory category,
    required double price,
    List<Uint8List> images = const [],
    required String contact,
    required String city,
    
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
      ownerName: auth.user!.displayName,
      contact: contact,
      city: city,
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
  
  void deleteAd(String id) {
  state = state.where((a) => a.id != id).toList();
}

void updateAd({
  required String id,
  required String title,
  required String description,
  required AdCategory category,
  required double price,
  required String contact,
  required String city,
  required List<Uint8List> images,
}) { 
  state = [
    for (final a in state)
      if (a.id == id)
        a.copyWith(
          title: title,
          description: description,
          category: category,
          price: price,
          contact: contact,
          city: city,
          images: images,
        )
      else
        a,
  ];
}

}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;


  



}
