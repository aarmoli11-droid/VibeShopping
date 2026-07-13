import '../../../core/repositories/product_repository.dart';
import '../models/product.dart';

class ProductService {
  final ProductRepository _repository;

  ProductService({required ProductRepository repository})
      : _repository = repository;

  Future<List<ProductEntity>> listProducts({
    List<String>? categoryIds,
    String? storeId,
    String? search,
    List<String>? storeIds,
  }) async {
    return _repository.listProducts(
      categoryIds: categoryIds,
      storeId: storeId,
      search: search,
      storeIds: storeIds,
    );
  }

  Future<ProductEntity?> getProduct(String id) async {
    return _repository.getProduct(id);
  }
}
