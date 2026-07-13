import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manual_list_provider.dart';
import '../models/manual_list_entity.dart';
import '../widgets/detail/detail_header.dart';
import '../widgets/detail/item_card.dart';
import '../widgets/detail/coming_soon_banner.dart';
import '../widgets/detail/detail_empty_items.dart';
import '../widgets/common/confirm_action_dialog.dart';
import '../widgets/common/edit_text_dialog.dart';

class ManualListDetailView extends StatefulWidget {
  const ManualListDetailView({super.key, required this.listId});

  final String listId;

  @override
  State<ManualListDetailView> createState() => _ManualListDetailViewState();
}

class _ManualListDetailViewState extends State<ManualListDetailView> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManualListProvider>();
    final list = provider.getListById(widget.listId);

    if (list == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lista no encontrada')),
        body: const Center(child: Text('La lista no existe')),
      );
    }

    final items = list.items;
    final avgPrice = items.isEmpty
        ? 0.0
        : items.fold(0.0, (s, i) => s + i.unitPriceSnapshot) / items.length;
    final storeCount = items.map((i) => i.storeNameSnapshot).toSet().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(list.colorValue).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                IconData(list.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Color(list.colorValue),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                list.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2C3E50)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              switch (value) {
                case 'edit_name':
                  _showEditNameDialog(context, list);
                case 'edit_desc':
                  _showEditDescriptionDialog(context, list);
                case 'clear':
                  _showClearConfirmation(context, list);
                case 'delete':
                  _showDeleteListDialog(context, list);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit_name',
                child: Text('Editar nombre'),
              ),
              const PopupMenuItem(
                value: 'edit_desc',
                child: Text('Editar descripción'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.remove_shopping_cart_outlined, size: 20),
                  title: Text('Vaciar lista', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child:
                    Text('Eliminar lista', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                DetailHeader(
                    list: list, avgPrice: avgPrice, storeCount: storeCount),
                if (items.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: const ComingSoonBanner(),
                    ),
                  ),
                if (items.isEmpty)
                  SliverFillRemaining(child: const DetailEmptyItems())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ItemCard(
                          key: ValueKey(items[index].productId),
                          item: items[index],
                          list: list,
                          onDelete: () {
                            showConfirmActionDialog(
                              context,
                              title: 'Eliminar producto',
                              message: '¿Eliminar este producto de la lista?',
                              confirmLabel: 'Eliminar',
                              onConfirm: () {
                                context
                                    .read<ManualListProvider>()
                                    .removeItemFromList(
                                        list.id, items[index].productId);
                              },
                            );
                          },
                        ),
                        childCount: items.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, ManualListEntity list) async {
    final name = await showEditTextDialog(
      context,
      title: 'Editar nombre',
      label: 'Nombre',
      initialValue: list.name,
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      context.read<ManualListProvider>().updateListName(list.id, name);
    }
  }

  void _showEditDescriptionDialog(
      BuildContext context, ManualListEntity list) async {
    final desc = await showEditTextDialog(
      context,
      title: 'Editar descripción',
      label: 'Descripción',
      initialValue: list.description ?? '',
      maxLines: 2,
    );
    if (desc != null && context.mounted) {
      context.read<ManualListProvider>().updateListDescription(list.id, desc);
    }
  }

  void _showClearConfirmation(BuildContext context, ManualListEntity list) {
    showConfirmActionDialog(
      context,
      title: 'Vaciar lista',
      message: '¿Eliminar todos los productos de la lista?',
      confirmLabel: 'Vaciar',
      onConfirm: () {
        context.read<ManualListProvider>().clearList(list.id);
      },
    );
  }

  void _showDeleteListDialog(BuildContext context, ManualListEntity list) {
    showConfirmActionDialog(
      context,
      title: 'Eliminar lista',
      message: '¿Estás seguro de eliminar "${list.name}"?',
      confirmLabel: 'Eliminar',
      onConfirm: () {
        context.read<ManualListProvider>().deleteList(list.id);
        Navigator.pop(context);
      },
    );
  }
}
