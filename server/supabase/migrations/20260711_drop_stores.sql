-- =============================================================
-- Migration: 20260711_drop_stores
-- Fecha: 2026-07-11
-- Propósito: Eliminar la tabla huérfana `stores`.
--
-- Contexto:
--   La tabla `stores` fue creada automáticamente (probablemente
--   por el Starter Kit de Supabase) y nunca fue utilizada.
--   El equipo renombró el concepto a `supermarkets` pero olvidó
--   eliminar `stores`.
--
-- Verificación de cero referencias:
--   - Flutter:  0 ocurrencias de .from('stores')
--   - Node.js:  0 ocurrencias de .from('stores')
--   - Views:    v_products_complete no usa stores
--   - SQL:      0 migraciones mencionan stores
--   - Triggers: 0 (no existen triggers en el proyecto)
--   - Policies: 0 (RLS no está habilitado en ninguna tabla)
--   - Datos:    Vacía (0 filas)
--
-- Idempotente: DROP TABLE IF EXISTS no falla si la tabla
--   ya fue eliminada.
-- =============================================================

DROP TABLE IF EXISTS stores;

-- =============================================================
-- Verificación
-- =============================================================
SELECT
  '20260711_drop_stores' AS migracion,
  'stores' AS tabla_eliminada,
  NOW()::TEXT AS fecha;
