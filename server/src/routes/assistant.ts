// ======================================================
// Archivo: server/src/routes/assistant.ts
// Responsabilidad: Endpoint del asistente de compras
//   con inteligencia artificial
// Qué hace: Recibe una pregunta del usuario (con contexto
//   opcional de productos), construye un prompt detallado
//   y lo envía a Gemini API para obtener una respuesta
// Quién lo utiliza: routes/index.ts (lo registra como
//   plugin), Flutter → AssistantService (consume el
//   endpoint)
// Cuándo se ejecuta: Cuando el usuario escribe una
//   pregunta en el asistente de la app
//
// Flujo dentro de la aplicación:
//   Flutter autenticado → POST /api/v1/assistant/ask
//     → authMiddleware (valida JWT)
//     → Rate limit (20 req/min específico para IA)
//     → Zod valida { question, context? }
//     → _buildPrompt construye el texto con o sin
//       contexto de productos
//     → GeminiService.generateContent() llama a Gemini
//     → Gemini devuelve texto generado por IA
//     → JSON con { success, data: { response } }
//
// Conceptos utilizados:
//   - Prompt engineering: técnica de escribir
//     instrucciones precisas para la IA. "Eres un
//     asistente de compras en Costa Rica" le da
//     personalidad y contexto
//   - Rate limit específico: este endpoint tiene un
//     límite más restrictivo (20/min) porque cada
//     llamada consume cuota de Gemini y tiene costo
//   - Gemini API: API REST de Google que procesa texto
//     usando un modelo de lenguaje. Recibe un prompt,
//     devuelve una respuesta
//   - Contexto de productos: datos estructurados
//     (nombre + precio + tienda) que la IA usa para
//     comparar y recomendar
// ======================================================

import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { GeminiService } from '../services/gemini';
import { authMiddleware } from '../middleware/auth';

// ======================================================
// Schema de validación Zod
// ======================================================

const askQuestionSchema = z.object({
  // La pregunta del usuario (obligatoria)
  question: z.string()
    .min(1, 'La pregunta no puede estar vacía')
    .max(2000, 'La pregunta es demasiado larga'),
  // Contexto opcional: lista de productos con precios
  // para que la IA pueda dar una respuesta informada
  context: z.string()
    .max(10000, 'El contexto es demasiado largo')
    .optional(),
});

// ======================================================
// Función: _buildPrompt
// Recibe: question (string), context (string opcional)
// Devuelve: string (el prompt completo para Gemini)
//
// El prompt es el texto que le enviamos a la IA para
// que genere una respuesta. Mientras más contexto le
// demos, mejor será la respuesta.
//
// Si hay contexto de productos, se lo incluimos para
// que pueda comparar precios. Si no, la IA responde
// con su conocimiento general
// ======================================================
function _buildPrompt(question: string, context?: string): string {
  if (context) {
    // Prompt con datos de productos para comparar precios
    return (
      `Eres un asistente de compras en Costa Rica. ` +
      `Ayudas al usuario a comparar precios y tomar decisiones ` +
      `de compra basadas en los siguientes datos de productos ` +
      `y precios:\n\n${context}\n\nPregunta del usuario:\n${question}`
    );
  }

  // Prompt sin contexto (respuesta general)
  return (
    `Eres un asistente de compras en Costa Rica. ` +
    `Responde la siguiente pregunta del usuario:\n${question}`
  );
}

// ======================================================
// Registro de rutas
// ======================================================

export async function assistantRoutes(app: FastifyInstance): Promise<void> {
  // Creamos una instancia de GeminiService que se reutilizará
  // en todas las llamadas a este endpoint
  const geminiService = new GeminiService();

  // Requiere autenticación
  app.addHook('onRequest', authMiddleware);

  // ======================================================
  // POST /api/v1/assistant/ask
  // Body: { question, context? }
  // Rate limit: 20 peticiones por minuto (más restrictivo
  //   porque cada llamada consume cuota de Gemini API)
  // Devuelve: { success, data: { response: string } }
  // ======================================================
  app.post('/assistant/ask', {
    config: { rateLimit: { max: 20, timeWindow: '1 minute' } },
    handler: async (request, reply) => {
      // Paso 1: Validar los datos de entrada con Zod
      const { question, context } = askQuestionSchema.parse(request.body);
      request.log.info({
        questionLength: question.length,
        hasContext: !!context,
      }, 'POST /api/v1/assistant/ask');

      // Paso 2: Construir el prompt para Gemini
      const prompt = _buildPrompt(question, context);

      // Paso 3: Enviar a Gemini y obtener respuesta
      const responseText = await geminiService.generateContent(prompt, request.log);

      // Paso 4: Devolver la respuesta
      reply.send({ success: true, data: { response: responseText } });
    },
  });
}
