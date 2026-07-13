import 'package:flutter/foundation.dart';
import '../domain/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({required CategoryService service}) : _service = service;

  final CategoryService _service;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _service.getCategories();
      _initialized = true;
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _error = 'Error al cargar categorías';
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _initialized = false;
    _service.invalidateCache();
    _categories = [];
    await initialize();
  }
}
