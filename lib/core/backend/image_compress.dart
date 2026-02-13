import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageCompress {
  static Uint8List toJpeg800(Uint8List input) {
    final decoded = img.decodeImage(input);
    if (decoded == null) return input;

    final resized = decoded.width > 800
        ? img.copyResize(decoded, width: 800)
        : decoded;

    final jpg = img.encodeJpg(resized, quality: 70);
    return Uint8List.fromList(jpg);
  }

  static List<Uint8List> compressMany(List<Uint8List> images) {
    return [for (final b in images) toJpeg800(b)];
  }
}
