import 'package:flutter/material.dart';
import '../../vibe_core/vibe_constants.dart';
import 'models/community_models.dart';

class FullscreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

class CommunityBubble extends StatelessWidget {
  const CommunityBubble({super.key, required this.message, this.onDelete});

  final CommunityMessage message;
  final Function(String)? onDelete;

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar mensaje'),
        content: const Text('¿Estás seguro de que deseas eliminar este mensaje para todos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              onDelete?.call(message.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openImage(BuildContext context) {
    if (message.imageUrl == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullscreenImageView(imageUrl: message.imageUrl!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = message.mine ? const Color(0xFF2C4361) : const Color(0xFFF8FAFB);
    final textColor = message.mine ? Colors.white : const Color(0xFF2F3C4C);
    final cross = message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final align = message.mine ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(message.mine ? 16 : 4),
      bottomRight: Radius.circular(message.mine ? 4 : 16),
    );

    Widget bubbleContent = Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: cross,
        children: [
          if (message.author.isNotEmpty && !message.mine)
            Text(
              message.author,
              style: TextStyle(
                color: const Color(0xFF5F6E7D).withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          if (message.author.isNotEmpty && !message.mine) const SizedBox(height: 4),
          if (message.text.isNotEmpty)
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 15,
                height: 1.28,
              ),
            ),
          if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
            if (message.text.isNotEmpty) const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openImage(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: VibeColors.mint.withValues(alpha: 0.18),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: VibeColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.timestampLabel,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.56),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (message.mine) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all_rounded,
                  size: 15,
                  color: textColor.withValues(alpha: 0.76),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: align,
        child: GestureDetector(
          onLongPress: message.mine ? () => _showDeleteDialog(context) : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 285),
            child: Container(
              decoration: BoxDecoration(color: bgColor, borderRadius: radius),
              child: bubbleContent,
            ),
          ),
        ),
      ),
    );
  }
}

class CommunityReferenceBubble extends StatelessWidget {
  const CommunityReferenceBubble({super.key, required this.item});

  final CommunityFeedItem item;

  @override
  Widget build(BuildContext context) {
    if (item.type == ReferenceBubbleType.productCard) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: VibeColors.mint.withValues(alpha: 0.65)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    item.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: VibeColors.mint.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item.actionLabel ?? 'Purchase',
                    style: const TextStyle(
                      color: Color(0xFF2F4B5B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return CommunityBubble(
      message: CommunityMessage(
        id: '',
        author: '',
        text: item.text ?? '',
        mine: item.mine,
        imageUrl: null,
        createdAt: DateTime.now(),
        timestampOverride: item.timestamp ?? '',
      ),
    );
  }
}
