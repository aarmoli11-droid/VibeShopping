-- =============================================================
-- Migration: 20260710_initial_schema
-- Fecha: 2026-07-10
-- Propósito: Documentar y garantizar la estructura fundacional
--   de las tablas principales del sistema.
--
-- Esta migración NO modifica datos existentes.
-- NO elimina tablas.
-- NO cambia comportamiento.
--
-- Idempotente: todas las operaciones usan IF NOT EXISTS o
-- DROP + CREATE para poder ejecutarse múltiples veces.
--
-- Orden de creación (respetando FKs):
--   1. supermarkets (no tiene FKs externas)
--   2. product_master (no tiene FKs externas)
--   3. products (FK → supermarkets, product_master)
--
-- Nota: las columnas redundantes de products (name, category_id,
-- subcategory, image_url) se documentan pero NO se eliminan en
-- esta migración. Su limpieza está planificada para una fase
-- futura.
-- =============================================================

-- =============================================================
-- TABLA: supermarkets
-- Propósito: Catálogo de supermercados. Cada fila representa
--   una tienda física con datos de identidad, ubicación y
--   servicios.
-- Creada originalmente: Fuera del sistema de migraciones
--   (Dashboard de Supabase, setup inicial)
-- Documentada en: 20260710_initial_schema
-- Consumida por: Flutter (SupabaseExplorerRepository),
--   v_products_complete (VIEW)
-- =============================================================
CREATE TABLE IF NOT EXISTS supermarkets (
  id          UUID PRIMARY KEY,
  name        TEXT,
  logo_url    TEXT,
  latitude    DOUBLE PRECISION,
  longitude   DOUBLE PRECISION,
  address     TEXT,
  parking     BOOLEAN DEFAULT FALSE,
  delivery    BOOLEAN DEFAULT FALSE,
  pickup      BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE supermarkets IS
  'Catálogo de supermercados. Creada en setup inicial (fuera de migraciones). '
  'Documentada en 20260710_initial_schema.';

COMMENT ON COLUMN supermarkets.id        IS 'UUID primario del supermercado.';
COMMENT ON COLUMN supermarkets.name      IS 'Nombre comercial del supermercado.';
COMMENT ON COLUMN supermarkets.logo_url  IS 'URL del logo del supermercado.';
COMMENT ON COLUMN supermarkets.latitude  IS 'Latitud (OpenStreetMap, referencias aproximadas). Agregada en 20260709.';
COMMENT ON COLUMN supermarkets.longitude IS 'Longitud (OpenStreetMap, referencias aproximadas). Agregada en 20260709.';
COMMENT ON COLUMN supermarkets.address   IS 'Descripción amigable de ubicación. Agregada en 20260709.';
COMMENT ON COLUMN supermarkets.parking   IS 'Disponibilidad de parqueo. Agregada en 20260709.';
COMMENT ON COLUMN supermarkets.delivery  IS 'Ofrece servicio a domicilio. Agregada en 20260709.';
COMMENT ON COLUMN supermarkets.pickup    IS 'Ofrece recogida en tienda. Agregada en 20260709.';


-- =============================================================
-- TABLA: product_master
-- Propósito: Entidad maestra de productos. Un registro por
--   producto canónico (sin importar la tienda). Normaliza la
--   relación muchos-a-muchos entre productos y supermercados.
-- Creada en: 20260708_paso1_create_product_master.sql
-- Poblada en: 20260708_paso2_populate_product_master.sql
-- Consumida por: v_products_complete (VIEW)
-- =============================================================
CREATE TABLE IF NOT EXISTS product_master (
  id              UUID PRIMARY KEY,
  canonical_name  TEXT,
  brand           TEXT,
  category_id     TEXT,
  subcategory     TEXT,
  image_url       TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE product_master IS
  'Entidad maestra de productos. Un registro por producto canónico. '
  'Creada en 20260708_paso1. Poblada desde products con DISTINCT ON (master_product_id).';

COMMENT ON COLUMN product_master.id             IS 'UUID del producto maestro. Corresponde a products.master_product_id.';
COMMENT ON COLUMN product_master.canonical_name IS 'Nombre canónico del producto (tomado del registro más antiguo en products).';
COMMENT ON COLUMN product_master.brand          IS 'Marca del producto. Actualmente NULL — products no tiene columna brand. Reservado para futuro.';
COMMENT ON COLUMN product_master.category_id    IS 'Identificador de categoría (string, ej: cat_lacteos). Será FK → categories(slug) en Fase D.6.';
COMMENT ON COLUMN product_master.subcategory    IS 'Subcategoría del producto (ej: Quesos para cat_lacteos).';
COMMENT ON COLUMN product_master.image_url      IS 'URL de la imagen principal del producto.';
COMMENT ON COLUMN product_master.created_at     IS 'Timestamp de creación (copiado de products.created_at del registro fuente).';


-- =============================================================
-- TABLA: products
-- Propósito: Producto por supermercado. Una fila por cada
--   combinación (producto × tienda) con su precio específico.
--   La columna master_product_id normaliza múltiples filas del
--   mismo producto lógico en diferentes tiendas.
-- Creada originalmente: Fuera del sistema de migraciones
--   (Dashboard de Supabase, setup inicial)
-- Documentada en: 20260710_initial_schema
-- Consumida por: v_products_complete (VIEW, indirectamente
--   toda la aplicación)
--
-- Columnas redundantes (candidatas a eliminación futura):
--   name, category_id, subcategory, image_url — fueron
--   reemplazadas por product_master.canonical_name, etc.
--   La VIEW y toda la aplicación leen desde product_master.
-- =============================================================
CREATE TABLE IF NOT EXISTS products (
  id                  UUID PRIMARY KEY,
  master_product_id   UUID,
  name                TEXT,
  price               NUMERIC,
  category_id         TEXT,
  subcategory         TEXT,
  image_url           TEXT,
  supermarket_id      UUID,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE products IS
  'Producto por supermercado. Una fila por cada (producto × tienda). '
  'Creada en setup inicial (fuera de migraciones). Documentada en 20260710_initial_schema. '
  'La VIEW v_products_complete es la fuente oficial de consulta.';

COMMENT ON COLUMN products.id                IS 'UUID primario del producto por supermercado.';
COMMENT ON COLUMN products.master_product_id IS 'FK → product_master(id). Normaliza el mismo producto lógico en distintas tiendas.';
COMMENT ON COLUMN products.name              IS '[Redundante] Nombre del producto en esta tienda. Reemplazado por product_master.canonical_name.';
COMMENT ON COLUMN products.price             IS 'Precio en CRC.';
COMMENT ON COLUMN products.category_id       IS '[Redundante] Identificador de categoría. Reemplazado por product_master.category_id.';
COMMENT ON COLUMN products.subcategory       IS '[Redundante] Subcategoría. Reemplazado por product_master.subcategory.';
COMMENT ON COLUMN products.image_url         IS '[Redundante] URL de imagen. Reemplazado por product_master.image_url.';
COMMENT ON COLUMN products.supermarket_id    IS 'FK → supermarkets(id). Identifica la tienda donde se vende este precio.';
COMMENT ON COLUMN products.created_at        IS 'Timestamp de creación de este registro.';

-- =============================================================
-- FK: products → product_master
-- =============================================================
ALTER TABLE products DROP CONSTRAINT IF EXISTS fk_products_master;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_master_product_id_fkey;

ALTER TABLE products
  ADD CONSTRAINT fk_products_master
    FOREIGN KEY (master_product_id)
    REFERENCES product_master(id)
    ON DELETE SET NULL;

-- =============================================================
-- FK: products → supermarkets
-- =============================================================
ALTER TABLE products DROP CONSTRAINT IF EXISTS fk_products_supermarket;
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_supermarket_id_fkey;

ALTER TABLE products
  ADD CONSTRAINT fk_products_supermarket
    FOREIGN KEY (supermarket_id)
    REFERENCES supermarkets(id)
    ON DELETE SET NULL;

-- =============================================================
-- Índices
-- =============================================================

-- JOIN product_master
CREATE INDEX IF NOT EXISTS idx_products_master_product_id
  ON products(master_product_id);

-- JOIN supermarkets
CREATE INDEX IF NOT EXISTS idx_products_supermarket_id
  ON products(supermarket_id);

-- Uniqueness: un solo producto por (master_product_id, supermarket_id)
ALTER TABLE products DROP CONSTRAINT IF EXISTS uq_products_master_supermarket;

ALTER TABLE products
  ADD CONSTRAINT uq_products_master_supermarket
    UNIQUE (master_product_id, supermarket_id);

-- Búsqueda y filtrado en product_master
CREATE INDEX IF NOT EXISTS idx_product_master_category
  ON product_master(category_id);

CREATE INDEX IF NOT EXISTS idx_product_master_canonical_name
  ON product_master(canonical_name);

-- =============================================================
-- Verificación
-- =============================================================
SELECT
  '20260710_initial_schema' AS migracion,
  (SELECT COUNT(*)::INTEGER FROM supermarkets) AS supermarkets,
  (SELECT COUNT(*)::INTEGER FROM product_master) AS product_master,
  (SELECT COUNT(*)::INTEGER FROM products) AS products,
  (SELECT COUNT(*)::INTEGER FROM pg_indexes WHERE tablename = 'products') AS productos_indices,
  (SELECT COUNT(*)::INTEGER FROM pg_indexes WHERE tablename = 'product_master') AS product_master_indices;
