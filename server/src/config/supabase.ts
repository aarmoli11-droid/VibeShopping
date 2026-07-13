// ======================================================
// Archivo: server/src/config/supabase.ts
// Responsabilidad: Crear y exportar el cliente de Supabase
//   con permisos de administrador (service_role)
// Qué hace: Inicializa un cliente Supabase usando la
//   service_role key, que tiene permisos para saltarse
//   las políticas RLS de la base de datos
// Quién lo utiliza: Todos los archivos de rutas que
//   necesitan leer o escribir en Supabase (products,
//   assistant)
// Cuándo se ejecuta: En el momento del import, una sola
//   vez. El cliente se cachea y reutiliza globalmente
//
// Flujo dentro de la aplicación:
//   env.ts → supabase.ts → createClient(URL, service_key)
//     → export supabase → rutas lo usan para queries
//
// Conceptos utilizados:
//   - Supabase: backend como servicio que combina
//     PostgreSQL, Auth, Storage y Edge Functions
//   - Service Role Key: clave de administrador. BYPASEA
//     las Row Level Security (RLS) policies. Nunca debe
//     exponerse al frontend
//   - Anon Key: clave pública del frontend. respeta RLS
//   - RLS (Row Level Security): políticas de seguridad
//     a nivel de fila en PostgreSQL
//   - Cliente Singleton: el cliente se crea una vez y se
//     reutiliza. Evita abrir múltiples conexiones
// ======================================================

import { createClient } from '@supabase/supabase-js';
import { env } from './env';
import { logger } from './logger';

// ======================================================
// ADVERTENCIA: Service Role Key
// ------------------------------------------------
// Usamos la service_role key (NO la anon key) porque
// este backend es de confianza y necesita saltarse
// las Row Level Security (RLS) policies de Supabase.
//
// ! Este cliente NUNCA debe exponerse al frontend.
//
// El frontend (Flutter) usa la anon key directamente
// contra Supabase con RLS. El backend usa service_role
// porque opera con sus propios controles de acceso
// (middleware JWT).
// ======================================================

// ======================================================
// Función: createSupabaseClient
// Recibe: nada (lee env.SUPABASE_URL y
//   env.SUPABASE_SERVICE_ROLE_KEY)
// Devuelve: SupabaseClient — el cliente listo para
//   hacer consultas a la base de datos
// Quién la llama: La última línea del archivo
//   (export const supabase = ...)
// Cuándo se ejecuta: Una vez al importar el módulo
//
// Paso 1. Crear el cliente con URL + service_role key
// Paso 2. Configurar auth: sin refresco automático ni
//         persistencia de sesión (el backend es stateless)
// Paso 3. Exportar e reutilizar el cliente
// ======================================================
function createSupabaseClient() {
  logger.info('Inicializando cliente Supabase (service_role)...');

  // Crear cliente con permisos de administrador
  const client = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
      // El backend es stateless — no necesita refrescar
      // sesiones ni persistir tokens en disco
      autoRefreshToken: false,
      persistSession: false,
    },
  });

  logger.info('Cliente Supabase listo');
  return client;
}

export const supabase = createSupabaseClient();
