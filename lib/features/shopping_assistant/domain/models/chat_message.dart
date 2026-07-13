import '../enums/message_role.dart';
import '../enums/assistant_intent.dart';

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final AssistantIntent? type;
  final DateTime timestamp;
  final Map<String, dynamic>? payload;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.type,
    required this.timestamp,
    this.payload,
  });

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    AssistantIntent? type,
    DateTime? timestamp,
    Map<String, dynamic>? payload,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      payload: payload ?? this.payload,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      content: json['content'] as String,
      type: json['type'] != null
          ? AssistantIntent.fromJson(json['type'] as String)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toJson(),
      'content': content,
      if (type != null) 'type': type!.toJson(),
      'timestamp': timestamp.toIso8601String(),
      if (payload != null) 'payload': payload,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.role == role &&
        other.content == content &&
        other.type == type &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(id, role, content, type, timestamp);
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, type: $type, timestamp: $timestamp)';
  }
}
