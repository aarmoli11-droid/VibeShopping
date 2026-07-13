import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/vibe_constants.dart';
import '../../products/widgets/vibe_product_card.dart';
import '../../products/screens/product_detail_view.dart';
import '../../assistant/screens/vibe_ai_assistant.dart';
import '../providers/explorer_provider.dart';
import '../widgets/vibe_brand_logo.dart';
import '../widgets/vibe_search_bar.dart';
import '../widgets/vibe_category_bar.dart';
import '../widgets/vibe_selection_modals.dart';
import '../widgets/store_filter_selector.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/empty_product_state.dart';

class MarketExplorerView extends StatefulWidget {
  const MarketExplorerView({super.key});

  @override
  State<MarketExplorerView> createState() => _MarketExplorerViewState();
}

class _MarketExplorerViewState extends State<MarketExplorerView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _locationZone = 'San Isidro';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ExplorerProvider>().initialize();
      _precacheStoreLogos();
    });
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<ExplorerProvider>().setSearchQuery(_searchController.text);
    });
  }

  void _precacheStoreLogos() {
    final stores = context.read<ExplorerProvider>().stores;
    for (final store in stores) {
      if (store.logoUrl != null && store.logoUrl!.isNotEmpty) {
        unawaited(precacheImage(
          CachedNetworkImageProvider(store.logoUrl!),
          context,
          onError: (_, __) {},
        ));
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExplorerProvider>();
    final isLoading = provider.productsLoading;

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
            leading: const SizedBox.shrink(),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VibeBrandLogo(),
                GestureDetector(
                  onTap: () => VibeSelectionModals.openLocationPicker(
                    context,
                    _locationZone,
                    (zone) => setState(() => _locationZone = zone),
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
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16, color: VibeColors.navy),
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
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: StoreFilterSelector(
                label: provider.storeFilterLabel,
                selectedStoreIds: provider.selectedStoreIds,
                stores: provider.stores,
                onTap: () => VibeSelectionModals.openStorePicker(
                  context,
                  provider.allStores,
                  provider.selectedStoreIds,
                  provider.stores,
                  (all, selected) => provider.setStoreFilter(all, selected),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: VibeCategoryBar(
              categories: provider.categories,
              selectedCategoryId: provider.categoryId,
              onCategorySelected: (id) => provider.setCategory(id),
            ),
          ),
          SliverToBoxAdapter(
            child: isLoading
                ? const LoadingIndicator()
                : _buildProductContent(provider),
          ),
        ],
      ),
      floatingActionButton: VibeAiAssistant.buildFloatingButton(context),
    );
  }

  Widget _buildProductContent(ExplorerProvider provider) {
    final grouped = provider.groupedProducts;

    if (grouped.isEmpty) {
      if (!provider.allStores && provider.selectedStoreIds.isNotEmpty) {
        final label = provider.selectedStoreIds.length == 1
            ? provider.storeNameById(provider.selectedStoreIds.first)
            : provider.selectedStoreIds
                .map((id) => provider.storeNameById(id))
                .join(' o ');
        return EmptyProductState(storeName: label);
      }
      return const EmptyProductState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final sectionTitle = grouped.keys.elementAt(index);
        final productsInSection = grouped[sectionTitle]!;

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
                itemBuilder: (context, productIndex) {
                  final product = productsInSection[productIndex];
                  return SizedBox(
                    width: 170.0,
                    child: VibeProductCard(
                      data: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailView(
                              product: product,
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
  }
}
