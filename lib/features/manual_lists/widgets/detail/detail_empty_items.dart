import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';

class DetailEmptyItems extends StatelessWidget {
  const DetailEmptyItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: VibeColors.mint.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text(
            'Esta lista está vacía',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: VibeColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega productos desde el explorador',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.explore_outlined, size: 20),
            label: const Text('Explorar productos'),
            style: FilledButton.styleFrom(
              backgroundColor: VibeColors.navy,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
