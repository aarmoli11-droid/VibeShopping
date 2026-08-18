// Asistente de compras conversacional: chat con la Edge Function gemini-chat.
// La Edge Function consulta Supabase, calcula precios + distancia + transporte
// y arma el contexto; Gemini solo redacta con esos datos reales.
// El transporte se resuelve dentro de la conversación (la Edge Function lo
// detecta en los mensajes y pregunta si falta); no depende de chips.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/vibe_constants.dart';

class ShoppingAssistantScreen extends StatefulWidget {
  const ShoppingAssistantScreen({super.key});

  @override
  State<ShoppingAssistantScreen> createState() =>
      _ShoppingAssistantScreenState();
}

class _ShoppingAssistantScreenState extends State<ShoppingAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_Message> _messages = [
    _Message(
        text:
            'Pregúntame sobre tus compras y te ayudaré a elegir la mejor opción.'),
  ];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Historial completo de la conversación (sin mensajes de error).
    final history = _messages
        .where((m) => !m.isError)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'text': m.text,
            })
        .toList();

    try {
      final res =
          await Supabase.instance.client.functions.invoke('gemini-chat', body: {
        'messages': history,
      });
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _messages.add(_Message(
          text: data['response'] as String? ?? 'Sin respuesta.',
        ));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message(text: _describeError(e), isError: true));
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  String _describeError(Object error) {
    if (error is FunctionException) {
      if (error.status == 429) {
        return 'En este momento el asistente alcanzó el límite temporal de consultas. '
            'Intenta nuevamente en unos segundos.';
      }
      final details = error.details;
      if (details is Map && details['error'] is String) {
        return details['error'] as String;
      }
      return 'Error ${error.status} · ${error.reasonPhrase}';
    }
    return 'No se pudo conectar con el asistente.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibeColors.backgroundWhite,
      appBar: AppBar(title: const Text('VibeShopping Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                for (final message in _messages) _bubble(message),
                if (_loading)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: VibeColors.mint),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
                decoration:
                    const InputDecoration(hintText: 'Escribe tu mensaje…'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _loading ? null : _send,
              style: IconButton.styleFrom(
                backgroundColor: VibeColors.navy,
                foregroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(38, 38),
                maximumSize: const Size(38, 38),
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_upward, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(_Message message) {
    final background = message.isUser
        ? VibeColors.navy
        : message.isError
            ? const Color(0xFFFCE4EC)
            : VibeColors.backgroundMint;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
              color: message.isUser ? Colors.white : VibeColors.navy,
              fontSize: 15),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isError;

  const _Message(
      {required this.text, this.isUser = false, this.isError = false});
}
