import '../../comparison/models/comparison_result.dart';
import '../../comparison/providers/comparison_provider.dart';
import '../models/product.dart';
import '../../../core/vibe_formatter.dart';

class GridPriceRef {
  const GridPriceRef({required this.price});

  final String price;
}

class ProductDisplayHelper {
  ProductDisplayHelper._();

  static GridPriceRef resolveGridPrice(ProductEntity entity) {
    if (entity.prices.isEmpty) {
      return const GridPriceRef(price: 'Precio no disponible');
    }
    final first = entity.prices.first;
    return GridPriceRef(
      price: VibeFormatter.formatPrice(first.price),
    );
  }

  static String displayPrice(ProductEntity entity) {
    if (entity.prices.isEmpty) return 'Precio no disponible';
    return VibeFormatter.formatPrice(entity.prices.first.price);
  }

  static String? primaryImage(ProductEntity entity) {
    final urls = entity.imageUrls.where((u) => u.trim().isNotEmpty).toList();
    return urls.isNotEmpty ? urls.first : null;
  }

  static String referenceStoreName(ProductEntity entity) {
    return entity.prices.isNotEmpty
        ? entity.prices.first.storeName
        : 'Desconocida';
  }

  static Map<String, dynamic>? supermarketData(ProductEntity entity) {
    if (entity.prices.isEmpty) return null;
    final first = entity.prices.first;
    return {
      'name': first.storeName,
      'logo_url': first.logoUrl,
    };
  }

  static List<String> validImageUrls(ProductEntity entity) {
    return entity.imageUrls.where((u) => u.trim().isNotEmpty).toList();
  }

  static ComparisonPreview? getComparisonPreview(
    ProductEntity entity,
    ComparisonProvider provider,
  ) {
    if (entity.prices.isEmpty) return null;
    final result = provider.compareProduct(entity.id);
    if (result == null || result.bestPrice == null) return null;
    final currentPrice = entity.referencePrice;
    final savings = currentPrice - result.bestPrice!.price;
    return ComparisonPreview(
      bestStoreName: result.bestPrice!.storeName,
      bestStoreLogoUrl: result.bestPrice!.storeLogoUrl,
      bestPrice: result.bestPrice!.price,
      savings: savings > 0 ? savings : 0,
      storeCount: result.stores.length,
    );
  }
}
