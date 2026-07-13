// ======================================================
// Archivo: features/products/models/product.dart
// Responsabilidad: Modelo de datos del catálogo
// Qué hace: Define ProductPrice (precio en una tienda)
//   y ProductEntity (producto completo). La entidad sabe
//   construirse desde API Node.js (camelCase) o desde
//   Supabase directo (snake_case) usando factory methods
// Quién lo utiliza: ProductService, ProductProvider,
//   ProductDisplayHelper, VibeProductCard, VibeAiAssistant
//
// Flujo dentro de la aplicación:
//   1. ProductService obtiene datos JSON (Node.js o Supabase)
//   2. Llama a fromApiMap() o fromSupabaseMap() según la ruta
//   3. ProductProvider almacena ProductEntity en su lista
//   4. Los widgets (VibeProductCard, ProductDetailView) leen
//      los datos para mostrar nombre, precio, imágenes
//   5. VibeAiAssistant usa ProductEntity para dar contexto
//      de productos al asistente de compras
//
// Conceptos utilizados:
//   - Factory constructor: constructor que no siempre crea
//     una nueva instancia. Puede devolver una existente o
//     hacer lógica antes de crear. Se usa con "factory"
//   - camelCase vs snake_case: la API Node.js devuelve
//     "categoryId" (camelCase), Supabase devuelve
//     "category_id" (snake_case). Cada factory maneja el
//     formato correspondiente
//   - Map<String, dynamic>: representa un objeto JSON
//     sin tipar. El factory extrae cada campo con casting
//     y valores por defecto (??) para evitar nulos
//   - parseImageUrls: función compartida que normaliza
//     URLs de imágenes venga como String, List o null
// ======================================================

import '../../../core/parse_image_urls.dart';

// ======================================================
// Clase: ProductPrice
// Representa el precio de un producto en una tienda
//   específica. Una entidad ProductEntity puede tener
//   varios ProductPrice (una por tienda) para comparar
// Cuándo se crea: dentro de los factory methods de
//   ProductEntity al parsear la respuesta JSON
// ======================================================
class ProductPrice {
  final String storeId;
  final String storeName;
  final double price;
  final String currency;
  final String? logoUrl;
  final double? latitude;
  final double? longitude;

  const ProductPrice({
    required this.storeId,
    required this.storeName,
    required this.price,
    required this.currency,
    this.logoUrl,
    this.latitude,
    this.longitude,
  });
}

// ======================================================
// Clase: ProductEntity
// Representa un producto completo del catálogo con
//   todos sus datos e imágenes. Es inmutable (todos
//   los campos son final) y se construye desde JSON
//   mediante factory methods
// Cuándo se crea: cada vez que se carga un listado de
//   productos o se consulta el detalle de uno
//
// Por qué fusionamos DTO y Entity:
//   Antes había ProductEntity (datos) y ProductDto
//   (serialización) como dos clases separadas con los
//   mismos campos. Ahora ProductEntity sabe construirse
//   desde ambos formatos. Menos archivos, menos repetición
// ======================================================
class ProductEntity {
  final String id;
  final String categoryId;
  final String? subcategory;
  final String name;
  final List<String> imageUrls;
  final List<ProductPrice> prices;
  final String createdAt;
  final String? masterProductId;

  const ProductEntity({
    required this.id,
    required this.categoryId,
    this.subcategory,
    required this.name,
    required this.imageUrls,
    required this.prices,
    required this.createdAt,
    this.masterProductId,
  });

  // Getter: precio del primer elemento (referencia rápida
  // para tarjetas en grilla sin tener que acceder a prices[0])
  double get referencePrice => prices.isNotEmpty ? prices.first.price : 0.0;

  // Getter: nombre de la primera tienda (referencia rápida)
  String get referenceStoreName =>
      prices.isNotEmpty ? prices.first.storeName : 'Desconocida';

  // ======================================================
  // Factory: fromApiMap
  // Recibe: Map<String, dynamic> con keys en camelCase
  //   (ej: "categoryId", "imageUrls") proveniente de la
  //   API Node.js
  // Devuelve: ProductEntity con todos los campos poblados
  // Cuándo se ejecuta: cuando ApiConfig.useNodeApi = true
  // Quién lo llama: ProductService._listProductsViaApi()
  //
  // Paso 1: Iterar sobre el array "prices" del JSON y
  //   crear un ProductPrice por cada elemento
  // Paso 2: Construir la entidad con los valores extraídos,
  //   usando ?? para valores por defecto si el campo es null
  // Paso 3: parseImageUrls normaliza imageUrls que puede
  //   venir como String único, List<String> o null
  // ======================================================
  factory ProductEntity.fromApiMap(Map<String, dynamic> map) {
    // Paso 1: parsear prices
    final prices = <ProductPrice>[];
    if (map['prices'] != null && map['prices'] is List) {
      for (final priceData in map['prices'] as List) {
        prices.add(ProductPrice(
          storeId: priceData['storeId'] as String? ?? '',
          storeName: priceData['storeName'] as String? ?? 'Desconocida',
          price: (priceData['price'] as num?)?.toDouble() ?? 0.0,
          currency: priceData['currency'] as String? ?? 'CRC',
          logoUrl: priceData['logoUrl'] as String?,
          latitude: (priceData['latitude'] as num?)?.toDouble(),
          longitude: (priceData['longitude'] as num?)?.toDouble(),
        ));
      }
    }

    return ProductEntity(
      id: map['id']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      subcategory: map['subcategory'] as String?,
      name: map['name'] as String? ?? 'Producto',
      imageUrls: parseImageUrls(map['imageUrls']),
      prices: prices,
      createdAt: map['createdAt'] as String? ?? '',
      masterProductId: map['masterProductId']?.toString(),
    );
  }

  factory ProductEntity.fromSupabaseMap(Map<String, dynamic> map) {
    final master = map['product_master'] as Map<String, dynamic>?;
    final supermarket = map['supermarkets'] as Map<String, dynamic>?;
    final priceRaw = map['price'];
    final price = (priceRaw as num?)?.toDouble() ?? 0.0;

    final prices = (supermarket != null || priceRaw != null)
        ? [
            ProductPrice(
              storeId: (supermarket?['id'] as String?) ?? '',
              storeName: (supermarket?['name'] as String?) ?? 'Desconocida',
              price: price,
              currency: 'CRC',
              logoUrl: supermarket?['logo_url'] as String?,
              latitude: (supermarket?['latitude'] as num?)?.toDouble(),
              longitude: (supermarket?['longitude'] as num?)?.toDouble(),
            ),
          ]
        : <ProductPrice>[];

    return ProductEntity(
      id: map['id']?.toString() ?? '',
      categoryId: master?['category_id']?.toString() ??
          map['category_id']?.toString() ??
          '',
      subcategory:
          master?['subcategory'] as String? ?? map['subcategory'] as String?,
      name: master?['canonical_name'] as String? ??
          map['name'] as String? ??
          'Producto',
      imageUrls: parseImageUrls(master?['image_url'] ?? map['image_url']),
      prices: prices,
      createdAt: master?['created_at'] as String? ??
          map['created_at'] as String? ??
          '',
      masterProductId: map['master_product_id']?.toString(),
    );
  }

  factory ProductEntity.fromViewMap(Map<String, dynamic> map) {
    final price = (map['price'] as num?)?.toDouble() ?? 0.0;

    final prices = (map['price'] != null)
        ? [
            ProductPrice(
              storeId: map['supermarket_id']?.toString() ?? '',
              storeName: map['supermarket_name'] as String? ?? 'Desconocida',
              price: price,
              currency: 'CRC',
              logoUrl: map['supermarket_logo_url'] as String?,
              latitude: (map['supermarket_latitude'] as num?)?.toDouble(),
              longitude: (map['supermarket_longitude'] as num?)?.toDouble(),
            ),
          ]
        : <ProductPrice>[];

    return ProductEntity(
      id: map['product_id']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      subcategory: map['subcategory'] as String?,
      name: map['canonical_name'] as String? ?? 'Producto',
      imageUrls: parseImageUrls(map['image_url']),
      prices: prices,
      createdAt: map['master_created_at'] as String? ?? '',
      masterProductId: map['master_product_id']?.toString(),
    );
  }
}
