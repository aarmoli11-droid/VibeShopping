import '../domain/store_model.dart';
import '../../products/models/product.dart';

class ExplorerService {
  Map<String, List<ProductEntity>> filterAndGroupProducts(
    List<ProductEntity> allProducts,
    String searchQuery,
  ) {
    final query = searchQuery.toLowerCase();

    Iterable<ProductEntity> filtered = allProducts;
    if (query.isNotEmpty) {
      filtered = filtered.where((product) =>
          product.name.toLowerCase().contains(query) ||
          (product.subcategory != null &&
              product.subcategory!.toLowerCase().contains(query)));
    }

    final grouped = <String, List<ProductEntity>>{};
    for (var product in filtered) {
      final key = (product.subcategory != null &&
              product.subcategory!.trim().isNotEmpty)
          ? product.subcategory!.trim()
          : 'General';
      grouped.putIfAbsent(key, () => []).add(product);
    }
    return grouped;
  }

  String buildStoreLabel(
    bool allStores,
    Set<String> selectedStoreIds,
    List<StoreModel> stores,
  ) {
    if (allStores || selectedStoreIds.isEmpty) {
      return 'Todos los supermercados';
    }
    if (selectedStoreIds.length == 1) {
      return storeNameById(stores, selectedStoreIds.first);
    }
    return '${selectedStoreIds.length} supermercados';
  }

  String storeNameById(List<StoreModel> stores, String id) {
    for (final store in stores) {
      if (store.id == id) return store.name;
    }
    return id;
  }
}
