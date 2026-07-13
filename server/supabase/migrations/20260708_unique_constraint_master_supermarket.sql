-- =============================================================
-- Integridad: UNIQUE CONSTRAINT sobre
--   (master_product_id, supermarket_id)
-- =============================================================
-- Objetivo: Impedir que vuelva a insertarse más de un producto
-- con la misma combinación master_product_id + supermarket_id.
--
-- Prerrequisito: Corrección de duplicado ejecutada.
-- =============================================================

-- =============================================================
-- 1. Verificación previa: confirmar 0 duplicados
-- =============================================================
SELECT
  'Verificación previa' AS paso,
  COUNT(*)::INTEGER AS duplicados_existentes
FROM (
  SELECT master_product_id, supermarket_id
  FROM products
  WHERE master_product_id IS NOT NULL
  GROUP BY master_product_id, supermarket_id
  HAVING COUNT(*) > 1
) dup;

-- =============================================================
-- 2. Crear UNIQUE CONSTRAINT
-- =============================================================
-- Decisión técnica: UNIQUE CONSTRAINT vs UNIQUE INDEX
--
-- UNIQUE CONSTRAINT es la opción correcta aquí porque:
--   • Es SQL estándar (portable entre motores de base de datos)
--   • Aparece en information_schema.table_constraints como
--     documentación auto-gestionada del esquema
--   • PostgreSQL la implementa internamente como un índice
--     único (mismo rendimiento que UNIQUE INDEX)
--   • No necesitamos cláusula WHERE parcial ni INCLUDE columns
--
-- UNIQUE INDEX sería preferible solo si necesitáramos:
--   • Uniqueness parcial (solo para ciertos valores)
--   • Índice con INCLUDE (columnas adicionales para index-only scans)
--   Ninguno de estos casos aplica aquí.
-- =============================================================

-- Limpiar constraint previo con el mismo nombre (idempotencia)
ALTER TABLE products DROP CONSTRAINT IF EXISTS uq_products_master_supermarket;

-- Crear la constraint
ALTER TABLE products
  ADD CONSTRAINT uq_products_master_supermarket
    UNIQUE (master_product_id, supermarket_id);

-- Nota sobre NULL:
--   PostgreSQL trata NULL como "distinto de cualquier otro NULL"
--   en unique constraints. Esto significa que múltiples productos
--   con master_product_id = NULL y el mismo supermarket_id
--   pueden coexistir. Es el comportamiento correcto: productos
--   sin asignación maestra son casos incompletos y temporales.

-- =============================================================
-- 3. Auditoría final
-- =============================================================
SELECT
  'Auditoría final' AS paso;

-- 3a. Constraints existentes en products
SELECT
  constraint_name,
  constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'products'
ORDER BY constraint_type, constraint_name;

-- 3b. Índices existentes en products
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'products'
ORDER BY indexname;

-- 3c. Confirmación de que ya no es posible insertar duplicados
SELECT
  'Protección activa' AS estado,
  'La UNIQUE CONSTRAINT uq_products_master_supermarket impide
   insertar dos productos con el mismo master_product_id
   y supermarket_id. Cualquier intento generará:
   ERROR: duplicate key value violates unique constraint.' AS descripcion;
