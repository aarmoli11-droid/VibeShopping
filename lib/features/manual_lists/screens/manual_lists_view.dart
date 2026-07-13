import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manual_list_provider.dart';
import '../models/manual_list_entity.dart';
import '../widgets/list_creation_sheet.dart';
import '../widgets/list/list_header.dart';
import '../widgets/list/list_search_sort_bar.dart';
import '../widgets/list/list_filter_chips.dart';
import '../widgets/list/list_card.dart';
import '../widgets/list/list_no_search_results.dart';
import '../widgets/list/list_empty_state.dart';
import '../widgets/common/confirm_action_dialog.dart';
import '../widgets/common/edit_text_dialog.dart';
import 'manual_list_detail_view.dart';

class ManualListsView extends StatefulWidget {
  const ManualListsView({super.key});

  @override
  State<ManualListsView> createState() => _ManualListsViewState();
}

class _ManualListsViewState extends State<ManualListsView> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ManualListProvider>();
      if (!provider.loaded) provider.load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _duplicateList(String listId) async {
    final provider = context.read<ManualListProvider>();
    await provider.duplicateList(listId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lista duplicada correctamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF2C3E50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManualListProvider>();
    final filtered = provider.filteredLists;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: !provider.loaded
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty && provider.searchQuery.isEmpty
              ? const ListEmptyState()
              : CustomScrollView(
                  slivers: [
                    ListHeader(
                      activeCount: filtered.length,
                      totalCount: provider.lists
                          .where((l) => l.status == ManualListStatus.active)
                          .length,
                    ),
                    SliverToBoxAdapter(
                      child: ListSearchSortBar(
                        showSearch: _showSearch,
                        searchController: _searchController,
                        showFilters: _showFilters,
                        onToggleSearch: () {
                          setState(() {
                            _showSearch = !_showSearch;
                            if (!_showSearch) {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            }
                          });
                        },
                        onToggleFilters: () =>
                            setState(() => _showFilters = !_showFilters),
                        onSearchChanged: (q) => provider.setSearchQuery(q),
                      ),
                    ),
                    if (_showSearch && _showFilters)
                      SliverToBoxAdapter(
                        child: ListFilterChips(
                          currentFilter: provider.filterMode,
                          currentSort: provider.sortMode,
                          sortAscending: provider.sortAscending,
                          onFilterChanged: (f) => provider.setFilterMode(f),
                          onSortChanged: (s, a) =>
                              provider.setSortMode(s, ascending: a),
                        ),
                      ),
                    if (_showFilters && !_showSearch)
                      SliverToBoxAdapter(
                        child: ListFilterChips(
                          currentFilter: provider.filterMode,
                          currentSort: provider.sortMode,
                          sortAscending: provider.sortAscending,
                          onFilterChanged: (f) => provider.setFilterMode(f),
                          onSortChanged: (s, a) =>
                              provider.setSortMode(s, ascending: a),
                        ),
                      ),
                    if (filtered.isEmpty && provider.searchQuery.isNotEmpty)
                      ListNoSearchResults(query: provider.searchQuery)
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => ListCard(
                              key: ValueKey(filtered[index].id),
                              list: filtered[index],
                              onOpen: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ManualListDetailView(
                                        listId: filtered[index].id),
                                  ),
                                );
                              },
                              onEditName: () async {
                                final name = await showEditTextDialog(
                                  context,
                                  title: 'Editar nombre',
                                  label: 'Nombre',
                                  initialValue: filtered[index].name,
                                );
                                if (name != null &&
                                    name.isNotEmpty &&
                                    context.mounted) {
                                  context
                                      .read<ManualListProvider>()
                                      .updateListName(filtered[index].id, name);
                                }
                              },
                              onEditDescription: () async {
                                final desc = await showEditTextDialog(
                                  context,
                                  title: 'Editar descripción',
                                  label: 'Descripción',
                                  initialValue:
                                      filtered[index].description ?? '',
                                  maxLines: 2,
                                );
                                if (desc != null && context.mounted) {
                                  context
                                      .read<ManualListProvider>()
                                      .updateListDescription(
                                          filtered[index].id, desc);
                                }
                              },
                              onDuplicate: () =>
                                  _duplicateList(filtered[index].id),
                              onDelete: () {
                                showConfirmActionDialog(
                                  context,
                                  title: 'Eliminar lista',
                                  message:
                                      '¿Estás seguro de eliminar "${filtered[index].name}"?\nEsta acción no se puede deshacer.',
                                  confirmLabel: 'Eliminar',
                                  onConfirm: () {
                                    context
                                        .read<ManualListProvider>()
                                        .deleteList(filtered[index].id);
                                  },
                                );
                              },
                            ),
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final list = await ListCreationSheet.show(context);
          if (list != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManualListDetailView(listId: list.id),
              ),
            );
          }
        },
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Lista'),
      ),
    );
  }
}
