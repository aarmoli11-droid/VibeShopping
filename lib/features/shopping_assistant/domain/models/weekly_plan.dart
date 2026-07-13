class MealPlan {
  final String type;
  final String name;
  final String? recipeId;
  final double estimatedCost;
  final String preparationTime;

  const MealPlan({
    required this.type,
    required this.name,
    this.recipeId,
    required this.estimatedCost,
    required this.preparationTime,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      type: json['type'] as String,
      name: json['name'] as String,
      recipeId: json['recipeId'] as String?,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      preparationTime: json['preparationTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      if (recipeId != null) 'recipeId': recipeId,
      'estimatedCost': estimatedCost,
      'preparationTime': preparationTime,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlan &&
        other.type == type &&
        other.name == name &&
        other.recipeId == recipeId;
  }

  @override
  int get hashCode => Object.hash(type, name, recipeId);

  @override
  String toString() => 'MealPlan($type: $name — ₡$estimatedCost)';
}

class DayPlan {
  final String day;
  final List<MealPlan> meals;

  const DayPlan({required this.day, required this.meals});

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day'] as String,
      meals: (json['meals'] as List<dynamic>)
          .map((e) => MealPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'meals': meals.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayPlan && other.day == day;
  }

  @override
  int get hashCode => day.hashCode;

  @override
  String toString() => 'DayPlan($day — ${meals.length} meals)';
}

class WeeklyPlan {
  final String title;
  final List<DayPlan> days;
  final double totalEstimatedCost;
  final String currency;
  final String? shoppingListSummary;

  const WeeklyPlan({
    required this.title,
    required this.days,
    required this.totalEstimatedCost,
    required this.currency,
    this.shoppingListSummary,
  });

  WeeklyPlan copyWith({
    String? title,
    List<DayPlan>? days,
    double? totalEstimatedCost,
    String? currency,
    String? shoppingListSummary,
  }) {
    return WeeklyPlan(
      title: title ?? this.title,
      days: days ?? this.days,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      currency: currency ?? this.currency,
      shoppingListSummary: shoppingListSummary ?? this.shoppingListSummary,
    );
  }

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyPlan(
      title: json['title'] as String,
      days: (json['days'] as List<dynamic>)
          .map((e) => DayPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      currency: json['currency'] as String,
      shoppingListSummary: json['shoppingListSummary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'days': days.map((e) => e.toJson()).toList(),
      'totalEstimatedCost': totalEstimatedCost,
      'currency': currency,
      if (shoppingListSummary != null)
        'shoppingListSummary': shoppingListSummary,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyPlan && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;

  @override
  String toString() {
    return 'WeeklyPlan($title — ${days.length} days, ₡$totalEstimatedCost)';
  }
}
