class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final int displayOrder;
  final bool isActive;
  final List<String> dbCategoryIds;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.displayOrder,
    required this.isActive,
    required this.dbCategoryIds,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        iconName: json['icon_name'] as String? ?? 'category',
        displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        dbCategoryIds: _parseDbCategoryIds(json['db_category_ids']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon_name': iconName,
        'display_order': displayOrder,
        'is_active': isActive,
        'db_category_ids': dbCategoryIds,
      };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconName,
    int? displayOrder,
    bool? isActive,
    List<String>? dbCategoryIds,
  }) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        displayOrder: displayOrder ?? this.displayOrder,
        isActive: isActive ?? this.isActive,
        dbCategoryIds: dbCategoryIds ?? this.dbCategoryIds,
      );

  static List<String> _parseDbCategoryIds(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) {
      // PostgreSQL array format: {cat_abarrotes,cat_granos}
      return value
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          id == other.id &&
          name == other.name &&
          iconName == other.iconName &&
          displayOrder == other.displayOrder &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(id, name, iconName, displayOrder, isActive);

  @override
  String toString() =>
      'CategoryModel(id: $id, name: $name, iconName: $iconName, '
      'displayOrder: $displayOrder, isActive: $isActive)';
}
