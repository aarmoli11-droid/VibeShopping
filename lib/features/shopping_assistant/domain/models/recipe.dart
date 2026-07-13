import 'recipe_ingredient.dart';

class Recipe {
  final String name;
  final String preparationTime;
  final String difficulty;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final double totalEstimatedCost;
  final String currency;
  final List<String>? storeIds;
  final Map<String, String>? nutritionalInfo;

  const Recipe({
    required this.name,
    required this.preparationTime,
    required this.difficulty,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.totalEstimatedCost,
    required this.currency,
    this.storeIds,
    this.nutritionalInfo,
  });

  Recipe copyWith({
    String? name,
    String? preparationTime,
    String? difficulty,
    int? servings,
    List<RecipeIngredient>? ingredients,
    List<String>? steps,
    double? totalEstimatedCost,
    String? currency,
    List<String>? storeIds,
    Map<String, String>? nutritionalInfo,
  }) {
    return Recipe(
      name: name ?? this.name,
      preparationTime: preparationTime ?? this.preparationTime,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      currency: currency ?? this.currency,
      storeIds: storeIds ?? this.storeIds,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] as String,
      preparationTime: json['preparationTime'] as String,
      difficulty: json['difficulty'] as String,
      servings: (json['servings'] as num).toInt(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>).cast<String>(),
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      currency: json['currency'] as String,
      storeIds: (json['storeIds'] as List<dynamic>?)?.cast<String>(),
      nutritionalInfo: (json['nutritionalInfo'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'preparationTime': preparationTime,
      'difficulty': difficulty,
      'servings': servings,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps,
      'totalEstimatedCost': totalEstimatedCost,
      'currency': currency,
      if (storeIds != null) 'storeIds': storeIds,
      if (nutritionalInfo != null) 'nutritionalInfo': nutritionalInfo,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Recipe($name — $preparationTime, ₡$totalEstimatedCost)';
  }
}
