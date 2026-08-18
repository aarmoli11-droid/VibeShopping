# VibeShopping

Prototipo académico MVP de comparación de precios entre supermercados de Costa Rica, construido con Flutter y Supabase.

## Qué hace

- Búsqueda y visualización de productos por categoría y supermercado (`v_products_complete`).
- Comparación de precios entre supermercados para un producto.
- Asistente de compras multicriterio (reglas simples: precio + distancia + transporte).
- Mapa demostrativo de supermercados de San Isidro (datos ficticios, sin GPS).
- Login/registro y listas de compras manuales.

## Arquitectura

```
Flutter (lib/)
    │
    └── Supabase SDK (auth + v_products_complete)
```

Sin backend. Todos los datos se leen directamente de Supabase con el SDK. La distancia se calcula con Haversine local; la posición del usuario es ficticia (centro de San Isidro).

## Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.22+ |
| Supabase project | (local o cloud) con `supermarkets` y `v_products_complete` pobladas |

## Quick Start

```bash
copy .env.example .env    # completar SUPABASE_URL y SUPABASE_ANON_KEY
.\run.ps1
```

## Configuración

| Variable | Requerida | Propósito |
|---|---|---|
| `SUPABASE_URL` | Siempre | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | Siempre | Clave anónima |

## Estructura

```
lib/
├── main.dart
├── core/                 # colores, tema, formateo, configuración Supabase, DI
└── features/
    ├── auth/             # login, registro, perfil
    ├── explorer/         # pantalla principal, búsqueda y filtros
    ├── products/         # productos, precios, detalle
    ├── comparison/       # comparación de precios entre tiendas
    ├── categories/       # filtro por categorías
    ├── manual_lists/     # listas de compras manuales (congelada)
    ├── location_demo/    # mapa real de San Isidro (flutter_map + OSM)
    └── shopping_assistant/  # recomendación precio + distancia + transporte
```

## Verificación

```bash
flutter analyze lib/
flutter test test/features/shopping_assistant/
```

## Alcance académico

Proyecto de demostración: código reducido y comprensible para un estudiante. No incluye IA, GPS, backend ni complejidad de producción.
