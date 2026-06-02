import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';
import '../../../../models/store_kind.dart';

class VibeSelectionModals {
  static void openLocationPicker(BuildContext context, String currentZone, Function(String) onZoneChanged) {
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
                (z) => ListTile(
                  title: Text(z, style: const TextStyle(color: VibeColors.navy)),
                  trailing: z == currentZone
                      ? const Icon(Icons.check, color: VibeColors.navy, size: 20)
                      : null,
                  onTap: () {
                    onZoneChanged(z);
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

  static void openStorePicker(BuildContext context, bool allStores, Set<VibeStoreKind> selectedKinds, Function(bool, Set<VibeStoreKind>) onStoreChanged) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool all = allStores;
        final selected = Set<VibeStoreKind>.from(selectedKinds);

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
                    activeColor: VibeColors.mint,
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
                      activeColor: VibeColors.mint,
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
            );
          },
        );
      },
    );
  }
}