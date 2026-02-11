import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skriptarnica/features/ads/ads_repo_provider.dart';
import 'package:uuid/uuid.dart';

import '../auth/auth_provider.dart';
import '../auth/auth_state.dart';
import 'ad_model.dart';

final adsProvider = NotifierProvider<AdsController, List<Ad>>(AdsController.new);

class AdsController extends Notifier<List<Ad>> {
  final _uuid = const Uuid();
  bool _demoLoaded = false;

  @override
  List<Ad> build() {
    if (!_demoLoaded) { 
      _demoLoaded = true;

      state = const [
        Ad(
          id: '1',
          title: 'iPhone 11 64GB',
          description: 'Odlično stanje, uz kutiju.',
          category: AdCategory.elektronika,
          price: 220,
          ownerId: 'demoOwner1',
          ownerName: 'Korisnik 1',
          contact: '060/123-456',
          city: 'Beograd - Voždovac',
          images: [],
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
          images: [],
        ),
        Ad(
          id: '3',
          title: 'Samsung S10 Plus',
          description: 'Odlično stanje, uz kutiju.',
          category: AdCategory.elektronika,
          price: 150,
          ownerId: 'demoOwner3',
          ownerName: 'Korisnik 3',
          contact: '065/589-2547',
          city: 'Beograd - Skadarlija',
          images: [],
        ),
        Ad(
          id: '4',
          title: 'Laptop Lenovo ThinkPad',
          description: 'i5, 16GB RAM, SSD 512GB.',
          category: AdCategory.elektronika,
          price: 450,
          ownerId: 'demoOwner4',
          ownerName: 'Nikola',
          contact: 'nikola@mail.com',
          city: 'Kragujevac',
          images: [],
        ),
        Ad(
          id: '5',
          title: 'Trpezarijski sto + 4 stolice',
          description: 'Masivno drvo, očuvano.',
          category: AdCategory.namestaj,
          price: 150,
          ownerId: 'demoOwner5',
          ownerName: 'Ana',
          contact: '063/222-333',
          city: 'Subotica',
          images: [],
        ),
        Ad(
          id: '6',
          title: 'Čišćenje stanova',
          description: 'Generalno i redovno čišćenje.',
          category: AdCategory.usluge,
          price: 15,
          ownerId: 'demoOwner6',
          ownerName: 'CleanPro',
          contact: '064/999-888',
          city: 'Beograd',
          images: [],
        ),
        Ad(
          id: '7',
          title: 'Bicikl Trek 29"',
          description: 'Odličan za grad i prirodu.',
          category: AdCategory.ostalo,
          price: 300,
          ownerId: 'demoOwner7',
          ownerName: 'Stefan',
          contact: '061/777-444',
          city: 'Čačak',
          images: [],
        ),
        Ad(
          id: '8',
          title: 'Samsung Smart TV 55"',
          description: '4K UHD, Android TV.',
          category: AdCategory.elektronika,
          price: 400,
          ownerId: 'demoOwner8',
          ownerName: 'Ivana',
          contact: 'ivana@gmail.com',
          city: 'Zrenjanin',
          images: [],
        ),
        Ad(
          id: '9',
          title: 'Haljina za svečane prilike',
          description: 'Veličina M, jednom nošena.',
          category: AdCategory.odeca,
          price: 40,
          ownerId: 'demoOwner9',
          ownerName: 'Milica',
          contact: '065/333-222',
          city: 'Valjevo',
          images: [],
        ),
      ];

      Future.microtask(_loadDemoImages);
    }

    return state;
  }

  Future<Uint8List?> _assetBytes(String path) async {
    try {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<List<Uint8List>> _loadMany(List<String> paths) async {
    final list = await Future.wait(paths.map(_assetBytes));
    return list.whereType<Uint8List>().toList();
  }

  Future<void> _loadDemoImages() async {
    final iphoneImgs = await _loadMany([
      'assets/ads/iphone11_1.jpg',
      'assets/ads/iphone11_2.jpg',  
    ]);

    final couchImgs = await _loadMany([
      'assets/ads/kauc3.jpg',
      'assets/ads/kauc2.jpg',
      'assets/ads/kauc1.jpg',
    ]);

    final samsungImgs = await _loadMany([
      'assets/ads/samsungs10_1.webp',
      'assets/ads/samsung1.jpg',
      'assets/ads/samsung2.webp',
    ]);

    final lenovoImgs = await _loadMany([
      'assets/ads/lenovo2.jpg', 
      'assets/ads/lenovo1.webp',
    ]);

    final tableImgs = await _loadMany([
      'assets/ads/sto1.webp',
    ]);

    final bikeImgs = await _loadMany([
      'assets/ads/bicikl1.webp',
    ]);

    final tvImgs = await _loadMany([
      'assets/ads/tv1.webp',
      'assets/ads/tv2.webp',
    ]);

    final dressImgs = await _loadMany([
      'assets/ads/haljina1.jpg',
    ]);

    state = [
      for (final a in state)
        if (a.id == '1')
          a.copyWith(images: iphoneImgs)
        else if (a.id == '2')
          a.copyWith(images: couchImgs)
        else if (a.id == '3')
          a.copyWith(images: samsungImgs)
        else if (a.id == '4')
          a.copyWith(images: lenovoImgs)
        else if (a.id == '5')
          a.copyWith(images: tableImgs)
        else if (a.id == '7')
          a.copyWith(images: bikeImgs)
        else if (a.id == '8')
          a.copyWith(images: tvImgs)
        else if (a.id == '9')
          a.copyWith(images: dressImgs)
        else
          a,
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
      ownerName: auth.user!.displayName,
      contact: contact,
      city: city,
      images: images,
    );

    state = [newAd, ...state];
  }

  void deleteAdAsOwnerOrAdmin(String adId) {
    final auth = ref.read(authProvider);
    final ad = state.where((a) => a.id == adId).firstOrNull;
    if (ad == null) return;

    final canDelete =
        auth.role == UserRole.admin || (auth.user?.id == ad.ownerId);
    if (!canDelete) return;

    state = state.where((a) => a.id != adId).toList();
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

final adsStreamProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(adsRepoProvider);
  return repo.watchAll();
});

final myAdsStreamProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(adsRepoProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) {
    return const Stream<List<Ad>>.empty();
  }
  return repo.watchMy(user.id);
});
