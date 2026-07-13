import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';
import '../../../../core/vibe_formatter.dart';
import '../../models/manual_list_entity.dart';
import '../common/stat_chip.dart';

class ListCard extends StatelessWidget {
  final ManualListEntity list;
  final VoidCallback onOpen;
  final VoidCallback onEditName;
  final VoidCallback onEditDescription;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const ListCard({
    super.key,
    required this.list,
    required this.onOpen,
    required this.onEditName,
    required this.onEditDescription,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysAgo = DateTime.now().difference(list.updatedAt).inDays;
    final dateStr = daysAgo == 0
        ? 'Hoy'
        : daysAgo == 1
            ? 'Ayer'
            : '${list.updatedAt.day}/${list.updatedAt.month}/${list.updatedAt.year}';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Color(list.colorValue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      IconData(list.iconCodePoint, fontFamily: 'MaterialIcons'),
                      color: Color(list.colorValue),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                list.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: VibeColors.navy,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (list.totalItems > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(list.colorValue)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${list.totalItems}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(list.colorValue),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (list.description != null &&
                            list.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              list.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            StatChip(
                              icon: Icons.inventory_2_outlined,
                              label: '${list.totalItems}',
                            ),
                            const SizedBox(width: 8),
                            StatChip(
                              icon: Icons.category_outlined,
                              label: '${list.totalQuantity} uds.',
                            ),
                            const SizedBox(width: 8),
                            StatChip(
                              icon: Icons.attach_money,
                              label: VibeFormatter.formatPrice(list.totalPrice),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 11, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              'Modificado: $dateStr',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: Colors.grey, size: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (value) {
                      switch (value) {
                        case 'open':
                          onOpen();
                        case 'edit_name':
                          onEditName();
                        case 'edit_desc':
                          onEditDescription();
                        case 'duplicate':
                          onDuplicate();
                        case 'delete':
                          onDelete();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'open',
                        child: ListTile(
                          leading: Icon(Icons.open_in_new),
                          title: Text('Abrir lista'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'edit_name',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar nombre'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit_desc',
                        child: ListTile(
                          leading: Icon(Icons.description_outlined),
                          title: Text('Editar descripción'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: ListTile(
                          leading: Icon(Icons.copy_outlined),
                          title: Text('Duplicar lista'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading:
                              Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Eliminar lista',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
