// ======================================================
// Archivo: server/src/services/gemini.ts
// Responsabilidad: Comunicarse con la API REST de Gemini
//   (modelo de lenguaje de Google)
// Qué hace: Toma un prompt (texto), construye el cuerpo
//   de la petición, la envía a Gemini mediante fetch() y
//   devuelve el texto generado por la IA
// Quién lo utiliza: routes/assistant.ts (POST /assistant/ask)
// Cuándo se ejecuta: Cuando el usuario hace una pregunta
//   en el asistente de compras
//
// Flujo dentro de la aplicación:
//   assistant.ts → GeminiService.generateContent(prompt)
//     → _validateApiKey() → _buildApiUrl()
//     → _buildRequestBody(prompt)
//     → fetch(url, { method, headers, body, signal })
//     → Gemini API procesa y responde JSON
//     → _parseResponse() extrae el texto
//     → devuelve string al handler de la ruta
//
// Conceptos utilizados:
//   - API REST: interfaz que sigue el estilo REST
//     (REpresentational State Transfer). Gemini expone
//     un endpoint POST al que se envía JSON y devuelve
//     JSON
//   - fetch(): API nativa de Node.js (y del navegador)
//     para hacer peticiones HTTP. Devuelve una Promesa
//     que se resuelve con la respuesta
//   - HTTP POST: método HTTP para enviar datos al
//     servidor (el prompt viaja en el body)
//   - JSON.stringify(): convierte un objeto JavaScript
//     a string JSON para enviarlo en el body
//   - AbortController: mecanismo para cancelar una
//     petición fetch() en curso. Si Gemini tarda más
//     de GEMINI_TIMEOUT, abortamos
//   - setTimeout / clearTimeout: programan y cancelan
//     la abort. Garantizan que no se quede colgada
//   - Record<string, unknown>: tipo de TypeScript que
//     representa un objeto con claves string y valores
//     desconocidos. Útil para parsear JSON dinámico
//   - Conventions:
//     - const GEMINI_... son constantes del módulo, no
//       variables de instancia, porque no cambian entre
//       peticiones
//     - Los métodos privados (_validateApiKey, etc.)
//       encapsulan responsabilidades individuales para
//       que generateContent() sea fácil de leer
// Nota: GEMINI_API_KEY se obtiene de env en lugar de
// process.env directamente para pasar por la validación
// Zod de env.ts
// ======================================================

import { env } from '../config/env';
const GEMINI_API_KEY = env.GEMINI_API_KEY;
const GEMINI_MODEL = 'gemini-2.0-flash';
const GEMINI_TIMEOUT = 15_000; // 15 segundos

// ======================================================
// Clase: GeminiService
// Representa: El servicio que envía prompts a Gemini
// Cuándo se crea: En routes/assistant.ts cuando se
//   registra la ruta
// Problema que resuelve: Aislar la lógica de llamada
//   a la API de Google en un solo lugar, para que si
//   la API cambia (modelo, version, formato), solo
//   tengamos que modificar este archivo
// ======================================================
export class GeminiService {
  // ======================================================
  // Método: generateContent
  // Recibe:
  //   - prompt: string (texto con la pregunta + contexto)
  //   - requestLog: objeto para registrar logs (opcional)
  // Devuelve: Promise<string> (respuesta de Gemini)
  // Cuándo se ejecuta: Cuando el usuario envía una
  //   pregunta al asistente de compras
  // Quién lo llama: routes/assistant.ts en POST /assistant/ask
  // ======================================================
  async generateContent(prompt: string, requestLog?: { debug: (obj: object, msg: string) => void }): Promise<string> {
    // Paso 1: Validar que la API key existe
    this._validateApiKey();

    // Paso 2: Construir URL y body de la petición
    const url = this._buildApiUrl();
    const requestBody = this._buildRequestBody(prompt);

    // Paso 3: Configurar timeout con AbortController
    // Si Gemini no responde en 15 segundos, cancelamos
    // la petición para no dejar el servidor colgado
    const startTime = Date.now();
    const abortController = new AbortController();
    const timeoutId = setTimeout(() => abortController.abort(), GEMINI_TIMEOUT);

    try {
      // Paso 4: Enviar la petición HTTP a Gemini
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
        signal: abortController.signal,
      });

      // Paso 5: Registrar métricas de la respuesta
      const duration = Date.now() - startTime;
      requestLog?.debug({ duration, status: response.status }, 'Respuesta de Gemini');

      // Paso 6: Verificar que Gemini respondió OK
      if (!response.ok) {
        const errorBody = await response.text().catch(() => '');
        throw new Error(`Gemini API error: ${response.status} — ${errorBody}`);
      }

      // Paso 7: Parsear la respuesta JSON y extraer texto
      const responseData = await response.json() as Record<string, unknown>;
      const generatedText = this._parseResponse(responseData);

      return generatedText;
    } catch (error) {
      // Paso 8: Manejar errores (timeout, red, API)
      requestLog?.debug({ error }, 'Error en Gemini API');
      if (error instanceof Error && error.name === 'AbortError') {
        throw new Error('La solicitud a Gemini superó el tiempo máximo de espera');
      }
      throw error;
    } finally {
      // Paso 9: Limpiar el timeout (importante:
      // evitar fugas de memoria si la petición
      // se completó antes del timeout)
      clearTimeout(timeoutId);
    }
  }

  // ======================================================
  // Método: _validateApiKey (privado)
  // Recibe: nada (lee GEMINI_API_KEY del módulo)
  // Devuelve: void (lanza error si falta la key)
  // Quién lo llama: generateContent() al inicio
  // Cuándo se ejecuta: Cada vez que se genera contenido
  //   (antes de gastar tiempo en la petición HTTP)
  // ======================================================
  private _validateApiKey(): void {
    if (!GEMINI_API_KEY) {
      throw new Error('GEMINI_API_KEY no configurada');
    }
  }

  // ======================================================
  // Método: _buildApiUrl (privado)
  // Recibe: nada (lee GEMINI_MODEL y GEMINI_API_KEY)
  // Devuelve: string (URL completa de la API)
  // Quién lo llama: generateContent() antes del fetch
  //
  // Formato: /v1beta/models/{modelo}:generateContent?key={apiKey}
  // ======================================================
  private _buildApiUrl(): string {
    return `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;
  }

  // ======================================================
  // Método: _buildRequestBody (privado)
  // Recibe: prompt (string) — el texto a enviar a la IA
  // Devuelve: object — el body en el formato de Gemini
  // Quién lo llama: generateContent() antes del fetch
  //
  // Gemini espera:
  // {
  //   contents: [{ parts: [{ text: "..." }] }]
  // }
  // ======================================================
  private _buildRequestBody(prompt: string): object {
    return {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ]
    };
  }

  // ======================================================
  // Método: _parseResponse (privado)
  // Recibe: responseData (Record<string, unknown>) — el
  //   JSON parseado de la respuesta de Gemini
  // Devuelve: string — el texto generado por la IA
  // Quién lo llama: generateContent() después del fetch
  //
  // La respuesta de Gemini tiene esta estructura:
  // {
  //   candidates: [
  //     { content: { parts: [{ text: "respuesta" }] } }
  //   ]
  // }
  //
  // Extraemos el texto navegando por esta estructura
  // ======================================================
  private _parseResponse(responseData: Record<string, unknown>): string {
    const candidates = responseData.candidates as Array<Record<string, unknown>> | undefined;
    const firstCandidate = candidates?.[0];
    const content = firstCandidate?.content as Record<string, unknown> | undefined;
    const parts = content?.parts as Array<Record<string, unknown>> | undefined;
    const text = parts?.[0]?.text as string | undefined;

    if (!text) {
      throw new Error('Gemini API: respuesta vacía');
    }

    return text.trim();
  }
}
