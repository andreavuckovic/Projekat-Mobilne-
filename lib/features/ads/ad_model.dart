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
  final int imagesCount;

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
    this.imagesCount = 0,
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
    int? imagesCount,
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
      imagesCount: imagesCount ?? this.imagesCount,
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
      'imagesCount': imagesCount,
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
      imagesCount: ((data['imagesCount'] as num?) ?? 0).toInt(),
    );
  }
}
