enum MessageRole {
  user,
  assistant,
  system;

  String toJson() => name;

  static MessageRole fromJson(String json) {
    return MessageRole.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MessageRole.user,
    );
  }
}
