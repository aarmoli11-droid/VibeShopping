import '../../../core/api_client.dart';

class AssistantService {
  AssistantService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<String> askQuestion(String question, {String? context}) async {
    final body = <String, dynamic>{'question': question};
    if (context != null && context.isNotEmpty) body['context'] = context;

    final response = await _apiClient.post('/api/v1/assistant/ask', data: body);
    final data = ApiClient.unwrapData(response) as Map<String, dynamic>;
    final text = data['response'] as String?;
    if (text == null || text.isEmpty) {
      throw Exception(
        'El asistente no pudo generar una respuesta. Por favor intentá de nuevo.',
      );
    }
    return text;
  }
}
