// ======================================================
// Archivo: features/assistant/providers/assistant_provider.dart
// Responsabilidad: Gestionar el estado de la consulta al
//   asistente IA y notificar cambios a los widgets
// Qué hace: Expone askQuestion() que devuelve la respuesta
//   como String. Mantiene isLoading y error para la UI
// Quién lo utiliza: VibeAiAssistant (bottom sheet del
//   asistente IA)
//
// Flujo dentro de la aplicación:
//   1. VibeAiAssistant llama a provider.askQuestion(text, context)
//   2. El provider pone isLoading=true y notifica
//   3. Llama al service (operación async hacia el backend)
//   4. Si ok: devuelve la respuesta; la UI la agrega al chat
//   5. Si error: devuelve mensaje de fallback
//   6. Finalmente pone isLoading=false y notifica
//
// Diferencia con otros providers:
//   askQuestion devuelve String en lugar de void o bool.
//   La respuesta se maneja en la UI (VibeAiAssistant agrega
//   el mensaje a la lista local), no se almacena en el provider
// ======================================================

import 'package:flutter/foundation.dart';
import '../services/assistant_service.dart';

// ======================================================
// Clase: AssistantProvider
// Provider de estado para el asistente IA de compras
// Cuándo se crea: en main.dart, inyectado vía
//   ChangeNotifierProvider dentro de MultiProvider
//
// Nota: a diferencia de otros providers, este NO almacena
// el resultado de la consulta. La respuesta se devuelve
// como String y la UI (VibeAiAssistant) la agrega a su
// lista local de mensajes (_messages)
// ======================================================
class AssistantProvider extends ChangeNotifier {
  AssistantProvider({required this.service});

  final AssistantService service;

  // ——— Estado interno ———
  bool _isLoading = false;
  String? _error;

  // ——— Getters ———
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ======================================================
  // askQuestion
  // Recibe: question (String — pregunta del usuario),
  //   context (String? — datos de productos para contexto)
  // Devuelve: String con la respuesta del asistente
  // Cuándo se ejecuta: cuando el usuario envía una pregunta
  // Quién lo llama: VibeAiAssistant._sendMessage()
  //
  // Paso 1: marcar loading y limpiar error
  // Paso 2: llamar al service (async)
  // Paso 3: si hay error, devolver mensaje de fallback
  // Paso 4: siempre notificar al final
  // ======================================================
  Future<String> askQuestion(String question, {String? context}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await service.askQuestion(question, context: context);
      return response;
    } catch (e) {
      debugPrint('Error en AssistantProvider: $e');
      _error = 'Error al consultar el asistente';
      return 'Lo siento, no pude procesar tu pregunta. Intenta de nuevo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // clearError
  // Recibe: nada — limpia el mensaje de error
  // ======================================================
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
