class ConversationSummary {
  final String conversationId;
  final String summary;
  final int messageCount;
  final List<String>? keyTopics;
  final DateTime lastMessageAt;

  const ConversationSummary({
    required this.conversationId,
    required this.summary,
    required this.messageCount,
    this.keyTopics,
    required this.lastMessageAt,
  });

  ConversationSummary copyWith({
    String? conversationId,
    String? summary,
    int? messageCount,
    List<String>? keyTopics,
    DateTime? lastMessageAt,
  }) {
    return ConversationSummary(
      conversationId: conversationId ?? this.conversationId,
      summary: summary ?? this.summary,
      messageCount: messageCount ?? this.messageCount,
      keyTopics: keyTopics ?? this.keyTopics,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      conversationId: json['conversationId'] as String,
      summary: json['summary'] as String,
      messageCount: (json['messageCount'] as num).toInt(),
      keyTopics: (json['keyTopics'] as List<dynamic>?)?.cast<String>(),
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'summary': summary,
      'messageCount': messageCount,
      if (keyTopics != null) 'keyTopics': keyTopics,
      'lastMessageAt': lastMessageAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationSummary &&
        other.conversationId == conversationId &&
        other.summary == summary;
  }

  @override
  int get hashCode => Object.hash(conversationId, summary);

  @override
  String toString() {
    return 'ConversationSummary(conversationId: $conversationId, ${messageCount}msgs)';
  }
}
