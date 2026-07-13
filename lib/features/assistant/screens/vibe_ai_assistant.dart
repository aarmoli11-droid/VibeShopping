// ======================================================
// Archivo: features/assistant/screens/vibe_ai_assistant.dart
// Responsabilidad: Pantalla de chat con el asistente IA
//   de compras (VibeShopping Assistant)
// Qué hace: Muestra un bottom sheet con diálogo tipo chat.
//   El usuario pregunta sobre productos/precios y el
//   asistente responde usando datos reales del catálogo.
//   Incluye un botón flotante para abrir el asistente
// Quién lo utiliza: MarketExplorerView (botón flotante),
//   ChatInput (botón de asistente desde el chat comunitario)
//
// Flujo dentro de la aplicación:
//   1. El usuario toca el botón flotante o el icono IA
//   2. Se abre un ModalBottomSheet con el chat
//   3. El asistente saluda con mensaje de bienvenida
//   4. El usuario escribe una pregunta (ej: "¿qué leche es más barata?")
//   5. _sendMessage() carga productos reales del catálogo
//   6. Construye contexto estructurado (nombre + precios por tienda)
//   7. Envía pregunta + contexto al backend IA
//   8. La respuesta se muestra como nueva burbuja en el chat
//
// Conceptos utilizados:
//   - ModalBottomSheet: panel que emerge desde abajo,
//     ocupando el 80% de la pantalla. showDragHandle muestra
//     la barra de arrastre para cerrar
//   - StringBuffer: clase eficiente para construir Strings
//     largos concatenando. Mejor que "texto $var" repetido
//   - Contexto estructurado: los datos de productos se
//     formatean como texto plano para que la IA los entienda.
//     La IA no ve JSON, solo texto como:
//       "Leche Dos Pinos:
//         Walmart: ₡2500
//         MaxiPali: ₡2300"
//   - null: sin filtro de tienda (todas las disponibles)
// ======================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/vibe_constants.dart';
import '../../products/models/product.dart';
import '../../products/services/product_service.dart';
import '../providers/assistant_provider.dart';
import '../../auth/providers/auth_provider.dart';

// ======================================================
// Clase: VibeAiAssistant
// StatefulWidget que representa el chat con el asistente IA.
// Incluye dos métodos estáticos de utilidad:
//   - showAssistantSheet: abre el bottom sheet del asistente
//   - buildFloatingButton: construye el botón flotante para
//     abrir el asistente desde cualquier pantalla
// ======================================================
class VibeAiAssistant extends StatefulWidget {
  const VibeAiAssistant({super.key});

  // ======================================================
  // showAssistantSheet (static)
  // Recibe: BuildContext
  // Qué hace: abre un ModalBottomSheet con el asistente IA
  //   ocupando el 80% de la altura de la pantalla
  // Cuándo se ejecuta: al tocar el botón flotante o el
  //   icono IA desde ChatInput
  //
  // Concepto: showModalBottomSheet
  //   Muestra un panel modal desde abajo. showDragHandle
  //   agrega una barra de arrastre para cerrar con gesto.
  //   isScrollControlled permite contenido scrolleable
  // ======================================================
  static Future<void> showAssistantSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: VibeColors.backgroundWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const VibeAiAssistant(),
      ),
    );
  }

  // ======================================================
  // buildFloatingButton (static)
  // Recibe: BuildContext
  // Devuelve: Widget con el botón flotante estilo
  //   glassmorphism (efecto vidrio con blur)
  // Cuándo se ejecuta: en MarketExplorerView para
  //   mostrar el FAB del asistente
  //
  // Concepto: BackdropFilter + blur
  //   Crea el efecto de vidrio esmerilado. El filtro blur
  //   desenfoca el contenido detrás del botón
  // ======================================================
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
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida del asistente
    _messages.add({
      'content':
          '¡Hola, Aarón! Soy tu asistente de VibeShopping. ¿Qué deseas comprar hoy con tu presupuesto?',
      'role': 'Asistente de VibeShopping',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ======================================================
  // _sendMessage
  // Recibe: nada (lee _controller.text)
  // Devuelve: Future<void>
  // Cuándo se ejecuta: al tocar el botón de enviar
  //
  // Paso 1: agregar el mensaje del usuario a la lista local
  // Paso 2: cargar productos reales del catálogo (todos
  //   los storeIds para tener contexto completo)
  // Paso 3: construir contexto estructurado con StringBuffer
  // Paso 4: llamar al provider con pregunta + contexto
  // Paso 5: agregar respuesta de la IA a la lista local
  // ======================================================
  Future<void> _sendMessage() async {
    // Protección contra envíos concurrentes
    if (_isSending) return;
    _isSending = true;

    final text = _controller.text.trim();
    if (text.isEmpty) {
      _isSending = false;
      return;
    }

    try {
      // Paso 1: agregar mensaje del usuario al chat
      final user = context.read<AuthProvider>().user;
      final message = {
        'user_id': user?.id,
        'content': text,
        'role': 'user',
        'created_at': DateTime.now().toIso8601String(),
      };

      setState(() {
        _messages.add(message);
        _controller.clear();
      });

      // Paso 2: cargar productos para dar contexto a la IA
      final repo = context.read<ProductService>();
      final List<ProductEntity> products;
      try {
        products = await repo.listProducts(storeIds: null);
      } catch (e) {
        debugPrint('Error al cargar productos para el asistente: $e');
        final errorMessage = {
          'content':
              'Lo siento, no pude consultar los precios. Revisa tu conexión e intenta de nuevo.',
          'role': 'Asistente de VibeShopping',
          'created_at': DateTime.now().toIso8601String(),
        };
        if (!mounted) return;
        setState(() => _messages.add(errorMessage));
        return;
      }

      // Paso 3: construir contexto estructurado en texto plano
      // Formato: "Producto:\n  Tienda: ₡precio"
      final buffer = StringBuffer();
      for (final product in products) {
        buffer.writeln('${product.name}:');
        for (final price in product.prices) {
          final formattedPrice = price.price.toStringAsFixed(0);
          buffer.writeln('  ${price.storeName}: ₡$formattedPrice');
        }
        buffer.writeln();
      }

      // Paso 4: enviar al asistente
      final provider = context.read<AssistantProvider>();
      final response =
          await provider.askQuestion(text, context: buffer.toString());

      // Paso 5: mostrar respuesta
      final aiMessage = {
        'content': response,
        'role': 'Asistente de VibeShopping',
        'created_at': DateTime.now().toIso8601String(),
      };

      if (!mounted) return;
      setState(() {
        _messages.add(aiMessage);
      });
    } finally {
      _isSending = false;
    }
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
              // ——— Lista de mensajes ———
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
              // ——— Barra de entrada ———
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
                    IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _isSending ? null : _sendMessage),
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
