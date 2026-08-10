import 'package:flutter/foundation.dart';
import '../../../core/data/supabase/supabase_product_repository.dart';
import '../models/product.dart';

// Estado del catálogo de productos: lista, carga y filtros de consulta.
class ProductProvider extends ChangeNotifier {
  ProductProvider({required this.repository});

  final SupabaseProductRepository repository;

  List<ProductEntity> _products = [];
  bool _isLoading = false;

  List<ProductEntity> get products => _products;
  bool get isLoading => _isLoading;

  // Carga el catálogo completo una vez por sesión.
  Future<void> loadProducts({
    List<String>? categoryIds,
    String? search,
    List<String>? storeIds,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await repository.listProducts(
        categoryIds: categoryIds,
        search: search,
        storeIds: storeIds,
      );
    } catch (_) {
      // Si falla la consulta se muestra la lista vacía.
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
