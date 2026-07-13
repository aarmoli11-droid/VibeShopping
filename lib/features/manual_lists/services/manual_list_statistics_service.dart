import '../../products/models/product.dart';
import '../models/manual_list_entity.dart';
import '../models/manual_list_summary.dart';

class ManualListStatisticsService {
  Map<String, ProductEntity> _buildProductMap(
      List<ProductEntity> catalogProducts) {
    final map = <String, ProductEntity>{};
    for (final p in catalogProducts) {
      map[p.id] = p;
    }
    return map;
  }

  ManualListSummary computeSummary(
    ManualListEntity list,
    List<ProductEntity> catalogProducts,
  ) {
    final productMap = _buildProductMap(catalogProducts);
    final items = list.items;

    final totalItems = items.length;
    final totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);
    final estimatedTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
    final averageProductPrice =
        totalItems > 0 ? estimatedTotal / totalItems : 0.0;

    // Find extremes
    SummaryProductInfo? mostExpensive;
    SummaryProductInfo? cheapest;
    if (items.isNotEmpty) {
      // sort by unitPriceSnapshot desc
      final sorted = List<ManualListItemEntity>.from(items)
        ..sort((a, b) => b.unitPriceSnapshot.compareTo(a.unitPriceSnapshot));
      final mostItem = sorted.first;
      final cheapestItem = sorted.last;
      final mostProduct = productMap[mostItem.productId];
      final cheapestProduct = productMap[cheapestItem.productId];

      mostExpensive = SummaryProductInfo(
        productId: mostItem.productId,
        productName: mostProduct?.name ?? 'Producto',
        price: mostItem.unitPriceSnapshot,
        storeName: mostItem.storeNameSnapshot,
        quantity: mostItem.quantity,
      );

      cheapest = SummaryProductInfo(
        productId: cheapestItem.productId,
        productName: cheapestProduct?.name ?? 'Producto',
        price: cheapestItem.unitPriceSnapshot,
        storeName: cheapestItem.storeNameSnapshot,
        quantity: cheapestItem.quantity,
      );
    }

    // Unique stores
    final storeNames = <String>{};
    for (final item in items) {
      if (item.storeNameSnapshot.isNotEmpty) {
        storeNames.add(item.storeNameSnapshot);
      }
    }

    // Unique categories
    final categoryNames = <String>{};
    for (final item in items) {
      final product = productMap[item.productId];
      if (product != null) {
        final catId = product.categoryId;
        if (catId.isNotEmpty) {
          categoryNames.add(catId);
        }
      }
    }

    return ManualListSummary(
      totalItems: totalItems,
      totalQuantity: totalQuantity,
      estimatedTotal: estimatedTotal,
      averageProductPrice: averageProductPrice,
      mostExpensiveProduct: mostExpensive,
      cheapestProduct: cheapest,
      storesInvolved: storeNames.toList()..sort(),
      categoriesInvolved: categoryNames.toList()..sort(),
      lastUpdated: list.updatedAt,
    );
  }

  double calculateAverageProductPrice(ManualListEntity list) {
    if (list.items.isEmpty) return 0.0;
    return list.estimatedTotal / list.items.length;
  }

  ManualListItemEntity? findMostExpensiveProduct(ManualListEntity list) {
    if (list.items.isEmpty) return null;
    return list.items.reduce(
      (a, b) => a.unitPriceSnapshot > b.unitPriceSnapshot ? a : b,
    );
  }

  ManualListItemEntity? findCheapestProduct(ManualListEntity list) {
    if (list.items.isEmpty) return null;
    return list.items.reduce(
      (a, b) => a.unitPriceSnapshot < b.unitPriceSnapshot ? a : b,
    );
  }

  int countStores(ManualListEntity list) {
    final storeIds = <String>{};
    for (final item in list.items) {
      if (item.storeId.isNotEmpty) {
        storeIds.add(item.storeId);
      }
    }
    return storeIds.length;
  }

  int countCategories(
    ManualListEntity list,
    List<ProductEntity> catalogProducts,
  ) {
    final productMap = _buildProductMap(catalogProducts);
    final catIds = <String>{};
    for (final item in list.items) {
      final product = productMap[item.productId];
      if (product?.categoryId != null && product!.categoryId.isNotEmpty) {
        catIds.add(product.categoryId);
      }
    }
    return catIds.length;
  }
}
