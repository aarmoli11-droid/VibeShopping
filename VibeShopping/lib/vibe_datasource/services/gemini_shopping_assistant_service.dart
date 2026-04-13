import 'package:google_generative_ai/google_generative_ai.dart';

import '../../vibe_core/vibe_constants.dart';

/// Asistente de Compras Inteligente (Gemini) — capa de datos.
class GeminiShoppingAssistantService {
  GeminiShoppingAssistantService({GenerativeModel? model})
      : _model = model ??
            GenerativeModel(
              model: VibeConfig.geminiModel,
              apiKey: VibeConfig.geminiApiKey,
            );

  final GenerativeModel _model;

  /// Respuesta breve a una consulta del usuario (precios referenciales, ideas, etc.).
  Future<String> askShoppingQuestion(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    final text = response.text;
    if (text == null || text.isEmpty) {
      return 'No se pudo generar una respuesta en este momento.';
    }
    return text.trim();
  }
}
