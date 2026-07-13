// ======================================================
// Archivo: server/src/config/logger.ts
// Responsabilidad: Configurar el logger estructurado
// Qué hace: Crea una instancia de Pino con el nivel de
//   log configurado. En desarrollo usa pino-pretty para
//   colores; en producción genera JSON plano
// Quién lo utiliza: Todos los archivos del servidor que
//   necesiten registrar eventos (app.ts, supabase.ts,
//   rutas, middleware, servicios)
// Cuándo se ejecuta: En el momento del import. Se crea
//   una sola vez y se reutiliza globalmente
//
// Flujo dentro de la aplicación:
//   env.ts (config) → logger.ts → Pino(config)
//     → export logger → usado por todos los módulos
//
// Conceptos utilizados:
//   - Logger estructurado: en lugar de console.log(),
//     cada mensaje es un objeto JSON con timestamp,
//     nivel, mensaje y metadatos. Esto permite buscar
//     y filtrar en herramientas como Datadog
//   - Pino: logger mínimo para Node.js (~7kB, 5x más
//     rápido que Winston). Ideal para microservicios
//   - Transport: flujo de salida del log.
//     pino-pretty transforma JSON en texto legible
//   - Niveles de log: debug < info < warn < error.
//     En desarrollo usamos 'debug', en producción 'info'
// ======================================================

import pino from 'pino';
import { env } from './env';

// ======================================================
// Transport condicional según entorno
// env.NODE_ENV está disponible porque env se importa y
// valida antes de logger. El orden de import importa:
// las dependencias se cargan en orden ascendente
// - Desarrollo: pino-pretty colorea y formatea la salida
// - Producción: undefined → Pino emite JSON puro por
//   stdout, ideal para ingestión por servicios cloud
// ======================================================
const transport = env.NODE_ENV === 'development'
  ? { target: 'pino-pretty', options: { colorize: true, translateTime: 'HH:MM:ss.l' } }
  : undefined;

export const logger = pino({
  level: env.LOG_LEVEL,
  transport,
});
