// ======================================================
// Archivo: features/products/providers/product_provider.dart
// Responsabilidad: Gestionar el estado del catálogo de
//   productos y notificar cambios a los widgets
// Qué hace: Mantiene la lista de productos, el producto
//   seleccionado, estado de carga y error. Expone métodos
//   para cargar productos y limpiar errores
// Quién lo utiliza: MarketExplorerView (carga y muestra
//   productos), ProductDetailView (detalle de producto),
//   VibeAiAssistant (contexto de productos)
//
// Flujo dentro de la aplicación:
//   1. Un widget llama context.read<ProductProvider>().loadProducts()
//   2. ProductProvider pone isLoading=true y notifica
//   3. El widget se reconstruye y muestra spinner
//   4. ProductProvider llama service.listProducts() (async)
//   5. Cuando termina, guarda el resultado y notifica
//   6. El widget se reconstruye y muestra los productos
//   7. Si hay error, guarda el mensaje y el widget muestra
//      la pantalla de error
//
// Conceptos utilizados:
//   - ChangeNotifier: clase de Flutter que permite
//     notificar cambios a listeners. Cuando se llama a
//     notifyListeners(), los widgets suscritos con
//     context.watch() se reconstruyen automáticamente
//   - Provider: patrón de inyección de dependencias y
//     estado. Se configura en main.dart con MultiProvider
//   - context.watch() vs context.read(): watch() se
//     suscribe a cambios (se reconstruye al notificar),
//     read() solo obtiene la referencia sin suscribirse
//   - try/catch/finally: bloque que captura excepciones
//     asíncronas. finally se ejecuta siempre, haya o no
//     error — ideal para poner isLoading=false
// ======================================================

import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

// ======================================================
// Clase: ProductProvider
// Provider de estado para el catálogo de productos.
// Separa la lógica de datos (ProductService) de la UI.
// Los widgets reaccionan a cambios sin saber cómo se
// obtienen los datos
// Cuándo se crea: en main.dart, inyectado vía
//   ChangeNotifierProvider dentro de MultiProvider
// ======================================================
class ProductProvider extends ChangeNotifier {
  ProductProvider({required this.service});

  final ProductService service;

  // ——— Estado interno ———
  List<ProductEntity> _products = [];
  ProductEntity? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  // ——— Getters (solo lectura para los widgets) ———
  List<ProductEntity> get products => _products;
  ProductEntity? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ======================================================
  // loadProducts
  // Recibe: filtros opcionales (los mismos de ProductService)
  // Devuelve: Future<void> — el resultado se guarda en
  //   _products, los widgets acceden vía getter
  // Cuándo se ejecuta: al iniciar el explorador, al cambiar
  //   de categoría, al buscar, al hacer pull-to-refresh
  // Quién lo llama: MarketExplorerView (onInit, onSearch,
  //   onCategoryTap), VibeAiAssistant
  //
  // Paso 1: marcar loading=true y limpiar error previo
  // Paso 2: notificar para que la UI muestre el spinner
  // Paso 3: llamar al service (operación async)
  // Paso 4: si hay error, guardar mensaje y limpiar lista
  // Paso 5: siempre (finally) marcar loading=false y notificar
  // ======================================================
  Future<void> loadProducts({
    List<String>? categoryIds,
    String? storeId,
    String? search,
    List<String>? storeIds,
  }) async {
    // Paso 1: estado de carga
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Paso 3: operación asíncrona
      _products = await service.listProducts(
        categoryIds: categoryIds,
        storeId: storeId,
        search: search,
        storeIds: storeIds,
      );
    } catch (e) {
      // Paso 4: manejo de errores
      debugPrint('Error loading products: $e');
      _error = 'Error al cargar productos';
      _products = [];
    } finally {
      // Paso 5: siempre se ejecuta
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // loadProductDetail
  // Recibe: id del producto (String UUID)
  // Devuelve: Future<void> — el resultado se guarda en
  //   _selectedProduct
  // Cuándo se ejecuta: al navegar a la vista de detalle
  // Quién lo llama: ProductDetailView o quien navegue allí
  //
  // Diferencias con loadProducts:
  //   - Solo carga un producto (no una lista)
  //   - Guarda en _selectedProduct (no en _products)
  //   - Limpia _selectedProduct a null antes de cargar
  // ======================================================
  Future<void> loadProductDetail(String id) async {
    _isLoading = true;
    _selectedProduct = null;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await service.getProduct(id);
    } catch (e) {
      debugPrint('Error loading product detail: $e');
      _error = 'Error al cargar detalle del producto';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // clearError
  // Recibe: nada
  // Devuelve: void — limpia el mensaje de error
  // Cuándo se ejecuta: cuando el usuario descarta el error
  //   (ej: toca un botón "Reintentar")
  // Quién lo llama: widgets que muestran el estado de error
  // ======================================================
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
