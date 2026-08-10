import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/category_model.dart';

// Acceso a las categorías desde la tabla de Supabase.
class SupabaseCategoryRepository {
  SupabaseCategoryRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  final SupabaseClient _supabase;

  // Devuelve las categorías activas ordenadas para la barra.
  Future<List<CategoryModel>> getCategories() async {
    final response = await _supabase
        .from('categories')
        .select('*')
        .eq('is_active', true)
        .order('display_order');

    final list = response as List;
    return list
        .map((row) => CategoryModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
