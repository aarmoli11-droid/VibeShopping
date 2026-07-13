import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/category_model.dart';
import '../../domain/repositories/category_repository.dart';

class SupabaseCategoryRepository implements CategoryRepository {
  SupabaseCategoryRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  final SupabaseClient _supabase;

  @override
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
