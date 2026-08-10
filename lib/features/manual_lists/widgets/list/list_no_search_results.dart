import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';

class ListNoSearchResults extends StatelessWidget {
  final String query;

  const ListNoSearchResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
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
                child: const Icon(Icons.search_off_rounded,
                    size: 40, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sin resultados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: VibeColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No encontramos listas que coincidan\ncon "$query"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
