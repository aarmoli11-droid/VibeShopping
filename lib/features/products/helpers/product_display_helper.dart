import '../../comparison/models/comparison_result.dart';
import '../../comparison/providers/comparison_provider.dart';
import '../models/product.dart';
import '../../../core/vibe_formatter.dart';

// Helpers para mostrar datos de producto en las tarjetas y el detalle.
class ProductDisplayHelper {
  ProductDisplayHelper._();

  // Precio formateado de la primera tienda.
  static String displayPrice(ProductEntity entity) {
    if (entity.prices.isEmpty) return 'Precio no disponible';
    return VibeFormatter.formatPrice(entity.prices.first.price);
  }

  // Primera imagen válida del producto (o null si no hay).
  static String? primaryImage(ProductEntity entity) {
    final urls = entity.imageUrls.where((u) => u.trim().isNotEmpty).toList();
    return urls.isNotEmpty ? urls.first : null;
  }

  // URLs de imagen válidas para el slider.
  static List<String> validImageUrls(ProductEntity entity) {
    return entity.imageUrls.where((u) => u.trim().isNotEmpty).toList();
  }

  // Datos de la primera tienda del producto para la tarjeta.
  static Map<String, String>? supermarketData(ProductEntity entity) {
    if (entity.prices.isEmpty) return null;
    final price = entity.prices.first;
    return {
      'name': price.storeName,
      'logo_url': price.logoUrl ?? '',
    };
  }

  // Resumen de comparación para la tarjeta (mejor precio y ahorro).
  static ComparisonPreview? getComparisonPreview(
    ProductEntity entity,
    ComparisonProvider provider,
  ) {
    if (entity.prices.isEmpty) return null;
    final result = provider.compareProduct(entity.id);
    if (result == null || result.bestPrice == null) return null;
    final savings = entity.referencePrice - result.bestPrice!.price;
    return ComparisonPreview(
      bestStoreName: result.bestPrice!.storeName,
      bestStoreLogoUrl: result.bestPrice!.storeLogoUrl,
      bestPrice: result.bestPrice!.price,
      savings: savings > 0 ? savings : 0,
    );
  }
}
