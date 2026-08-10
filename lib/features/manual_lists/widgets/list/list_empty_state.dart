import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';
import '../list_creation_sheet.dart';
import '../../screens/manual_list_detail_view.dart';

class ListEmptyState extends StatelessWidget {
  const ListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: VibeColors.mint.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.playlist_add_rounded,
                  size: 60, color: VibeColors.navy),
            ),
            const SizedBox(height: 28),
            const Text(
              'No tienes listas todavía',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: VibeColors.navy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Explora productos y crea tu primera\nlista de compras inteligente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
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
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text('Crear primera lista'),
              style: FilledButton.styleFrom(
                backgroundColor: VibeColors.navy,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
