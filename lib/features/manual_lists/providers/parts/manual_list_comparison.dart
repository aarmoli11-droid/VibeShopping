import 'package:flutter/foundation.dart';
import '../../models/manual_list_entity.dart';
import '../../../comparison/providers/comparison_provider.dart';

mixin ManualListComparisonMixin {
  @protected
  List<ManualListEntity> get listsInternal;

  @protected
  Future<void> persist();

  void notifyListeners();

  Future<void> enrichItemsWithComparisons(
      ComparisonProvider comparisonProvider) async {
    for (final list in listsInternal) {
      bool changed = false;
      for (final item in list.items) {
        final info = comparisonProvider.buildPriceComparisonInfo(
          item.productId,
          item.unitPriceSnapshot,
        );
        if (info != null) {
          item.priceComparison = info;
          changed = true;
        }
      }
      if (changed) {
        list.updatedAt = DateTime.now();
      }
    }
    await persist();
    notifyListeners();
  }
}
