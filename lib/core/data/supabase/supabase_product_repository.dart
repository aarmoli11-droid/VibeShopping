import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/products/models/product.dart';

// Acceso a los productos desde la vista de Supabase.
class SupabaseProductRepository {
  SupabaseProductRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  final SupabaseClient _supabase;

  // Consulta los productos aplicando los filtros opcionales.
  Future<List<ProductEntity>> listProducts({
    List<String>? categoryIds,
    String? search,
    List<String>? storeIds,
  }) async {
    var query = _supabase.from('v_products_complete').select('*');

    if (categoryIds != null && categoryIds.isNotEmpty) {
      query = categoryIds.length == 1
          ? query.eq('category_id', categoryIds.first)
          : query.inFilter('category_id', categoryIds);
    }

    if (search != null && search.isNotEmpty) {
      query = query.ilike('canonical_name', '%$search%');
    }

    if (storeIds != null && storeIds.isNotEmpty) {
      query = storeIds.length == 1
          ? query.eq('supermarket_id', storeIds.first)
          : query.inFilter('supermarket_id', storeIds);
    }

    final response = await query;
    final rows = response as List<dynamic>;
    return rows
        .map((e) => ProductEntity.fromViewMap(e as Map<String, dynamic>))
        .toList();
  }
}
