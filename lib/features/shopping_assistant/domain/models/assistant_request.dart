import 'assistant_context.dart';
import 'assistant_metadata.dart';

class AssistantRequest {
  final String question;
  final String? conversationId;
  final AssistantContext? context;
  final AssistantMetadata? metadata;

  const AssistantRequest({
    required this.question,
    this.conversationId,
    this.context,
    this.metadata,
  });

  AssistantRequest copyWith({
    String? question,
    String? conversationId,
    AssistantContext? context,
    AssistantMetadata? metadata,
  }) {
    return AssistantRequest(
      question: question ?? this.question,
      conversationId: conversationId ?? this.conversationId,
      context: context ?? this.context,
      metadata: metadata ?? this.metadata,
    );
  }

  factory AssistantRequest.fromJson(Map<String, dynamic> json) {
    return AssistantRequest(
      question: json['question'] as String,
      conversationId: json['conversationId'] as String?,
      context: json['context'] != null
          ? AssistantContext.fromJson(json['context'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] != null
          ? AssistantMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      if (conversationId != null) 'conversationId': conversationId,
      if (context != null) 'context': context!.toJson(),
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssistantRequest && other.question == question;
  }

  @override
  int get hashCode => question.hashCode;

  @override
  String toString() {
    return 'AssistantRequest(question: $question, conversationId: $conversationId)';
  }
}
