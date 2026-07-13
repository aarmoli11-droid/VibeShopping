import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/vibe_constants.dart';
import '../domain/store_model.dart';

class VibeSelectionModals {
  static void openLocationPicker(BuildContext context, String currentZone,
      Function(String) onZoneChanged) {
    const zones = ['San Isidro'];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Tu ubicación',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: VibeColors.navy,
                  ),
                ),
              ),
              ...zones.map(
                (zone) => ListTile(
                  title: Text(zone,
                      style: const TextStyle(color: VibeColors.navy)),
                  trailing: zone == currentZone
                      ? const Icon(Icons.check,
                          color: VibeColors.navy, size: 20)
                      : null,
                  onTap: () {
                    onZoneChanged(zone);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  static void openStorePicker(
      BuildContext context,
      bool allStores,
      Set<String> selectedIds,
      List<StoreModel> stores,
      Function(bool, Set<String>) onStoreChanged) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool all = allStores;
        final selected = Set<String>.from(selectedIds);
        return StatefulBuilder(
          builder: (context, setModal) {
            void onTapTodos() {
              setModal(() {
                all = true;
                selected.clear();
              });
            }

            void onTapStore(String storeId) {
              setModal(() {
                if (all) {
                  all = false;
                  selected.add(storeId);
                } else if (selected.contains(storeId)) {
                  selected.remove(storeId);
                  if (selected.isEmpty) all = true;
                } else {
                  selected.add(storeId);
                  if (selected.length == stores.length) {
                    all = true;
                    selected.clear();
                  }
                }
              });
            }

            final counterText = all
                ? null
                : selected.isEmpty
                    ? null
                    : '${selected.length} supermercado${selected.length == 1 ? '' : 's'} seleccionado${selected.length == 1 ? '' : 's'}';

            return DraggableScrollableSheet(
              initialChildSize: 1.0,
              minChildSize: 0.5,
              maxChildSize: 1.0,
              expand: false,
              builder: (_, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Supermercados',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: VibeColors.navy,
                              ),
                            ),
                          ),
                          if (counterText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: VibeColors.mint.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                counterText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: VibeColors.navy,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StoreTile(
                        logoUrl: null,
                        name: 'Todos',
                        selected: all,
                        onTap: onTapTodos,
                      ),
                      const SizedBox(height: 4),
                      ...stores.map((store) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _StoreTile(
                              logoUrl: store.logoUrl,
                              name: store.name,
                              selected: selected.contains(store.id),
                              onTap: () => onTapStore(store.id),
                            ),
                          )),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          onStoreChanged(all, selected);
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({
    required this.logoUrl,
    required this.name,
    required this.selected,
    this.onTap,
  });

  final String? logoUrl;
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? VibeColors.mint.withValues(alpha: 0.22)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: logoUrl != null && logoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: logoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.storefront,
                              size: 24,
                              color: VibeColors.navy),
                        )
                      : const Icon(Icons.storefront,
                          size: 24, color: VibeColors.navy),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: VibeColors.navy,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? VibeColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: selected
                      ? null
                      : Border.all(
                          color: VibeColors.navy.withValues(alpha: 0.4),
                          width: 2),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
