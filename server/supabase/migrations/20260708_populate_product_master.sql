-- =============================================================
-- Migration: populate_product_master
-- Fecha: 2026-07-08
-- Responsabilidad: Convertir product_master en la entidad
--   maestra real del sistema.
--
-- Qué hace:
--   1. Crea product_master si no existe
--   2. Agrega columnas necesarias si faltan
--   3. Inserta un registro por cada master_product_id distinto
--   4. Verifica que todos los products tengan FK válida
--   5. Agrega FK constraint si no existe
--
-- Ejecutar en: Supabase Dashboard → SQL Editor
--   o vía: supabase db push
-- =============================================================

DO $$
DECLARE
  master_count INTEGER;
  orphan_count INTEGER;
  fixed_count INTEGER;
BEGIN

  -- =============================================================
  -- Paso 1: Crear product_master si no existe
  -- =============================================================
  CREATE TABLE IF NOT EXISTS product_master (
    id UUID PRIMARY KEY,
    canonical_name TEXT,
    brand TEXT,
    category_id TEXT,
    subcategory TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
  );

  -- =============================================================
  -- Paso 2: Agregar columnas faltantes (seguro si ya existen)
  -- =============================================================
  ALTER TABLE product_master ADD COLUMN IF NOT EXISTS canonical_name TEXT;
  ALTER TABLE product_master ADD COLUMN IF NOT EXISTS brand TEXT;
  ALTER TABLE product_master ADD COLUMN IF NOT EXISTS category_id TEXT;
  ALTER TABLE product_master ADD COLUMN IF NOT EXISTS subcategory TEXT;
  ALTER TABLE product_master ADD COLUMN IF NOT EXISTS image_url TEXT;
  ALTER TABLE product_master ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

  -- =============================================================
  -- Paso 3: Insertar datos desde products
  --   Toma la fila más antigua de cada grupo como fuente
  --   (la primera vez que apareció el producto en el sistema)
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
    AND NOT EXISTS (
      SELECT 1 FROM product_master pm WHERE pm.id = p.master_product_id
    )
  ORDER BY p.master_product_id, p.created_at ASC;

  GET DIAGNOSTICS master_count = ROW_COUNT;
  RAISE NOTICE 'Registros insertados en product_master: %', master_count;

  -- =============================================================
  -- Paso 4: Verificar y corregir FK
  -- =============================================================
  SELECT COUNT(*) INTO orphan_count
  FROM products p
  LEFT JOIN product_master pm ON pm.id = p.master_product_id
  WHERE p.master_product_id IS NOT NULL AND pm.id IS NULL;

  IF orphan_count > 0 THEN
    RAISE NOTICE 'Huérfanos encontrados: %. Insertando registros padre faltantes...', orphan_count;

    INSERT INTO product_master (id, canonical_name, brand, category_id, subcategory, image_url, created_at)
    SELECT DISTINCT ON (p.master_product_id)
      p.master_product_id,
      p.name,
      NULL,
      p.category_id,
      p.subcategory,
      p.image_url,
      p.created_at
    FROM products p
    LEFT JOIN product_master pm ON pm.id = p.master_product_id
    WHERE p.master_product_id IS NOT NULL AND pm.id IS NULL
    ORDER BY p.master_product_id, p.created_at ASC;

    GET DIAGNOSTICS fixed_count = ROW_COUNT;
    RAISE NOTICE 'Huérfanos corregidos: %', fixed_count;
  ELSE
    RAISE NOTICE '0 huérfanos encontrados. Todas las FK son válidas.';
  END IF;

  -- =============================================================
  -- Paso 5: Agregar o verificar FK constraint
  -- =============================================================
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY'
      AND table_name = 'products'
      AND constraint_name = 'fk_products_master'
  ) THEN
    ALTER TABLE products
      DROP CONSTRAINT IF EXISTS products_master_product_id_fkey,
      ADD CONSTRAINT fk_products_master
        FOREIGN KEY (master_product_id) REFERENCES product_master(id)
        ON DELETE SET NULL;
    RAISE NOTICE 'FK constraint fk_products_master agregada.';
  ELSE
    RAISE NOTICE 'FK constraint ya existe.';
  END IF;

  -- =============================================================
  -- Reporte final
  -- =============================================================
  RAISE NOTICE '==========================================';
  RAISE NOTICE 'Migración completada exitosamente.';
  RAISE NOTICE 'Tabla product_master: % registros',
    (SELECT COUNT(*) FROM product_master);
  RAISE NOTICE 'Tabla products:       % registros',
    (SELECT COUNT(*) FROM products);
  RAISE NOTICE '==========================================';

END $$;
