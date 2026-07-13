enum AssistantState {
  idle,
  loading,
  streaming,
  error;

  String toJson() => name;

  static AssistantState fromJson(String json) {
    return AssistantState.values.firstWhere(
      (e) => e.name == json,
      orElse: () => AssistantState.idle,
    );
  }
}
