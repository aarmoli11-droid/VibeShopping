# Architecture Overview

Prototipo académico MVP. Flutter + Supabase directo, sin backend.

## Layers
- **Flutter** (lib/): Presentation UI, state (Provider), models, Supabase SDK queries
- **Supabase**: PostgreSQL, auth, view `v_products_complete`

## Flutter (lib/)
| Layer | Location | Purpose |
|---|---|---|
| Core | lib/core/ | Constants, theme, formatter, Supabase config, DI |
| Features | lib/features/<name>/ | 8 feature modules (auth, categories, comparison, explorer, manual_lists, products, location_demo, shopping_assistant) |

### Features
| Feature | Estado | Rol |
|---|---|---|
| auth | Conservada | Login, registro, recuperación, perfil |
| explorer | Conservada | Pantalla principal, búsqueda, filtros |
| products | Conservada | Productos, precios, detalle |
| comparison | Conservada | Comparación de precios entre tiendas |
| categories | Conservada | Filtro por categorías |
| manual_lists | Congelada (NO modificar) | Listas de compras manuales (Hive) |
| location_demo | Nueva | Mapa real de San Isidro (flutter_map + OpenStreetMap) |
| shopping_assistant | Nueva | Recomendación precio + distancia + transporte |

### Features eliminadas (scope final)
- `assistant/` (IA/chat), `shopping_planner/`, `navigation/` (OSRM/FlutterMap/GPS), `location/` (FlutterMap), `server/` (Node/TS), `test/features/shopping_planner/`

## Supabase
| Table/View | Purpose |
|---|---|
| supermarkets | Store catalog with location, address, services |
| product_master | Canonical product entities |
| products | Product prices per store |
| v_products_complete | JOIN view products + product_master + supermarkets |
| categories | Product categories |

## Data Flow
1. **Explorer / Products**: Flutter → Supabase SDK → `v_products_complete` → ProductEntity
2. **Assistant**: ProductProvider (productos) + ExplorerProvider (stores) → Haversine local → recomendación ordenada
3. **Auth**: Flutter → Supabase Auth
4. **LocationDemo**: datos demo locales (posición ficticia del centro de San Isidro) + Haversine

## Inyección de dependencias
- Providers registrados centralmente en `lib/core/di/app_providers.dart`
- `main.dart` solo inicializa Supabase + Hive y delega el DI a `AppProviders`
- Sin Service Locator, sin GetIt, sin reflexión

## Verificación
```bash
flutter analyze lib/
flutter test test/features/shopping_assistant/
```
