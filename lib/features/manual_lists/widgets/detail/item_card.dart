import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/vibe_constants.dart';
import '../../../../core/vibe_formatter.dart';
import '../../../products/providers/product_provider.dart';
import '../../models/manual_list_entity.dart';
import '../../providers/manual_list_provider.dart';

class ItemCard extends StatelessWidget {
  final ManualListItemEntity item;
  final ManualListEntity list;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.list,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    final product = productProvider.products
        .where((p) => p.id == item.productId)
        .firstOrNull;
    final displayName = product?.name ?? 'Producto';
    final imageUrl = (product?.imageUrls.isNotEmpty == true)
        ? product!.imageUrls.first
        : null;
    final storeLogoUrl = product?.prices
        .where((p) => p.storeId == item.storeId)
        .firstOrNull
        ?.logoUrl;

    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Eliminar producto'),
            content: Text('¿Eliminar "$displayName" de la lista?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuad,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 15 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[100],
                            child: const Icon(Icons.image_outlined,
                                color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey[100],
                          child: const Icon(Icons.image_outlined,
                              color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: VibeColors.navy,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (item.storeNameSnapshot.isNotEmpty)
                        Row(
                          children: [
                            if (storeLogoUrl != null && storeLogoUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: CachedNetworkImage(
                                    imageUrl: storeLogoUrl,
                                    width: 14,
                                    height: 14,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(
                                        Icons.storefront,
                                        size: 14,
                                        color: VibeColors.navy),
                                  ),
                                ),
                              ),
                            Flexible(
                              child: Text(
                                item.storeNameSnapshot,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            VibeFormatter.formatPrice(item.unitPriceSnapshot),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Subtotal: ${VibeFormatter.formatPrice(item.subtotal)}',
                            style: const TextStyle(
                              color: VibeColors.navy,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            onTap: () {
                              final provider =
                                  context.read<ManualListProvider>();
                              provider.updateItemQuantity(
                                list.id,
                                item.productId,
                                item.quantity + 1,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.add,
                                  size: 16, color: VibeColors.navy),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10)),
                            onTap: item.quantity > 1
                                ? () {
                                    final provider =
                                        context.read<ManualListProvider>();
                                    provider.updateItemQuantity(
                                      list.id,
                                      item.productId,
                                      item.quantity - 1,
                                    );
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(Icons.remove,
                                  size: 16,
                                  color: item.quantity > 1
                                      ? VibeColors.navy
                                      : Colors.grey[300]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline,
                            size: 18, color: Colors.red[300]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
