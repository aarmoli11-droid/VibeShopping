-- =============================================================
-- Paso 1: Crear / verificar estructura de product_master
-- =============================================================
-- Este script solo define la estructura. No modifica datos.
-- No crea restricciones sobre datos existentes.
-- No inserta ni modifica registros.
-- Se puede ejecutar múltiples veces sin efectos secundarios.
-- =============================================================

-- 0. Normalizar: renombrar category → category_id si existe
--    La tabla existente tiene 'category' (legacy), el sistema
--    completo (Flutter, server, products) usa 'category_id'.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'product_master' AND column_name = 'category'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'product_master' AND column_name = 'category_id'
  ) THEN
    ALTER TABLE product_master RENAME COLUMN category TO category_id;
    RAISE NOTICE 'Renombrado: category → category_id';
  ELSE
    RAISE NOTICE 'No se requirió rename (category_id ya existe o category no existe)';
  END IF;
END $$;

-- 1. Crear tabla si no existe
CREATE TABLE IF NOT EXISTS product_master (
  id UUID PRIMARY KEY,
  canonical_name TEXT,
  brand TEXT,
  category_id TEXT,
  subcategory TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Agregar columnas faltantes (seguro si ya existen)
ALTER TABLE product_master ADD COLUMN IF NOT EXISTS canonical_name TEXT;
ALTER TABLE product_master ADD COLUMN IF NOT EXISTS brand TEXT;
ALTER TABLE product_master ADD COLUMN IF NOT EXISTS category_id TEXT;
ALTER TABLE product_master ADD COLUMN IF NOT EXISTS subcategory TEXT;
ALTER TABLE product_master ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE product_master ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- 3. Índices para búsqueda y JOIN
CREATE INDEX IF NOT EXISTS idx_product_master_category ON product_master(category_id);
CREATE INDEX IF NOT EXISTS idx_product_master_canonical_name ON product_master(canonical_name);

-- 4. Documentación del esquema
COMMENT ON TABLE product_master IS
  'Entidad maestra de productos. Un registro por producto canónico (
   sin importar la tienda). products.master_product_id → product_master.id.
   Poblada desde products con DISTINCT ON (master_product_id).';

COMMENT ON COLUMN product_master.id IS
  'UUID del producto maestro. Corresponde a products.master_product_id.
   Se toma del primer registro de cada grupo en products.';

COMMENT ON COLUMN product_master.canonical_name IS
  'Nombre canónico del producto. Fuente: products.name del registro
   más antiguo de cada grupo DISTINCT ON (master_product_id).';

COMMENT ON COLUMN product_master.brand IS
  'Marca del producto. Reservado para futuro; actualmente NULL
   porque products no tiene columna brand.';

COMMENT ON COLUMN product_master.category_id IS
  'Identificador de categoría. Copiado desde products.category_id
   del registro fuente. Usado para filtrado y agrupación.';

COMMENT ON COLUMN product_master.subcategory IS
  'Subcategoría del producto. Copiada desde products.subcategory
   del registro fuente. Puede ser NULL.';

COMMENT ON COLUMN product_master.image_url IS
  'URL de la imagen principal del producto. Copiada desde
   products.image_url del registro fuente.';

COMMENT ON COLUMN product_master.created_at IS
  'Timestamp de creación. Copiado desde products.created_at
   del registro fuente. Por defecto NOW() si es NULL.';

-- 5. Verificación (solo lectura, no modifica nada)
SELECT
  'product_master' AS tabla,
  COUNT(*)::INTEGER AS registros_actuales
FROM product_master;
