import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';

class ListHeader extends StatelessWidget {
  final int activeCount;
  final int totalCount;

  const ListHeader({
    super.key,
    required this.activeCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 16,
          20,
          20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              VibeColors.backgroundMint,
              VibeColors.backgroundWhite,
            ],
          ),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Mis Listas',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: VibeColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              totalCount == 0
                  ? 'No tienes listas creadas'
                  : 'Mostrando $activeCount de $totalCount listas',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
