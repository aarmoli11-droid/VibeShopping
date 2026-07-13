// ======================================================
// Archivo: server/src/types/index.ts
// Responsabilidad: Definir tipos compartidos de TypeScript
// Qué hace: Declara la interfaz AuthenticatedUser y
//   extiende FastifyRequest para que TypeScript sepa
//   que request.user existe después de authMiddleware
// Quién lo utiliza: Todos los archivos de rutas que
//   leen request.user, y el middleware de autenticación
//   que lo escribe
// Cuándo se ejecuta: Solo en tiempo de compilación
//   (TypeScript). No genera código JavaScript
//
// Flujo dentro de la aplicación:
//   (compile-time) auth.ts escribe request.user
//     → types/index.ts declara la interfaz
//     → rutas leen request.user con tipos seguros
//
// Conceptos utilizados:
//   - TypeScript interfaces: definen la forma de un
//     objeto. No existen en JS, solo en TypeScript
//   - declare module 'fastify': module augmentation,
//     una característica de TypeScript que permite
//     añadir propiedades a tipos de terceros sin
//     modificar la librería original
//   - FastifyRequest: tipo que representa la petición
//     HTTP entrante. Al extenderlo, todas las rutas
//     tienen acceso a request.user tipado
// ======================================================

// ======================================================
// Interfaz: AuthenticatedUser
// Representa: Un usuario que ya pasó la autenticación
// Cuándo se crea: En el middleware auth.ts después de
//   validar el token JWT contra Supabase
// Problema que resuelve: Tipar correctamente el objeto
//   user que se inyecta en cada Request
// ======================================================
export interface AuthenticatedUser {
  id: string;
  email: string;
  role?: string;
}

// ======================================================
// Extensión de FastifyRequest
// Esto le dice a TypeScript que todas las peticiones
// tendrán un campo "user" después de pasar por el
// middleware de autenticación
// ======================================================
declare module 'fastify' {
  interface FastifyRequest {
    user: AuthenticatedUser;
  }
}
