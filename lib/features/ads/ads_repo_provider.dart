import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ads_repository.dart';

final adsRepoProvider = Provider((ref) => AdsRepository());
