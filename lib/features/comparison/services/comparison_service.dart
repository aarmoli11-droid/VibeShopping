import '../../products/models/product.dart';
import '../models/store_price.dart';
import '../models/comparison_result.dart';
import '../models/comparison_summary.dart';

class ComparisonService {
  ComparisonResult? compare({
    required ProductEntity product,
    required List<ProductEntity> allProducts,
  }) {
    final masterId = product.masterProductId;
    if (masterId == null || masterId.isEmpty) return null;

    final siblings = allProducts
        .where((p) =>
            p.masterProductId == masterId && p.prices.any((pr) => pr.price > 0))
        .toList();

    if (siblings.isEmpty) return null;

    final storePrices = <StorePrice>[];
    final seenStores = <String>{};

    for (final p in siblings) {
      for (final price in p.prices) {
        if (price.price <= 0) continue;
        if (seenStores.add(price.storeId)) {
          storePrices.add(StorePrice(
            storeId: price.storeId,
            storeName: price.storeName,
            storeLogoUrl: price.logoUrl,
            price: price.price,
            latitude: price.latitude,
            longitude: price.longitude,
          ));
        }
      }
    }

    if (storePrices.length < 2) return null;

    return ComparisonResult(
      masterProductId: masterId,
      productName: product.name,
      stores: storePrices,
    );
  }

  ComparisonSummary buildSummary(ComparisonResult result) {
    final prices = result.stores.map((s) => s.price).toList();
    final cheapest = prices.reduce((a, b) => a < b ? a : b);
    final highest = prices.reduce((a, b) => a > b ? a : b);
    final average = prices.fold(0.0, (sum, p) => sum + p) / prices.length;
    final savings = highest - cheapest;
    final percentageDiff =
        cheapest > 0 ? ((highest - cheapest) / cheapest) * 100 : 0.0;

    return ComparisonSummary(
      cheapestPrice: cheapest,
      highestPrice: highest,
      averagePrice: average,
      savings: savings,
      percentageDifference: percentageDiff,
      supermarketsCompared: prices.length,
    );
  }
}
