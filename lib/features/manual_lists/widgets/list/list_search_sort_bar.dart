import 'package:flutter/material.dart';
import '../../../../core/vibe_constants.dart';

class ListSearchSortBar extends StatelessWidget {
  final bool showSearch;
  final TextEditingController searchController;
  final bool showFilters;
  final VoidCallback onToggleSearch;
  final VoidCallback onToggleFilters;
  final ValueChanged<String> onSearchChanged;

  const ListSearchSortBar({
    super.key,
    required this.showSearch,
    required this.searchController,
    required this.showFilters,
    required this.onToggleSearch,
    required this.onToggleFilters,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          if (showSearch)
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: searchController,
                  autofocus: true,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar listas...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          if (!showSearch)
            IconButton(
              icon: const Icon(Icons.search_outlined, color: VibeColors.navy),
              onPressed: onToggleSearch,
            ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              showFilters ? Icons.sort_rounded : Icons.sort_outlined,
              color: showFilters ? VibeColors.mint : VibeColors.navy,
            ),
            onPressed: onToggleFilters,
          ),
        ],
      ),
    );
  }
}
