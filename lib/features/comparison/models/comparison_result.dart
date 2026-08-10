import 'store_price.dart';

// Resultado de comparar precios de un producto entre tiendas.
class ComparisonResult {
  final String masterProductId;
  final String productName;
  final List<StorePrice> stores;

  const ComparisonResult({
    required this.masterProductId,
    required this.productName,
    required this.stores,
  });

  // Mejor precio si hay al menos dos tiendas comparables.
  StorePrice? get bestPrice {
    if (stores.length < 2) return null;
    return stores.reduce((a, b) => a.price < b.price ? a : b);
  }
}

// Resumen de la mejor opción para mostrar en la tarjeta del producto.
class ComparisonPreview {
  final String bestStoreName;
  final String? bestStoreLogoUrl;
  final double bestPrice;
  final double savings;

  const ComparisonPreview({
    required this.bestStoreName,
    this.bestStoreLogoUrl,
    required this.bestPrice,
    required this.savings,
  });
}
