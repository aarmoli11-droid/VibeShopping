-- =============================================================
-- Migration: 20260711_fix_category_ids
-- Propósito: Corregir acentos en db_category_ids de Panadería
--   y Lácteos, y eliminar cat_huevos (no existe en
--   v_products_complete ni en product_master).
--
-- Contexto:
--   Los valores db_category_ids insertados tenían los acentos
--   incorrectos respecto a los category_id reales en las tablas
--   product_master / v_products_complete:
--
--     cat_panaderia → cat_panadería  (falta acento en la i)
--     cat_lacteos   → cat_lácteos    (falta acento en la a)
--     cat_huevos    → (eliminado)    (0 registros en toda la DB)
--
-- Idempotente:
--   • UPDATE con WHERE id = ? solo afecta si la fila existe.
--   • Se puede ejecutar N veces sin cambiar el resultado.
-- =============================================================

-- =============================================================
-- Panadería: cat_panaderia → cat_panadería
-- =============================================================
UPDATE categories
SET db_category_ids = '{cat_panadería}',
    updated_at = NOW()
WHERE id = 'panaderia';

-- =============================================================
-- Lácteos: {cat_lacteos,cat_huevos} → {cat_lácteos}
-- =============================================================
UPDATE categories
SET db_category_ids = '{cat_lácteos}',
    updated_at = NOW()
WHERE id = 'lacteos';

-- =============================================================
-- Verificación
-- =============================================================
SELECT
  '20260711_fix_category_ids' AS migracion,
  id,
  name,
  db_category_ids
FROM categories
WHERE id IN ('panaderia', 'lacteos')
ORDER BY display_order;
