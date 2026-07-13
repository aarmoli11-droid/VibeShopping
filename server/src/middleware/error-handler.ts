// ======================================================
// Archivo: server/src/middleware/error-handler.ts
// Responsabilidad: Capturar errores no manejados y
//   devolver respuestas consistentes
// Qué hace: Clasifica cualquier error no capturado en
//   4 tipos (ZodError, validación Fastify, rate limit,
//   error inesperado) y responde siempre con el mismo
//   formato JSON: { success, code, message }
// Quién lo utiliza: app.ts (app.setErrorHandler)
// Cuándo se ejecuta: Cuando cualquier ruta lanza una
//   excepción no capturada. Es el último filtro antes
//   de que Fastify devuelva un error 500 genérico
//
// Flujo dentro de la aplicación:
//   Ruta → excepción → Fastify → globalErrorHandler
//     → clasifica el error → reply.status().send()
//
// Conceptos utilizados:
//   - Error handler global: en lugar de try/catch en
//     cada ruta, un solo handler captura todo. DRY
//   - ZodError: error de validación de Zod. Se detecta
//     con instanceof ZodError
//   - statusCode HTTP: 400 (bad request), 429 (too many
//     requests), 500 (internal server error)
//   - instanceof: operador de JS que verifica si un
//     objeto pertenece a una clase específica
// ======================================================

import { FastifyError, FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { env } from '../config/env';

// ======================================================
// Función: globalErrorHandler
// Recibe: El error original, el request y el reply
// Devuelve: void (envía la respuesta al cliente)
// Cuándo se ejecuta: Cuando cualquier ruta lanza una
//   excepción o cuando Fastify detecta un error de
//   validación automática
// Quién lo llama: Fastify internamente
//
// Diferencia 4 tipos de error para dar la respuesta
// adecuada en cada caso
// ======================================================
export function globalErrorHandler(
  error: FastifyError | Error,
  request: FastifyRequest,
  reply: FastifyReply
): void {
  // ======================================================
  // Tipo 1: Error de validación Zod (400)
  // Ocurre cuando el cliente envía datos con formato
  // incorrecto. Por ejemplo, un UUID inválido o un
  // campo requerido faltante
  // ======================================================
  if (error instanceof ZodError) {
    request.log.warn({ errors: error.errors }, 'Error de validación Zod');
    reply.status(400).send({
      success: false,
      code: 'VALIDATION_ERROR',
      message: 'Datos de entrada inválidos',
    });
    return;
  }

  // ======================================================
  // Tipo 2: Error de validación Fastify (400)
  // Fastify también valida schemas automáticamente.
  // Este error ocurre si hay validación configurada
  // en el schema de la ruta (no usamos esto mucho,
  // preferimos Zod explícito)
  // ======================================================
  if ('validation' in error && error.validation) {
    request.log.warn({ validation: error.validation }, 'Error de validación Fastify');
    reply.status(400).send({
      success: false,
      code: 'VALIDATION_ERROR',
      message: 'Datos de entrada inválidos',
    });
    return;
  }

  // ======================================================
  // Tipo 3: Error de rate-limit (429)
  // @fastify/rate-limit lanza un error con statusCode 429
  // cuando el cliente excede el límite de peticiones
  // ======================================================
  if ('statusCode' in error && error.statusCode === 429) {
    reply.status(429).send({
      success: false,
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Demasiadas solicitudes. Intenta de nuevo más tarde.',
    });
    return;
  }

  // ======================================================
  // Tipo 4: Error inesperado (500)
  // Log completo con detalles, pero respuesta genérica.
  // En producción NO exponemos el mensaje real del error
  // para evitar filtrar información sensible
  // ======================================================
  request.log.error({ error, url: request.url, method: request.method }, 'Error interno del servidor');

  const statusCode = 'statusCode' in error && typeof error.statusCode === 'number'
    ? error.statusCode
    : 500;

  reply.status(statusCode).send({
    success: false,
    code: 'INTERNAL_ERROR',
    message: env.NODE_ENV === 'production'
      ? 'Error interno del servidor'
      : error.message,
  });
}
