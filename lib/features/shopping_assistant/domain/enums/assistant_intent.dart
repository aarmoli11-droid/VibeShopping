enum AssistantIntent {
  productSearch,
  recommendation,
  comparison,
  recipe,
  shoppingList,
  budgetAnalysis,
  substitution,
  weeklyPlan,
  promotion,
  nutritionalInfo,
  dietaryAdvice,
  storeGuide,
  answer;

  String toJson() => name;

  static AssistantIntent fromJson(String json) {
    return AssistantIntent.values.firstWhere(
      (e) => e.name == json,
      orElse: () => AssistantIntent.answer,
    );
  }
}
