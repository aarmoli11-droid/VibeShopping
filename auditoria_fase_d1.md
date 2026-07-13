# Auditoría de Rendimiento de Carga de Productos — Fase D.1

## 1. Diagrama Completo del Flujo de Carga

```
ExplorerShell.build()
  │
  ├── _navIndex = 0 ⇒ MarketExplorerView(clave: _scaffoldKey)
  │
  ├── MarketExplorerView.initState()
  │     ├── _searchController.addListener(→ ExplorerProvider.setSearchQuery)
  │     └── WidgetsBinding.addPostFrameCallback()
  │           │
  │           ├── (1) ExplorerProvider.loadStores()          ← NO await
  │           │     └── ExplorerService.getStores()
  │           │           └── SupabaseExplorerRepository.getStores()
  │           │                 └── SUPABASE: SELECT * FROM supermarkets ORDER BY name
  │           │
  │           └── (2) ExplorerProvider.setCategory(categoryId) ← inmediato
  │                 ├── notifyListeners()  ← REBUILD A
  │                 └── ExplorerProvider._loadProducts()
  │                       └── ProductProvider.loadProducts(categoryId: null, storeIds: null)
  │                             ├── notifyListeners()  ← REBUILD B
  │                             └── ProductService.listProducts()
  │                                   └── SupabaseProductRepository.listProducts()
  │                                         └── SUPABASE: SELECT * FROM v_products_complete
  │                                               (sin filtros = todos los productos)
  │
  ├── (1) termina ⇒ notifyListeners()  ← REBUILD C
  ├── (2) termina ⇒ notifyListeners()  ← REBUILD D
  │
  └── MarketExplorerView.build()
        └── context.watch<ExplorerProvider>()
              ├── provider.productsLoading ? LoadingIndicator : _buildProductContent(provider)
              ├── provider.groupedProducts  ← llama a ExplorerService.filterAndGroupProducts()
              │     ├── Iteración O(n) sobre todos los productos
              │     ├── Filtro local por searchQuery (si existe)
              │     └── Agrupación por subcategoría (nuevo Map + List cada vez)
              │
              └── ListView.builder → VibeProductCard × N
                    ├── ProductDisplayHelper.resolveGridPrice()    ← precios
                    ├── ProductDisplayHelper.validImageUrls()     ← imágenes
                    ├── ProductDisplayHelper.supermarketData()    ← logo tienda
                    ├── Image.network(logo)                       ← logo store (sin caché explícita)
                    ├── VibeImageSlider(urls)
                    │     └── Image.network(imagen)               ← imagen producto (sin caché explícita)
                    └── _PriceComparison
                          └── ComparisonProvider.compareProduct(entity.id)
                                └── iteración de todos los precios
```

## 2. Número Total de Consultas a Supabase

| Evento | Consultas | Tabla/VIEW | Filtros |
|---|---|---|---|
| Carga inicial (tab Explorer) | 2 | supermarkets, v_products_complete | Ninguno (todos los productos) |
| Cambio de categoría | 1 | v_products_complete | category_id = [...] |
| Cambio de filtro de tienda | 1 | v_products_complete | supermarket_id IN [...] |
| Búsqueda por texto | **0** | — | Filtrado local en Flutter |
| Asistente IA (cada pregunta) | 1 | v_products_complete | storeIds: null (todos) |
| Navegación entre tabs (vuelta a Explorer) | **2** | supermarkets + v_products_complete | Idem carga inicial |

**Cada vez que el usuario vuelve a la pestaña Explorer desde otra pestaña se ejecutan 2 consultas nuevas.**

## 3. Número de Reconstrucciones (Widget Rebuilds)

### 3a. Durante la carga inicial (tab Explorer)

| # | Causa | Disparador | Widgets que se reconstruyen |
|---|---|---|---|
| 1 | `loadStores()` inicia | `_storesLoading=true; notifyListeners()` | MarketExplorerView completo |
| 2 | `setCategory()` llama | `notifyListeners()` dentro del setter | MarketExplorerView completo |
| 3 | `loadProducts()` inicia | `_isLoading=true; notifyListeners()` | MarketExplorerView completo |
| 4 | `loadStores()` termina | `_storesLoading=false; notifyListeners()` | MarketExplorerView completo |
| 5 | `loadProducts()` termina | `_isLoading=false; notifyListeners()` | MarketExplorerView completo |

**Total: 5 rebuilds completos de MarketExplorerView en la carga inicial.**

### 3b. Categoría cambia

| # | Causa |
|---|---|
| 1 | `setCategory()` → `notifyListeners()` |
| 2 | `loadProducts()` inicia → `notifyListeners()` |
| 3 | `loadProducts()` termina → `notifyListeners()` |

**Total: 3 rebuilds**

### 3c. Filtro de tienda cambia

Igual que categoría: **3 rebuilds**

### 3d. Búsqueda por texto (cada tecla)

`setSearchQuery()` → `notifyListeners()` → **1 rebuild por tecla**

**Problema:** El listener de `_searchController` se dispara en cada tecla, cada tecla reconstruye `MarketExplorerView` completo (SliverAppBar, StoreFilterSelector, VibeCategoryBar, además de la lista de productos). Aunque el filtrado es local, la reconstrucción del árbol completo es costosa.

### 3e. Cada tarjeta de producto

Cada `VibeProductCard` contiene:
- `_PriceComparison` widget que en `build()` llama a `context.read<ComparisonProvider>().compareProduct(entity.id)` — esto **no** causa rebuilds adicionales del card porque usa `read()` en lugar de `watch()`, pero sí ejecuta lógica de comparación en cada build del card.

## 4. Tiempos Estimados por Etapa

Basado en análisis del código (no instrumentación en dispositivo real):

| Etapa | Tiempo estimado (ms) | Tipo |
|---|---|---|
| Conexión Supabase (handshake + TLS) | 50–150 | Red |
| Query supermarkets (tabla pequeña, ~4 filas) | 20–60 | Supabase |
| Query v_products_complete (sin filtros, todos los productos) | 100–500 | Supabase + Red |
| Parseo JSON → ProductEntity (N productos × N stores) | 5–30 | Flutter (CPU) |
| `StoreModel.fromJson()` (4 stores) | <1 | Flutter |
| `filterAndGroupProducts()` (O(n) sobre todos los productos) | 2–10 | Flutter |
| `context.watch<ExplorerProvider>().groupedProducts` | 2–10 | Flutter |
| `VibeProductCard.build()` × N tarjetas | 1–5 c/u | Flutter |
| `Image.network(logo)` | 50–300 c/u | Red |
| `Image.network(producto)` | 100–500 c/u | Red |
| `_PriceComparison.build()` → `compareProduct()` | 1–3 | Flutter |

**Tiempo total estimado (carga inicial fría):** 300–1,500 ms (depende del caché de imágenes y velocidad de red).

## 5. Cuello de Botella Identificado

### Distribución estimada del tiempo de carga inicial

| Componente | % | Evidencia |
|---|---|---|
| **Supabase (query + red)** | 35% | 2 consultas secuenciales-concurrentes, v_products_complete devuelve todos los productos |
| **Imágenes de producto (carga red)** | 30% | Cada card carga 1+ imágenes `Image.network`. Sin caché explícita. Se cargan al hacer build del card. |
| **Reconstrucciones innecesarias** | 15% | 5 rebuilds de MarketExplorerView completo en carga inicial. 1 rebuild por tecla en búsqueda. |
| **Logos de tienda (carga red)** | 10% | Cada card carga logo de tienda vía `Image.network`. Misma URL, múltiples descargas. |
| **Filtrado/agrupación local** | 5% | `filterAndGroupProducts()` O(n) en cada rebuild. |
| **Parseo y construcción de widgets** | 5% | Creación de árbol de widgets, `_PriceComparison` por card. |

### Diagnóstico

- **Cuello principal: Supabase** no por lentitud de la BD, sino porque **cada filtro (categoría, tienda) descarta los datos ya cargados y vuelve a consultar**. La app nunca reutiliza datos.
- **Cuello secundario: Red de imágenes**. No hay precarga, no hay caché explícita, no hay lazy loading controlado. Las imágenes se descargan cuando el widget se renderiza, que ocurre múltiples veces por los rebuilds.
- **Cuello terciario: Reconstrucciones**. El patrón cascade en `initState` causa 5 notifyListeners sin necesidad. Los rebuilds por tecla en búsqueda son el caso más grave si el catálogo es grande.

## 6. Lista Priorizada de Problemas Encontrados

### 🔴 P1 — ProductProvider.loadProducts() se llama sin necesidad al cambiar tabs
**Archivo:** `lib/features/explorer/screens/explorer_shell.dart:54`
**Causa:** `MarketExplorerView` se crea dentro de `_ExplorerShellState.build()` como parte de `pages[_navIndex]`. Cada vez que `_navIndex` cambia y vuelve a 0, se crea un nuevo `MarketExplorerView`, cuyo `initState()` ejecuta `loadStores()` + `loadProducts()` desde cero.
**Impacto:** Cada navegación de tab → 2 consultas Supabase + 5 rebuilds.
**Riesgo de optimización:** Bajo — mover `MarketExplorerView` fuera del build o usar `IndexedStack` / `AutomaticKeepAliveClientMixin`.

### 🔴 P2 — No hay caché de productos entre filtros
**Archivo:** `lib/features/products/providers/product_provider.dart:96`
**Causa:** `loadProducts()` reemplaza `_products` completamente con el resultado de Supabase. Cambiar categoría o tienda descarta los productos previamente cargados (incluso "todos") y ejecuta una consulta nueva.
**Impacto:** Cada cambio de filtro = 1 consulta Supabase completa + 3 rebuilds.
**Riesgo de optimización:** Bajo-Medio — caché en memoria con invalidación por tiempo o por cambio significativo.

### 🔴 P3 — Cascade en initState sin await
**Archivo:** `lib/features/explorer/screens/market_explorer_view.dart:35-38`
**Causa:**
```dart
context.read<ExplorerProvider>()
  ..loadStores()                          // ← retorna Future, no se await
  ..setCategory(...);                     // ← se ejecuta inmediatamente
```
`loadStores()` inicia su ejecución async pero `setCategory()` se ejecuta inmediatamente (por el cascade), lanzando `loadProducts()` concurrentemente con `getStores()`. Ambas mutan el estado y llaman `notifyListeners()` de forma descoordinada.
**Impacto:** 5 rebuilds en lugar de 3. Posible doble renderizado si `loadStores()` termina después que `loadProducts()`.
**Riesgo de optimización:** Muy bajo — simplemente usar `await` secuencial o eliminar la dependencia.

### 🟡 P4 — Sin debounce ni throttling en búsqueda
**Archivo:** `lib/features/explorer/screens/market_explorer_view.dart:31-33`
**Causa:** El listener del `TextEditingController` se dispara en cada tecla y llama a `ExplorerProvider.setSearchQuery()` que hace `notifyListeners()`. Cada tecla reconstruye `MarketExplorerView` completo.
**Impacto:** En catálogos grandes (>100 productos), cada tecla ejecuta `filterAndGroupProducts()` O(n) para filtrar/agrupar, más el rebuild de todo el árbol de widgets.
**Riesgo de optimización:** Muy bajo — agregar `debounce` de 300ms en el listener.

### 🟡 P5 — ComparisonProvider.compareProduct() en cada tarjeta
**Archivo:** `lib/features/comparison/services/comparison_service.dart`
**Causa:** `_PriceComparison.build()` dentro de cada `VibeProductCard` llama a `provider.compareProduct(entity.id)` que itera todos los precios del producto. Aunque usa `read()` (no `watch()`), la lógica se ejecuta en cada build de cada tarjeta.
**Impacto:** Si hay 30 tarjetas visibles, se ejecutan 30 comparaciones en cada rebuild del Explorer.
**Riesgo de optimización:** Medio — los resultados de comparación ya se cachean en `ComparisonProvider._cache`, pero se recomputan en cada rebuild del card.

### 🟡 P6 — VibeAiAssistant carga todos los productos en cada pregunta
**Archivo:** `lib/features/assistant/screens/vibe_ai_assistant.dart:190`
**Causa:** `repo.listProducts(storeIds: null)` se ejecuta cada vez que el usuario hace una pregunta al asistente. Esto consulta `v_products_complete` completo desde Supabase.
**Impacto:** Cada pregunta = 1 consulta Supabase completa + parseo de todos los productos, incluso si los productos no cambiaron desde la última pregunta.
**Riesgo de optimización:** Bajo — reusar `ProductProvider.products` si ya están cargados, o cachear el contexto.

### 🟢 P7 — Logos de tienda sin caché explícita
**Archivo:** `lib/features/products/widgets/vibe_product_card.dart:85-90`
**Causa:** `Image.network(storeData['logo_url'])` se ejecuta en cada `VibeProductCard.build()`. Sin `cached_network_image`, Flutter usa su `ImageCache` global (por defecto 1000 imágenes, 50MB). Si el card se reconstruye, puede re-descargar el logo.
**Impacto:** Múltiples descargas del mismo logo en una sesión. Las tarjetas se reconstruyen en cada búsqueda y en los 5 rebuilds de carga inicial.
**Riesgo de optimización:** Muy bajo — agregar `cached_network_image` package o usar `ImageCache` más agresivo.

### 🟢 P8 — Imágenes de producto sin precarga
**Archivo:** `lib/features/products/widgets/vibe_image_slider.dart:160-165`
**Causa:** `Image.network()` en cada tarjeta se descarga al renderizar la tarjeta. No hay precarga en segundo plano.
**Impacto:** La primera vez que se ven las tarjetas, todas empiezan a descargar imágenes simultáneamente. Flutter maneja concurrencia pero sin priorización.
**Riesgo de optimización:** Bajo — `precacheImage()` en segundo plano después de cargar productos.

### 🟢 P9 — ProductDisplayHelper.getComparisonPreview() llamada en cada build
**Archivo:** `lib/features/products/helpers/product_display_helper.dart:54-70`
**Causa:** `_PriceComparison` llama a `getComparisonPreview()` que a su vez llama a `provider.compareProduct()`. Se ejecuta en cada build de cada card.
**Impacto:** Carga computacional O(n × m) donde n = cards, m = precios por producto.
**Riesgo de optimización:** Muy bajo — ya hay caché en el provider.

## 7. Recomendaciones Ordenadas por Impacto

| # | Recomendación | Impacto estimado | Riesgo | Archivos a modificar |
|---|---|---|---|---|
| 1 | **Mantener vivo Explorer con IndexedStack** | Elimina 2 consultas y 5 rebuilds por navegación | Bajo | `explorer_shell.dart` |
| 2 | **Cachear productos en memoria entre filtros** | Elimina ~70% de consultas a Supabase | Medio | `product_provider.dart`, `explorer_provider.dart` |
| 3 | **Debounce en búsqueda (300ms)** | Reduce rebuilds de N por tecla a 1 por palabra | Muy bajo | `market_explorer_view.dart` |
| 4 | **Await secuencial en initState** | Reduce 5 rebuilds → 3 en carga inicial | Muy bajo | `market_explorer_view.dart` |
| 5 | **Reusar ProductProvider.products en Assistant** | Elimina 1 consulta Supabase por pregunta | Bajo | `vibe_ai_assistant.dart` |
| 6 | **cached_network_image para logos** | Reduce descargas repetidas de logos | Muy bajo | `pubspec.yaml`, `vibe_product_card.dart` |
| 7 | **Precarga de imágenes** | Mejora perceived performance | Bajo | `market_explorer_view.dart` |

## 8. Riesgos de Cada Optimización

| # | Riesgo | Mitigación |
|---|---|---|
| 1 | **IndexedStack mantiene widgets en memoria.** El explorador consume RAM aunque no esté visible. | Usar `AutomaticKeepAliveClientMixin` con límite de tiempo. |
| 2 | **Caché en memoria puede quedar desactualizado** si otro usuario o sesión modifica productos en Supabase. | Invalidar caché cada 5 minutos o en pull-to-refresh. |
| 3 | **Debounce retrasa la respuesta visual** 300ms. | Usar 150ms si se siente lento. |
| 4 | **Jobs secuenciales aumentan tiempo total de carga** en lugar de concurrentes. | La diferencia real es mínima (<50ms) y el beneficio de menos rebuilds lo compensa. |
| 5 | **Assistant usa datos posiblemente desactualizados** si ProductProvider no ha cargado recientemente. | Forzar recarga si han pasado >5 min. |
| 6 | **Nueva dependencia** en `cached_network_image`. | Usar `ImageCache` nativo con tamaño ajustado si no se quiere dep. |
| 7 | **Precarga consume ancho de banda** aunque el usuario no vea las imágenes. | Solo precargar primeras 5-10 tarjetas. |

## 9. Estado de Verificación

```
flutter analyze lib/  → Sin cambios realizados (fase de análisis únicamente)
npx tsc --noEmit      → Sin cambios realizados
```

No se modificó ningún archivo de código. Solo se creó este reporte.
