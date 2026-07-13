import 'shopping_list_item.dart';

class ShoppingList {
  final String? id;
  final String title;
  final List<ShoppingListItem> items;
  final double totalEstimatedCost;
  final String currency;
  final String? bestStore;
  final String? savingsTip;

  const ShoppingList({
    this.id,
    required this.title,
    required this.items,
    required this.totalEstimatedCost,
    required this.currency,
    this.bestStore,
    this.savingsTip,
  });

  ShoppingList copyWith({
    String? id,
    String? title,
    List<ShoppingListItem>? items,
    double? totalEstimatedCost,
    String? currency,
    String? bestStore,
    String? savingsTip,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      title: title ?? this.title,
      items: items ?? this.items,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      currency: currency ?? this.currency,
      bestStore: bestStore ?? this.bestStore,
      savingsTip: savingsTip ?? this.savingsTip,
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as String?,
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ShoppingListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      currency: json['currency'] as String,
      bestStore: json['bestStore'] as String?,
      savingsTip: json['savingsTip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'items': items.map((e) => e.toJson()).toList(),
      'totalEstimatedCost': totalEstimatedCost,
      'currency': currency,
      if (bestStore != null) 'bestStore': bestStore,
      if (savingsTip != null) 'savingsTip': savingsTip,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingList && other.title == title && other.id == id;
  }

  @override
  int get hashCode {
    return Object.hash(id, title);
  }

  @override
  String toString() {
    return 'ShoppingList($title — ₡$totalEstimatedCost, ${items.length} items)';
  }
}
