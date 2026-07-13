import '../domain/models/chat_response.dart';

class AssistantResponseParser {
  ChatResponse parseResponse(Map<String, dynamic> json) {
    return ChatResponse.fromJson(json);
  }
}
