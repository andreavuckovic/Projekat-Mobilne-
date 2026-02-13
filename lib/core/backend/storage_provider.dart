import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_service.dart';

final storageProvider = Provider<StorageService>((ref) {
  return StorageService();
});
