# Local Dev Setup

## Prerequisites
- Flutter 3.22+ (uses `--dart-define-from-file`)
- Node.js 20+
- pnpm
- Supabase project (local or cloud)

## Quick Start (from zero)

```powershell
# 1. Clone
git clone <repo>
cd VibeShopping

# 2. Create Flutter config from template
copy .env.example .env

# 3. Edit .env with your Supabase credentials
notepad .env

# 4. Run the app
.\run.ps1
```

**That's it.** No IDE setup, no global env vars, no hidden steps.

---

## Configuration System

### Architecture

```
Project Root/
├── .env                 # Flutter dart-define values (gitignored)
├── .env.example         # Template (committed)
├── run.ps1              # PowerShell wrapper
├── run.bat              # cmd.exe wrapper
└── server/
    ├── .env             # Server env vars (gitignored by root .gitignore)
    └── .env.example     # Server template (committed)
```

### How it works

Flutter 3.22+ supports `--dart-define-from-file=<file>`, which reads a `.json` or `.env` file and passes every key-value pair as a `--dart-define`.

The same file works for all commands:

```bash
flutter run --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
flutter build appbundle --dart-define-from-file=.env
```

No need for manual `--dart-define=KEY=VAL` flags. No dependency on IDE-run configurations.

### dart-define flags

| Variable | Required | Default | Read by | Purpose |
|---|---|---|---|---|
| `SUPABASE_URL` | Always | — | `supabase_config.dart:18` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Always | — | `supabase_config.dart:20` | Supabase anonymous key |
| `USE_NODE_API` | Optional | `false` | `api_config.dart:20` | Use Node.js backend |
| `API_BASE_URL` | Conditional | `http://localhost:3001` | `api_config.dart:41` | Node.js API base URL |

Each variable has exactly **one point of reading** in the code.

### Required vs Optional

Add to `.env`:
```
# Required (always)
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=eyJ...

# Optional — uncomment when needed
# USE_NODE_API=true
# API_BASE_URL=http://localhost:3001
```

---

## Running the App

### PowerShell (recommended)

```powershell
.\run.ps1                    # default device
.\run.ps1 -Device emulator-5554
```

### cmd.exe

```cmd
run.bat
```

### VS Code (F5)

Press `F5` — the `.vscode/launch.json` already passes `--dart-define-from-file=.env`. No global env vars needed.

### Android Studio

Open `Run → Edit Configurations`, select `main.dart`. The `additionalArgs` field already contains `--dart-define-from-file=.env`.

### Direct terminal

```bash
flutter run --dart-define-from-file=.env
```

---

## Switching Between Supabase Direct vs Node.js Backend

The app can run in two modes:

| Mode | `.env` setting | Data path |
|---|---|---|
| **Supabase direct** (default) | (no `USE_NODE_API`) | Flutter → Supabase SDK |
| **Node.js backend** | `USE_NODE_API=true` | Flutter → Node.js API → Supabase |

To switch:

```powershell
# Supabase direct (just SUPABASE_URL + SUPABASE_ANON_KEY)
.\run.ps1

# Node.js backend (add USE_NODE_API=true + API_BASE_URL to .env)
notepad .env
.\run.ps1
```

The AI assistant always uses the Node.js backend via `POST /api/v1/assistant/ask`. The Supabase Edge Function path was removed in Phase D.4.

---

## Adding a New Environment Variable

1. Add the key to `.env.example` with a placeholder value and documentation comment.
2. Read it in code via `String.fromEnvironment('KEY')`, `bool.fromEnvironment('KEY')`, or `int.fromEnvironment('KEY')`.
3. Update the dart-define flags table above.
4. Ensure `.env` remains gitignored.

---

## Server

```bash
# One-time setup
cd server
copy .env.example .env
notepad .env                  # fill SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, GEMINI_API_KEY

# Run
pnpm install
pnpm dev
```

### Server env vars

| Variable | Required | Read by | Purpose |
|---|---|---|---|
| `PORT` | No (3001) | `env.ts:13` → Zod | Fastify port |
| `SUPABASE_URL` | Yes | `env.ts:14` → Zod | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | `env.ts:15` → Zod | Service role (admin) |
| `GEMINI_API_KEY` | Yes | `env.ts:16` → Zod | Gemini AI API key |
| `LOG_LEVEL` | No (info) | `env.ts:17` → Zod | Pino log level |
| `NODE_ENV` | No (development) | `env.ts:18` → Zod | Environment mode |

### Dead variables

- `SUPABASE_JWT_SECRET` — present in `server/.env` but **zero consumers** in code. Listed in LEGACY.md.

> ⚠️ **Note**: `GEMINI_API_KEY` is also read raw via `process.env.GEMINI_API_KEY` in `gemini.service.ts:12` and `routes/index.ts:42`, bypassing Zod validation in `env.ts`. This is a code quality finding but not a security risk since the file is gitignored.

---

## Phase 5 — AI Assistant Backend Migration (Complete)

The AI assistant now uses **only** the Node.js backend (`POST /api/v1/assistant/ask`). The Supabase Edge Function `asistente-compras` is no longer called by Flutter and should be deleted from the Supabase Dashboard.

### Current Data Flow

```
User types question
    ↓
vibe_ai_assistant.dart
    ↓ context.read<ProductRepository>()
ProductRepository.listProducts(storeIds: _allStoreIds)
    ↓ returns List<ProductEntity>
Build structured text context (name + store prices)
    ↓
AssistantService.askQuestion() → _apiClient.post('/api/v1/assistant/ask')
    ↓
Node.js backend → authMiddleware → Zod validation → GeminiService
    ↓
Gemini API
```

### Server endpoint
- `POST /api/v1/assistant/ask` — receives `{ question, context? }`, validates with Zod, rate-limited (20/min), calls Gemini, returns `{ success, data: { response } }`.
- Auth: JWT middleware (same as other routes).
- Logging: Pino (request.log).

## Progress

### Done
- **Manual Lists Provider refactor**: Converted `part of` files to 4 mixins (`ManualListCrudMixin`, `ManualListSearchSortMixin`, `ManualListStatisticsMixin`, `ManualListComparisonMixin`). Enums `ListSortMode`/`ListFilterMode` moved to `manual_list_entity.dart`. Provider uses `with Mixin1, Mixin2, ...` — no `part` directives. Protected accessors for internal state.
- **Widget extraction**: Both views rewritten to use public widgets. `manual_lists_view.dart` 890→212 lines. `manual_list_detail_view.dart` 927→226 lines. Extracted widgets: `ListHeader`, `ListSearchSortBar`, `ListFilterChips`, `ListCard`, `ListNoSearchResults`, `ListEmptyState`, `DetailHeader`, `ItemCard`, `ComingSoonBanner`, `DetailEmptyItems`, `StatChip`, `ConfirmActionDialog`, `EditTextDialog`.
- **Price Comparator (MVP)**: Created `StorePriceComparison` widget showing prices across stores for a product, highlighting cheapest. Integrated into `ProductDetailView` via `ComparisonProvider.compareProduct()`.
- **Phase B.3 — Navigation data model**: `StoreModel` extended with `double? latitude/longitude`, `copyWith`, `==`/`hashCode`, `toString`. `SupabaseExplorerRepository` documented for future coordinates. Navigation module remains decoupled. No UI changes.
- **Phase B.5 — Supermarkets extended**: Migration `20260709_extend_supermarkets.sql` adds `latitude`, `longitude`, `address`, `parking`, `delivery`, `pickup` to `supermarkets`. Coordinates populated at district level (GAM). `ProductPrice`/`StorePrice` untouched — coordinates live exclusively in `StoreModel`.
- **Phase D.4 — Edge Function removed**: Flutter no longer calls `asistente-compras` Edge Function. `AssistantService` uses only Node.js backend (`POST /api/v1/assistant/ask`). `useNodeAssistant` flag removed from `ApiConfig`. `SupabaseClient` dependency removed from `AssistantService`. Delete `asistente-compras` from Supabase Dashboard.
- **flutter analyze lib/**: 0 issues. **npx tsc --noEmit**: 0 errors.

## Code Deletion Rules (Permanent)

Before deleting any file, class, method, variable, helper, widget, provider, DTO, Entity, service, repository, or constant:

1. **Find all consumers** of the element.
2. **Confirm zero references** — direct or indirect.
3. **Verify no usage via**: Provider, DI, reflection, routes, navigation, dynamic imports, extensions, barrel exports.
4. **Run `flutter analyze`** and **`npx tsc --noEmit`** before deleting.
5. **If unsure, DO NOT delete.** Mark `LEGACY` with a comment explaining why instead.
6. **Delete only when**: zero active references, no indirect deps, no functional impact, compilation OK, analysis clean.

For every deletion, document in the report:
- What was deleted and why
- What replaces it
- How safety was verified

## Directory Structure Conventions (Phase 8C)

### Feature module layout
```
lib/features/<name>/
  domain/entities/
  domain/repositories/       (abstract)
  data/dto/
  data/repositories/         (implementations)
  presentation/providers/
  presentation/helpers/      (pure presentation logic, no widgets)
  presentation/screens/      (feature-owned screens)
  presentation/widgets/      (feature-owned widgets only)
```

### Shared widgets (used by multiple features)
```
lib/ui/common_widgets/       (VibeProductCard, VibeImageSlider)
```

### Feature-specific screens & widgets go inside the feature, not in ui/
- `lib/features/explorer/presentation/screens/` — 4 screens (market_explorer, product_detail, shopping_list, vibe_manual_lists)
- `lib/features/explorer/presentation/widgets/` — 6 widgets (vibe_side_drawer, vibe_search_bar, etc.)
- Screens import feature widgets via `../widgets/`, shared widgets via `../../../../ui/common_widgets/`

### Cross-feature imports (allowed)
- Explorer → Products: `product.entity.dart`, `product_provider.dart`, `product_display_helper.dart`
- Explorer → ShoppingList: `shopping_list_entity.dart`, `shopping_list_provider.dart`
- Explorer → Auth: `auth_provider.dart`, `login_view.dart`
- Explorer → Assistant: `vibe_ai_assistant.dart` (via `ui/assistant/`)
- Products → Comparison: `comparison_provider.dart` (ProductDetailView → StorePriceComparison)
- Products → ShoppingList: `shopping_list_provider.dart` (VibeProductCard)
- No feature imports from `features/explorer/` (Explorer is a consumer, not a provider)

### Single source of truth
- `lib/core/constants/store_ids.dart` (StoreIds) — all store UUIDs
- `lib/core/vibe_constants.dart` (VibeColors) — palette: navy `#2C3E50`, mint `#A8D5BA`, backgroundMint, backgroundWhite
- `lib/core/parse_image_urls.dart` (parseImageUrls) — shared image URL parsing (normaliza image_url → List<String>)
- `lib/core/network/api_client.dart` (ApiClient.unwrapData) — shared API response unwrapping
- `lib/features/products/presentation/helpers/product_display_helper.dart` — price resolution, image parsing

### Dependency Injection (Phase 4.3 — Final freeze)
- Providers are registered centrally in `lib/core/di/app_providers.dart`
- `AppProviders.providers` exposes a `List<dynamic>` that gets spread into `MultiProvider`
- `main.dart` only bootstraps the app (init Supabase, Hive, ApiClient) and delegates DI to `AppProviders`
- Adding a new feature = add provider to `app_providers.dart` + add screen to existing navigation
- No Service Locator, no GetIt, no reflection

### Dead code removed (Phase 8C consolidation / Phase 11 / Phase 4.3)
- `lib/core/auth_service.dart` — LEGACY, replaced by AuthProvider
- `lib/core/core.dart` — unused barrel file
- `lib/logic/` — entire directory (BasketProductEntity, ListBasketProductsUsecase)
- `lib/data/vibe_community_chat/community_chat_message_query.dart`
- `lib/ui/auth/auth_register_view.dart` / `auth_forgot_password_view.dart` — typedef wrappers
- No empty directories remain (`lib/data/repositories/` deleted)
- `flutter_test` (dev dep) — removed in Phase 11 (no test files exist)
- `flutter_lints` (dev dep) — removed in Phase 11 (not referenced in analysis_options.yaml)
- `vitest` (server dev dep) — removed in Phase 11 (no test files exist)
- `lib/core/repositories/comparison_repository.dart` — removed in Phase 4.3 (never implemented, no consumers)
- `lib/core/repositories/manual_list_repository.dart` — removed in Phase 4.3 (never implemented, no consumers)
- `lib/core/repositories/community_repository.dart` — removed in Phase 4.3 (never implemented, no consumers)

### Phase B.3 — Navigation data model prepared
- **`StoreModel`** (`lib/features/explorer/domain/store_model.dart`): added `double? latitude`, `double? longitude`, `copyWith()`, `==`/`hashCode`, `toString()`. `fromJson()` parses `latitude`/`longitude` via `(json['latitude'] as num?)?.toDouble()` — null-safe even if columns don't exist yet in Supabase.
- **`SupabaseExplorerRepository`** (`lib/features/explorer/data/supabase_explorer_repository.dart`): added FUTURE comment documenting that when `supermarkets` gains `latitude`/`longitude` columns, `StoreModel.fromJson` will read them automatically. References the migration file where this was planned.
- **`FakeNavigationRepository`**: unchanged — uses internal simulated coordinates (`NavigationLocation`, `StoreRoute` only). Does NOT inject fake coords into `StoreModel`. Module is fully decoupled.
- **Visual integration** (Navigate button in `StorePriceComparison` → `NavigationBottomSheet`): **pending** — requires real coordinates from Supabase or a fallback lookup. No UI changes in this phase.
- **Verification**: `flutter analyze lib/`: 0 issues. `npx tsc --noEmit`: 0 errors.

### Community feature removed (Phase 12)
- **Entire `lib/features/community/` directory** — 10 files (screens, widgets, providers, services, repositories, entities) were permanently deleted.
- **Server routes**: `server/src/routes/community.ts` deleted; `communityMessages` health check replaced with `v_products_complete`.
- **Why**: Community chat was a global chat feature with its own CRUD APIs, Supabase table (`community_messages`), and Node.js routes. It's being redesigned.
- **Intended replacement**: A per-product comment system associated with `product_master`, not a global chat. No timeline set — in roadmap for future release.
- **Navigation tab**: The "Comunidad" NavigationBar destination is preserved for structure; its body renders a simple "Próximamente" placeholder with no providers, services, repositories, or Supabase calls.
- **Verification**: `flutter analyze lib/`: 0 issues. `npx tsc --noEmit`: 0 errors. All community references (imports, DI registrations, server routes) eliminated.

### Phase D.2 — Explorer loading stabilization

- **`ExplorerProvider`**: Added `_initialized` guard. New `initialize()` method replaces the `initState` cascade — runs stores + products load once per session. `refresh()` is the sole public route for re-fetching. `_allCachedProducts` holds the full product list in memory for the session lifetime.
- **Local filtering**: `setCategory()`, `setStoreFilter()`, `setSearchQuery()` never call Supabase. All filtering operates on `_allCachedProducts` via `groupedProducts` getter. Category IDs resolved with private `_categoryIdsFor()` helper.
- **Flow**:
  ```
  MarketExplorerView.initState()
    ↓
  ExplorerProvider.initialize()
    ↓ (once per session — _initialized guard)
  ┌─ ExplorerService.getStores()  ──→ Supabase (supermarkets)
  └─ ProductProvider.loadProducts() ──→ Supabase (v_products_complete)
    ↓
  _allCachedProducts = full product list
    ↓
  setCategory / setStoreFilter / setSearchQuery
    ↓ (local only, no Supabase)
  groupedProducts getter → applyFilters() → notifyListeners()
  ```
- **Rebuilds**: initial load ~2 (was ~5), category/store/search change = 1 (was 3).
- **Queries to Supabase**: 2 total per session (was 2 every tab switch + n per filter change).

### Phase B.5 — Supermarkets extended for navigation
- **Migration created**: `server/supabase/migrations/20260709_extend_supermarkets.sql`
- **Columns added**: `latitude DOUBLE PRECISION`, `longitude DOUBLE PRECISION`, `address TEXT`, `parking BOOLEAN DEFAULT FALSE`, `delivery BOOLEAN DEFAULT FALSE`, `pickup BOOLEAN DEFAULT FALSE`
- **Data populated**: Approximate coordinates (OpenStreetMap, San Isidro de El General, Pérez Zeledón) for Buen Día (cerca Maxi Palí), Más Súper (cerca CoopeAgri), Súper Ahorro (cerca Walmart), Super Vida Saludable (Sector Plaza Monte General). `address` uses friendly reference descriptions. `parking` = TRUE for Súper Ahorro and Super Vida Saludable (evidencia pública de parqueo en Walmart y Plaza Monte General).
- **Architecture**: Coordinates belong exclusively to `StoreModel` (Explorer domain). `ProductPrice` and `StorePrice` remain unchanged — no coordinate duplication. Navigation consumes coordinates via `StoreModel` using `storeId`, never via product price models.
- **Verification**: `flutter analyze lib/`: 0 issues. `npx tsc --noEmit`: 0 errors.

### Verification

Before committing changes:
```bash
# Flutter analysis (can be slow on first run)
flutter analyze lib/

# Server type-check
cd server && npx tsc --noEmit

# Server tests
cd server && pnpm test
```
