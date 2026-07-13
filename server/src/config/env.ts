// ======================================================
// Archivo: server/src/config/env.ts
// Responsabilidad: Cargar y validar variables de entorno
// Qué hace: Ejecuta dotenv para cargar .env, define un
//   esquema Zod con tipos, valores por defecto y
//   mensajes de error, y exporta un objeto tipado
// Quién lo utiliza: Todos los archivos del servidor que
//   necesiten configuración (app.ts, logger.ts, etc.)
// Cuándo se ejecuta: En el momento del import, antes de
//   que cualquier otro código se ejecute. Si falta una
//   variable, la app falla inmediatamente
//
// Flujo dentro de la aplicación:
//   Node.js arranca → import env from './config/env'
//     → dotenv carga .env → Zod valida process.env
//     → env exportado como objeto tipado
//
// Conceptos utilizados:
//   - dotenv: librería que lee el archivo .env y lo
//     fusiona con process.env
//   - Zod: librería de validación de esquemas. Define
//     la forma y tipo que deben tener los datos
//   - safeParse(): valida sin lanzar excepción. Devuelve
//     un objeto con success: true/false
//   - parse(): valida y lanza excepción si falla (no lo
//     usamos aquí porque preferimos mostrar errores
//     legibles)
//   - z.coerce.number(): convierte strings a número
//     automáticamente (process.env siempre devuelve
//     strings)
// ======================================================

import 'dotenv/config';
import { z } from 'zod';

// ======================================================
// Esquema de validación con Zod
// Cada variable de entorno tiene:
//   - Tipo esperado (number, string, enum)
//   - Valor por defecto (si aplica)
//   - Mensaje de error personalizado (si aplica)
//
// Zod ejecuta esta validación en el momento del import,
// es decir, antes de que cualquier otro código se ejecute
// ======================================================
const envSchema = z.object({
  PORT: z.coerce.number().default(3001),
  SUPABASE_URL: z.string().url('SUPABASE_URL debe ser una URL válida'),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1, 'SUPABASE_SERVICE_ROLE_KEY es obligatoria'),
  GEMINI_API_KEY: z.string().min(1, 'GEMINI_API_KEY es obligatoria para el asistente IA'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
});

// ======================================================
// safeParse vs parse:
// Usamos safeParse para poder mostrar un error claro
// con todas las variables que fallaron, en lugar de
// dejar que Zod lance una excepción genérica
// ======================================================
// ======================================================
// Validación al arrancar
// safeParse devuelve { success: true, data } o
// { success: false, error }. A diferencia de parse(),
// no lanza excepción — podemos controlar el error.
// Si falla, mostramos qué variables fallaron y
// terminamos con código de error 1
// ======================================================
const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Variables de entorno inválidas:', parsed.error.flatten().fieldErrors);
  process.exit(1);
}

// ======================================================
// Exportación del objeto de configuración
// env es un objeto con tipos infieridos del esquema.
// Cualquier archivo que importe env obtiene
// autocompletado y chequeo de tipos en tiempo real
// ======================================================
export const env = parsed.data;
