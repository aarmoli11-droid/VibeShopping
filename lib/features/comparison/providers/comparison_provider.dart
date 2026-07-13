import 'package:flutter/foundation.dart';
import '../../products/providers/product_provider.dart';
import '../../manual_lists/models/price_comparison_info.dart';
import '../models/comparison_result.dart';
import '../models/comparison_summary.dart';
import '../services/comparison_service.dart';

class ComparisonProvider extends ChangeNotifier {
  final ProductProvider productProvider;
  final ComparisonService _service = ComparisonService();
  final Map<String, ComparisonResult> _cache = {};
  final Map<String, ComparisonSummary> _summaryCache = {};

  ComparisonProvider({required this.productProvider}) {
    productProvider.addListener(_onProductsChanged);
  }

  void _onProductsChanged() {
    _cache.clear();
    _summaryCache.clear();
  }

  @override
  void dispose() {
    productProvider.removeListener(_onProductsChanged);
    super.dispose();
  }

  ComparisonResult? compareProduct(String productId) {
    if (_cache.containsKey(productId)) return _cache[productId];
    final product =
        productProvider.products.where((p) => p.id == productId).firstOrNull;
    if (product == null) return null;
    final result = _service.compare(
        product: product, allProducts: productProvider.products);
    if (result != null) _cache[productId] = result;
    return result;
  }

  ComparisonSummary? summaryFor(String productId) {
    if (_summaryCache.containsKey(productId)) return _summaryCache[productId];
    final result = compareProduct(productId);
    if (result == null) return null;
    final summary = _service.buildSummary(result);
    _summaryCache[productId] = summary;
    return summary;
  }

  Map<String, ComparisonResult?> compareProducts(List<String> productIds) {
    final results = <String, ComparisonResult?>{};
    for (final id in productIds) {
      results[id] = compareProduct(id);
    }
    return results;
  }

  Map<String, ComparisonResult?> compareManualList(List<String> productIds) {
    return compareProducts(productIds);
  }

  List<ComparisonResult> compareStore(String storeId) {
    final results = <ComparisonResult>[];
    final processed = <String>{};
    for (final product in productProvider.products) {
      final hasStore = product.prices.any((p) => p.storeId == storeId);
      if (!hasStore) continue;
      final masterId = product.masterProductId;
      if (masterId == null || processed.contains(masterId)) continue;
      processed.add(masterId);
      final result = compareProduct(product.id);
      if (result != null) results.add(result);
    }
    return results;
  }

  PriceComparisonInfo? buildPriceComparisonInfo(
      String productId, double currentPrice) {
    final result = compareProduct(productId);
    if (result == null || result.bestPrice == null) return null;
    final savings = currentPrice - result.bestPrice!.price;
    return PriceComparisonInfo(
      currentPrice: currentPrice,
      recommendedPrice: result.bestPrice!.price,
      bestStoreId: result.bestPrice!.storeId,
      bestStoreName: result.bestPrice!.storeName,
      estimatedSavings: savings > 0 ? savings : 0,
    );
  }

  void invalidateCache() {
    _cache.clear();
  }
}
