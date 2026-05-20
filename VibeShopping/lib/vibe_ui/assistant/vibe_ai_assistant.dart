import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../vibe_core/vibe_colors.dart';
import '../../vibe_data/vibe_services/gemini_assistant_service.dart';

class VibeAiAssistant extends StatefulWidget {
  const VibeAiAssistant({super.key});

  static Future<void> showAssistantSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Provider.value(
        value: context.read<GeminiShoppingAssistantService>(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: const VibeAiAssistant(),
        ),
      ),
    );
  }

  static Widget buildFloatingButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => showAssistantSheet(context),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: VibeColors.mint.withValues(alpha: 0.95)),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFF2C4361), size: 28),
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<VibeAiAssistant> createState() => _VibeAiAssistantState();
}

class _VibeAiAssistantState extends State<VibeAiAssistant> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'content': '¡Hola, Aarón! Soy tu asistente de VibeShopping. ¿Qué deseas comprar hoy con tu presupuesto?',
      'role': 'ai',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    final message = {
      'user_id': user?.id,
      'content': text,
      'role': 'user',
      'created_at': DateTime.now().toIso8601String(),
    };

    // Usando tabla correcta según requerimiento (ej. community_messages)
    await Supabase.instance.client.from('community_messages').insert(message);
    
    setState(() {
      _messages.add(message);
      _controller.clear();
    });

    final service = context.read<GeminiShoppingAssistantService>();
    final response = await service.askShoppingQuestion(text);
    
    final aiMessage = {
      'content': response,
      'role': 'ai',
      'created_at': DateTime.now().toIso8601String(),
    };
    
    await Supabase.instance.client.from('community_messages').insert(aiMessage);

    setState(() {
      _messages.add(aiMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return ListTile(
                      title: Text(msg['content']),
                      subtitle: Text(msg['role']),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Pregúntale algo...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => _messages.clear())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
