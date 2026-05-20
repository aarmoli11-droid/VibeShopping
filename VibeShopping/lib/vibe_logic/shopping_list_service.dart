import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../vibe_ui/Home/product_detail_view.dart';
import '../vibe_models/store_kind.dart';

class ShoppingListService {
  const ShoppingListService._();

  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Agrega un producto a la tabla 'shopping_list' en Supabase.
  /// 
  /// Se obtienen los datos necesarios del objeto [ProductDetailData] y se
  /// resuelve la tienda y el precio de referencia usando [allStores] y [selectedKinds].
  static Future<bool> addItem(
    ProductDetailData product, {
    required bool allStores,
    required Set<VibeStoreKind> selectedKinds,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final gridRef = product.resolveGridPrice(
        allStores: allStores,
        selectedKinds: selectedKinds,
      );

      final storeName = gridRef.store?.displayName ?? 'Desconocida';
      
      // Asegurarse de que el precio sea numérico
      final priceString = gridRef.price.replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.tryParse(priceString) ?? 0.0;

      await _supabase.from('shopping_list').insert({
        'user_id': user.id,
        'product_id': product.id,
        'quantity': 1,
        'store_name': storeName,
        'price_at_addition': price,
      });

      return true;
    } on PostgrestException catch (e) {
      debugPrint('Error de Supabase: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error inesperado: $e');
      rethrow;
    }
  }

  /// Elimina un producto de la lista.
  static Future<bool> removeItem(int id) async {
    try {
      await _supabase.from('shopping_list').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Actualiza la cantidad de un producto en la lista.
  static Future<bool> updateQuantity(int id, int newQuantity) async {
    try {
      await _supabase
          .from('shopping_list')
          .update({'quantity': newQuantity})
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene los items de la lista para el usuario actual con join a productos y supermercados.
  static Future<List<Map<String, dynamic>>> fetchItems() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('shopping_list')
          .select('*, products(*, supermarkets(name, logo_url))')
          .eq('user_id', user.id);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Calcula el total de la lista.
  static double calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (sum, item) {
      final price = (item['price_at_addition'] as num?)?.toDouble() ?? 0.0;
      return sum + price;
    });
  }
}
