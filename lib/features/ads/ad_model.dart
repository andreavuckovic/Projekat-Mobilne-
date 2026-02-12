import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

enum AdCategory { elektronika, odeca, namestaj, usluge, ostalo }

class Ad {
  final String id;
  final String title;
  final String description;
  final AdCategory category;
  final double price;
  final String ownerId;
  final String ownerName;
  final String contact;
  final String city;

  final List<Uint8List> images;
  final List<String> imageUrls;

  const Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.ownerId,
    required this.ownerName,
    required this.contact,
    required this.city,
    this.images = const [],
    this.imageUrls = const [],
  });

  Ad copyWith({
    String? id,
    String? title,
    String? description,
    AdCategory? category,
    double? price,
    String? ownerId,
    String? ownerName,
    String? contact,
    String? city,
    List<Uint8List>? images,
    List<String>? imageUrls,
  }) {
    return Ad(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      contact: contact ?? this.contact,
      city: city ?? this.city,
      images: images ?? this.images,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'price': price,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'contact': contact,
      'city': city,
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Ad fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final catStr = (data['category'] as String?) ?? 'ostalo';
    final cat = AdCategory.values.firstWhere(
      (c) => c.name == catStr,
      orElse: () => AdCategory.ostalo,
    );

    return Ad(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      category: cat,
      price: ((data['price'] as num?) ?? 0).toDouble(),
      ownerId: (data['ownerId'] as String?) ?? '',
      ownerName: (data['ownerName'] as String?) ?? '',
      contact: (data['contact'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      images: const [],
      imageUrls: (data['imageUrls'] as List?)?.cast<String>() ?? const [],
    );
  }
}
