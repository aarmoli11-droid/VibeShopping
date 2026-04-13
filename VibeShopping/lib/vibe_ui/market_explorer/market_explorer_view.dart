import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vibe_core/vibe_constants.dart';
import '../../vibe_datasource/models/vibe_store_kind.dart';
import '../../vibe_datasource/services/gemini_shopping_assistant_service.dart';
import 'product_detail_view.dart';

/// Contenedor principal con Home, Chat y Perfil + FAB asistente.
class MarketExplorerShell extends StatefulWidget {
  const MarketExplorerShell({super.key});

  @override
  State<MarketExplorerShell> createState() => _MarketExplorerShellState();
}

class _MarketExplorerShellState extends State<MarketExplorerShell> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const MarketExplorerHomeView(),
      const _MarketChatPlaceholder(),
      const _MarketProfilePlaceholder(),
    ];

    return Scaffold(
      body: pages[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAssistant(context),
        backgroundColor: VibeColors.mint,
        foregroundColor: VibeColors.navy,
        child: const Icon(Icons.auto_awesome),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> openAssistant(BuildContext context) async {
    final service = context.read<GeminiShoppingAssistantService>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asistente de Compras',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: VibeColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gemini está listo para ayudarte a comparar precios y planificar tu canasta (sin compras en la app).',
                style: TextStyle(
                  color: VibeColors.navy.withValues(alpha: 0.75),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  if (!context.mounted) return;
                  try {
                    await service.askShoppingQuestion('Hola');
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Asistente de Compras: conexión respondió correctamente.'),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se pudo contactar al asistente en este momento.'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.bolt, size: 20),
                label: const Text('Probar conexión'),
                style: FilledButton.styleFrom(
                  backgroundColor: VibeColors.navy,
                  foregroundColor: VibeColors.backgroundWhite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MarketChatPlaceholder extends StatelessWidget {
  const _MarketChatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(
        child: Text(
          'Foro / chat comunitario — próximamente',
          style: TextStyle(color: VibeColors.navy.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _MarketProfilePlaceholder extends StatelessWidget {
  const _MarketProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Text(
          'Tu perfil — próximamente',
          style: TextStyle(color: VibeColors.navy.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

/// Home: selector de cadenas, banner, categorías y grilla sin botón de compra.
class MarketExplorerHomeView extends StatefulWidget {
  const MarketExplorerHomeView({super.key});

  @override
  State<MarketExplorerHomeView> createState() => _MarketExplorerHomeViewState();
}

class _MarketExplorerHomeViewState extends State<MarketExplorerHomeView> {
  /// `true` = comparar todas las cadenas; si no, usa [_selectedKinds].
  bool _allStores = true;
  final Set<VibeStoreKind> _selectedKinds = {};
  String _categoryId = 'abarrotes';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _categories = <_CategoryOption>[
    _CategoryOption(id: 'abarrotes', label: 'Abarrotes'),
    _CategoryOption(id: 'snacks', label: 'Snacks'),
    _CategoryOption(id: 'lacteos', label: 'Lácteos'),
    _CategoryOption(id: 'bebidas', label: 'Bebidas'),
    _CategoryOption(id: 'limpieza', label: 'Limpieza'),
  ];

  String _selectorLabel() {
    if (_allStores || _selectedKinds.isEmpty) {
      return 'Todos los supermercados';
    }
    if (_selectedKinds.length == 1) {
      return _selectedKinds.first.displayName;
    }
    return _selectedKinds.map((e) => e.shortName).join(', ');
  }

  void _openStorePicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var all = _allStores;
        final selected = Set<VibeStoreKind>.from(_selectedKinds);

        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Supermercados',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: VibeColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: all,
                    activeColor: VibeColors.navy,
                    title: const Text('Todos (comparar)'),
                    onChanged: (v) {
                      setModal(() {
                        all = v ?? false;
                        if (all) selected.clear();
                      });
                    },
                  ),
                  ...VibeStoreKind.values.map((k) {
                    return CheckboxListTile(
                      value: selected.contains(k),
                      activeColor: VibeColors.navy,
                      title: Text(k.displayName),
                      onChanged: all
                          ? null
                          : (v) {
                              setModal(() {
                                if (v ?? false) {
                                  selected.add(k);
                                } else {
                                  selected.remove(k);
                                }
                              });
                            },
                    );
                  }),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _allStores = all;
                        _selectedKinds
                          ..clear()
                          ..addAll(selected);
                      });
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: VibeColors.navy,
                      foregroundColor: VibeColors.backgroundWhite,
                    ),
                    child: const Text('Listo'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibeColors.backgroundMint,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: VibeColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _openStorePicker,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.store_mall_directory_outlined,
                            color: VibeColors.navy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Buscar productos...',
                          hintStyle: TextStyle(
                            color: VibeColors.navy.withValues(alpha: 0.45),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: VibeColors.navy,
                            size: 22,
                          ),
                          filled: true,
                          fillColor: VibeColors.backgroundWhite,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFA8D5BA),
                              width: 1.35,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFA8D5BA),
                              width: 1.75,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFA8D5BA),
                              width: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: VibeColors.mint,
                        foregroundColor: VibeColors.navy,
                        minimumSize: const Size(48, 48),
                        maximumSize: const Size(48, 48),
                      ),
                      onPressed: () {
                        final shell =
                            context.findAncestorStateOfType<_MarketExplorerShellState>();
                        shell?.openAssistant(context);
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      tooltip: 'Asistente de Compras',
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _selectorLabel(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: VibeColors.navy.withValues(alpha: 0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                child: Row(
                  children: [
                    const Text(
                      'Categorías',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: VibeColors.navy,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _categoryId,
                      underline: const SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(12),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _categoryId = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: _categories.map((c) {
                    final selected = c.id == _categoryId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(c.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _categoryId = c.id),
                        selectedColor: const Color(0xFFA8D5BA).withValues(alpha: 0.42),
                        checkmarkColor: VibeColors.navy,
                        labelStyle: TextStyle(
                          color: VibeColors.navy,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        side: const BorderSide(color: Color(0xFFA8D5BA), width: 1.25),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = _demoProducts[index % _demoProducts.length];
                    return _ProductCard(
                      data: p,
                      onTap: () {
                        final stores = resolveStoresForComparison(
                          _allStores,
                          _selectedKinds,
                        );
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => ProductDetailView(
                              product: p,
                              comparisonStores: stores,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final headline = _allStores || _selectedKinds.isEmpty
        ? 'Comparativa de precios — referencia informativa'
        : _selectedKinds.length == 1
            ? 'Ofertas y referencias — ${_selectedKinds.first.displayName}'
            : 'Comparando: ${_selectedKinds.map((e) => e.shortName).join(' · ')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 160,
          color: VibeColors.backgroundWhite,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      VibeColors.mint.withValues(alpha: 0.35),
                      VibeColors.backgroundWhite,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _bannerLogo(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            headline,
                            style: const TextStyle(
                              color: VibeColors.navy,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Espacio publicitario / campaña del comercio seleccionado.',
                            style: TextStyle(
                              color: VibeColors.navy.withValues(alpha: 0.65),
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerLogo() {
    if (_allStores || _selectedKinds.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/logo_vibe.png',
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackLogo('VS'),
        ),
      );
    }
    final first = _selectedKinds.first;
    return _StoreAvatar(kind: first);
  }
}

class _StoreAvatar extends StatelessWidget {
  const _StoreAvatar({required this.kind});

  final VibeStoreKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: kind.accentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VibeColors.mint, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        kind.shortName,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: VibeColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption({required this.id, required this.label});
  final String id;
  final String label;
}

final _demoProducts = <ProductDetailData>[
  ProductDetailData(
    id: 'arroz-2kg',
    name: 'Arroz 2 kg',
    description:
        'Arroz blanco de grano largo en presentación familiar de 2 kg. '
        'Información orientativa para comparar precios entre cadenas; la app no realiza pedidos.',
    imageUrls: const [
      'https://picsum.photos/seed/rice1/800/600',
      'https://picsum.photos/seed/rice2/800/600',
    ],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 1 890',
      VibeStoreKind.maxiPali: '₡ 1 950',
      VibeStoreKind.bm: '₡ 1 820',
      VibeStoreKind.coopeagri: '₡ 1 890',
    },
  ),
  ProductDetailData(
    id: 'frijoles',
    name: 'Frijoles rojos',
    description:
        'Frijoles rojos secos, bolsa estándar. Ideal para sopas y casados. Precios referenciales por tienda.',
    imageUrls: const [
      'https://picsum.photos/seed/beans1/800/600',
      'https://picsum.photos/seed/beans2/800/600',
    ],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 980',
      VibeStoreKind.maxiPali: '₡ 1 050',
      VibeStoreKind.bm: '₡ 940',
      VibeStoreKind.coopeagri: '₡ 990',
    },
  ),
  ProductDetailData(
    id: 'aceite',
    name: 'Aceite 900 ml',
    description:
        'Aceite vegetal para cocina en botella de 900 ml. Comparativa informativa entre supermercados.',
    imageUrls: const [
      'https://picsum.photos/seed/oil1/800/600',
    ],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 2 150',
      VibeStoreKind.maxiPali: '₡ 2 090',
      VibeStoreKind.bm: '₡ 2 200',
      VibeStoreKind.coopeagri: '₡ 2 120',
    },
  ),
  ProductDetailData(
    id: 'azucar',
    name: 'Azúcar 1 kg',
    description:
        'Azúcar refinada blanca 1 kg. Revisa la tabla para ver diferencias entre cadenas.',
    imageUrls: const [
      'https://picsum.photos/seed/sugar1/800/600',
      'https://picsum.photos/seed/sugar2/800/600',
    ],
    priceByStore: {
      VibeStoreKind.walmart: '₡ 720',
      VibeStoreKind.maxiPali: '₡ 750',
      VibeStoreKind.bm: '₡ 690',
      VibeStoreKind.coopeagri: '₡ 710',
    },
  ),
];

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.data, required this.onTap});

  final ProductDetailData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = data.imageUrls.isNotEmpty
        ? data.imageUrls.first
        : 'https://picsum.photos/seed/p/400/400';

    return Material(
      color: VibeColors.backgroundWhite,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    thumb,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFA8D5BA).withValues(alpha: 0.28),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: VibeColors.navy,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.gridPriceLabel,
                style: const TextStyle(
                  color: VibeColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _fallbackLogo(String text) {
  return Container(
    width: 72,
    height: 72,
    color: VibeColors.mint.withValues(alpha: 0.35),
    alignment: Alignment.center,
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: VibeColors.navy,
      ),
    ),
  );
}

extension on VibeStoreKind {
  String get displayName => switch (this) {
        VibeStoreKind.walmart => 'Walmart',
        VibeStoreKind.maxiPali => 'Maxi Palí',
        VibeStoreKind.bm => 'BM',
        VibeStoreKind.coopeagri => 'Coopeagri',
      };

  String get shortName => switch (this) {
        VibeStoreKind.walmart => 'Walmart',
        VibeStoreKind.maxiPali => 'Maxi Palí',
        VibeStoreKind.bm => 'BM',
        VibeStoreKind.coopeagri => 'Coopeagri',
      };

  Color get accentColor => switch (this) {
        VibeStoreKind.walmart => const Color(0xFF0071CE),
        VibeStoreKind.maxiPali => const Color(0xFFE31837),
        VibeStoreKind.bm => const Color(0xFF00A651),
        VibeStoreKind.coopeagri => const Color(0xFF6B4F2D),
      };
}
