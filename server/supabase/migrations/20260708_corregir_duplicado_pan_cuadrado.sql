-- =============================================================
-- Corrección: eliminar duplicado de Pan Cuadrado 600 g
-- en Super Vida Saludable.
-- =============================================================
-- Contexto: Durante el import inicial se insertaron dos
-- registros idénticos con precios distintos (1900 y 2220).
-- Se conserva el de precio 1.900 por estar más alineado
-- con el promedio del mercado.
--
-- Referencia: acta de auditoría Fase 4.2
-- =============================================================

-- =============================================================
-- 1. Verificación previa
-- =============================================================
SELECT
  'Antes de la corrección' AS estado,
  COUNT(*)::INTEGER        AS registros_en_products,
  (SELECT COUNT(*)::INTEGER FROM v_products_complete) AS registros_en_view
FROM products;

-- =============================================================
-- 2. Eliminar el registro duplicado
-- =============================================================
DELETE FROM products
WHERE id = 'dbb04977-2dc6-4d84-a71d-cbbdf6c576b9';

-- =============================================================
-- 3. Verificación posterior
-- =============================================================
SELECT
  'Después de la corrección' AS estado,
  COUNT(*)::INTEGER          AS registros_en_products,
  (SELECT COUNT(*)::INTEGER  FROM v_products_complete) AS registros_en_view
FROM products;

-- =============================================================
-- 4. Verificar que no queden duplicados
-- =============================================================
SELECT
  COUNT(*)::INTEGER AS grupos_duplicados
FROM (
  SELECT master_product_id, supermarket_id, COUNT(*)
  FROM products
  WHERE master_product_id IS NOT NULL
  GROUP BY master_product_id, supermarket_id
  HAVING COUNT(*) > 1
) dup;
