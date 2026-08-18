import 'package:flutter/foundation.dart';
import '../services/explorer_service.dart';
import '../domain/store_model.dart';
import '../domain/store_location.dart';
import '../../categories/domain/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../products/models/product.dart';
import '../../products/providers/product_provider.dart';
import '../../../core/data/supabase/supabase_product_repository.dart';

// Estado del explorador: filtros y productos derivados de los providers.
class ExplorerProvider extends ChangeNotifier {
  ExplorerProvider({
    required ExplorerService service,
    required ProductProvider productProvider,
    required CategoryProvider categoryProvider,
    required SupabaseProductRepository repository,
  })  : _service = service,
        _productProvider = productProvider,
        _categoryProvider = categoryProvider,
        _repository = repository;

  final ExplorerService _service;
  final ProductProvider _productProvider;
  final CategoryProvider _categoryProvider;
  final SupabaseProductRepository _repository;

  bool _initialized = false;
  List<StoreModel> _stores = [];
  List<ProductEntity> _allCachedProducts = [];

  // Estado de filtros.
  bool _allStores = true;
  final Set<String> _selectedStoreIds = {};
  String _categoryId = 'todo';
  String _searchQuery = '';

  bool get allStores => _allStores;
  Set<String> get selectedStoreIds => _selectedStoreIds;
  String get categoryId => _categoryId;
  String get searchQuery => _searchQuery;
  List<StoreModel> get stores => _stores;
  bool get initialized => _initialized;

  List<ProductEntity> get products => _productProvider.products;
  bool get productsLoading => _productProvider.isLoading;
  List<CategoryModel> get categories => _categoryProvider.categories;

  // Productos filtrados por categoría, tienda y búsqueda (sin Supabase).
  Map<String, List<ProductEntity>> get groupedProducts {
    if (!_initialized) return {};

    var filtered = _allCachedProducts;

    if (_categoryId != 'todo') {
      final catIds = _categoryIdsFor(_categoryId);
      filtered = filtered.where((p) => catIds.contains(p.categoryId)).toList();
    }

    if (!_allStores) {
      if (_selectedStoreIds.isEmpty) return {};
      filtered = filtered
          .where((p) =>
              p.prices.any((pr) => _selectedStoreIds.contains(pr.storeId)))
          .toList();
    }

    return _service.filterAndGroupProducts(filtered, _searchQuery);
  }

  String get storeFilterLabel =>
      _service.buildStoreLabel(_allStores, _selectedStoreIds, _stores);

  String storeNameById(String id) => _service.storeNameById(_stores, id);

  List<String>? get selectedStoreUuids {
    if (_allStores || _selectedStoreIds.isEmpty) return null;
    return _selectedStoreIds.toList();
  }

  // Carga productos y categorías una vez por sesión.
  Future<void> initialize() async {
    if (_initialized) return;

    await Future.wait([
      _productProvider.loadProducts(),
      _categoryProvider.initialize(),
    ]);

    _allCachedProducts = List<ProductEntity>.from(_productProvider.products);
    _deriveStores(await _loadStoreLocations());
    _initialized = true;
    notifyListeners();
  }

  // Coordenadas reales de supermercados (tabla `supermarkets`).
  Future<Map<String, StoreLocation>> _loadStoreLocations() async {
    final locations = <String, StoreLocation>{};
    try {
      for (final store in await _repository.listSupermarkets()) {
        final lat = store.latitude;
        final lng = store.longitude;
        if (lat == null || lng == null) continue;
        locations[store.id] = StoreLocation(latitude: lat, longitude: lng);
      }
    } catch (_) {
      // Sin coordenadas la distancia simplemente no aplica.
    }
    return locations;
  }

  // Filtros locales (no llaman a Supabase).
  void setCategory(String id) {
    _categoryId = id;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStoreFilter(bool allStores, Set<String> selectedIds) {
    _allStores = allStores;
    _selectedStoreIds
      ..clear()
      ..addAll(selectedIds);
    notifyListeners();
  }

  // Deriva la lista de tiendas desde los precios del catálogo y las coordenadas reales.
  void _deriveStores(Map<String, StoreLocation> locations) {
    final seen = <String>{};
    _stores = [];
    for (final product in _allCachedProducts) {
      for (final price in product.prices) {
        if (seen.add(price.storeId)) {
          final location = locations[price.storeId] ??
              ((price.latitude != null && price.longitude != null)
                  ? StoreLocation(
                      latitude: price.latitude!, longitude: price.longitude!)
                  : null);
          _stores.add(StoreModel(
            id: price.storeId,
            name: price.storeName,
            logoUrl: price.logoUrl,
            locations: location == null ? const [] : [location],
          ));
        }
      }
    }
  }

  // IDs de la base para una categoría de la barra.
  Set<String> _categoryIdsFor(String categoryId) {
    final cat = _categoryProvider.categories
        .where((c) => c.id == categoryId)
        .firstOrNull;
    if (cat == null || cat.dbCategoryIds.isEmpty) return {categoryId};
    return cat.dbCategoryIds.toSet();
  }
}
