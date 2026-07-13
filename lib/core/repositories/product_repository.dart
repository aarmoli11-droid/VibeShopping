import '../../features/products/models/product.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> listProducts({
    List<String>? categoryIds,
    String? storeId,
    String? search,
    List<String>? storeIds,
  });

  Future<ProductEntity?> getProduct(String id);
}
