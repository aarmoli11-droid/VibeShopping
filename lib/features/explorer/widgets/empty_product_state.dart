import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';

class EmptyProductState extends StatelessWidget {
  const EmptyProductState({this.storeName});

  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final message = storeName != null
        ? 'No hay productos disponibles para $storeName'
        : 'No encontramos productos en esta categoría';

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 80, color: VibeColors.navy.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VibeColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
