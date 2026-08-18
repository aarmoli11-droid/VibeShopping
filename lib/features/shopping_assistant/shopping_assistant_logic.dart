import '../products/models/product.dart';
import '../explorer/domain/store_model.dart';
import 'shopping_assistant_data.dart';

// Modos de transporte disponibles para la recomendación.
enum TransportMode { car, bus, bike, walking }

// Puntaje de una tienda para un producto.
class StoreScore {
  final String storeId;
  final String storeName;
  final double price;
  final double distanceKm;
  final int travelMinutes;
  final double score;

  const StoreScore({
    required this.storeId,
    required this.storeName,
    required this.price,
    required this.distanceKm,
    required this.travelMinutes,
    required this.score,
  });
}

// Resultado completo de la recomendación.
class ShoppingRecommendation {
  final String productName;
  final TransportMode transport;
  final StoreScore best;
  final double estimatedSavings;
  final List<StoreScore> alternatives;

  const ShoppingRecommendation({
    required this.productName,
    required this.transport,
    required this.best,
    required this.estimatedSavings,
    required this.alternatives,
  });
}

// Datos intermedios de una tienda antes del cálculo final.
class _Candidate {
  final String storeId;
  final String storeName;
  final double price;
  final double distanceKm;

  _Candidate({
    required this.storeId,
    required this.storeName,
    required this.price,
    required this.distanceKm,
  });
}

// Motor de recomendación: precio + distancia según el transporte.
// score = pesoPrecio * (másBarato/precio) + pesoDistancia * (másCerca/distancia).
abstract final class ShoppingAssistantLogic {
  // Pesos precio/distancia según el transporte.
  static ({double price, double distance}) _weights(TransportMode mode) {
    return switch (mode) {
      TransportMode.car => (price: 0.6, distance: 0.4),
      TransportMode.bus => (price: 0.5, distance: 0.5),
      TransportMode.bike => (price: 0.4, distance: 0.6),
      TransportMode.walking => (price: 0.3, distance: 0.7),
    };
  }

  // Velocidad promedio (km/h) por transporte para estimar el tiempo.
  static double _speedKmh(TransportMode mode) {
    return switch (mode) {
      TransportMode.car => 30,
      TransportMode.bus => 20,
      TransportMode.bike => 15,
      TransportMode.walking => 5,
    };
  }

  // Recomendación para una cesta (uno o más productos mencionados en la
  // consulta): se suma el costo por tienda y se puntúa como buildRecommendation.
  // Solo son candidatas las tiendas que tienen todos los productos de la cesta.
  static ShoppingRecommendation? buildBasketRecommendation({
    required String query,
    required List<ProductEntity> products,
    required List<StoreModel> stores,
    required TransportMode mode,
  }) {
    final basket = _matchBasket(query, products);
    if (basket.isEmpty) return null;

    // Total y cobertura por tienda para la cesta completa.
    final totals = <String, ({String storeName, double total})>{};
    final coverage = <String, int>{};
    final names = <String>{};
    for (final item in basket) {
      names.add(item.name);
      for (final price in item.prices) {
        coverage[price.storeId] = (coverage[price.storeId] ?? 0) + 1;
        final current = totals[price.storeId];
        totals[price.storeId] = (
          storeName: price.storeName,
          total: (current?.total ?? 0) + price.price,
        );
      }
    }

    // Candidatas: cesta completa y distancia conocida.
    final candidates = <_Candidate>[];
    for (final store in stores) {
      final data = totals[store.id];
      if (data == null || coverage[store.id] != basket.length) continue;
      final distance = ShoppingAssistantData.distanceToStore(store);
      if (distance == null) continue;

      candidates.add(_Candidate(
        storeId: store.id,
        storeName: data.storeName,
        price: data.total,
        distanceKm: distance,
      ));
    }
    if (candidates.isEmpty) return null;

    return _rankedRecommendation(names.join(', '), candidates, mode);
  }

  // Recomendación ordenada para el producto buscado, o null si no aplica.
  static ShoppingRecommendation? buildRecommendation({
    required String query,
    required List<ProductEntity> products,
    required List<StoreModel> stores,
    required TransportMode mode,
  }) {
    final product = _matchProduct(query, products);
    if (product == null) return null;

    // Candidatos con distancia válida.
    final candidates = <_Candidate>[];
    for (final price in product.prices) {
      final store = _storeById(stores, price.storeId);
      final distance = ShoppingAssistantData.distanceToStore(store);
      if (distance == null) continue;

      candidates.add(_Candidate(
        storeId: price.storeId,
        storeName: price.storeName,
        price: price.price,
        distanceKm: distance,
      ));
    }
    if (candidates.isEmpty) return null;

    return _rankedRecommendation(product.name, candidates, mode);
  }

  // Puntúa, ordena y arma el resultado final a partir de los candidatos.
  static ShoppingRecommendation _rankedRecommendation(
      String productName, List<_Candidate> candidates, TransportMode mode) {
    final minPrice =
        candidates.map((c) => c.price).reduce((a, b) => a < b ? a : b);
    final minDistance =
        candidates.map((c) => c.distanceKm).reduce((a, b) => a < b ? a : b);

    final weights = _weights(mode);
    final scores = candidates.map((c) {
      final score = weights.price * (minPrice / c.price) +
          weights.distance * (minDistance / c.distanceKm);

      return StoreScore(
        storeId: c.storeId,
        storeName: c.storeName,
        price: c.price,
        distanceKm: c.distanceKm,
        travelMinutes: (c.distanceKm / _speedKmh(mode) * 60).ceil(),
        score: score,
      );
    }).toList();

    scores.sort((a, b) => b.score.compareTo(a.score));
    final best = scores.first;
    final mostExpensive =
        scores.map((s) => s.price).reduce((a, b) => a > b ? a : b);

    return ShoppingRecommendation(
      productName: productName,
      transport: mode,
      best: best,
      estimatedSavings: mostExpensive - best.price,
      alternatives: scores.sublist(1),
    );
  }

  // Productos (deduplicados por nombre) cuyas palabras aparecen en la consulta.
  // Junta los precios de todas las tiendas del mismo producto.
  static List<({String name, List<ProductPrice> prices})> _matchBasket(
      String query, List<ProductEntity> products) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'[^a-záéíóúñü0-9]+'))
        .where((w) => w.length >= 3)
        .toList();
    if (words.isEmpty) return [];

    final grouped = <String, ({String name, List<ProductPrice> prices})>{};
    for (final product in products) {
      if (!words.any(product.name.toLowerCase().contains)) continue;
      final entry = grouped.putIfAbsent(
          product.name, () => (name: product.name, prices: []));
      entry.prices.addAll(product.prices);
    }
    return grouped.values.toList();
  }

  // Primer producto cuyo nombre contenga la consulta.
  static ProductEntity? _matchProduct(
      String query, List<ProductEntity> products) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final product in products) {
      if (product.name.toLowerCase().contains(normalized)) return product;
    }
    return null;
  }

  static StoreModel? _storeById(List<StoreModel> stores, String id) {
    for (final store in stores) {
      if (store.id == id) return store;
    }
    return null;
  }
}
