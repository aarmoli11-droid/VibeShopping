import '../domain/category_model.dart';
import '../domain/repositories/category_repository.dart';

class CategoryService {
  CategoryService({required CategoryRepository repository})
      : _repository = repository;

  final CategoryRepository _repository;

  List<CategoryModel>? _cached;

  Future<List<CategoryModel>> getCategories() async {
    if (_cached != null) return _cached!;
    _cached = await _repository.getCategories();
    return _cached!;
  }

  void invalidateCache() {
    _cached = null;
  }
}
