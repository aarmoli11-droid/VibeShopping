import 'package:flutter/foundation.dart';
import '../services/explorer_service.dart';
import '../domain/store_model.dart';
import '../../categories/domain/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../products/models/product.dart';
import '../../products/providers/product_provider.dart';

class ExplorerProvider extends ChangeNotifier {
  ExplorerProvider({
    required ExplorerService service,
    required ProductProvider productProvider,
    required CategoryProvider categoryProvider,
  })  : _service = service,
        _productProvider = productProvider,
        _categoryProvider = categoryProvider;

  final ExplorerService _service;
  final ProductProvider _productProvider;
  final CategoryProvider _categoryProvider;

  // ——— Initialization guard ———
  bool _initialized = false;

  // ——— Stores (derived from product prices) ———
  List<StoreModel> _stores = [];

  // ——— Full cached product list (loaded once per session) ———
  List<ProductEntity> _allCachedProducts = [];

  // ——— Filter state ———
  bool _allStores = true;
  final Set<String> _selectedStoreIds = {};
  String _categoryId = 'todo';
  String _searchQuery = '';

  // ——— Getters ———
  bool get allStores => _allStores;
  Set<String> get selectedStoreIds => _selectedStoreIds;
  String get categoryId => _categoryId;
  String get searchQuery => _searchQuery;
  List<StoreModel> get stores => _stores;
  bool get initialized => _initialized;

  List<ProductEntity> get products => _productProvider.products;
  bool get productsLoading => _productProvider.isLoading;

  List<CategoryModel> get categories => _categoryProvider.categories;

  // ——— Local filtering (never calls Supabase) ———
  Map<String, List<ProductEntity>> get groupedProducts {
    if (!_initialized) return {};

    var filtered = _allCachedProducts;

    // Apply category filter locally
    if (_categoryId != 'todo') {
      final catIds = _categoryIdsFor(_categoryId);
      filtered = filtered.where((p) => catIds.contains(p.categoryId)).toList();
    }

    // Apply store filter locally
    if (!_allStores) {
      if (_selectedStoreIds.isEmpty) return {};
      filtered = filtered
          .where((p) =>
              p.prices.any((pr) => _selectedStoreIds.contains(pr.storeId)))
          .toList();
    }

    // Apply search + group
    return _service.filterAndGroupProducts(filtered, _searchQuery);
  }

  String get storeFilterLabel =>
      _service.buildStoreLabel(_allStores, _selectedStoreIds, _stores);

  String storeNameById(String id) => _service.storeNameById(_stores, id);

  List<String>? get selectedStoreUuids {
    if (_allStores || _selectedStoreIds.isEmpty) return null;
    return _selectedStoreIds.toList();
  }

  // ——— Initialization (runs once per session) ———
  Future<void> initialize() async {
    if (_initialized) return;

    // Kick off dependent loaders
    await Future.wait([
      _productProvider.loadProducts(),
      _categoryProvider.initialize(),
    ]);

    _allCachedProducts = List<ProductEntity>.from(_productProvider.products);
    _deriveStores();
    _initialized = true;
    notifyListeners();
  }

  // ——— Local category filter (no Supabase call) ———
  void setCategory(String id) {
    _categoryId = id;
    notifyListeners();
  }

  // ——— Local search filter (no Supabase call) ———
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ——— Local store filter (no Supabase call) ———
  void setStoreFilter(bool allStores, Set<String> selectedIds) {
    _allStores = allStores;
    _selectedStoreIds
      ..clear()
      ..addAll(selectedIds);
    notifyListeners();
  }

  // ——— Full reload (clears cache and re-queries Supabase) ———
  Future<void> refresh() async {
    _initialized = false;
    _allCachedProducts = [];
    _stores = [];
    await initialize();
  }

  // ——— Derive stores from cached product prices ———
  void _deriveStores() {
    final seen = <String>{};
    _stores = [];
    for (final product in _allCachedProducts) {
      for (final price in product.prices) {
        if (seen.add(price.storeId)) {
          _stores.add(StoreModel(
            id: price.storeId,
            name: price.storeName,
            logoUrl: price.logoUrl,
            latitude: price.latitude,
            longitude: price.longitude,
          ));
        }
      }
    }
  }

  // ——— Helpers ———
  Set<String> _categoryIdsFor(String categoryId) {
    final cat = _categoryProvider.categories
        .where((c) => c.id == categoryId)
        .firstOrNull;
    if (cat == null || cat.dbCategoryIds.isEmpty) return {categoryId};
    return cat.dbCategoryIds.toSet();
  }
}
