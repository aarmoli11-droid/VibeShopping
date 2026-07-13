import '../enums/assistant_intent.dart';

class ChatResponse {
  final String conversationId;
  final AssistantIntent type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  const ChatResponse({
    required this.conversationId,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  ChatResponse copyWith({
    String? conversationId,
    AssistantIntent? type,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
  }) {
    return ChatResponse(
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      conversationId: json['conversationId'] as String,
      type: AssistantIntent.fromJson(json['type'] as String),
      payload: json['payload'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'type': type.toJson(),
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatResponse &&
        other.conversationId == conversationId &&
        other.type == type &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(conversationId, type, timestamp);
  }

  @override
  String toString() {
    return 'ChatResponse(conversationId: $conversationId, type: $type)';
  }
}
