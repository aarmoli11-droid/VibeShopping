import '../entities/basket_product_entity.dart';

/// Caso de uso: listar productos de canasta básica (fuentes de datos en fases posteriores).
class ListBasketProductsUsecase {
  const ListBasketProductsUsecase();

  Future<List<BasketProductEntity>> call() async {
    return const [
      BasketProductEntity(
        id: 'demo-1',
        name: 'Arroz',
        category: 'Granos',
        referenceUnit: 'kg',
      ),
      BasketProductEntity(
        id: 'demo-2',
        name: 'Frijoles',
        category: 'Granos',
        referenceUnit: 'kg',
      ),
    ];
  }
}
