# Auditoría de Seguridad Supabase

## Resumen

Sin cambios realizados en Flutter, Node.js ni migraciones. Solo análisis.

---

## 1. Riesgos Reales

### 1.1. RLS deshabilitado en todas las tablas
| Tabla | RLS | Políticas |
|---|---|---|
| `product_master` | ❌ No | 0 |
| `products` | ❌ No | 0 |
| `supermarkets` | ❌ No | 0 |
| `stores` (obsoleta) | ❌ No | 0 |

**Impacto real para MVP:** Bajo.

Todas las tablas contienen datos públicos de catálogo (precios de supermercado, nombres, URLs de imágenes). No hay PII, credenciales, datos de usuarios ni información financiera sensible. El modelo de negocio es comparable a un volante de ofertas público.

**Consumidores:**
- Flutter (anon key): `supabase.from('v_products_complete').select('*')` y `supabase.from('supermarkets').select('*')`
- Node.js (service_role key): `supabase.from('v_products_complete').select('*')`

**Recomendación:** No implementar RLS en esta fase. Si en el futuro se agregan tablas con datos de usuarios (listas de compras, favoritos, historial), esas tablas DEBEN tener RLS obligatorio.

### 1.2. No existe `config.toml` para Supabase CLI
No hay archivo `server/supabase/config.toml`. El proyecto no está vinculado a Supabase CLI. Las migraciones existen como scripts SQL independientes.

**Impacto:** Las migraciones no pueden ejecutarse automáticamente con `supabase db push`. Deben ejecutarse manualmente en el SQL Editor del dashboard.

**Recomendación:** Para la próxima fase de infraestructura, crear `config.toml` y migrar a `supabase migration` workflow.

---

## 2. Warnings que pueden ignorarse

### 2.1. `v_products_complete` sin SECURITY DEFINER

**Estado actual:** La vista se crea con `CREATE OR REPLACE VIEW v_products_complete AS ...` — sin cláusula SECURITY. PostgreSQL usa `SECURITY INVOKER` por defecto.

**Análisis:**
- `SECURITY INVOKER`: las consultas a la vista verifican permisos del **usuario que ejecuta la consulta** (anon key o service_role).
- `SECURITY DEFINER`: las consultas a la vista usan permisos del **creador de la vista** (dueño de la tabla).

**¿Debe cambiarse a SECURITY DEFINER?** No.
- Flutter (anon key) necesita leer `v_products_complete`. Con INVOKER, la anon key requiere permisos SELECT en `products`, `product_master` y `supermarkets` (las tablas base). Como RLS está deshabilitado, la anon key ya tiene estos permisos (GRANT por defecto en tablas públicas).
- Node.js (service_role) bypassa RLS de todos modos.
- **No hay beneficio de seguridad** en cambiar a DEFINER. El diseño actual es correcto.

**Veredicto:** ✅ Mantener como está. SECURITY INVOKER es la opción correcta para este caso de uso.

### 2.2. `supabase_explorer_repository.dart` usa `SELECT *` sin columnas explícitas
```dart
await _supabase.from('supermarkets').select('*').order('name');
```
No es un riesgo de seguridad, pero es mala práctica para producción (puede devolver columnas innecesarias). Aceptable para MVP.

### 2.3. Service Role Key expuesta en servidor Node.js
```typescript
const client = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, ...);
```
Esto es **correcto por diseño**: la service_role key está en `.env` (gitignored) y solo se usa en el servidor Node.js, nunca en Flutter. El servidor Node.js tiene su propia autenticación vía middleware JWT.

---

## 3. Objetos Obsoletos

### 3.1. Migración duplicada: `20260708_populate_product_master.sql`

**Problema:** Este archivo es funcionalmente idéntico a la combinación de:
- `20260708_paso1_create_product_master.sql` (crea tabla + columnas + índices)
- `20260708_paso2_populate_product_master.sql` (inserta datos)

Fue creado como versión "todo-en-uno" pero nunca se eliminó cuando se adoptó el enfoque paso a paso. Es idempotente (IF NOT EXISTS), así que no causa errores, pero genera confusión.

**Archivo:** `server/supabase/migrations/20260708_populate_product_master.sql`

**Recomendación:** Eliminar en una migración de limpieza futura. Etiquetar como `LEGACY`.

### 3.2. Edge Function `asistente-compras`

**Problema:** El código Flutter (`assistant_service.dart:96-97`) invoca la Edge Function `asistente-compras` mediante `_supabase.functions.invoke()`. Sin embargo, el repositorio no contiene el código fuente de esta Edge Function (no hay `supabase/functions/` directory, no hay `config.toml`).

**Esto es un riesgo operativo:** si la Edge Function se elimina o modifica en el dashboard de Supabase, el asistente IA dejará de funcionar en modo legacy.

**Impacto:** Bajo, porque la feature flag `USE_NODE_ASSISTANT=true` en el `.env` de Flutter redirige al backend Node.js, que está bajo control del repositorio.

**Recomendación:** Documentar que la Edge Function `asistente-compras` es externa al repositorio. No eliminar el código legacy hasta que `USE_NODE_ASSISTANT` esté habilitado en producción.

---

## 4. Tablas Candidatas a Eliminar

### 4.1. `stores` (vacía, sin referencias)

| Aspecto | Resultado |
|---|---|
| ¿Creada en migración? | ❌ No. No hay `CREATE TABLE stores` en ninguna migración. |
| ¿Referenciada en Flutter? | ❌ No. Cero ocurrencias de `.from('stores')`. |
| ¿Referenciada en Node.js? | ❌ No. Cero ocurrencias de `.from('stores')`. |
| ¿Referenciada en VIEW? | ❌ No. `v_products_complete` no usa `stores`. |
| ¿Referenciada en migraciones? | ❌ No. Ninguna migración menciona `stores`. |
| ¿Contiene datos? | ❌ Vacía (tabla creada posiblemente por error al configurar Supabase). |

**Posible origen:** Supabase Starter Kits a veces crean una tabla `stores` por defecto. El equipo probablemente la renombró a `supermarkets` pero olvidó eliminar `stores`.

**Recomendación:** Marcar como candidata a eliminación. Crear migración `DROP TABLE IF EXISTS stores;` en la próxima fase de limpieza.

---

## 5. Buckets Candidatos a Eliminar

**No existen buckets de Storage.** Cero referencias a Supabase Storage en Flutter, Node.js o migraciones. `@supabase/storage-js` es solo una dependencia transitiva de `@supabase/supabase-js`.

Si el dashboard de Supabase muestra buckets (ej: `logos`, `imagenes`, `assets`), fueron creados manualmente y no son utilizados por el código. Pueden eliminarse.

| Bucket | Referencias en código | Estado |
|---|---|---|
| Ninguno | 0 | Sin buckets requeridos |

---

## 6. Políticas RLS que Deben Corregirse

No existen políticas RLS. No hay nada que corregir.

Si en el futuro se agregan:
- Tabla `user_shopping_lists` → RLS obligatorio por `user_id`
- Tabla `user_favorites` → RLS obligatorio por `user_id`
- Tabla `user_history` → RLS obligatorio por `user_id`

---

## 7. Objetos que Deben Mantenerse Exactamente como Están

| Objeto | Motivo |
|---|---|
| `v_products_complete` (SECURITY INVOKER) | Diseño correcto. No cambiar. |
| `products` (sin RLS) | Datos públicos de catálogo. |
| `product_master` (sin RLS) | Datos públicos de catálogo. |
| `supermarkets` (sin RLS) | Datos públicos de catálogo. |
| `fk_products_master` | Integridad referencial. |
| `uq_products_master_supermarket` | Previene duplicados. |
| `idx_products_master_product_id` | Optimiza JOINs. |

---

## 8. Orden Recomendado para Aplicar Correcciones

1. **Crear migración de limpieza** (`20260710_cleanup.sql`):
   - `DROP TABLE IF EXISTS stores;`
   - Marcar `20260708_populate_product_master.sql` como LEGACY (comentario o renombrar).

2. **Configurar Supabase CLI** (futuro):
   - Crear `server/supabase/config.toml`
   - Vincular proyecto remoto
   - Migrar a `supabase db push`

3. **Implementar RLS** (cuando existan tablas de usuario).

4. **Eliminar Edge Function legacy** (cuando `USE_NODE_ASSISTANT=true` esté en producción).

---

## 9. Verificación

```
flutter analyze lib/  → sin modificaciones en Flutter
npx tsc --noEmit     → sin modificaciones en Node.js
Ninguna migración nueva creada.
Solo documentación y análisis.
```
