import 'package:supabase_flutter/supabase_flutter.dart';

//** */ Asistente de Compras Inteligente (VibeShopping) — Capa de datos y seguridad.

//** */ Su labor es enviar la consulta a nuestra Edge Function de Supabase para proteger la API Key.
class GeminiShoppingAssistantService {
  
  //* Instancia del cliente de Supabase para invocar funciones en la nube

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Respuesta breve a una consulta del usuario sobre la canasta básica costarricense.
  Future<String> askShoppingQuestion(String prompt) async {
    try {

      //* Invocamos el servidor seguro pasándole el mensaje del usuario

      final response = await _supabase.functions.invoke(
        'asistente-compras',
        body: {'mensaje': prompt},
      );

      //** Si todo sale bien, procesamos la respuesta de la IA

      if (response.status == 200 && response.data != null) {
        final String? text = response.data['respuesta'];
        if (text == null || text.isEmpty) {
          return 'No se pudo generar una respuesta en este momento.';
        }
        return text.trim();
      } else {
        return 'El asistente de VibeShopping está experimentando una alta demanda. Por favor, reintenta.';
      }
    } catch (e) {

      //**!Control de caídas de red para proteger la experiencia del usuario costarricense

      print('Error al conectar con la Edge Function: $e');
      return 'Tuvimos problemas para conectar con el servidor. Revisa tu conexión a internet.';
    }
  }
}
