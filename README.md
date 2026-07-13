# VibeShopping

Smart shopping assistant for Costa Rica — compare prices across supermarkets with AI-powered recommendations.

## Architecture

```
Flutter (frontend)
    │
    ├── Supabase Auth (authentication)
    ├── Supabase Realtime (community chat)
    │
    └── Node.js + Fastify (backend API)
            │
            ├── Supabase (database)
            └── Gemini API (AI assistant)
```

## Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.x |
| Node.js | 20+ |
| pnpm | 8+ |
| Supabase project | (local or cloud) |

## Quick Start

### 1. Backend

```bash
cd server
cp .env.example .env   # Edit with your keys
pnpm install
pnpm dev               # http://localhost:3001
```

### 2. Flutter (with Supabase — legacy)

```bash
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>
```

### 3. Flutter (with Node.js backend)

```bash
flutter run --dart-define=USE_NODE_API=true \
           --dart-define=API_BASE_URL=http://<ip>:3001/api/v1 \
           --dart-define=SUPABASE_URL=<url> \
           --dart-define=SUPABASE_ANON_KEY=<key>
```

### 4. Flutter (with Node.js backend + AI assistant)

```bash
flutter run --dart-define=USE_NODE_API=true \
           --dart-define=API_BASE_URL=http://<ip>:3001/api/v1 \
           --dart-define=SUPABASE_URL=<url> \
           --dart-define=SUPABASE_ANON_KEY=<key>
```

## Environment Variables

### Server (`server/.env`)

| Variable | Required | Description |
|---|---|---|
| `PORT` | No (default 3001) | Server port |
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Yes | Supabase service_role key (server-side only) |
| `GEMINI_API_KEY` | Yes (for assistant) | Gemini API key (server-side only) |
| `LOG_LEVEL` | No (default info) | Pino log level: debug, info, warn, error |
| `NODE_ENV` | No (default development) | Environment: development, production, test |

### Flutter (`--dart-define`)

| Flag | Required | Purpose |
|---|---|---|
| `SUPABASE_URL` | Always | Supabase project URL |
| `SUPABASE_ANON_KEY` | Always | Supabase anonymous key |
| `USE_NODE_API` | Optional | `true` to use Node.js backend (Products, Shopping List, Community) |
| `API_BASE_URL` | Required when `USE_NODE_API=true` | Backend URL (e.g. `http://localhost:3001/api/v1`) |

## Feature Flags

| Flag | Controls | Default |
|---|---|---|
| `USE_NODE_API` | Products, Shopping List, Community repositories | `false` (Supabase direct) |

## Project Structure

```
server/
├── src/
│   ├── config/          # env, supabase, logger
│   ├── controllers/     # Fastify request handlers
│   ├── domain/
│   │   ├── entities/    # TypeScript interfaces
│   │   └── interfaces/  # Repository contracts
│   ├── middleware/       # Auth, error handler
│   ├── repositories/    # Supabase queries
│   ├── routes/          # Route registration
│   ├── schemas/         # Zod validation
│   └── services/        # Business logic

lib/
├── core/                # Config, network, auth
├── data/                # Legacy services & repositories
├── features/
│   ├── assistant/       # AI assistant (Phase 5)
│   ├── community/       # Chat (Phase 3)
│   ├── products/        # Catalog (Phase 1)
│   └── shopping_list/   # Shopping list (Phase 2)
├── models/              # Legacy models (DEPRECATED)
├── logic/               # Legacy services (DEPRECATED)
└── ui/                  # Flutter views & widgets
```

## Available Scripts

### Server

| Script | Command | Purpose |
|---|---|---|
| `dev` | `tsx watch src/index.ts` | Development with hot-reload |
| `build` | `tsc` | Production build |
| `start` | `node dist/index.js` | Production start |
| `typecheck` | `tsc --noEmit` | Type checking |
| `test` | `vitest run` | Run tests |

### Flutter

```bash
flutter analyze lib/     # Lint & static analysis
flutter test             # Run tests
```

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/api/v1/health` | No | System health + dependency checks |
| `GET` | `/api/v1/version` | No | API version |
| `GET` | `/api/v1/products` | No | Product catalog with filters |
| `GET` | `/api/v1/products/:id` | No | Product detail |
| `GET` | `/api/v1/shopping-list` | Yes | User's shopping list |
| `POST` | `/api/v1/shopping-list` | Yes | Add item to list |
| `PATCH` | `/api/v1/shopping-list/:id` | Yes | Update quantity |
| `DELETE` | `/api/v1/shopping-list/:id` | Yes | Remove item |
| `GET` | `/api/v1/community/messages` | Yes | Community messages |
| `POST` | `/api/v1/community/messages` | Yes | Send message |
| `DELETE` | `/api/v1/community/messages/:id` | Yes | Delete own message |
| `POST` | `/api/v1/assistant/ask` | Yes | AI shopping assistant |

## Verification

```bash
# Flutter
flutter analyze lib/

# Server type-check
cd server && npx tsc --noEmit
```

## LEGACY Code

See [LEGACY.md](LEGACY.md) for deprecated code documentation and removal timeline.
