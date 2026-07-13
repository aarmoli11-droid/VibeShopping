# LEGACY & DEPRECATED Code

This document catalogs all deprecated code that remains in the codebase but should not be used for new development. Each entry explains why it's deprecated, what replaced it, and when it will be removed.

---

## Catalog

### 1. `lib/core/session.dart`
- **Status**: LEGACY
- **Why**: Legacy session persistence via SharedPreferences. Replaced by `AuthProvider` (Supabase session management).
- **Replaced by**: `AuthProvider` (features/auth/)
- **Kept for**: `main.dart` still initializes `VibeSession.instance.init()` for backward compatibility
- **Deprecated at**: Phase 7A

### 2. `lib/ui/auth/auth_placeholder.dart`
- **Status**: LEGACY
- **Why**: Delegates to `LoginView` from features/auth/. Kept to avoid breaking imports.
- **Replaced by**: `LoginView` (features/auth/presentation/screens/)
- **Kept for**: Imported by `community_view.dart`
- **Deprecated at**: Phase 7A

---

## Feature Flags

- `USE_NODE_API` — controls Products, Shopping List, Community repositories
- `USE_NODE_ASSISTANT` — **DELETED** (Phase D.4.1). Removed from `ApiConfig`, README, AGENTS.md. Edge Function path removed from `AssistantService`. No references remain in code.

---

## Dead Environment Variables

### 1. `SUPABASE_JWT_SECRET` (server)
- **Status**: DEAD — zero consumers in code
- **Where**: Present in `server/.env` only
- **Evidence**: Not referenced in `server/src/config/env.ts` (Zod schema), not used in any `.ts` file in `server/src/`
- **Origin**: Likely intended for JWT token verification but never implemented
- **Risk**: None — placeholder value (`your-jwt-secret-here`) in gitignored file
- **Proposal**: Remove from `server/.env` when authorization is given

---

## Removed (Phase 8C / Phase 11)

The following files were listed in previous versions of LEGACY.md but have been deleted:
- `lib/data/repositories/market_catalog_repository.dart` — DEPRECATED, deleted
- `lib/data/repositories/market_catalog_repository_impl.dart` — DEPRECATED, deleted
- `lib/models/walmart_store_model.dart` — DEPRECATED, deleted
- `lib/models/maxi_pali_store_model.dart` — DEPRECATED, deleted
- `lib/models/bm_store_model.dart` — DEPRECATED, deleted
- `lib/models/coopeagri_store_model.dart` — DEPRECATED, deleted
- `lib/logic/shopping_list_service.dart` — LEGACY, deleted
- `lib/core/auth_service.dart` — LEGACY, deleted (Phase 8C consolidation)
- `lib/core/core.dart` — unused barrel, deleted (Phase 8C consolidation)
- `lib/logic/` — entire directory (BasketProductEntity, ListBasketProductsUsecase), deleted (Phase 8C consolidation)
- `lib/data/vibe_community_chat/community_chat_message_query.dart` — dead code, deleted (Phase 8C consolidation)
- `lib/ui/auth/auth_register_view.dart` — typedef wrapper, deleted (Phase 8C consolidation)
- `lib/ui/auth/auth_forgot_password_view.dart` — typedef wrapper, deleted (Phase 8C consolidation)
- `flutter_test` (dev dep) — removed in Phase 11 (no test files exist)
- `flutter_lints` (dev dep) — removed in Phase 11 (not referenced in analysis_options.yaml)
- `vitest` (server dev dep) — removed in Phase 11 (no test files exist)
