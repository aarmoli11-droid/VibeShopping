-- =============================================================
-- Migración: Extender supermarkets para navegación
-- =============================================================
-- Propósito: Agregar columnas de ubicación y servicios a la
-- tabla supermarkets para soportar el módulo Navigation.
--
-- Idempotente: las columnas usan ADD COLUMN IF NOT EXISTS.
-- Los UPDATEs son deterministas: siempre escriben los mismos
-- valores demo independientemente del estado anterior.
-- =============================================================

-- =============================================================
-- BLOQUE 1: Agregar columnas nuevas
-- =============================================================
ALTER TABLE supermarkets ADD COLUMN IF NOT EXISTS latitude     DOUBLE PRECISION;
ALTER TABLE supermarkets ADD COLUMN IF NOT EXISTS longitude    DOUBLE PRECISION;
ALTER TABLE supermarkets ADD COLUMN IF NOT EXISTS address      TEXT;
ALTER TABLE supermarkets ADD COLUMN IF NOT EXISTS parking      BOOLEAN DEFAULT FALSE;
ALTER TABLE supermarkets ADD COLUMN IF NOT EXISTS delivery     BOOLEAN DEFAULT FALSE;
ALTER TABLE supermarkets ADD COLUMN IF NOT EXISTS pickup       BOOLEAN DEFAULT FALSE;

-- =============================================================
-- BLOQUE 2: Poblar datos demo
-- =============================================================
--
-- Demo locations
--
-- Las coordenadas representan ubicaciones aproximadas cercanas
-- a puntos de interés de San Isidro de El General, Pérez
-- Zeledón, Costa Rica. Fuente: OpenStreetMap (Nominatim).
--
-- Los supermercados son completamente ficticios.
--
-- Estas ubicaciones existen únicamente para demostrar el módulo
-- de navegación del prototipo.
--
-- Los UPDATEs se ejecutan siempre (sin condición previa),
-- garantizando que los datos demo se sincronicen incluso si
-- fueron modificados manualmente.
-- =============================================================

UPDATE supermarkets SET
  latitude  = 9.3675,
  longitude = -83.6964,
  address   = 'Cerca de Maxi Palí San Isidro',
  parking   = FALSE,
  delivery  = FALSE,
  pickup    = FALSE
WHERE name = 'Buen Día';

UPDATE supermarkets SET
  latitude  = 9.3719,
  longitude = -83.7048,
  address   = 'Cerca de CoopeAgri San Isidro',
  parking   = FALSE,
  delivery  = FALSE,
  pickup    = FALSE
WHERE name = 'Más Súper';

UPDATE supermarkets SET
  latitude  = 9.3503,
  longitude = -83.6744,
  address   = 'Cerca de Walmart San Isidro',
  parking   = TRUE,
  delivery  = FALSE,
  pickup    = FALSE
WHERE name = 'Súper Ahorro';

UPDATE supermarkets SET
  latitude  = 9.3414,
  longitude = -83.6734,
  address   = 'Sector Plaza Monte General',
  parking   = TRUE,
  delivery  = FALSE,
  pickup    = FALSE
WHERE name = 'Super Vida Saludable';

-- =============================================================
-- BLOQUE 3: Documentación de columnas
-- =============================================================
COMMENT ON COLUMN supermarkets.latitude  IS 'Latitud (OpenStreetMap, punto de referencia cercano).';
COMMENT ON COLUMN supermarkets.longitude IS 'Longitud (OpenStreetMap, punto de referencia cercano).';
COMMENT ON COLUMN supermarkets.address   IS 'Descripción amigable de ubicación (punto de referencia local).';
COMMENT ON COLUMN supermarkets.parking   IS 'Disponibilidad de parqueo (TRUE si hay evidencia pública).';
COMMENT ON COLUMN supermarkets.delivery  IS 'Ofrece servicio a domicilio.';
COMMENT ON COLUMN supermarkets.pickup    IS 'Ofrece recogida en tienda.';

-- =============================================================
-- BLOQUE 4: Verificación
-- =============================================================
SELECT
  'extend_supermarkets' AS migracion,
  COUNT(*)::INTEGER AS total_supermercados,
  COUNT(latitude)::INTEGER AS con_coordenadas,
  COUNT(address)::INTEGER AS con_direccion,
  COUNT(*) FILTER (WHERE parking)::INTEGER AS con_parqueo,
  COUNT(*) FILTER (WHERE delivery)::INTEGER AS con_delivery,
  COUNT(*) FILTER (WHERE pickup)::INTEGER AS con_pickup
FROM supermarkets;
