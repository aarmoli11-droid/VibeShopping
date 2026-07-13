// ======================================================
// Archivo: server/src/middleware/auth.ts
// Responsabilidad: Verificar que el usuario está
//   autenticado antes de acceder a rutas protegidas
// Qué hace: Extrae el token JWT del header Authorization,
//   lo valida contra Supabase Auth y, si es válido,
//   inyecta los datos del usuario en request.user
// Quién lo utiliza: assistant.ts
//   (mediante app.addHook('onRequest'))
// Cuándo se ejecuta: Antes de cada petición a rutas
//   protegidas. Fastify ejecuta hooks 'onRequest' en
//   orden, antes de llegar al handler de la ruta
//
// Flujo dentro de la aplicación:
//   Cliente → Petición HTTP → Fastify
//     → authMiddleware (onRequest hook)
//     → Extrae Bearer token → Supabase Auth GET /user
//     → Inyecta request.user → Handler de la ruta
//
// Conceptos utilizados:
//   - JWT (JSON Web Token): estándar para transmitir
//     información de autenticación. El frontend obtiene
//     un JWT al iniciar sesión con Supabase Auth
//   - Bearer Token: esquema de autenticación HTTP donde
//     el token viaja en el header Authorization:
//     "Authorization: Bearer <token>"
//   - Supabase Auth: servicio de autenticación de
//     Supabase. Valida JWTs y devuelve información del
//     usuario
//   - Middleware (hook onRequest): función que Fastify
//     ejecuta antes del handler. Puede modificar el
//     request o rechazar la petición
// ======================================================

import { FastifyReply, FastifyRequest } from 'fastify';
import { supabase } from '../config/supabase';

// ======================================================
// Middleware: authMiddleware
// Recibe: El request y reply de Fastify
// Devuelve: void (llama a reply.send() si hay error)
// Cuándo se ejecuta: Antes de cada ruta protegida
// Quién lo llama: Fastify automáticamente a través
//   del hook 'onRequest'
//
// Flujo:
// 1. Extraer el header Authorization: "Bearer <token>"
// 2. Llamar a Supabase Auth para validar el token
// 3. Si es válido → inyectar request.user
// 4. Si no → responder con 401
// ======================================================
export async function authMiddleware(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  // Paso 1: Verificar que el header Authorization existe
  const authHeader = request.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    reply.status(401).send({
      success: false,
      code: 'UNAUTHORIZED',
      message: 'Token de autenticación no proporcionado',
    });
    return;
  }

  // Paso 2: Extraer el token (después de "Bearer ")
  const token = authHeader.split(' ')[1];

  try {
    // Paso 3: Validar el token contra Supabase Auth
    const { data, error } = await supabase.auth.getUser(token);
    if (error || !data?.user) {
      request.log.warn('Intento de acceso con token inválido');
      reply.status(401).send({
        success: false,
        code: 'INVALID_TOKEN',
        message: 'Token inválido o expirado',
      });
      return;
    }

    // Paso 4: Inyectar usuario autenticado en el request
    request.user = {
      id: data.user.id,
      email: data.user.email ?? '',
      role: data.user.role,
    };
  } catch (error) {
    // Error inesperado (ej: Supabase caído)
    request.log.error({ error }, 'Error al validar token');
    reply.status(500).send({
      success: false,
      code: 'AUTH_ERROR',
      message: 'Error al validar autenticación',
    });
  }
}
