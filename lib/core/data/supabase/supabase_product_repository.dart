import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/product_repository.dart';
import '../../../features/products/models/product.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _supabase;

  SupabaseProductRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<List<ProductEntity>> listProducts({
    List<String>? categoryIds,
    String? storeId,
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

    if (storeId != null) {
      query = query.eq('supermarket_id', storeId);
    }

    final response = await query;
    final rows = response as List<dynamic>;
    return rows
        .map((e) => ProductEntity.fromViewMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductEntity?> getProduct(String id) async {
    final response = await _supabase
        .from('v_products_complete')
        .select('*')
        .eq('product_id', id)
        .single();
    final data = response as Map<String, dynamic>?;
    if (data == null || data.isEmpty) return null;
    return ProductEntity.fromViewMap(data);
  }
}
