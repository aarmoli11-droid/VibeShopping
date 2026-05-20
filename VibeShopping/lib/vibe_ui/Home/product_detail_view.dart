import 'package:flutter/material.dart';

import '../../vibe_models/store_kind.dart';
import '../../vibe_core/vibe_formatter.dart';

/// Datos de producto para detalle y comparativa (UI).
class ProductDetailData {
  const ProductDetailData({
    required this.id,
    required this.categoryId,
    this.subcategory,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.priceByStore,
    this.rawPrice,
    this.supermarketData,
  });

  final String id;
  final String categoryId;
  final String? subcategory;
  final String name;
  final String description;
  final List<String> imageUrls;
  final Map<VibeStoreKind, String> priceByStore;
  final dynamic rawPrice;
  final Map<String, dynamic>? supermarketData;

  factory ProductDetailData.fromMap(Map<String, dynamic> map) {
    final priceRaw = map['price'];
    final int price = (priceRaw is num) ? priceRaw.toInt() : 0;
    
    List<String> images = [];
    final rawImages = map['image_urls'] ?? map['image_url'];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString().trim()).toList();
    } else if (rawImages is String && rawImages.isNotEmpty) {
      images = [rawImages.trim()];
    }

    VibeStoreKind? store;
    final supermarketData = map['supermarkets'];
    if (supermarketData is Map<String, dynamic>) {
      // Usar el ID real si existe
      // final storeId = supermarketData['id']?.toString();
      final name = supermarketData['name']?.toString().toLowerCase() ?? '';
      
      // Mapeo lógico inicial basado en nombre, pero podemos usar el ID si lo tenemos
      if (name.contains('walmart')) {
        store = VibeStoreKind.walmart;
      } else if (name.contains('pali') || name.contains('palí')) {
        store = VibeStoreKind.maxiPali;
      } else if (name.contains('bm')) {
        store = VibeStoreKind.bm;
      } else if (name.contains('coopeagri')) {
        store = VibeStoreKind.coopeagri;
      }
    }

    return ProductDetailData(
      id: map['id']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? map['category']?.toString() ?? 'unknown',
      subcategory: map['subcategory']?.toString(),
      name: map['name']?.toString() ?? 'Producto',
      description: map['description']?.toString() ?? '',
      imageUrls: images,
      priceByStore: store != null ? {store: "$price"} : {},
      rawPrice: price,
      supermarketData: map['supermarkets'] as Map<String, dynamic>?,
    );
  }

  String get gridPriceLabel {
    if (rawPrice != null && (rawPrice as num) > 0) {
      return VibeFormatter.formatPrice(rawPrice);
    }
    return 'Precio no disp.';
  }

  /// Precio y tienda de referencia en Home según filtro de supermercados.
  GridPriceRef resolveGridPrice({
    required bool allStores,
    required Set<VibeStoreKind> selectedKinds,
  }) {
    if (rawPrice == null || (rawPrice as num) <= 0) return const GridPriceRef(price: 'Precio no disp.', store: null);
    
    VibeStoreKind? store;
    if (priceByStore.isNotEmpty) {
      store = priceByStore.keys.first;
    }

    final formattedPrice = VibeFormatter.formatPrice(rawPrice);
    return GridPriceRef(price: formattedPrice, store: store);
  }

  String get displayPrice {
    if (rawPrice != null && (rawPrice as num) > 0) {
      return VibeFormatter.formatPrice(rawPrice);
    }
    return "Precio no disp.";
  }

  /// Cadena asociada al precio mostrado en grilla ([gridPriceLabel]).
  VibeStoreKind? get gridPriceStore {
    // Por ahora, como estamos reconstruyendo, devolvemos null o el primero si tuviéramos lógica de join
    // pero el requerimiento pide select('*, supermarkets(...)') lo que implica que el producto
    // pertenece a un supermercado específico.
    return null; 
  }
}

/// Resultado de [ProductDetailData.resolveGridPrice] para la etiqueta de precio en grilla.
class GridPriceRef {
  const GridPriceRef({required this.price, this.store});

  final String price;
  final VibeStoreKind? store;
}

/// Supermercados a mostrar en la tabla según la selección del explorador.
List<VibeStoreKind> resolveStoresForComparison(
  bool allStores,
  Set<VibeStoreKind> selected,
) {
  if (allStores || selected.isEmpty) {
    return List<VibeStoreKind>.from(VibeStoreKind.values);
  }
  final list = selected.toList()
    ..sort((a, b) => a.index.compareTo(b.index));
  return list;
}

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({
    super.key,
    required this.product,
    required this.comparisonStores,
  });

  final ProductDetailData product;
  final List<VibeStoreKind> comparisonStores;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  @override
  Widget build(BuildContext context) {
    final String? imageUrl = widget.product.imageUrls.isNotEmpty
        ? widget.product.imageUrls.first
        : null;
    
    debugPrint('Debug ImageURL: $imageUrl');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ZONA DE IMAGEN CON ZOOM (30% altura, padding 48)
            if (imageUrl != null && imageUrl.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Image.network(
                      imageUrl,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // ZONA DE INFORMACIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Título
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  // B. Precio
                  const SizedBox(height: 12),
                  Text(
                    widget.product.displayPrice,
                    style: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  
                  // C. Descripción
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  // D. Detalles (simulado aquí)
                  const SizedBox(height: 8),
                  Text(
                    "Cantidad estándar disponible",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
