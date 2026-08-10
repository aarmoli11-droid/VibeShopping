import 'package:flutter/foundation.dart';
import '../domain/category_model.dart';
import '../data/repositories/supabase_category_repository.dart';

// Estado de las categorías para la barra de filtros del explorador.
class CategoryProvider extends ChangeNotifier {
  CategoryProvider({required SupabaseCategoryRepository repository})
      : _repository = repository;

  final SupabaseCategoryRepository _repository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _initialized = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  // Carga las categorías una sola vez por sesión.
  Future<void> initialize() async {
    if (_initialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
      _initialized = true;
    } catch (_) {
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
