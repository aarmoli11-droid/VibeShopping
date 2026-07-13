class AssistantRemoteDataSource {
  Future<Map<String, dynamic>> askQuestion({
    required String question,
    String? conversationId,
    List<String>? storeIds,
    double? budget,
  }) {
    throw UnimplementedError('AssistantRemoteDataSource.askQuestion()');
  }

  Future<Map<String, dynamic>> getHistory({
    required String conversationId,
    int? limit,
  }) {
    throw UnimplementedError('AssistantRemoteDataSource.getHistory()');
  }

  Future<void> clearConversation(String conversationId) {
    throw UnimplementedError('AssistantRemoteDataSource.clearConversation()');
  }
}
