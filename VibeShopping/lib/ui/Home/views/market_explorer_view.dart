
import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';
import '../../../models/store_kind.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibeshopping/ui/common_widgets/vibe_product_card.dart';
import 'shopping_list_view.dart';
import '../../assistant/vibe_ai_assistant.dart';
import '../../community/community_view.dart';
import '../widgets/header/vibe_brand_logo.dart';
import '../widgets/header/vibe_search_bar.dart';
import '../widgets/categories/vibe_category_bar.dart';
import '../widgets/vibe_side_drawer.dart';
import '../widgets/modals/vibe_selection_modals.dart';
import './product_detail_view.dart';

class MarketExplorerShell extends StatefulWidget {
  const MarketExplorerShell({super.key});

  @override
  State<MarketExplorerShell> createState() => _MarketExplorerShellState();
}

class _MarketExplorerShellState extends State<MarketExplorerShell> {
  int _navIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      MarketExplorerHomeView(scaffoldKey: _scaffoldKey),
      const VibeCommunityView(),
      const ShoppingListView(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: const VibeSideDrawer(),
      body: pages[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Mis Listas',
          ),
        ],
      ),
    );
  }
}

class MarketExplorerHomeView extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const MarketExplorerHomeView({super.key, this.scaffoldKey});

  @override
  State<MarketExplorerHomeView> createState() => _MarketExplorerHomeViewState();
}

class _MarketExplorerHomeViewState extends State<MarketExplorerHomeView> {
  bool _allStores = true;
  final Set<VibeStoreKind> _selectedKinds = {};
  String? _categoryId;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _locationZone = 'San Isidro';

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      var query = Supabase.instance.client
          .from('products')
          .select('*, supermarkets(*)');
          
      if (_categoryId != null && _categoryId != 'todo') {
        if (_categoryId == 'abarrotes') {
          query = query.inFilter('category_id', ['cat_abarrotes', 'cat_granos']);
        } else if (_categoryId == 'lacteos') {
          query = query.inFilter('category_id', ['cat_lacteos', 'cat_huevos']);
        } else if (_categoryId == 'panaderia') {
          query = query.eq('category_id', 'cat_panaderia');
        } else {
          query = query.eq('category_id', _categoryId!);
        }
      }
      
      if (!_allStores && _selectedKinds.isNotEmpty) {
        
        final Map<String, String> storeIds = {
          'Walmart': '550e8400-e29b-41d4-a716-446655440000',
          'MaxiPalí': '550e8400-e29b-41d4-a716-446655440001',
          'Supermercados BM': '550e8400-e29b-41d4-a716-446655440002',
          'CoopeAgri': '550e8400-e29b-41d4-a716-446655440003',
        };
        
        final List<String> selectedUuids = _selectedKinds
            .map((k) => storeIds[k.displayName] ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
            
        if (selectedUuids.isNotEmpty) {
          if (selectedUuids.length == 1) {
            query = query.eq('supermarket_id', selectedUuids.first);
          } else {
            query = query.inFilter('supermarket_id', selectedUuids);
          }
        }
      }
      
      final data = await query;
      
      setState(() {
        _products = (data as List<dynamic>)
            .map((e) => ProductDetailData.fromMap(e as Map<String, dynamic>))
            .toList();
              _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching products: $e');
    }
  }

  List<ProductDetailData> _products = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<ProductDetailData>> _filterAndGroupProducts() {
    final searchQuery = _searchController.text.toLowerCase();
    final bool isSearching = searchQuery.isNotEmpty;

    Iterable<ProductDetailData> filteredProducts = _products;
    if (isSearching) {
      filteredProducts = filteredProducts.where((p) =>
          p.name.toLowerCase().contains(searchQuery) ||
          (p.subcategory != null && p.subcategory!.toLowerCase().contains(searchQuery)));
    }

    final grouped = <String, List<ProductDetailData>>{};
    for (var p in filteredProducts) {
      final String key = (p.subcategory != null && p.subcategory!.trim().isNotEmpty)
          ? p.subcategory!.trim()
          : 'General';

      grouped.putIfAbsent(key, () => []).add(p);
    }
    return grouped;
  }

  static const _categories = <VibeCategoryOption>[
    VibeCategoryOption(
      id: 'todo',
      label: 'Todo',
      iconAsset: 'assets/assets_icons/bolsa_icon_all.png',
    ),
    VibeCategoryOption(
      id: 'carnes',
      label: 'Carnes',
      iconAsset: 'assets/assets_icons/carne-de-vaca.png',
    ),
    VibeCategoryOption(
      id: 'panaderia',
      label: 'Panadería',
      iconAsset: 'assets/assets_icons/panaderia.png',
    ),
    VibeCategoryOption(
      id: 'frutas',
      label: 'Frutas',
      iconAsset: 'assets/assets_icons/fruta.png',
    ),
    VibeCategoryOption(
      id: 'higiene',
      label: 'Higiene',
      iconAsset: 'assets/assets_icons/cepillado_higiene.png',
    ),
    VibeCategoryOption(
      id: 'abarrotes',
      label: 'Abarrotes',
      iconAsset: 'assets/assets_icons/aperitivos_snacks.png',
    ),
    VibeCategoryOption(
      id: 'lacteos',
      label: 'Lácteos',
      iconAsset: 'assets/assets_icons/lacteos.png',
    ),
    VibeCategoryOption(
      id: 'bebidas',
      label: 'Bebidas',
      iconAsset: 'assets/assets_icons/bebidas.png',
    ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: VibeColors.navy),
              onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VibeBrandLogo(),
                GestureDetector(
                  onTap: () => VibeSelectionModals.openLocationPicker(
                    context, 
                    _locationZone, 
                    (z) => setState(() => _locationZone = z),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _locationZone,
                        style: const TextStyle(
                          color: VibeColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: VibeColors.navy),
                    ],
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: VibeSearchBar(
                  controller: _searchController,
                  searchHintSize: 14,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Material(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => VibeSelectionModals.openStorePicker(
                    context, 
                    _allStores, 
                    _selectedKinds, 
                    (all, selected) => setState(() {
                      _allStores = all;
                      _selectedKinds..clear()..addAll(selected);
                      _fetchProducts();
                    }),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 20, color: VibeColors.navy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectorLabel(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: VibeColors.navy,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: VibeColors.navy),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: VibeCategoryBar(
              categories: _categories,
              selectedCategoryId: _categoryId ?? 'todo',
              onCategorySelected: (id) {
                setState(() => _categoryId = id);
                _fetchProducts();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Builder(builder: (context) {
                    final finalGrouped = _filterAndGroupProducts();
                    if (finalGrouped.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded, size: 80, color: VibeColors.navy.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              const Text(
                                'No encontramos productos en esta categoría',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: VibeColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: finalGrouped.length,
                      itemBuilder: (context, index) {
                        final sectionTitle = finalGrouped.keys.elementAt(index);
                        final productsInSection = finalGrouped[sectionTitle]!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                              child: Text(
                                sectionTitle,
                                style: const TextStyle(
                                  fontSize: 20, 
                                  fontWeight: FontWeight.w800, 
                                  color: VibeColors.navy,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 240,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: productsInSection.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, i) {
                                  final product = productsInSection[i];
                                  return SizedBox(
                                    width: 170.0,
                                    child: VibeProductCard(
                                      data: product,
                                      allStores: _allStores,
                                      selectedKinds: _selectedKinds,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailView(
                                              product: product,
                                              comparisonStores: VibeStoreKind.values,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
          ),
        ],
      ),
      floatingActionButton: VibeAiAssistant.buildFloatingButton(context),
    );
  }
}
