import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../vibe_data/vibe_services/gemini_assistant_service.dart';

class VibeAssistantMessage {
  final String text;
  final bool isUser;
  VibeAssistantMessage({required this.text, required this.isUser});
}

class VibeAssistantView extends StatefulWidget {
  const VibeAssistantView({super.key});

  @override
  State<VibeAssistantView> createState() => _VibeAssistantViewState();
}

class _VibeAssistantViewState extends State<VibeAssistantView> {
  final List<VibeAssistantMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(VibeAssistantMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    final service = context.read<GeminiShoppingAssistantService>();
    try {
      final response = await service.askShoppingQuestion(text);
      setState(() {
        _messages.add(VibeAssistantMessage(text: response, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(VibeAssistantMessage(text: 'Error: $e', isUser: false));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente de Compras')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(_messages[i].text),
                tileColor: _messages[i].isUser ? Colors.blue[50] : Colors.grey[100],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Pregunta algo...'),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
