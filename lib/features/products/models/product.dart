import '../../../core/parse_image_urls.dart';

// Precio de un producto en una tienda concreta.
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

// Producto del catálogo con sus precios por tienda.
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

  // Precio del primer elemento (referencia rápida para tarjetas).
  double get referencePrice => prices.isNotEmpty ? prices.first.price : 0.0;

  // Construye el producto desde una fila de v_products_complete.
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
