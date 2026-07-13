import '../domain/models/assistant_request.dart';
import '../domain/models/assistant_context.dart';
import '../domain/models/assistant_metadata.dart';

class AssistantRequestBuilder {
  AssistantRequest build({
    required String question,
    String? conversationId,
    List<String>? storeIds,
    double? budget,
    List<String>? dietaryRestrictions,
  }) {
    return AssistantRequest(
      question: question,
      conversationId: conversationId,
      context: AssistantContext(
        storeIds: storeIds,
        budget: budget,
        dietaryRestrictions: dietaryRestrictions,
      ),
      metadata: AssistantMetadata(
        appVersion: '1.0.0',
        platform: 'unknown',
        language: 'es',
        timezone: DateTime.now().timeZoneName,
      ),
    );
  }
}
