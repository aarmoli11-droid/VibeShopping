-- =============================================================
-- Migration: 20260711_seed_categories
-- Propósito: Crear la tabla categories y poblar datos iniciales.
--
-- Corrige: 20260720_categories (migración eliminada por tener
--   fecha futura respecto a las migraciones ya aplicadas, que
--   llegan hasta 20260711_drop_stores).
--
-- Cada fila representa una categoría visible en la UI, con:
--   • id: identificador semántico (ej: 'carnes', 'abarrotes')
--   • name: nombre visible (ej: 'Carnes', 'Abarrotes')
--   • icon_name: identificador semántico para mapper de íconos
--     (NO es el nombre del icono de Flutter, es un semantic ID
--      como 'meat', 'groceries'. category_icon_mapper.dart lo
--      traduce a IconData)
--   • db_category_ids: IDs reales en product_master.category_id
--     a los que esta categoría agrupa. Ej: 'abarrotes' agrupa
--     'cat_abarrotes' y 'cat_granos'. Array vacío = "todas".
--   • display_order: orden de aparición en la UI
--   • is_active: si se muestra en la UI
--
-- Idempotente:
--   • CREATE TABLE usa IF NOT EXISTS
--   • CREATE INDEX usa IF NOT EXISTS
--   • INSERT usa ON CONFLICT DO NOTHING
--   • COMMENT ON es idempotente por naturaleza
--   • Se puede ejecutar N veces sin duplicar registros
-- =============================================================

-- =============================================================
-- Tabla: categories
-- =============================================================
CREATE TABLE IF NOT EXISTS categories (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  icon_name       TEXT NOT NULL DEFAULT 'category',
  db_category_ids TEXT[] NOT NULL DEFAULT '{}',
  display_order   INTEGER NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE categories IS
  'Categorías visibles en la UI. Reemplaza las listas hardcodeadas '
  'en Flutter y Node.js. Poblada en 20260711_seed_categories.';

COMMENT ON COLUMN categories.id IS
  'Identificador semántico único (ej: carnes, abarrotes). '
  'Se usa como key de navegación y referencia en la UI.';

COMMENT ON COLUMN categories.name IS
  'Nombre visible al usuario (ej: Carnes, Abarrotes, Lácteos).';

COMMENT ON COLUMN categories.icon_name IS
  'Identificador semántico para el mapper de íconos '
  '(category_icon_mapper.dart). NO es un nombre de Flutter Icons. '
  'Ej: meat, groceries, dairy, drinks.';

COMMENT ON COLUMN categories.db_category_ids IS
  'Array de IDs reales en product_master.category_id que esta '
  'categoría agrupa. Ej: abarrotes = {cat_abarrotes, cat_granos}. '
  'Array vacío significa "todas las categorías" (caso "Todo").';

COMMENT ON COLUMN categories.display_order IS
  'Orden de aparición en la barra de categorías (0 = primero).';

COMMENT ON COLUMN categories.is_active IS
  'Si la categoría está activa y debe mostrarse en la UI.';

-- =============================================================
-- Índices
-- =============================================================
CREATE INDEX IF NOT EXISTS idx_categories_display_order
  ON categories(display_order);

CREATE INDEX IF NOT EXISTS idx_categories_is_active
  ON categories(is_active);

-- =============================================================
-- Datos iniciales
-- Mismas categorías que el sistema actual, mismo orden.
-- icon_name usa identificadores semánticos (NO Flutter Icons).
-- =============================================================
INSERT INTO categories (id, name, icon_name, db_category_ids, display_order, is_active) VALUES
  ('todo',       'Todo',        'all',             '{}',                            0, TRUE),
  ('carnes',     'Carnes',      'meat',            '{cat_carnes}',                  1, TRUE),
  ('panaderia',  'Panadería',   'bakery',          '{cat_panadería}',               2, TRUE),
  ('frutas',     'Frutas',      'eco',             '{cat_frutas}',                  3, TRUE),
  ('congelados', 'Congelados',  'frozen',          '{cat_congelados}',              4, TRUE),
  ('higiene',    'Higiene',     'personal_care',   '{cat_higiene}',                 5, TRUE),
  ('enlatados',  'Enlatados',   'inventory',       '{cat_enlatados}',               6, TRUE),
  ('abarrotes',  'Abarrotes',   'groceries',       '{cat_abarrotes,cat_granos}',    7, TRUE),
  ('lacteos',    'Lácteos',     'dairy',           '{cat_lácteos}',                 8, TRUE),
  ('bebidas',    'Bebidas',     'drinks',           '{cat_bebidas}',                 9, TRUE)
ON CONFLICT (id) DO NOTHING;

-- =============================================================
-- Verificación
-- =============================================================
SELECT
  '20260711_seed_categories' AS migracion,
  COUNT(*)::INTEGER AS total_categorias,
  COUNT(*) FILTER (WHERE is_active)::INTEGER AS activas,
  COUNT(*) FILTER (WHERE is_active = FALSE)::INTEGER AS inactivas
FROM categories;
