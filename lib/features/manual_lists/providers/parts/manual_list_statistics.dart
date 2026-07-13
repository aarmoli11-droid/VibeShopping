import 'package:flutter/foundation.dart';
import '../../../products/models/product.dart';
import '../../../products/providers/product_provider.dart';
import '../../models/manual_list_entity.dart';
import '../../models/manual_list_summary.dart';
import '../../services/manual_list_statistics_service.dart';

mixin ManualListStatisticsMixin {
  ManualListStatisticsService get statisticsService;

  ProductProvider? get productProvider;

  @protected
  ManualListEntity? getListById(String id);

  @protected
  Map<String, ProductEntity> buildProductMap();

  ManualListSummary getSummary(String listId) {
    final list = getListById(listId);
    if (list == null) {
      return ManualListSummary(
        totalItems: 0,
        totalQuantity: 0,
        estimatedTotal: 0.0,
        averageProductPrice: 0.0,
        storesInvolved: [],
        categoriesInvolved: [],
        lastUpdated: DateTime.now(),
      );
    }
    return statisticsService.computeSummary(
      list,
      productProvider?.products ?? [],
    );
  }

  Map<String, List<ManualListItemEntity>> getProductsByStore(String listId) {
    final list = getListById(listId);
    if (list == null) return {};
    final grouped = <String, List<ManualListItemEntity>>{};
    for (final item in list.items) {
      final key = item.storeNameSnapshot.isNotEmpty
          ? item.storeNameSnapshot
          : 'Sin tienda';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }
    return grouped;
  }

  Map<String, List<ManualListItemEntity>> getProductsByCategory(String listId) {
    final list = getListById(listId);
    if (list == null) return {};
    final productMap = buildProductMap();
    final grouped = <String, List<ManualListItemEntity>>{};
    for (final item in list.items) {
      final product = productMap[item.productId];
      final key = product?.categoryId.isNotEmpty == true
          ? product!.categoryId
          : 'Sin categoría';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }
    return grouped;
  }

  Map<String, List<ManualListItemEntity>> getProductsBySubcategory(
      String listId) {
    final list = getListById(listId);
    if (list == null) return {};
    final productMap = buildProductMap();
    final grouped = <String, List<ManualListItemEntity>>{};
    for (final item in list.items) {
      final product = productMap[item.productId];
      final key = product?.subcategory?.isNotEmpty == true
          ? product!.subcategory!
          : 'Sin subcategoría';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }
    return grouped;
  }
}
