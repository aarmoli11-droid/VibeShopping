import 'package:flutter/material.dart';

class CategoryIconMapper {
  CategoryIconMapper._();

  static IconData map(String iconName) {
    return _mapping[iconName] ?? Icons.category_outlined;
  }

  static const Map<String, IconData> _mapping = {
    'all': Icons.apps,
    'groceries': Icons.shopping_cart,
    'meat': Icons.restaurant,
    'bakery': Icons.bakery_dining,
    'eco': Icons.eco,
    'frozen': Icons.ac_unit,
    'personal_care': Icons.cleaning_services,
    'inventory': Icons.inventory_2,
    'dairy': Icons.egg_alt,
    'drinks': Icons.local_drink,
    'category': Icons.category_outlined,
  };
}
