import '../models/chat_response.dart';

abstract class AssistantRepository {
  Future<ChatResponse> askQuestion({
    required String question,
    String? conversationId,
    List<String>? storeIds,
    double? budget,
  });
}
