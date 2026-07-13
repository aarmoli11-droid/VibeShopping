import '../../domain/models/chat_response.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../../services/assistant_response_parser.dart';
import '../../services/assistant_validator.dart';
import '../datasources/assistant_remote_datasource.dart';

class ShoppingAssistantRepository implements AssistantRepository {
  final AssistantRemoteDataSource _dataSource;
  final AssistantResponseParser _parser;
  final AssistantValidator _validator;

  ShoppingAssistantRepository({
    required AssistantRemoteDataSource dataSource,
    required AssistantResponseParser parser,
    required AssistantValidator validator,
  })  : _dataSource = dataSource,
        _parser = parser,
        _validator = validator;

  @override
  Future<ChatResponse> askQuestion({
    required String question,
    String? conversationId,
    List<String>? storeIds,
    double? budget,
  }) async {
    final json = await _dataSource.askQuestion(
      question: question,
      conversationId: conversationId,
      storeIds: storeIds,
      budget: budget,
    );

    final validation = _validator.validate(json);
    if (!validation.isValid) {
      throw Exception(validation.errors.join('; '));
    }

    return _parser.parseResponse(json);
  }
}
