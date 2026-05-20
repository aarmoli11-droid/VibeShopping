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
  final String _systemPrompt = '''
Eres el asistente de VibeShopping. Tu único conocimiento son estos 40 productos en Costa Rica con sus respectivos precios y supermercados (Walmart, CoopeAgri, Maxi Palí, etc.). Ayuda al usuario a comparar los precios de estos productos específicos y optimizar su presupuesto en colones (₡). No inventes productos fuera de esta lista.
Cuando el usuario pregunte por precios, compara exclusivamente los valores vigentes de estos 40 productos entre los supermercados mapeados.
Contexto: Lista de productos básica: [Arroz 1kg, Frijoles 800g, Azúcar 1kg, Sal 500g, Café 250g, Leche entera 1L, Huevos 12u, Aceite 900ml, Pasta 400g, Harina de trigo 1kg, Pan molde 500g, Tortillas de maíz 10u, Queso Turrialba 400g, Mantequilla 250g, Pollo entero 1.5kg, Carne molida 500g, Salchichón 400g, Jamón 250g, Papas 1kg, Cebollas 500g, Tomates 500g, Chiles dulces 3u, Zanahorias 500g, Bananos 1kg, Plátanos 3u, Manzanas 4u, Naranjas 1kg, Papayas 1u, Atún en agua 150g, Sardinas 150g, Yogurt 1L, Crema de leche 250ml, Avena 500g, Cereal 300g, Jugo de naranja 1L, Agua embotellada 1.5L, Detergente 1kg, Jabón de baño 3u, Pasta dental 100g, Papel higiénico 4u].
''';

  /// Respuesta breve a una consulta del usuario (precios referenciales, ideas, etc.).
  Future<String> askShoppingQuestion(String prompt) async {
    final content = [
      Content.multi([TextPart(_systemPrompt), TextPart(prompt)])
    ];
    final response = await _model.generateContent(content);
    final text = response.text;
    if (text == null || text.isEmpty) {
      return 'No se pudo generar una respuesta en este momento.';
    }
    return text.trim();
  }
}
