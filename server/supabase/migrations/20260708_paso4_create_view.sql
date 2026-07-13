-- =============================================================
-- Paso 4: FK definitiva + vista v_products_complete
-- =============================================================
-- Prerrequisitos: Paso 1-3 ejecutados. product_master poblado.
--
-- Este script:
--   1. Verifica que no haya huérfanos antes de crear la FK
--   2. Crea FK products.master_product_id → product_master.id
--   3. Crea índice en products.master_product_id
--   4. Crea la vista v_products_complete (fuente oficial única)
--   5. Auditoría final de consistencia
--
-- Idempotente: puede ejecutarse múltiples veces sin errores.
-- =============================================================

-- =============================================================
-- BLOQUE 1: Verificación de huérfanos
-- =============================================================
-- Antes de crear la FK, confirmamos que todos los registros
-- de products con master_product_id tengan un padre válido
-- en product_master. Si hay huérfanos, el script se detiene.
-- =============================================================
DO $$
DECLARE
  orphan_count INTEGER;
  total_count  INTEGER;
BEGIN
  SELECT COUNT(*) INTO orphan_count
  FROM products p
  WHERE p.master_product_id IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM product_master pm WHERE pm.id = p.master_product_id
    );

  SELECT COUNT(*) INTO total_count
  FROM products
  WHERE master_product_id IS NOT NULL;

  RAISE NOTICE 'Productos con master_product_id: %', total_count;
  RAISE NOTICE 'Huérfanos encontrados: %', orphan_count;

  IF orphan_count > 0 THEN
    RAISE EXCEPTION 'ABORTANDO: % productos huérfanos sin padre en product_master. Corrección manual requerida.', orphan_count;
  ELSE
    RAISE NOTICE 'OK: 0 huérfanos. Se procederá con la FK.';
  END IF;
END $$;

-- =============================================================
-- BLOQUE 2: FK definitiva
-- =============================================================
-- products.master_product_id → product_master.id
-- ON DELETE SET NULL: si se elimina un producto maestro, los
-- productos asociados quedan sin referencia pero no se borran.
-- =============================================================
ALTER TABLE products DROP CONSTRAINT IF EXISTS fk_products_master;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_master_product_id_fkey;

ALTER TABLE products
  ADD CONSTRAINT fk_products_master
    FOREIGN KEY (master_product_id)
    REFERENCES product_master(id)
    ON DELETE SET NULL;

-- Índice de apoyo para JOINs y búsquedas por producto maestro
CREATE INDEX IF NOT EXISTS idx_products_master_product_id
  ON products(master_product_id);

-- =============================================================
-- BLOQUE 3: Vista v_products_complete
-- =============================================================
-- Propósito: Fuente oficial única para todas las consultas
-- de productos desde Flutter y el servidor Node.js.
--
-- Reemplaza los JOINs manuales que antes hacía cada capa:
--   select('*, product_master(*), supermarkets(*)')
--
-- Ventajas:
--   • Un solo punto de definición de esquema
--   • Estructura plana (sin anidamiento) = parseo más simple
--   • Agregar columnas futuras no requiere cambios en código
--   • La app nunca más necesita conocer la estructura interna
--     de products/product_master/supermarkets
--
-- Cómo extenderla en futuras fases:
--   Simplemente agregar nuevas columnas en el SELECT dentro
--   del bloque correspondiente. No requiere migrar Flutter.
--   Ejemplos preparados abajo como comentarios.
-- =============================================================
CREATE OR REPLACE VIEW v_products_complete AS
SELECT
  -- ==========================================================
  -- IDENTIDAD
  -- ==========================================================
  p.id               AS product_id,
  pm.id              AS master_product_id,

  -- ==========================================================
  -- PRODUCTO MAESTRO (product_master)
  -- ==========================================================
  pm.canonical_name,
  pm.brand,
  pm.category_id,
  pm.subcategory,
  pm.image_url,

  -- FUTURO: agregar aquí columnas de product_master
  -- , pm.rating              → calificación del producto
  -- , pm.description         → descripción larga
  -- , pm.thumbnail_url       → miniatura adicional

  -- ==========================================================
  -- PRODUCTO POR SUPERMERCADO (products)
  -- ==========================================================
  p.price,

  -- FUTURO: agregar aquí columnas de products
  -- , p.currency              → moneda (ej: CRC, USD) — columna
  --                             no existe actualmente en la tabla
  -- , p.promotion_price       → precio promocional
  -- , p.stock                 → inventario disponible
  -- , p.aisle                 → pasillo / ubicación en tienda
  -- , p.discount_percentage   → porcentaje de descuento

  -- ==========================================================
  -- SUPERMERCADO (supermarkets)
  -- ==========================================================
  p.supermarket_id,
  s.name             AS supermarket_name,
  s.logo_url         AS supermarket_logo_url,
  s.latitude         AS supermarket_latitude,
  s.longitude        AS supermarket_longitude,

  -- ==========================================================
  -- METADATOS
  -- ==========================================================
  pm.created_at      AS master_created_at,
  p.created_at       AS product_created_at,

  -- LLAVE COMPUESTA
  -- store_product_key: identificador único por combinación
  -- producto-maestro + supermercado. Utilizada para:
  --   • caché local (Hive)
  --   • comparación de precios
  --   • promociones y descuentos
  --   • favoritos del usuario
  --   • historial de precios
  --   • rutas inteligentes
  --   • entrenamiento de IA
  -- Al construirla en la VIEW, evitamos reconstruirla en
  -- Flutter cada vez que se necesita.
  -- Formato: "master_product_id|supermarket_id"
  pm.id || '|' || p.supermarket_id AS store_product_key

  -- FUTURO: agregar aquí metadatos adicionales
  -- , p.updated_at            → última modificación del precio

FROM products p
LEFT JOIN product_master pm ON pm.id = p.master_product_id
LEFT JOIN supermarkets s   ON s.id   = p.supermarket_id;

-- Nota sobre LEFT JOIN:
--   Usamos LEFT JOIN para garantizar que productos sin
--   master_product_id (incompletos) sigan apareciendo.
--   En el estado actual no hay ninguno, pero la vista
--   debe ser tolerante a datos imperfectos.

-- =============================================================
-- BLOQUE 4: Auditoría final
-- =============================================================
-- Verifica la integridad y completitud de la vista.
-- =============================================================
SELECT
  'Auditoría v_products_complete' AS auditoria,
  (SELECT COUNT(*)::INTEGER FROM v_products_complete) AS total_registros,
  (SELECT COUNT(DISTINCT supermarket_id)::INTEGER FROM v_products_complete) AS supermercados_distintos,
  (SELECT COUNT(DISTINCT master_product_id)::INTEGER FROM v_products_complete) AS productos_maestros_distintos,
  (SELECT COUNT(*)::INTEGER FROM v_products_complete WHERE canonical_name IS NULL OR TRIM(canonical_name) = '') AS canonical_name_vacio,
  (SELECT COUNT(*)::INTEGER FROM v_products_complete WHERE supermarket_name IS NULL OR TRIM(supermarket_name) = '') AS supermarket_name_vacio;
