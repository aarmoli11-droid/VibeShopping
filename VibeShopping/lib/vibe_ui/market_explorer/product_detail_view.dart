import 'package:flutter/material.dart';

import '../../vibe_core/vibe_constants.dart';
import '../../models/vibe_store_kind.dart';

/// Datos de producto para detalle y comparativa (UI).
class ProductDetailData {
  const ProductDetailData({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.priceByStore,
  });

  final String id;
  /// Identificador de categoría para filtrado en el explorador (ej. `lacteos`).
  final String categoryId;
  final String name;
  final String description;
  final List<String> imageUrls;
  final Map<VibeStoreKind, String> priceByStore;

  /// Precio mostrado en la grilla (primer valor disponible por orden de cadena).
  String get gridPriceLabel {
    if (priceByStore.isEmpty) return '—';
    for (final k in VibeStoreKind.values) {
      final p = priceByStore[k];
      if (p != null && p.isNotEmpty) return p;
    }
    return priceByStore.values.first;
  }

  /// Cadena asociada al precio mostrado en grilla ([gridPriceLabel]).
  VibeStoreKind? get gridPriceStore {
    if (priceByStore.isEmpty) return null;
    for (final k in VibeStoreKind.values) {
      final p = priceByStore[k];
      if (p != null && p.isNotEmpty) return k;
    }
    return priceByStore.keys.first;
  }

  /// Precio y tienda de referencia en Home según filtro de supermercados.
  GridPriceRef resolveGridPrice({
    required bool allStores,
    required Set<VibeStoreKind> selectedKinds,
  }) {
    final stores = resolveStoresForComparison(allStores, selectedKinds);
    for (final k in stores) {
      final p = priceByStore[k];
      if (p != null && p.isNotEmpty) {
        return GridPriceRef(price: p, store: k);
      }
    }
    if (priceByStore.isEmpty) return const GridPriceRef(price: '—', store: null);
    for (final k in VibeStoreKind.values) {
      final p = priceByStore[k];
      if (p != null && p.isNotEmpty) {
        return GridPriceRef(price: p, store: k);
      }
    }
    return GridPriceRef(price: priceByStore.values.first, store: priceByStore.keys.first);
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
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.product.imageUrls.isNotEmpty
        ? widget.product.imageUrls
        : ['https://picsum.photos/seed/placeholder/800/600'];

    return Scaffold(
      backgroundColor: VibeColors.backgroundMint,
      appBar: AppBar(
        backgroundColor: VibeColors.mint,
        foregroundColor: VibeColors.navy,
        surfaceTintColor: Colors.transparent,
        title: const Text('Detalle del producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: urls.length,
                      onPageChanged: (i) => setState(() => _pageIndex = i),
                      itemBuilder: (context, i) {
                        final imageUrl = urls[i].trim();
                        final isNetwork =
                            imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
                        if (isNetwork) {
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: VibeColors.mint.withValues(alpha: 0.25),
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported_outlined),
                            ),
                          );
                        }
                        return Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: VibeColors.mint.withValues(alpha: 0.25),
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        );
                      },
                    ),
                    if (urls.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            urls.length,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: i == _pageIndex
                                    ? VibeColors.navy
                                    : VibeColors.backgroundWhite.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: VibeColors.navy,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: VibeColors.navy.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Comparativa de precios (referencia)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: VibeColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Según supermercados seleccionados en el explorador.',
              style: TextStyle(
                fontSize: 13,
                color: VibeColors.navy.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            _ComparisonTable(
              stores: widget.comparisonStores,
              priceByStore: widget.product.priceByStore,
            ),
          ],
        ),
      ),
    );
  }
}

String _storeDisplayName(VibeStoreKind s) => switch (s) {
      VibeStoreKind.walmart => 'Walmart',
      VibeStoreKind.maxiPali => 'Maxi Palí',
      VibeStoreKind.bm => 'BM',
      VibeStoreKind.coopeagri => 'Coopeagri',
    };

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({
    required this.stores,
    required this.priceByStore,
  });

  final List<VibeStoreKind> stores;
  final Map<VibeStoreKind, String> priceByStore;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VibeColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA8D5BA), width: 1.35),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
              color: VibeColors.mint.withValues(alpha: 0.55),
            ),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: VibeColors.mint.withValues(alpha: 0.35),
              ),
              children: const [
                _TableCellHeader(text: 'Supermercado'),
                _TableCellHeader(text: 'Precio'),
              ],
            ),
            ...stores.map((s) {
              final price = priceByStore[s] ?? '—';
              return TableRow(
                children: [
                  _TableCellBody(text: _storeDisplayName(s)),
                  _TableCellBody(
                    text: price,
                    emphasize: true,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TableCellHeader extends StatelessWidget {
  const _TableCellHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: VibeColors.navy,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TableCellBody extends StatelessWidget {
  const _TableCellBody({
    required this.text,
    this.emphasize = false,
  });

  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        textAlign: emphasize ? TextAlign.end : TextAlign.start,
        style: TextStyle(
          fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
          fontSize: emphasize ? 15 : 14,
          color: VibeColors.navy,
        ),
      ),
    );
  }
}
