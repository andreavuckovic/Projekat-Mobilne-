import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ad_model.dart';

final categoryFilterProvider =
    NotifierProvider<CategoryFilterController, AdCategory?>(CategoryFilterController.new);

class CategoryFilterController extends Notifier<AdCategory?> {
  @override
  AdCategory? build() => null;

  void setCategory(AdCategory? c) => state = c;
}
 

 