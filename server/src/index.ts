// ======================================================
// Archivo: server/src/index.ts
// Responsabilidad: Punto de entrada del servidor Node.js
// Qué hace: Construye la aplicación Fastify con toda su
//   configuración y la pone a escuchar en el puerto
//   indicado en las variables de entorno
// Quién lo utiliza: Node.js runtime (es el entry point
//   definido en package.json)
// Cuándo se ejecuta: Cada vez que se inicia el servidor
//   con "npm start", "pnpm dev" o "node dist/index.js"
//
// Flujo dentro de la aplicación:
//   1. El runtime de Node.js ejecuta este archivo
//   2. Se importan buildApp (la fábrica de Fastify),
//      env (config validada) y logger (Pino)
//   3. main() construye la app con buildApp()
//   4. app.listen() pone el servidor a escuchar
//   5. El servidor queda esperando peticiones HTTP
//
// Conceptos utilizados:
//   - Entry point: archivo que Node.js ejecuta primero.
//     Todo arranca desde aquí
//   - async/await: palabras clave para operaciones
//     asíncronas. await pausa la ejecución hasta que
//     la Promesa se resuelve
//   - process.exit(1): termina el proceso Node.js con
//     código de error 1 (indica fallo al sistema
//     operativo o al orquestador)
//   - Logger estructurado: en lugar de console.log,
//     usamos Pino que genera JSON para mejores búsquedas
// ======================================================

import { buildApp } from './app';
import { env } from './config/env';
import { logger } from './config/logger';

// ======================================================
// Función: main
// Recibe: nada (lee env.PORT de las variables de entorno)
// Devuelve: Promise<void> (una Promesa que se resuelve
//   cuando el servidor se detiene o falla)
// Quién la llama: la última línea del archivo: main()
// Cuándo se ejecuta: inmediatamente al arrancar Node.js
//
// Paso 1. Construir la aplicación Fastify (app.ts)
// Paso 2. Iniciar el servidor HTTP en el puerto
// Paso 3. Si hay error, registrar y terminar el proceso
// ======================================================
async function main() {
  logger.info({
    nodeEnv: env.NODE_ENV,
    port: env.PORT,
  }, 'Iniciando VibeShopping API...');

  // Paso 1: Construir la app (CORS, rate limit, rutas, etc.)
  const app = await buildApp();

  try {
    // Paso 2: Iniciar servidor
    // host '0.0.0.0' permite conexiones desde cualquier
    // dispositivo en la red local (celular en desarrollo)
    await app.listen({
      port: env.PORT,
      host: '0.0.0.0',
    });

    logger.info(`Servidor escuchando en http://localhost:${env.PORT}`);
  } catch (error) {
    // Paso 3: Si falla el inicio, registrar y salir
    logger.error({ error }, 'Error al iniciar el servidor');
    process.exit(1);
  }
}

main();
