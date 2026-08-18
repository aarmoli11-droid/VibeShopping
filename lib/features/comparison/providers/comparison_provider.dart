import 'package:flutter/foundation.dart';
import '../../products/providers/product_provider.dart';
import '../models/comparison_result.dart';
import '../models/comparison_summary.dart';
import '../services/comparison_service.dart';

// Compara precios de un producto entre tiendas, con caché.
class ComparisonProvider extends ChangeNotifier {
  final ProductProvider productProvider;
  final ComparisonService _service = ComparisonService();
  final Map<String, ComparisonResult> _cache = {};
  final Map<String, ComparisonSummary> _summaryCache = {};

  ComparisonProvider({required this.productProvider}) {
    productProvider.addListener(_onProductsChanged);
  }

  // Al recargar productos se descarta la caché de comparaciones.
  void _onProductsChanged() {
    _cache.clear();
    _summaryCache.clear();
  }

  @override
  void dispose() {
    productProvider.removeListener(_onProductsChanged);
    super.dispose();
  }

  // Resultado de comparación para un producto (usa caché si existe).
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

  // Resumen (precio más bajo/alto, ahorro) para un producto.
  ComparisonSummary? summaryFor(String productId) {
    if (_summaryCache.containsKey(productId)) return _summaryCache[productId];
    final result = compareProduct(productId);
    if (result == null) return null;
    final summary = _service.buildSummary(result);
    _summaryCache[productId] = summary;
    return summary;
  }
}
