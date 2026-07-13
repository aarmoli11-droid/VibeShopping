// ======================================================
// Archivo: server/src/routes/index.ts
// Responsabilidad: Orquestar el registro de todas las
//   rutas de la API en la aplicación Fastify
// Qué hace: Importa los plugins de rutas de cada
//   feature y los registra con el prefijo /api/v1.
//   También define los endpoints de utilidad (health,
//   version)
// Quién lo utiliza: app.ts → buildApp() → registerRoutes()
// Cuándo se ejecuta: Una vez al arrancar el servidor
//
// Flujo dentro de la aplicación:
//   buildApp() → registerRoutes(app)
//     → register(productsRoutes, {prefix: '/api/v1'})
//     → register(assistantRoutes, ...)
//     → app.get('/api/v1/health') → handler
//     → app.get('/api/v1/version') → handler
//
// Conceptos utilizados:
//   - Plugin de Fastify: cada grupo de rutas se registra
//     como un plugin con su propio contexto y prefijo.
//     Los plugins aïslan hooks, logs y decorators
//   - Prefijo de ruta: '/api/v1' agrupa todas las rutas
//     bajo una misma base URL. Si cambiamos la versión,
//     solo cambiamos el prefijo
//   - Health check: endpoint de monitoreo que verifica
//     que el servidor y sus dependencias funcionan
//   - process.uptime(): segundos desde que el proceso
//     Node.js arrancó. Útil para monitoreo
// ======================================================

import { FastifyInstance } from 'fastify';
import { productsRoutes } from './products';
import { assistantRoutes } from './assistant';
import { shoppingAssistantController } from '../assistant/controllers/shoppingAssistantController';
import { supabase } from '../config/supabase';
import { env } from '../config/env';

// ======================================================
// Función: registerRoutes
// Recibe: app (instancia de Fastify)
// Devuelve: void
// Cuándo se ejecuta: Durante el arranque del servidor
// Quién lo llama: app.ts → buildApp()
//
// Cada grupo de rutas se registra como un plugin de
// Fastify con su propio prefijo. Fastify permite
// aislar el contexto de cada plugin (logs, hooks, etc.)
// ======================================================
export async function registerRoutes(app: FastifyInstance): Promise<void> {
  // ——— Rutas de negocio ———
  await app.register(productsRoutes, { prefix: '/api/v1' });
  await app.register(assistantRoutes, { prefix: '/api/v1' });
  await app.register(shoppingAssistantController, { prefix: '/api/v2' });

  // ======================================================
  // Endpoint: GET /api/v1/health
  // Propósito: Verificar que el servidor está funcionando
  //   y que sus dependencias (Supabase, Gemini) responden
  // Uso: Monitoreo y orquestación (Kubernetes, Docker,
  //   load balancers)
  // ======================================================
  app.get('/api/v1/health', async (request, reply) => {
    const supabaseStatus = await _checkSupabaseConnection(request);
    const geminiStatus = _checkGeminiConfig();

    return {
      success: true,
      data: {
        status: supabaseStatus === 'ok' ? 'ok' : 'degraded',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        version: '1.0.0',
        checks: {
          supabase: supabaseStatus,
          gemini: geminiStatus,
        },
      },
    };
  });

  // ======================================================
  // Endpoint: GET /api/v1/version
  // Propósito: Conocer la versión actual de la API
  // Uso: Verificar despliegues, integración continua
  // ======================================================
  app.get('/api/v1/version', async () => ({
    success: true,
    data: {
      version: '1.0.0',
      name: 'vibeshopping-api',
    },
  }));
}

// ======================================================
// Función auxiliar: _checkSupabaseConnection
// Intenta hacer una consulta mínima a Supabase para
// verificar que la conexión a la base de datos funciona
// ======================================================
async function _checkSupabaseConnection(request: { log: { error: (obj: object, msg: string) => void } }): Promise<string> {
  try {
    const { error } = await supabase.from('v_products_complete').select('id').limit(1);
    return error ? 'error' : 'ok';
  } catch (err) {
    request.log.error({ error: err }, 'Health check: error al conectar con Supabase');
    return 'error';
  }
}

// ======================================================
// Función auxiliar: _checkGeminiConfig
// Solo verifica que la variable de entorno exista.
// No hace una llamada real a Gemini para no gastar
// cuotas de API en cada health check
// ======================================================
function _checkGeminiConfig(): string {
  return env.GEMINI_API_KEY ? 'configured' : 'missing';
}
