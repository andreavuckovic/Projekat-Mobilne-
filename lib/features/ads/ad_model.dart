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

  const Ad({
    required this.id, 
    required this.title, 
    required this.description,
    required this.category,
    required this.price,
    required this.ownerId,
    this.images = const [],
    required this.ownerName,
    required this.contact,
    required this.city,

  });

  Ad copyWith({
    String? title,
    String? description,
    AdCategory? category,
    double? price,
    List<Uint8List>? images,
    String? ownerName,
    String? contact,
    String? city,
  }) {
    return Ad( 
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      ownerId: ownerId,
      images: images ?? this.images,
      ownerName: ownerName ?? this.ownerName,
      contact: contact ?? this.contact,
      city: city ?? this.city,
    );
  } 
}
extension AdFirestore on Ad {
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
      'createdAt': FieldValue.serverTimestamp(),
      
    };
  }

  static Ad fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Ad(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      category: AdCategory.values.firstWhere(
        (c) => c.name == (data['category'] ?? 'ostalo'),
        orElse: () => AdCategory.ostalo,
      ),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      ownerId: (data['ownerId'] ?? '') as String,
      ownerName: (data['ownerName'] ?? '') as String,
      contact: (data['contact'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      images: const [], 
    );
  }
}
