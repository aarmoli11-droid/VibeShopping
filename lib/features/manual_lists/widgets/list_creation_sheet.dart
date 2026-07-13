import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/vibe_constants.dart';
import '../models/manual_list_entity.dart';
import '../providers/manual_list_provider.dart';

class ListCreationSheet extends StatefulWidget {
  const ListCreationSheet({super.key, this.prefillProduct});

  final ManualListItemEntity? prefillProduct;

  static Future<ManualListEntity?> show(
    BuildContext context, {
    ManualListItemEntity? prefillProduct,
  }) {
    return showModalBottomSheet<ManualListEntity>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: VibeColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListCreationSheet(prefillProduct: prefillProduct),
    );
  }

  @override
  State<ListCreationSheet> createState() => _ListCreationSheetState();
}

class _ListCreationSheetState extends State<ListCreationSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedColor = VibeDefaultColors.navy;
  int _selectedIconCodePoint = VibeDefaultIcons.cart;
  bool _creating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        32 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(_selectedColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(_selectedIconCodePoint, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nueva lista',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: VibeColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nombre de la lista',
              hintText: 'Ej: Compra semanal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VibeColors.mint, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              hintText: 'Ej: Productos para la semana',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: VibeColors.mint, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Color',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: VibeColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: VibeDefaultColors.all.map((c) {
              final selected = _selectedColor == c;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Color(c).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Icono',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: VibeColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: VibeDefaultIcons.all.map((cp) {
              final selected = _selectedIconCodePoint == cp;
              return GestureDetector(
                onTap: () => setState(() => _selectedIconCodePoint = cp),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? Color(_selectedColor).withValues(alpha: 0.15)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: selected
                        ? Border.all(color: Color(_selectedColor), width: 2)
                        : null,
                  ),
                  child: Icon(
                    IconData(cp, fontFamily: 'MaterialIcons'),
                    color: selected ? Color(_selectedColor) : Colors.grey[500],
                    size: 22,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _creating ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _creating
                      ? null
                      : () async {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) return;
                          setState(() => _creating = true);
                          final provider = context.read<ManualListProvider>();
                          final list = await provider.createList(
                            name: name,
                            description: _descriptionController.text.trim(),
                            initialItem: widget.prefillProduct,
                            colorValue: _selectedColor,
                            iconCodePoint: _selectedIconCodePoint,
                          );
                          if (context.mounted) {
                            Navigator.pop(context, list);
                          }
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: VibeColors.navy,
                  ),
                  child: _creating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Crear',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
