import 'package:flutter/foundation.dart';
import '../domain/models/conversation.dart';
import '../domain/models/chat_message.dart';
import '../domain/enums/assistant_state.dart';

class ShoppingAssistantProvider extends ChangeNotifier {
  Conversation? _conversation;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  AssistantState _state = AssistantState.idle;

  Conversation? get conversation => _conversation;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AssistantState get state => _state;

  Future<void> sendMessage(String text) {
    throw UnimplementedError('ShoppingAssistantProvider.sendMessage()');
  }

  void clearConversation() {
    throw UnimplementedError('ShoppingAssistantProvider.clearConversation()');
  }

  Future<void> loadConversation(String id) {
    throw UnimplementedError('ShoppingAssistantProvider.loadConversation()');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
