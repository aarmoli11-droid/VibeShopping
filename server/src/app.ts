// ======================================================
// Archivo: server/src/app.ts
// Responsabilidad: Crear y configurar la aplicación
//   Fastify (el servidor web)
// Qué hace: Crea una instancia de Fastify con logger,
//   CORS, rate limiting, manejador de errores global
//   y registra todas las rutas de la API
// Quién lo utiliza: index.ts (main)
// Cuándo se ejecuta: Una vez al iniciar el servidor
//
// Flujo dentro de la aplicación:
//   index.ts → buildApp() → Fastify({logger, genReqId})
//     → cors → rateLimit → setErrorHandler
//     → registerRoutes → app lista
//
// Conceptos utilizados:
//   - Fastify: framework HTTP rápido para Node.js,
//     similar a Express pero con validación nativa
//   - CORS: mecanismo que permite al frontend (Flutter)
//     conectarse al backend desde un origen distinto
//   - Rate Limiter: protege contra abusos limitando
//     peticiones por minuto por IP
//   - genReqId: genera un ID único por petición para
//     correlacionar logs entre servicios
//   - Inversión de Dependencias: app.ts crea la app,
//     index.ts la arranca. Separación de responsabilidades
// ======================================================

import Fastify from 'fastify';
import cors from '@fastify/cors';
import rateLimit from '@fastify/rate-limit';
import crypto from 'node:crypto';
import { env } from './config/env';
import { globalErrorHandler } from './middleware/error-handler';
import { registerRoutes } from './routes';

// ======================================================
// Función: buildApp
// Recibe: nada (lee env.NODE_ENV y env.LOG_LEVEL de la
//   configuración validada)
// Devuelve: FastifyInstance (la app configurada y lista)
// Quién la llama: main() en index.ts
// Cuándo se ejecuta: Una vez al arrancar el servidor
//
// Paso 1. Crear instancia Fastify con logger y requestId
// Paso 2. Configurar CORS (orígenes permitidos)
// Paso 3. Configurar rate limiting (protección contra abuso)
// Paso 4. Registrar manejador de errores global
// Paso 5. Registrar todas las rutas de la API
// ======================================================
// 1. Crear instancia de Fastify con logger y requestId
// 2. Configurar CORS (orígenes permitidos)
// 3. Configurar rate limiting (protección contra abuso)
// 4. Registrar manejador de errores global
// 5. Registrar todas las rutas de la API
// ======================================================
export async function buildApp() {
  // ——————————— Paso 1: Crear la instancia de Fastify ———————————
  const app = Fastify({
    logger: {
      level: env.LOG_LEVEL,
      ...(env.NODE_ENV === 'development' && {
        transport: {
          target: 'pino-pretty',
          options: { colorize: true, translateTime: 'HH:MM:ss.l' },
        },
      }),
    },
    // genReqId asigna un ID único a cada petición entrante.
    // Esto permite correlacionar logs de una misma petición
    // a través de todos los servicios
    genReqId: () => crypto.randomUUID(),
    // Timeout global: si una petición tarda más de 30s,
    // Fastify la cancela automáticamente
    requestTimeout: 30_000,
  });

  // ——————————— Paso 2: Configurar CORS ———————————
  // CORS (Cross-Origin Resource Sharing) controla qué
  // orígenes pueden hacer peticiones a este servidor
  await app.register(cors, {
    origin: env.NODE_ENV === 'development'
      ? '*' // En desarrollo permitimos cualquier origen
      : ['https://vibeshopping.app', 'https://www.vibeshopping.app'],
    credentials: true,
  });

  // ——————————— Paso 3: Configurar rate limiting ———————————
  // Límite: 200 peticiones por minuto por IP
  // Esto evita que un solo cliente sature el servidor
  await app.register(rateLimit, {
    max: 200,
    timeWindow: '1 minute',
  });

  // ——————————— Paso 4: Registrar error handler global ———————————
  app.setErrorHandler(globalErrorHandler);

  // ——————————— Paso 5: Registrar rutas ———————————
  await registerRoutes(app);

  return app;
}
