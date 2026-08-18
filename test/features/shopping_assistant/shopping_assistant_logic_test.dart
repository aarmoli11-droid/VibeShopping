// ======================================================
// Archivo: test/features/shopping_assistant/
//   shopping_assistant_logic_test.dart
// Responsabilidad: Pruebas unitarias del motor de
//   recomendación (lógica pura, sin Flutter ni Supabase)
// Qué verifica:
//   - Coincidencia de producto por nombre
//   - Influencia del transporte en la recomendación
//   - Casos sin coincidencia o sin distancia conocida
//   - Ahorro estimado y lista de alternativas
// Cómo correr: flutter test (o dart test)
// ======================================================

import 'package:test/test.dart';

import 'package:vibeshopping/features/shopping_assistant/shopping_assistant_logic.dart';
import 'package:vibeshopping/features/products/models/product.dart';
import 'package:vibeshopping/features/explorer/domain/store_model.dart';
import 'package:vibeshopping/features/explorer/domain/store_location.dart';

const _storeAId = 'store-a';
const _storeBId = 'store-b';

// Tienda A: cerca del usuario (~1.4 km) pero más cara
StoreModel _storeA() => StoreModel(
      id: _storeAId,
      name: 'Tienda A',
      locations: const [StoreLocation(latitude: 9.3760, longitude: -83.6900)],
    );

// Tienda B: lejos (~3.6 km) pero más barata
StoreModel _storeB() => StoreModel(
      id: _storeBId,
      name: 'Tienda B',
      locations: const [StoreLocation(latitude: 9.3760, longitude: -83.6700)],
    );

ProductEntity _leche() => ProductEntity(
      id: 'p-1',
      categoryId: 'cat-1',
      name: 'Leche Entera',
      imageUrls: const [],
      prices: const [
        ProductPrice(
          storeId: _storeAId,
          storeName: 'Tienda A',
          price: 2000,
          currency: 'CRC',
        ),
        ProductPrice(
          storeId: _storeBId,
          storeName: 'Tienda B',
          price: 1000,
          currency: 'CRC',
        ),
      ],
      createdAt: '',
    );

// Construye la recomendación y lanza si es null (promueve
// el tipo a no nulo para poder acceder a los campos)
ShoppingRecommendation _recommend(
  List<ProductEntity> products,
  List<StoreModel> stores,
  TransportMode mode, {
  String query = 'leche',
}) {
  final result = ShoppingAssistantLogic.buildRecommendation(
    query: query,
    products: products,
    stores: stores,
    mode: mode,
  );
  if (result == null) {
    fail('Se esperaba una recomendación para la consulta "$query"');
  }
  return result;
}

void main() {
  group('ShoppingAssistantLogic.buildRecommendation', () {
    test('recomienda el producto cuando el nombre coincide', () {
      final result =
          _recommend([_leche()], [_storeA(), _storeB()], TransportMode.car);

      expect(result.productName, 'Leche Entera');
    });

    test('en carro gana la tienda más barata aunque esté lejos', () {
      final result =
          _recommend([_leche()], [_storeA(), _storeB()], TransportMode.car);

      expect(result.best.storeId, _storeBId);
      expect(result.best.price, 1000);
    });

    test('a pie gana la tienda más cercana aunque sea más cara', () {
      final result =
          _recommend([_leche()], [_storeA(), _storeB()], TransportMode.walking);

      expect(result.best.storeId, _storeAId);
      expect(result.best.price, 2000);
    });

    test('retorna null si no hay producto que coincida', () {
      final result = ShoppingAssistantLogic.buildRecommendation(
        query: 'arroz',
        products: [_leche()],
        stores: [_storeA(), _storeB()],
        mode: TransportMode.car,
      );

      expect(result, isNull);
    });

    test('retorna null si ninguna tienda tiene distancia conocida', () {
      final unknownStore = StoreModel(id: 'store-x', name: 'Tienda X');
      final product = ProductEntity(
        id: 'p-2',
        categoryId: 'cat-1',
        name: 'Leche Entera',
        imageUrls: const [],
        prices: const [
          ProductPrice(
            storeId: 'store-x',
            storeName: 'Tienda X',
            price: 1500,
            currency: 'CRC',
          ),
        ],
        createdAt: '',
      );

      final result = ShoppingAssistantLogic.buildRecommendation(
        query: 'leche',
        products: [product],
        stores: [unknownStore],
        mode: TransportMode.bus,
      );

      expect(result, isNull);
    });

    test('calcula el ahorro estimado entre la mejor y la más cara', () {
      final result =
          _recommend([_leche()], [_storeA(), _storeB()], TransportMode.car);

      expect(result.estimatedSavings, 1000);
    });

    test('las alternativas excluyen la mejor opción', () {
      final result =
          _recommend([_leche()], [_storeA(), _storeB()], TransportMode.walking);

      expect(result.alternatives.length, 1);
      expect(result.alternatives.single.storeId, _storeBId);
    });
  });

  group('ShoppingAssistantLogic.buildBasketRecommendation', () {
    // Tienda C: muy cerca, pero solo vende leche (cesta incompleta).
    StoreModel _storeC() => const StoreModel(
          id: 'store-c',
          name: 'Tienda C',
          locations: [StoreLocation(latitude: 9.3770, longitude: -83.7000)],
        );

    // Una fila de catálogo (la vista trae una fila por producto y tienda).
    ProductEntity _row(String storeId, String name, double price) =>
        ProductEntity(
          id: '$name-$storeId',
          categoryId: 'cat-1',
          name: name,
          imageUrls: const [],
          prices: [
            ProductPrice(
              storeId: storeId,
              storeName: storeId,
              price: price,
              currency: 'CRC',
            ),
          ],
          createdAt: '',
        );

    List<ProductEntity> _catalog() => [
          _row(_storeAId, 'Leche Entera', 3000),
          _row(_storeBId, 'Leche Entera', 1000),
          _row('store-c', 'Leche Entera', 2500),
          _row(_storeAId, 'Arroz 2 kg', 1500),
          _row(_storeBId, 'Arroz 2 kg', 1100),
        ];

    List<StoreModel> _stores() => [_storeA(), _storeB(), _storeC()];

    ShoppingRecommendation _basket(
            String query, List<StoreModel> stores, TransportMode mode) =>
        ShoppingAssistantLogic.buildBasketRecommendation(
            query: query, products: _catalog(), stores: stores, mode: mode)!;

    test('una palabra: mismo criterio que el producto único', () {
      final result =
          _basket('leche', [_storeA(), _storeB()], TransportMode.car);
      expect(result.productName, 'Leche Entera');
      expect(result.best.storeId, _storeBId);
      expect(result.best.price, 1000);
    });

    test('el transporte inclina la elección (carro=barato, a pie=cerca)', () {
      final byCar = _basket('arroz y leche', _stores(), TransportMode.car);
      expect(byCar.best.storeId, _storeBId);
      expect(byCar.best.price, 2100); // 1100 + 1000
      expect(byCar.estimatedSavings, 2400); // 4500 - 2100

      final walking = _basket('arroz y leche', _stores(), TransportMode.walking);
      expect(walking.best.storeId, _storeAId);
      expect(walking.best.price, 4500); // 1500 + 3000
      // Tienda C es cercana y razonable, pero no vende arroz: no debe contar.
      expect(
          walking.alternatives.any((s) => s.storeId == 'store-c'), isFalse);
    });

    test('retorna null si ninguna palabra coincide', () {
      final result = ShoppingAssistantLogic.buildBasketRecommendation(
        query: 'pollo asado',
        products: [_leche()],
        stores: [_storeA(), _storeB()],
        mode: TransportMode.car,
      );
      expect(result, isNull);
    });
  });
}
