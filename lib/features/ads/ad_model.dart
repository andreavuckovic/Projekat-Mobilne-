import 'dart:typed_data';

enum AdCategory { elektronika, odeca, namestaj, usluge, ostalo }

class Ad {
  final String id;
  final String title;
  final String description;
  final AdCategory category;
  final double price;
  final String ownerId;

  final List<Uint8List> images;

  const Ad({
    required this.id, 
    required this.title, 
    required this.description,
    required this.category,
    required this.price,
    required this.ownerId,
    this.images = const [],

  });

  Ad copyWith({
    String? title,
    String? description,
    AdCategory? category,
    double? price,
    List<Uint8List>? images,
  }) {
    return Ad( 
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      ownerId: ownerId,
      images: images ?? this.images,
    );
  }
}
