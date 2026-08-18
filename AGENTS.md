# VibeShopping — Prototipo Académico (MVP)

Flutter + Supabase directo. **No hay backend Node.js** (eliminado en el cambio de alcance). Todos los datos se leen con el SDK de Supabase desde la vista `v_products_complete`.

## Estado del alcance

- **Dart**: 79 archivos, ~7,993 líneas totales (~7,834 código) — dentro del objetivo académico 6,000–8,000.
- **Backend / SQL**: 0 (el backend Node.ts y las migraciones `server/` fueron eliminados; los datos siguen en Supabase).
- **Dependencias pubspec**: `supabase_flutter`, `provider`, `hive`, `hive_flutter`, `cached_network_image`, `flutter_map`, `latlong2`, `test`.

## Prerequisites
- Flutter 3.22+ (usa `--dart-define-from-file`)
- Supabase project (local o cloud) con `supermarkets` y `v_products_complete` pobladas

## Quick Start (from zero)

```powershell
git clone <repo>
cd VibeShopping

# 1. Crear configuración Flutter desde plantilla
copy .env.example .env

# 2. Editar .env con credenciales de Supabase
notepad .env

# 3. Ejecutar la app
.\run.ps1
```

Sin IDE, sin variables de entorno globales, sin pasos ocultos.

## Configuración

Solo se necesita el par `SUPABASE_URL` + `SUPABASE_ANON_KEY`. Los flags `USE_NODE_API` / `API_BASE_URL` fueron eliminados junto con el backend.

```bash
flutter run --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
```

| Variable | Requerida | Leída por | Propósito |
|---|---|---|---|
| `SUPABASE_URL` | Siempre | `supabase_config.dart:22` | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | Siempre | `supabase_config.dart:24` | Clave anónima |

Cada variable tiene exactamente **un punto de lectura** en el código.

## Funcionalidades (alcance final)

| Feature | Estado | Líneas |
|---|---|---|
| `explorer/` | Conservada — pantalla principal, búsqueda y filtros | 1,220 |
| `products/` | Conservada — productos, precios y detalle | 634 |
| `comparison/` | Conservada — comparación de precios entre tiendas | 466 |
| `auth/` | Conservada — login/registro/perfil | 1,029 |
| `categories/` | Conservada — filtro por categorías | 168 |
| `manual_lists/` | **Congelada** — funciona, NO modificar | 2,703 |
| `location_demo/` | NUEVA — mapa real de San Isidro con flutter_map | 750 |
| `shopping_assistant/` | NUEVA — recomendación precio+distancia+transporte | 520 |

**Regla**: no invertir tiempo en `manual_lists` (congelado). No migrar, no conectar al asistente, no simplificar.

### Features eliminadas (definitivamente)

| Feature | Por qué se eliminó |
|---|---|
| `assistant/` (IA/chat) | IA fuera de alcance; reemplazada por `shopping_assistant` |
| `shopping_planner/` | 4,695 líneas muertas/inaccesibles; fuera de alcance |
| `navigation/` (OSRM/FlutterMap/GPS) | Complejidad fuera de alcance |
| `location/` (FlutterMap) | Reemplazada por `location_demo` |
| `server/` (Node/TS) + migraciones | Backend fuera de alcance; Supabase directo basta |
| `test/features/shopping_planner/` | Pruebas del motor eliminado |

### Navegación (4 tabs, `explorer_shell.dart`)

```
ExplorerShell
├── Tab 1: Explorar → MarketExplorerView  (botón asistente en AppBar)
├── Tab 2: Mis Listas → ManualListsView   (congelado)
├── Tab 3: Ubicación → LocationDemoScreen (mapa real flutter_map)
└── Tab 4: Perfil → ProfileView
```

## Flujo del Asistente de Compras (`shopping_assistant/`)

```
Usuario escribe producto + elige transporte
    ↓
ShoppingAssistantScreen → context.read<ProductProvider>() + ExplorerProvider()
    ↓
ShoppingAssistantLogic.buildRecommendation()
    ↓
matchProduct(query) → candidatos (precio por tienda)
distanceToStore(store) → Haversine local (coordenadas reales) + tiempo por transporte
    ↓
score = pesoPrecio * (másBarato/precio) + pesoDistancia * (másCerca/distancia)
    ↓
Recomendación ordenada + ahorro estimado
```

Pesos por transporte: carro 0.6/0.4, bus 0.5/0.5, bici 0.4/0.6, a pie 0.3/0.7. La recomendación también muestra el tiempo de traslado estimado (carro 30, bus 20, bici 15, a pie 5 km/h). Sin IA, sin backend, sin GPS: la posición del usuario es ficticia (centro de San Isidro).

## Flujo de la Ubicación Demo (`location_demo/`)

Mapa real de San Isidro de El General con `flutter_map` (tiles de OpenStreetMap, sin API key) y 3 supermercados con coordenadas reales de OSM: BM Bostón (El Prado), CoopeAgri San Luis (Barrio San Luis) y Maxi Palí (Barrio Sinaí). La posición del usuario es una referencia fija del centro de San Isidro (9.3760, -83.7025), etiquetada "Tu ubicación". Cada tienda es un marcador con su nombre sobre el mapa; pan y zoom con gestos + botones `+`/`−`. Al tocar un marcador (o la tarjeta) se abre un BottomSheet con dirección, distancia Haversine y tiempos auto (40 km/h), moto (35), bici (15) y a pie (5), marcados como estimaciones de referencia del prototipo. Sin GPS, sin rutas, sin OSRM.

## Reporte: Mapa real de Ubicación (flutter_map + OpenStreetMap)

- **Flutter**: 3.41.1 stable · **Dart**: 3.11.0 stable (2026-02).
- **Paquete de mapa**: `flutter_map ^8.3.1` + `latlong2 ^0.10.1` (requiere Dart ≥3.6 — cumplido). Reemplaza a `maplibre_gl ^0.26.2`. Sin cambio de SDK.
- **Proveedor de tiles**: OpenStreetMap. **URL**: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`. **API key**: no requiere. **User-Agent**: `com.example.vibeshopping` (`TileLayer.userAgentPackageName`). Atribución visible en el mapa ("© OpenStreetMap contributors").
- **Android**: compatible (permiso INTERNET ya declarado en el manifest). iOS: requiere configuración adicional (no aplica).
- **Supermercados** (coordenadas reales vía Nominatim/OSM):
  - BM Bostón: 9.3808282, -83.7061450 (Alameda Venegas, El Prado)
  - CoopeAgri San Luis: 9.3857375, -83.7065238 (Calle 14, Barrio San Luis)
  - Maxi Palí: 9.3675409, -83.6964465 (Vía 242, Barrio Sinaí)
- **Usuario (referencia)**: 9.3760, -83.7025 — Carretera Interamericana Sur, El Prado, San Isidro.
- **Distancias/tiempos** (Haversine + velocidades): BM 0.67 km → 1/1/3/8 min; CoopeAgri SL 1.17 km → 2/2/5/14; Maxi Palí 1.15 km → 2/2/5/14 (auto/moto/bici/a pie). Tiempos coherentes por medio (auto ≤ moto ≤ bici ≤ a pie).
- **Interacción**: pan y zoom con gestos (sin rotación) + botones `+`/`−` en la esquina superior derecha del mapa. Tap en un marcador o en una tarjeta abre un `showModalBottomSheet` con los datos del supermercado (nombre, dirección, distancia, tiempos por medio, nota de estimación y botón Cerrar).
- **Archivos**: los 6 de `location_demo/`; `explorer_shell.dart` sin cambios.
- **Total del proyecto**: 79 archivos lib, 7,993 líneas; código real ~7,993 (lib 7,834 + test 159) — dentro de 6,000–8,000.

## Estructura de directorios

### Features conservadas (estructura existente intacta)

```
lib/features/<name>/
  screens/  providers/  services/  models/  domain/  widgets/  data/
```

### Features nuevas (layout plano y sencillo)

```
lib/features/location_demo/
  location_demo_screen.dart        (178 — pantalla con mapa flutter_map)
  location_demo_data.dart          (87 — tiles OSM + coordenadas + Haversine + tiempos)
  location_demo_store.dart         (15 — modelo DemoStore)
  location_demo_widgets.dart       (142 — tarjeta StoreCard)
  location_demo_details_sheet.dart (181 — BottomSheet de detalle)
  location_demo_map_widgets.dart   (147 — marcadores + botones de zoom)

lib/features/shopping_assistant/
  shopping_assistant_screen.dart  (~250)
  shopping_assistant_logic.dart   (~160)  — lógica pura, sin UI
  shopping_assistant_data.dart    (~50)   — posición + distancias
```

No crear repository/datasource/DTO/mapper/useCase/provider si no hace falta.

### Cross-feature imports (actuales)
- Explorer → Products: `product.dart`, `product_provider.dart`
- Explorer → ShoppingAssistant: `shopping_assistant_screen.dart`
- Explorer → LocationDemo: `location_demo_screen.dart`
- Explorer → Auth: `auth_provider.dart`, `login_view.dart`
- Products → Comparison: `comparison_provider.dart`
- ManualLists → Products: `product_provider.dart`
- ShoppingAssistant → Products, Explorer, LocationDemo (Haversine)

### Single source of truth
- `lib/core/vibe_constants.dart` (VibeColors) — navy `#2C3E50`, mint `#A8D5BA`, backgroundMint, backgroundWhite
- `lib/core/vibe_theme.dart` (VibeTheme) — Material 3
- `lib/core/vibe_formatter.dart` (VibeFormatter.formatPrice) — precios ₡
- `lib/core/supabase_config.dart` — credenciales Supabase
- `lib/features/products/models/product.dart` — ProductEntity/ProductPrice

### Inyección de dependencias
- Providers registrados centralmente en `lib/core/di/app_providers.dart` (solo Auth, Products, Categories, Explorer, Comparison, ManualList)
- `main.dart` solo inicializa Supabase + Hive y delega el DI a `AppProviders`
- Sin Service Locator, sin GetIt, sin reflexión

## Líneas

| Módulo | Líneas |
|---|---|
| manual_lists (congelado) | 2,703 |
| auth | 1,029 |
| explorer | 1,220 |
| products | 634 |
| shopping_assistant (nuevo) | 520 |
| comparison | 466 |
| location_demo (nuevo) | 750 |
| core | 310 |
| categories | 168 |
| main | 34 |
| **Total** | **~7,993** |

Código real: ~7,834 en lib + 159 en test = ~7,993, dentro del rango 6,000–8,000. En la fase de limpieza se eliminaron capas de arquitectura innecesarias (interfaces `*Repository`, services passthrough `*Service`), código muerto y ~875 líneas de comentarios de bloque, y se retiró `font_awesome_flutter` (botones Google muertos).

## Verificación

```bash
flutter analyze lib/
flutter test test/features/shopping_assistant/
```

Sin `npx tsc` ni `pnpm test` (el backend fue eliminado). Los tests del asistente usan `package:test` (lógica pura, sin widgets).

## Código eliminado (referencia)

- `lib/core/api_client.dart`, `lib/core/api_config.dart` — solo servían al backend eliminado
- `ProductEntity.fromApiMap()` — factory de la API Node.js sin consumidores
- Registros muertos en `app_providers.dart` (shopping_planner, navigation, assistant)
- Directorios `lib/features/{assistant,shopping_planner,navigation,location}/`, `server/`, `test/`
- Fase de limpieza 2026-08: `core/repositories/` (interfaz `ProductRepository`), `products/services/product_service.dart`, `categories/services/category_service.dart`, `categories/domain/repositories/category_repository.dart` (interfaz duplicada), `auth/screens/join_community_gate.dart` → `auth_gate.dart` (`AuthGate`), y en `manual_lists/` (solo código muerto aprobado): `models/route_preparation.dart`, `models/price_comparison_info.dart`, `models/manual_list_summary.dart`, `services/manual_list_serializer.dart`, `services/manual_list_statistics_service.dart`, `providers/parts/manual_list_{comparison,statistics}.dart`, `widgets/detail/coming_soon_banner.dart`.

## Reglas de borrado (permanentes)

Antes de borrar cualquier elemento:
1. Buscar todos los consumidores.
2. Confirmar cero referencias directas e indirectas (Provider, DI, rutas, imports, exports).
3. Ejecutar `flutter analyze` antes y después.
4. Si hay duda, NO borrar; marcar `LEGACY` con comentario explicativo.
5. Documentar en el reporte qué se borró, qué lo reemplaza y cómo se verificó la seguridad.

## Historial de progreso

### Migración del mapa a flutter_map 2026-08 (flutter_map + OpenStreetMap)
- **Reemplazado**: el mapa de `maplibre_gl ^0.26.2` (tiles de OpenFreeMap) por `flutter_map ^8.3.1` + `latlong2 ^0.10.1` con tiles de OpenStreetMap (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`, sin API key). User-Agent `com.example.vibeshopping` y atribución visible.
- **Creado**: `location_demo_map_widgets.dart` (marcadores `StoreMarker`/`UserMarker` y controles de zoom `+`/`−`). Tap en marcador o tarjeta → BottomSheet; pan/zoom con gestos (sin rotación).
- **Ajustado**: velocidades coherentes auto 40 / moto 35 / bici 15 / a pie 5 km/h; etiquetas Auto/Moto/Bici/A pie; nota "tiempos estimados de referencia del prototipo" en tarjeta y BottomSheet; botón Cerrar. Se eliminó `mapStyleUrl` (OpenFreeMap).
- **Verificación**: `flutter analyze lib/`: 0 issues. `flutter test`: 7/7 pass.
- **Métricas**: 78 → 79 archivos lib; 7,637 → 7,993 líneas totales (6,960 → 7,834 código lib); feature `location_demo` 553 → 750 líneas.

### Mapa real de Ubicación 2026-08 (MapLibre + OpenFreeMap)
- **Creado**: `location_demo_widgets.dart` (StoreCard) y `location_demo_details_sheet.dart` (BottomSheet).
- **Reemplazado**: el mapa simulado (CustomPainter) por un mapa real con `maplibre_gl ^0.26.2` y tiles de OpenFreeMap (sin API key). Marcadores de texto con el nombre de cada tienda + "Tu ubicación".
- **Datos reales**: 3 supermercados con coordenadas verificadas en OSM (BM Bostón, CoopeAgri San Luis, Maxi Palí); distancia Haversine y tiempos a pie/bici/moto/carro calculados, no escritos a mano.
- **Verificación**: `flutter analyze lib/`: 0 issues. `flutter test`: 7/7 pass.
- **Métricas**: 76 → 78 archivos lib; 7,541 → 7,637 líneas totales; 6,867 → 6,960 código lib; test 121 → 159.

### Fase de limpieza final 2026-08 (código, alcance e incoherencias)
- **Eliminado** (sin consumidores): `lib/core/repositories/product_repository.dart` + carpeta `core/repositories/`, `products/services/product_service.dart`, `categories/services/category_service.dart`, `categories/domain/repositories/category_repository.dart`, `auth/screens/join_community_gate.dart` (→ `auth_gate.dart`), y en `manual_lists/`: `route_preparation.dart`, `price_comparison_info.dart`, `manual_list_summary.dart`, `manual_list_serializer.dart`, `manual_list_statistics_service.dart`, `providers/parts/manual_list_{comparison,statistics}.dart`, `widgets/detail/coming_soon_banner.dart`.
- **Eliminado de providers/modelos**: `ProductProvider.loadProductDetail/selectedProduct/error`, `ComparisonProvider.compareProducts/compareStore/invalidateCache/buildPriceComparisonInfo`, `ExplorerProvider.refresh()`, `CategoryProvider.refresh()`, `AuthProvider.authService` setter + `clearError`, `SupabaseAuthService.refreshSession/isAuthenticated`, `CategoryService`, campos muertos `priceComparison`/`routePreparation` y servicios del `ManualListProvider`, `VibeTheme.screenBackgroundGradient`, `AuthGatewayStyles.buildLogoHero`, `VibeSelectionModals.openLocationPicker`, `ProductDisplayHelper.resolveGridPrice/GridPriceRef/referenceStoreName`, `ComparisonPreview.storeCount`, `ProductEntity.referenceStoreName/fromSupabaseMap`, `StoreModel.fromJson/copyWith/==`.
- **Eliminado de UI (incoherencias)**: botones Google deshabilitados en login/registro (y `font_awesome_flutter` de pubspec), tiles no-op del perfil, `ComingSoonBanner` ("Próximamente"), banner "Comunidad" en `explorer_shell.dart`, picker de zona en `market_explorer_view.dart`.
- **Ajustado al alcance**: `location_demo` ahora muestra tiempos a pie/bici/moto/carro; el asistente muestra tiempo de traslado y ya no usa distancias de respaldo por nombre (solo Haversine real).
- **Simplificado**: repositorios Supabase concretos sin interfaces, inyección directa en providers (`app_providers.dart`), helpers de display limpios, ~875 líneas de comentarios de bloque → comentarios cortos.
- **Verificación**: `flutter analyze`: 0 issues. `flutter test`: 7/7 pass.
- **Métricas**: lib 88 → 76 archivos; 9,649 → 7,541 líneas totales; 7,972 → 6,867 código; 993 → 118 comentarios. Código real ~6,988 (dentro de 6,000–8,000).

### Cambio de alcance a Prototipo Académico
- **Eliminado**: `lib/features/assistant/` (8 archivos), `lib/features/shopping_planner/` (62), `lib/features/navigation/` (18), `lib/features/location/` (6), `test/` (3), `server/` completo (Node/TS + migraciones SQL), `lib/core/api_client.dart`, `lib/core/api_config.dart`.
- **Creado**: `location_demo/` (3 archivos, 470 líneas — mapa estático de San Isidro con CustomPainter + Haversine) y `shopping_assistant/` (3 archivos, 552 líneas — recomendación precio/distancia/transporte sin IA).
- **Modificado**: `app_providers.dart` (242→97 líneas), `main.dart` (sin ApiClient), `explorer_shell.dart` (tab Ubicación → LocationDemoScreen), `market_explorer_view.dart` (botón Asistente en AppBar), `pubspec.yaml` (−dio, −flutter_map, −latlong2, −geolocator, −url_launcher, −image_picker), `product.dart` (eliminado `fromApiMap`).
- **Verificación**: `flutter analyze lib/`: 0 issues. `flutter analyze` (completo): 0 issues.
- **Métricas**: 20,705 → 9,649 líneas totales; 233 → 88 archivos Dart; backend 1,828 → 0; SQL 1,672 → 0.

### Historial previo (resumen)
- Manual Lists refactor a 4 mixins; widgets extraídos (`manual_lists_view.dart` 890→212).
- Price Comparator MVP integrado en `ProductDetailView`.
- `StoreModel` con coordenadas (latitude/longitude) — usadas por el asistente para distancia real.
- Migración `20260709_extend_supermarkets.sql` (coordenadas de San Isidro) — los datos ya están en Supabase.
- Phase D.4: Edge Function `asistente-compras` eliminada de Flutter (borrar del Dashboard si existe).
- Estabilización: dead code removal, file splits, DI centralizado, `docs/ARCHITECTURE.md`.
- Community feature removida (Phase 12) — tab "Comunidad" es placeholder; el tab se conserva.
- Explorer loading stabilizado (Phase D.2) — 2 queries Supabase por sesión, filtrado local.
