-- =============================================================
-- Paso 2: Poblar product_master
-- =============================================================
-- Idempotente: se puede ejecutar múltiples veces.
-- ON CONFLICT DO UPDATE permite sincronizar cambios futuros.
-- No modifica products. No crea FKs. No elimina registros.
-- =============================================================

-- =============================================================
-- AUDITORÍA PREVIA
-- =============================================================
-- 2a. Resumen general de products
SELECT
  COUNT(*)::INTEGER AS total_registros_products,
  COUNT(DISTINCT master_product_id)::INTEGER AS master_ids_distintos,
  COUNT(*) FILTER (WHERE master_product_id IS NULL)::INTEGER AS con_master_id_null,
  (COUNT(*) - COUNT(DISTINCT master_product_id))::INTEGER AS ids_repetidos
FROM products;

-- 2b. Detalle por master_product_id (ordenado por tiendas descendente)
SELECT
  p.master_product_id,
  p.name AS canonical_name,
  p.category_id,
  p.subcategory,
  p.image_url,
  COUNT(DISTINCT p.supermarket_id)::INTEGER AS cantidad_supermercados
FROM products p
WHERE p.master_product_id IS NOT NULL
GROUP BY
  p.master_product_id,
  p.name,
  p.category_id,
  p.subcategory,
  p.image_url
ORDER BY cantidad_supermercados DESC;

-- =============================================================
-- INSERT: poblar product_master
-- =============================================================
INSERT INTO product_master (id, canonical_name, brand, category_id, subcategory, image_url, created_at)
SELECT DISTINCT ON (p.master_product_id)
  p.master_product_id,
  p.name         AS canonical_name,
  NULL           AS brand,
  p.category_id,
  p.subcategory,
  p.image_url,
  p.created_at
FROM products p
WHERE p.master_product_id IS NOT NULL
ORDER BY p.master_product_id, p.created_at ASC
ON CONFLICT (id)
DO UPDATE SET
  canonical_name = EXCLUDED.canonical_name,
  category_id = EXCLUDED.category_id,
  subcategory = EXCLUDED.subcategory,
  image_url = EXCLUDED.image_url;

-- =============================================================
-- AUDITORÍA POSTERIOR
-- =============================================================
-- 2c. Verificación de consistencia
SELECT
  'Consistencia post-migración' AS auditoria,
  (SELECT COUNT(*) FILTER (WHERE master_product_id IS NULL)::INTEGER
   FROM products) AS products_con_master_id_null,
  (SELECT COUNT(DISTINCT master_product_id)::INTEGER
   FROM products
   WHERE master_product_id IS NOT NULL) AS master_ids_distintos_en_products,
  (SELECT COUNT(*)::INTEGER
   FROM product_master) AS total_en_product_master;

-- 2d. Calidad de datos en product_master
SELECT
  (SELECT COUNT(*)::INTEGER FROM (
    SELECT id FROM product_master GROUP BY id HAVING COUNT(*) > 1
  ) dup) AS registros_duplicados_en_master,
  (SELECT COUNT(*)::INTEGER
   FROM product_master
   WHERE image_url IS NULL OR image_url = '') AS sin_imagen,
  (SELECT COUNT(*)::INTEGER
   FROM product_master
   WHERE canonical_name IS NULL OR TRIM(canonical_name) = '') AS nombre_vacio;
