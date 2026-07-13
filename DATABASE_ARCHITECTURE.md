# Database Architecture

> Generado durante Fase D.5 — Consolidación de la Base de Datos.
> Documento exhaustivo de tablas, vistas, migraciones, índices, relaciones y
> preparación para fases futuras.

---

## Contents

1. [Inventory: Tables](#1-inventory-tables)
2. [Inventory: Views](#2-inventory-views)
3. [Migrations Audit](#3-migrations-audit)
4. [Consolidation Proposal](#4-consolidation-proposal)
5. [Relations Diagram](#5-relations-diagram)
6. [Indexes Audit](#6-indexes-audit)
7. [Future: Dynamic Categories](#7-future-dynamic-categories)
8. [Future: Product Comments](#8-future-product-comments)
9. [Cleanup Candidates](#9-cleanup-candidates)
10. [SQL Roadmap](#10-sql-roadmap)
11. [Recommendations](#11-recommendations)

---

## 1. Inventory: Tables

### 1.1 `products`

| Aspect | Detail |
|---|---|
| **Status** | MVP |
| **Purpose** | Per-supermarket product row — one row per (product × store) combination with its specific price |
| **Created in** | Outside migration system (Supabase Dashboard / initial setup) |
| **Consumed by** | `v_products_complete` VIEW (indirectly: Flutter Node.js server) |
| **Notes** | No migration creates this table. It was the original table before the `product_master` refactor. |

#### Columns (reconstructed from migrations and code)

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | `uuid` | NO | — | Primary Key |
| `master_product_id` | `uuid` | YES | — | FK → `product_master(id)` via `fk_products_master`, `ON DELETE SET NULL`. Nullable for legacy/incomplete products. |
| `name` | `text` | YES | — | Original product name (used to populate `product_master.canonical_name`) |
| `price` | `numeric` | YES | — | Price in CRC |
| `category_id` | `text` | YES | — | Legacy category identifier (e.g., `cat_lacteos`). Copied to `product_master`. |
| `subcategory` | `text` | YES | — | Subcategory (nullable, copied to master) |
| `image_url` | `text` | YES | — | Image URL (copied to master) |
| `supermarket_id` | `uuid` | YES | — | FK → `supermarkets(id)` |
| `created_at` | `timestamptz` | YES | `now()` | Creation timestamp |

#### Indexes

| Name | Columns | Type |
|---|---|---|
| `products_pkey` | `id` | Primary Key (auto) |
| `idx_products_master_product_id` | `master_product_id` | B-tree (created in paso4) |
| `uq_products_master_supermarket` | `(master_product_id, supermarket_id)` | Unique Constraint (creates index) |

#### Constraints

| Name | Type | Definition |
|---|---|---|
| `products_pkey` | PRIMARY KEY | `(id)` |
| `fk_products_master` | FOREIGN KEY | `(master_product_id)` → `product_master(id)` ON DELETE SET NULL |
| `uq_products_master_supermarket` | UNIQUE | `(master_product_id, supermarket_id)` |

#### RLS

**Disabled** — no RLS policies on this table. The server uses service_role key (bypasses RLS). Flutter's `SupabaseProductRepository` reads `v_products_complete` (not raw `products`).

---

### 1.2 `product_master`

| Aspect | Detail |
|---|---|
| **Status** | MVP |
| **Purpose** | Canonical product entity — one row per unique product regardless of store. Normalizes the many-to-many relationship between products and supermarkets. |
| **Born in** | `20260708_paso1_create_product_master.sql` |
| **Populated by** | `20260708_paso2_populate_product_master.sql` (also `populate_product_master.sql` — legacy duplicate) |
| **Consumed by** | `v_products_complete` VIEW (indirectly: Flutter, Node.js server) |

#### Columns

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | `uuid` | NO | — | Primary Key. Same UUID as `products.master_product_id`. |
| `canonical_name` | `text` | YES | — | Canonical name taken from oldest `products.name` per group. Used for search and display. |
| `brand` | `text` | YES | — | **Always NULL.** The `products` table has no `brand` column. Reserved for future use. |
| `category_id` | `text` | YES | — | Category identifier (e.g., `cat_lacteos`, `cat_carnes`). String-based, not a FK to a categories table. |
| `subcategory` | `text` | YES | — | Subcategory (e.g., "Quesos" for `cat_lacteos`) |
| `image_url` | `text` | YES | — | Main product image URL |
| `created_at` | `timestamptz` | YES | `now()` | Creation timestamp (copied from oldest `products.created_at` per group) |

#### Indexes

| Name | Columns | Type |
|---|---|---|
| `product_master_pkey` | `id` | Primary Key (auto) |
| `idx_product_master_category` | `category_id` | B-tree |
| `idx_product_master_canonical_name` | `canonical_name` | B-tree |

#### Constraints

| Name | Type | Definition |
|---|---|---|
| `product_master_pkey` | PRIMARY KEY | `(id)` |

#### RLS

**Disabled.**

---

### 1.3 `supermarkets`

| Aspect | Detail |
|---|---|
| **Status** | MVP + Experimental (navigation columns) |
| **Purpose** | Store definitions — one row per supermarket. Contains display info and (experimental) navigation data. |
| **Created in** | Outside migration system (Supabase Dashboard / initial setup) |
| **Extended by** | `20260709_extend_supermarkets.sql` |
| **Consumed by** | Flutter `SupabaseExplorerRepository` (`.from('supermarkets').select('*')`), `v_products_complete` VIEW |

#### Columns

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | `uuid` | NO | — | Primary Key |
| `name` | `text` | YES | — | Display name (e.g., "Buen Día", "Más Súper") |
| `logo_url` | `text` | YES | — | Store logo URL |
| `latitude` | `double precision` | YES | — | Added in 20260709. Approximate coordinates (OpenStreetMap). |
| `longitude` | `double precision` | YES | — | Added in 20260709. Approximate coordinates (OpenStreetMap). |
| `address` | `text` | YES | — | Added in 20260709. Friendly reference description. |
| `parking` | `boolean` | YES | `false` | Added in 20260709. |
| `delivery` | `boolean` | YES | `false` | Added in 20260709. |
| `pickup` | `boolean` | YES | `false` | Added in 20260709. |

#### Indexes

| Name | Columns | Type |
|---|---|---|
| `supermarkets_pkey` | `id` | Primary Key (auto) |

#### Constraints

| Name | Type | Definition |
|---|---|---|
| `supermarkets_pkey` | PRIMARY KEY | `(id)` |

#### RLS

**Disabled.**

#### Data (4 stores)

| Name | Coordinates | Parking |
|---|---|---|
| Buen Día | 9.3675, -83.6964 | No |
| Más Súper | 9.3719, -83.7048 | No |
| Súper Ahorro | 9.3503, -83.6744 | Yes |
| Super Vida Saludable | 9.3414, -83.6734 | Yes |

---

### 1.4 `stores` (eliminada)

| Aspect | Detail |
|---|---|
| **Status** | **Eliminada** |
| **Dropped in** | `20260711_drop_stores.sql` (Fase D.5.1) |
| **Born in** | Unknown (no migration) — probable artifact del Starter Kit de Supabase |
| **Data** | Vacía |
| **Referenced by** | **Ninguno.** Verificación cruzada confirmó cero referencias en Flutter, Node.js, VIEWs, migraciones, triggers, policies. |
| **DROP** | `DROP TABLE IF EXISTS stores;` — idempotente. |
| **Motivo** | Tabla huérfana sin consumidores. Ocupaba espacio sin propósito. |

---

### 1.5 `profiles`

| Aspect | Detail |
|---|---|
| **Status** | **Does not exist.** Zero references across the entire project. |
| **Notes** | No profiles table exists. Auth relies solely on Supabase Auth (`auth.users`). User metadata (name, avatar, preferences) is not stored anywhere. |

---

## 2. Inventory: Views

### 2.1 `v_products_complete`

| Aspect | Detail |
|---|---|
| **Status** | MVP — **single source of truth** for all product queries |
| **Purpose** | Flat join of `products` + `product_master` + `supermarkets`. Eliminates the need for nested selects and manual JOINs in application code. |
| **Born in** | `20260708_paso4_create_view.sql` |
| **Consumed by** | Flutter (`SupabaseProductRepository`), Node.js (`routes/products.ts`, `routes/index.ts` health check) |
| **Replaces** | Legacy `select('*, product_master(*), supermarkets(*)')` pattern — nested JSON parsing is dead. |

#### Columns

| Column | Source Table | Type | Notes |
|---|---|---|---|
| `product_id` | `products.id` | `uuid` | PK of the per-store product row |
| `master_product_id` | `product_master.id` | `uuid` | Canonical product ID |
| `canonical_name` | `product_master.canonical_name` | `text` | Used for search & display |
| `brand` | `product_master.brand` | `text` | Always NULL currently |
| `category_id` | `product_master.category_id` | `text` | String-based category |
| `subcategory` | `product_master.subcategory` | `text` | Subcategory |
| `image_url` | `product_master.image_url` | `text` | Product image |
| `price` | `products.price` | `numeric` | Price in CRC |
| `supermarket_id` | `products.supermarket_id` | `uuid` | Store FK |
| `supermarket_name` | `supermarkets.name` | `text` | Store display name |
| `supermarket_logo_url` | `supermarkets.logo_url` | `text` | Store logo |
| `supermarket_latitude` | `supermarkets.latitude` | `double precision` | For navigation |
| `supermarket_longitude` | `supermarkets.longitude` | `double precision` | For navigation |
| `master_created_at` | `product_master.created_at` | `timestamptz` | Master creation time |
| `product_created_at` | `products.created_at` | `timestamptz` | Per-store creation time |
| `store_product_key` | Computed | `text` | `master_product_id \|\| '|' \|\| supermarket_id` — used for Hive cache keys |

#### Query performance

- `LEFT JOIN` ensures products without `master_product_id` still appear (tolerance for incomplete data)
- `idx_products_master_product_id` speeds up the JOIN on `products.master_product_id`
- `idx_product_master_category` and `idx_product_master_canonical_name` speed up filters

#### Worth keeping?

**Yes.** This view is the single source of truth for product queries. Every application layer reads from it. It eliminates JOIN duplication across Flutter and Node.js.

#### Can it be simplified?

It is already as simple as a 3-table LEFT JOIN can be. No simplification needed.

---

## 3. Migrations Audit

### 3.1 Migration Classification

| # | File | Classification | Purpose |
|---|---|---|---|
| 1 | `20260708_paso1_create_product_master.sql` | **Fundacional** | Creates `product_master` table, indexes, column rename |
| 2 | `20260708_paso2_populate_product_master.sql` | **Fundacional** | Populates `product_master` from `products` via `DISTINCT ON` |
| 3 | `20260708_paso4_create_view.sql` | **Fundacional** | Creates `v_products_complete` VIEW, adds FK constraint |
| 4 | `20260708_populate_product_master.sql` | **Duplicada** (de 1+2) | All-in-one version doing the same work in a DO block |
| 5 | `20260708_unique_constraint_master_supermarket.sql` | **Evolutiva** | Adds UNIQUE constraint on `(master_product_id, supermarket_id)` |
| 6 | `20260708_corregir_duplicado_pan_cuadrado.sql` | **Hotfix** | Deletes one specific duplicate row |
| 7 | `20260709_extend_supermarkets.sql` | **Evolutiva** | Adds navigation columns to `supermarkets` |

### 3.2 Issues Detected

#### 3.2.1 Duplicate migration

`20260708_populate_product_master.sql` duplicates the work of `paso1` + `paso2`:
- Creates `product_master` (IF NOT EXISTS) — same as paso1
- Adds columns (IF NOT EXISTS) — same as paso1
- Populates data using `SELECT DISTINCT ON` — same as paso2
- Has NO orphan correction logic (unlike paso2)
- Has NO FK creation (unlike paso4)

**Assessment:** This was an attempt to create an all-in-one migration, but it was superseded by the paso1–4 sequence. It is safe to run (idempotent), but **redundant**.

#### 3.2.2 Missing initial schema migration

Neither `products` nor `supermarkets` base tables have a migration file. They were created outside the version control system.

**Risk:** If the Supabase project is ever recreated from scratch, these tables would not exist. The migrations depend on them, so `supabase db push` would fail.

#### 3.2.3 Hotfix in migration file

`20260708_corregir_duplicado_pan_cuadrado.sql` deletes a specific row by hardcoded UUID. This is a legitimate hotfix, but:
- The UUID `dbb04977-2dc6-4d84-a71d-cbbdf6c576b9` cannot be reproduced from scratch
- The migration depends on a specific data state that only exists in the current database

**Assessment:** Already executed. Safe to keep as documentation, but not reproducible.

#### 3.2.4 Obsolete column in `products`

The `products.name` column was the original product name before the `product_master` refactor. After populating `product_master`, `products.name` is effectively a duplicate of `product_master.canonical_name` (via the JOIN in the VIEW).

**Risk:** None (`products.name` is not read by any code). But it's dead weight.

#### 3.2.5 `product_master.brand` is always NULL

The `brand` column was added proactively but no source data exists (the `products` table has no `brand` column).

**Impact:** `FROM v_products_complete` returns `brand = NULL` for every row. Flutter ignores it. Node.js ignores it.

### 3.3 Idempotency

| Migration | Idempotent? | Mechanism |
|---|---|---|
| paso1 | Yes | `IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS` |
| paso2 | Yes | `ON CONFLICT DO UPDATE` |
| paso4 | Yes | `DROP CONSTRAINT IF EXISTS`, `CREATE OR REPLACE VIEW` |
| populate_product_master | Yes | `IF NOT EXISTS` in DO block |
| unique_constraint | Yes | `DROP CONSTRAINT IF EXISTS` before creating |
| corregir_duplicado | **No** | Hardcoded DELETE — safe to rerun (row already deleted) |
| extend_supermarkets | Yes | `ADD COLUMN IF NOT EXISTS`, deterministic UPDATEs |

---

## 4. Consolidation Proposal

> A logical reorganization. Files are NOT renamed — this is a proposal for future action.

### Proposed file structure (logical)

```
server/supabase/migrations/
├── 001_initial_schema.sql           ← CREATE TABLE products, supermarkets (migration needed)
├── 002_product_master.sql           ← Current paso1 + paso2 (merged)
├── 003_fk_and_view.sql              ← Current paso4 (FK + v_products_complete)
├── 004_indexes_and_constraints.sql  ← Current unique_constraint
├── 005_navigation.sql               ← Current extend_supermarkets
├── 006_hotfix_pan_cuadrado.sql      ← Current corregir_duplicado (documentation)
└── 007_cleanup.sql                  ← DROP stores, DROP legacy columns
```

### What to do with existing files

| Current file | Action |
|---|---|
| `paso1_create_product_master.sql` | Keep as-is (already executed). |
| `paso2_populate_product_master.sql` | Keep as-is. |
| `paso4_create_view.sql` | Keep as-is. |
| `populate_product_master.sql` | **Candidates for deletion** — redundant duplicate. Mark as `LEGACY` or delete in a future cleanup phase (requires verifying it was already applied). |
| `unique_constraint_master_supermarket.sql` | Keep as-is. |
| `corregir_duplicado_pan_cuadrado.sql` | Keep for documentation. |
| `extend_supermarkets.sql` | Keep as-is. |

Best practice for new projects: add a new migration `20260710_initial_schema_snapshot.sql` that recreates `products` and `supermarkets` from scratch using `CREATE TABLE IF NOT EXISTS`.

---

## 5. Relations Diagram

```
┌──────────────────┐
│   auth.users     │  ← Supabase Auth managed
│  (Supabase Auth) │    (not a project table)
└────────┬─────────┘
         │ (JWT)
         ▼
┌─────────────────────────────────────────────┐
│             APPLICATION LAYER               │
├─────────────────────┬───────────────────────┤
│     FLUTTER         │    NODE.JS SERVER     │
│                     │                       │
│ SupabaseProductRepo │  routes/products.ts   │
│   └─ v_products_c.  │    └─ v_products_c.   │
│ ExplorerRepository  │  routes/index.ts      │
│   └─ supermarkets   │    └─ v_products_c.   │
│ AuthService         │  middleware/auth.ts   │
│   └─ auth.X()       │    └─ auth.getUser()  │
│                     │  AssistantService     │
│ ManualListProvider  │    └─ Gemini API      │
│   └─ Hive (local)  │    (no DB access)     │
│ ComparisonProvider  │                       │
│   └─ ProductPrice   │                       │
│ NavigationService   │                       │
│   └─ FakeRepo/     │                       │
│      GeoRepo        │                       │
└─────────────────────┴───────────────────────┘
         │                      │
         │    ┌─────────────────┘
         ▼    ▼
┌─────────────────────────────────────────────┐
│          DATABASE LAYER                     │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────┐    ┌──────────────┐       │
│  │ product_master│    │ supermarkets │       │
│  ├──────────────┤    ├──────────────┤       │
│  │ id (PK)     │◄┐   │ id (PK)      │       │
│  │ canonical   │ │   │ name         │       │
│  │ brand (NULL)│ │   │ logo_url     │       │
│  │ category_id │ │   │ latitude     │       │
│  │ subcategory │ │   │ longitude    │       │
│  │ image_url   │ │   │ address      │       │
│  │ created_at  │ │   │ parking      │       │
│  └──────────────┘ │   │ delivery     │       │
│                   │   │ pickup       │       │
│                   │   └──────────────┘       │
│                   │         │                │
│                   │         │                │
│  ┌────────────────┴─────────┴────────────┐   │
│  │           v_products_complete         │   │
│  │  (products p                          │   │
│  │    LEFT JOIN product_master pm        │   │
│  │    LEFT JOIN supermarkets s)          │   │
│  ├────────────────────────────────────────┤   │
│  │ product_id, master_product_id,        │   │
│  │ canonical_name, brand, category_id,   │   │
│  │ subcategory, image_url, price,        │   │
│  │ supermarket_id, supermarket_name,     │   │
│  │ supermarket_logo_url,                 │   │
│  │ supermarket_latitude,                 │   │
│  │ supermarket_longitude,                │   │
│  │ master_created_at, product_created_at,│   │
│  │ store_product_key                     │   │
│  └────────────────────────────────────────┘   │
│                     ▲                         │
│                     │                         │
│     ┌───────────────┴───────────────┐         │
│     │          products             │         │
│     ├───────────────────────────────┤         │
│     │ id (PK)                      │         │
│     │ master_product_id (FK)──►pm   │         │
│     │ name (legacy, unused)        │         │
│     │ price                        │         │
│     │ category_id (redundant)      │         │
│     │ subcategory (redundant)      │         │
│     │ image_url (redundant)        │         │
│     │ supermarket_id (FK)──►sup.   │         │
│     │ created_at                   │         │
│     └───────────────────────────────┘         │
│                                             │
│  ┌──────────────┐  LEGACY                   │
│  │    stores    │  (empty, orphan)          │
│  └──────────────┘                           │
└─────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│         LOCAL / EXTERNAL STORAGE            │
├─────────────────────────────────────────────┤
│  Hive (Flutter)                             │
│  └─ manual_lists box ─── ManualListProvider  │
│                                             │
│  Gemini API (external)                      │
│  └─ AssistantService → Node.js → Gemini     │
└─────────────────────────────────────────────┘
```

### Module-to-Table Mapping

| Module | Reads | Writes | Notes |
|---|---|---|---|
| **Explorer** | `supermarkets`, `v_products_complete` | None | Reads via Flutter Supabase SDK |
| **Products** | `v_products_complete` | None | Via Flutter or Node.js |
| **Comparison** | `v_products_complete` (via ProductProvider) | None | Pure in-memory aggregation |
| **Auth** | `auth.users` (via Supabase Auth API) | None | No custom users/profiles table |
| **Manual Lists** | None | Hive (local) | No Supabase involvement |
| **Navigation** | `supermarkets` (coordinates) | None | Via `StoreModel`. Coordinates from supermarkets table. |
| **Assistant** | None (uses Node.js API) | None | No direct database access. Context from ProductProvider memory. |

---

## 6. Indexes Audit

### 6.1 Existing Indexes

| Table | Index Name | Columns | Type | Created By |
|---|---|---|---|---|
| `products` | `products_pkey` | `id` | PK (B-tree) | Initial setup |
| `products` | `idx_products_master_product_id` | `master_product_id` | B-tree | `paso4_create_view.sql` |
| `products` | `uq_products_master_supermarket` | `(master_product_id, supermarket_id)` | Unique (B-tree) | `unique_constraint_master_supermarket.sql` |
| `product_master` | `product_master_pkey` | `id` | PK (B-tree) | `paso1_create_product_master.sql` |
| `product_master` | `idx_product_master_category` | `category_id` | B-tree | `paso1_create_product_master.sql` |
| `product_master` | `idx_product_master_canonical_name` | `canonical_name` | B-tree | `paso1_create_product_master.sql` |
| `supermarkets` | `supermarkets_pkey` | `id` | PK (B-tree) | Initial setup |

### 6.2 Missing Indexes (Recommendations)

| Table | Recommended Index | Columns | Why |
|---|---|---|---|
| `supermarkets` | `idx_supermarkets_name` | `name` | The only query on `supermarkets` is `SELECT * ORDER BY name`. Without an index, PostgreSQL performs a sequential scan + sort. For 4 stores this is negligible, but worth adding for correctness. |
| `products` | `idx_products_supermarket_id` | `supermarket_id` | The VIEW JOINs on `supermarket_id`. Although only 4 stores exist currently, this JOIN runs on every query. |
| `v_products_complete` | N/A | N/A | Views cannot have indexes directly. PostgreSQL may use underlying table indexes if statistics allow. |

### 6.3 Unnecessary/Redundant Indexes

| Index | Assessment |
|---|---|
| `product_master.brand` | No index exists (brand is always NULL). If populated in the future, an index may be needed. |
| `products.name` | No index exists. `products.name` is not queried anywhere (queries use `canonical_name` from the VIEW). |

### 6.4 Duplicate Indexes

**None detected.** All indexes serve distinct purposes.

---

## 7. Future: Dynamic Categories

### 7.1 Current situation

Categories are hardcoded strings in `product_master.category_id`:

```
cat_abarrotes, cat_granos, cat_lacteos, cat_huevos, cat_carnes,
cat_frutas, cat_higiene, cat_bebidas, cat_panaderia, cat_congelados,
cat_enlatados
```

Category grouping logic is duplicated in **two places**:
- **Node.js** `server/src/routes/products.ts:135-158` (`_buildCategoryFilter`)
- **Flutter** `lib/features/products/services/product_service.dart:17-50` (same switch statement)

This is the **definition of technical debt**: changing a category requires editing Dart + TypeScript + SQL data.

### 7.2 Proposed `categories` table

```sql
CREATE TABLE IF NOT EXISTS categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT UNIQUE NOT NULL,       -- 'cat_lacteos', 'abarrotes'
  name        TEXT NOT NULL,               -- 'Lácteos', 'Abarrotes'
  parent_id   UUID REFERENCES categories(id) ON DELETE SET NULL,  -- for grouping
  icon_url    TEXT,
  display_order INTEGER DEFAULT 0,
  is_active   BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 7.3 Relationship

```
categories.id
     ↑
     │ FK (future)
     │
product_master.category_id  ← currently TEXT, would become FK → categories(slug)
```

**Migration path:**
1. Create `categories` table
2. Insert all current category strings
3. Add FK `product_master.category_id → categories(slug)` (requires converting to NOT NULL and validating all values)
4. Remove `_buildCategoryFilter` from Node.js and `_resolveCategoryIds` from Flutter → replace with `JOIN categories` or `WHERE parent_id = X`

### 7.4 Impact

| Area | Impact |
|---|---|
| `product_master` | `category_id` becomes a FK. No structural change. |
| `v_products_complete` | Add `LEFT JOIN categories` to expose `category_name`, `parent_id`. |
| **Flutter** | Remove `_resolveCategoryIds`. Use `parent_id` from VIEW for grouping. |
| **Node.js** | Remove `_buildCategoryFilter`. Use `WHERE parent_id = X` or `WHERE slug = X`. |
| **Data** | Existing `category_id` values must match `categories.slug` exactly. Migrate data first. |

---

## 8. Future: Product Comments

### 8.1 Proposed schema

```sql
-- Core comments table
CREATE TABLE IF NOT EXISTS product_comments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID NOT NULL REFERENCES product_master(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  body        TEXT NOT NULL CHECK (char_length(body) >= 1 AND char_length(body) <= 2000),
  parent_id   UUID REFERENCES product_comments(id) ON DELETE CASCADE,  -- threaded replies
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Likes / votes
CREATE TABLE IF NOT EXISTS comment_likes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id  UUID NOT NULL REFERENCES product_comments(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (comment_id, user_id)
);

-- Reports / moderation
CREATE TABLE IF NOT EXISTS comment_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id  UUID NOT NULL REFERENCES product_comments(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reason      TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (comment_id, user_id)
);
```

### 8.2 Indexes

```sql
CREATE INDEX idx_product_comments_product ON product_comments(product_id);
CREATE INDEX idx_product_comments_user    ON product_comments(user_id);
CREATE INDEX idx_product_comments_parent  ON product_comments(parent_id);
CREATE INDEX idx_comment_likes_comment    ON comment_likes(comment_id);
CREATE INDEX idx_comment_reports_comment  ON comment_reports(comment_id);
```

### 8.3 RLS Policies

```sql
ALTER TABLE product_comments ENABLE ROW LEVEL SECURITY;

-- Anyone can read comments
CREATE POLICY "Comments are public" ON product_comments
  FOR SELECT USING (true);

-- Authenticated users can create comments
CREATE POLICY "Users can create comments" ON product_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own comments
CREATE POLICY "Users can update own comments" ON product_comments
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own comments
CREATE POLICY "Users can delete own comments" ON product_comments
  FOR DELETE USING (auth.uid() = user_id);
```

### 8.4 Integration with `v_products_complete`

Option A: Add comment count to the VIEW (LEFT JOIN + GROUP BY — may affect performance).
Option B: Create a separate endpoint `GET /api/v1/products/:id/comments`.

Recommendation: **Option B** — keeps the VIEW fast and focused.

### 8.5 Moderation strategy

- No automatic moderation in MVP
- Reports collected in `comment_reports`
- Admin panel (future) to review reports and delete/hide comments
- Soft-delete via `is_hidden BOOLEAN` column (instead of actual DELETE) recommended

---

## 9. Cleanup Candidates

### 9.1 Deleted

| Object | Reason | Migration |
|---|---|---|
| `stores` table | Empty. Zero references. Starter Kit artifact. | `20260711_drop_stores.sql` |

### 9.2 Can be deleted (safe)

| Object | Reason |
|---|---|
| `20260708_populate_product_master.sql` | Duplicate of paso1 + paso2. Already executed. No further value. |

### 9.3 Can be cleaned up (low risk)

| Object | Reason |
|---|---|
| `products.name` column | Superseded by `product_master.canonical_name`. Not queried anywhere. |
| `products.category_id` column | Superseded by `product_master.category_id`. The VIEW reads from master. |
| `products.subcategory` column | Superseded by `product_master.subcategory`. |
| `products.image_url` column | Superseded by `product_master.image_url`. |

**Note:** These columns in `products` are harmless duplicates. They occupy space but don't cause bugs. Cleaning them up requires a migration:

```sql
ALTER TABLE products DROP COLUMN IF EXISTS name;
ALTER TABLE products DROP COLUMN IF EXISTS category_id;
ALTER TABLE products DROP COLUMN IF EXISTS subcategory;
ALTER TABLE products DROP COLUMN IF EXISTS image_url;
```

This is safe because:
- `v_products_complete` reads these columns from `product_master` (via LEFT JOIN), not from `products`
- Flutter `fromViewMap` reads flat column names from the VIEW, not from `products`
- Node.js `_mapViewRowToProduct` reads from the VIEW, not from `products`

### 9.4 Edge Function

The `asistente-compras` Supabase Edge Function should be deleted from the Supabase Dashboard (Phase D.4). Flutter no longer calls it — all assistant traffic goes through the Node.js backend.

### 9.5 Storage

No Supabase Storage buckets were created for this project. Nothing to clean up.

---

## 10. SQL Roadmap

| Phase | What | Migration |
|---|---|---|
| **D.5** | Document, no changes | None |
| **D.5.1** | ✅ Initial schema snapshot | `20260710_initial_schema.sql` — `CREATE TABLE IF NOT EXISTS products`, `supermarkets`, `product_master` |
| **D.5.1** | ✅ Drop orphan `stores` | `20260711_drop_stores.sql` |
| **D.6** | Dynamic categories | `20260720_categories.sql` — categories table, FK, migration |
| **Future** | Navigation + real coordinates | Update `supermarkets.latitude/longitude` with real geocoding |
| **Future** | Product comments | `20260801_comments.sql` — comments, likes, reports, RLS |
| **Future** | Sync service | Table for sync metadata + queue |
| **Cleanup** | Drop legacy columns | `20260901_cleanup.sql` — `DROP COLUMN IF EXISTS name, category_id, subcategory, image_url` from `products` |

---

## 11. Recommendations

### Immediate (D.5.1) ✅

1. **Created initial schema migration** (`20260710_initial_schema.sql`) — `CREATE TABLE IF NOT EXISTS` for `products`, `supermarkets`, `product_master` with full docs, FKs, indexes.
2. **Dropped `stores` table** (`20260711_drop_stores.sql`) — zero references confirmed.
3. **Mark `20260708_populate_product_master.sql` as LEGACY** (it's a duplicate).
4. **Delete `asistente-compras` Edge Function** from Supabase Dashboard (already dead — Phase D.4).

### Short-term (D.6)

5. **Implement dynamic categories** — create `categories` table and migrate from hardcoded strings.
6. **Remove duplicated category logic** — delete `_buildCategoryFilter` from `products.ts` and `_resolveCategoryIds` from Flutter `product_service.dart`.

### Medium-term

7. **Drop redundant columns** from `products` table (`name`, `category_id`, `subcategory`, `image_url`) after verifying zero impact.
8. **Add missing indexes** (`idx_supermarkets_name`).

### Long-term

9. **Populate `product_master.brand`** — requires adding a `brand` column to the data source.
10. **Implement product comments** (schema proposed in §8).
11. **Real geocoding** for `supermarkets` — replace approximate coordinates with exact store locations.

---

*End of DATABASE_ARCHITECTURE.md — Generated during Phase D.5.*
