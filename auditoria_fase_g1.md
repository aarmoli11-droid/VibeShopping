# Auditoría Fase G.1 — Asistente de Compras Inteligente

## 1. Arquitectura Actual del Feature Assistant

### 1.1 Árbol de archivos

```
lib/features/assistant/
  services/assistant_service.dart      (22 LoC) — llamada HTTP al backend
  providers/assistant_provider.dart     (90 LoC) — estado loading/error
  screens/vibe_ai_assistant.dart       (286 LoC) — UI del chat + lógica de contexto

server/src/
  routes/assistant.ts                  (132 LoC) — endpoint + prompt building
  services/gemini.ts                   (211 LoC) — fetch a Gemini API
  middleware/auth.ts                    (95 LoC) — JWT validation
```

### 1.2 Flujo de datos actual

```
Usuario escribe pregunta
    ↓
VibeAiAssistant._sendMessage()
    ↓
ProductService.listProducts(storeIds: null)
    ↓ (SupabaseProductRepository → Supabase directo)
v_products_complete → List<ProductEntity>
    ↓
StringBuffer construye texto plano:
  "Producto:\n  Tienda: ₡precio\n"
    ↓
AssistantService.askQuestion(question, context: text)
    ↓ POST /api/v1/assistant/ask { question, context }
Node.js → authMiddleware → Zod → _buildPrompt()
    ↓
GeminiService.generateContent(prompt)
    ↓
Gemini 2.0 Flash → respuesta → JSON
```

### 1.3 Observaciones críticas

**1.3.1 — Los productos se cargan desde Supabase directo, NO desde Node.js**
- `vibe_ai_assistant.dart:187` usa `context.read<ProductService>()` que va a `SupabaseProductRepository` con `Supabase.instance.client`
- El backend Node.js recibe el contexto como string, nunca consulta `v_products_complete`
- Esto significa: dos conexiones separadas, el backend no tiene control sobre qué datos se envían a Gemini

**1.3.2 — Se fetchan TODOS los productos en cada pregunta**
- `repo.listProducts(storeIds: null)` sin filtros → descarga el catálogo completo
- Cada pregunta del usuario genera una consulta completa a Supabase desde Flutter

**1.3.3 — El contexto excede el límite de Zod (10.000 caracteres)**
- `assistant.ts:57` valida `context: z.string().max(10000)`
- Si hay 500 productos con ~200 caracteres cada uno = 100.000 chars → Zod rechaza la request
- El error se traga en `AssistantProvider.askQuestion()` catch → devuelve mensaje genérico

**1.3.4 — Sin historial de conversación**
- `_messages` es estado local del widget, nunca se envía al backend
- Cada pregunta es independiente: Gemini no sabe qué preguntó antes el usuario
- No hay tabla de conversaciones en Supabase ni en Node.js

**1.3.5 — Prompt mínimo**
- `_buildPrompt()` genera: `"Eres un asistente de compras en Costa Rica. Ayudas al usuario a comparar precios...\n\n{context}\n\n{question}"`
- Sin instrucciones de formato, sin constraints de respuesta, sin ejemplos (few-shot)

**1.3.6 — Modelo hardcodeado, sin fallback**
- `gemini.ts:55`: `const GEMINI_MODEL = 'gemini-2.0-flash'`
- Si el modelo falla o se deprecia, hay que cambiar código y redeployar

**1.3.7 — Sin streaming**
- El usuario espera la respuesta completa (promedio 1-3 segundos para gemini-2.0-flash)
- No hay feedback visual de progreso (más allá de `_isSending` que deshabilita el botón)

---

## 2. Productos Reales desde v_products_complete

### 2.1 Estructura de la VIEW

```sql
CREATE OR REPLACE VIEW v_products_complete AS
SELECT
  p.id                  AS product_id,
  pm.id                 AS master_product_id,
  pm.canonical_name,
  pm.brand,
  pm.category_id,
  pm.subcategory,
  pm.image_url,
  p.price,
  p.supermarket_id,
  s.name                AS supermarket_name,
  s.logo_url            AS supermarket_logo_url,
  s.latitude            AS supermarket_latitude,
  s.longitude           AS supermarket_longitude,
  pm.created_at         AS master_created_at,
  p.created_at          AS product_created_at,
  pm.id || '|' || p.supermarket_id AS store_product_key
FROM products p
LEFT JOIN product_master pm ON pm.id = p.master_product_id
LEFT JOIN supermarkets s   ON s.id   = p.supermarket_id;
```

### 2.2 Columnas disponibles desde Node.js

| Columna | Tipo | Uso para IA |
|---|---|---|
| `product_id` | UUID | Identificador |
| `master_product_id` | UUID | Agrupar mismo producto en distintas tiendas |
| `canonical_name` | text | Nombre del producto |
| `brand` | text | Marca |
| `category_id` | text | Categoría (cat_abarrotes, cat_lacteos, etc.) |
| `subcategory` | text | Subcategoría |
| `image_url` | text | URL de imagen |
| `price` | numeric | Precio |
| `supermarket_id` | UUID | ID de la tienda |
| `supermarket_name` | text | Nombre de la tienda |
| `supermarket_logo_url` | text | Logo de la tienda |
| `supermarket_latitude` | float8 | Coordenadas |
| `supermarket_longitude` | float8 | Coordenadas |
| `master_created_at` | timestamptz | Fecha creación |

### 2.3 Acceso desde Node.js

El servidor ya tiene `supabase` cliente configurado y consulta `v_products_complete` en `routes/products.ts`:

```typescript
let query = supabase.from('v_products_complete').select('*');
// Filtros: categoryId, search, storeIds, storeId
const { data, error } = await query;
```

### 2.4 Store IDs disponibles

Los UUIDs de tiendas están en la tabla `supermarkets`. El servidor puede obtenerlos con:
```typescript
const { data: stores } = await supabase.from('supermarkets').select('id, name');
```

---

## 3. Integración sin Romper Arquitectura Existente

### Principios

1. **No eliminar** la ruta actual `POST /api/v1/assistant/ask` — evolucionarla
2. **No cambiar** `ProductService` ni `ProductProvider` — son del explorador, no del asistente
3. **No tocar** la UI (`vibe_ai_assistant.dart`) más de lo necesario — solo el envío de contexto
4. **Migrar responsabilidad**: Flutter envía solo `{ question }`, Node.js carga productos

### 3.1 Qué debe recibir Gemini

| Información | Origen | Cómo se obtiene |
|---|---|---|
| Productos + precios | `v_products_complete` | Servidor consulta Supabase |
| Nombres de tiendas | `supermarkets` | Servidor consulta Supabase |
| Pregunta del usuario | Request body | Flutter → POST |
| Historial de conversación | Supabase (nuevo) o en memoria | Servidor consulta/resume |

### 3.2 Qué debe permanecer en Node.js

- Validación JWT (authMiddleware) — ya existe
- Rate limiting (20/min) — ya existe
- Carga de productos desde `v_products_complete` — mover desde Flutter
- Construcción del prompt con contexto estructurado — ya existe parcialmente
- Llamada a Gemini API — ya existe
- Parseo de respuesta — ya existe
- Gestión de historial de conversación — nuevo
- Cache de productos (futuro) — nuevo

### 3.3 Qué debe permanecer en Flutter

- UI del chat (burbujas, entrada de texto) — ya existe
- Estado local de mensajes para renderizado inmediato — ya existe
- Botón flotante de apertura — ya existe
- Indicador de "escribiendo..." — mejorar (hoy es solo botón deshabilitado)

---

## 4. Riesgos

### 4.1 Rendimiento

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Carga completa de productos en cada request | Latencia + carga DB | Cache en memoria del servidor con TTL (Fase G.1.5) |
| Contexto gigante en prompt | Token cost + latencia Gemini | Smart pruning por categorías (Fase G.1.6) |
| Múltiples usuarios simultáneos | Contención DB | Rate limit ya existente (20/min por usuario) |

### 4.2 Costos (Gemini 2.0 Flash)

- Precio: ~$0.10/1M input tokens, ~$0.40/1M output tokens
- Estimación conservadora: ~200 productos × 50 tokens c/u = 10K tokens input
- Costo por pregunta: ~$0.001
- 1.000 preguntas/día: ~$1.00/día (~$30/mes)
- Con historial de 5 turnos: ~$0.002-0.003 por pregunta

### 4.3 Context Window

- Gemini 2.0 Flash soporta 1M tokens de contexto
- Riesgo REAL: el costo, no el límite. 500 productos = ~150K chars ≈ ~37K tokens
- Sin historial: ~$0.0037/pregunta
- Con historial de 10 turnos: ~$0.005/pregunta

### 4.4 Calidad de respuesta

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Alucinaciones de precios | Usuario confiado compra con info falsa | Prompt: "Usa SOLO los precios proporcionados. Si no ves un precio, no lo inventes." |
| Respuestas genéricas | Usuario ignora el asistente | Prompt con instrucciones específicas de formato, tono y estructura |

---

## 5. Plan de Implementación por Fases

### Fase G.1.1 — Mover carga de productos al servidor

**Objetivo**: Flutter envía solo `{ question }`, Node.js carga productos desde Supabase y construye el contexto.

**Dependencias**: Ninguna

**Archivos a modificar**:
- `lib/features/assistant/services/assistant_service.dart` — eliminar parámetro `context`, enviar solo `{ question, conversationId? }`
- `lib/features/assistant/providers/assistant_provider.dart` — eliminar `context` de `askQuestion()`
- `lib/features/assistant/screens/vibe_ai_assistant.dart` — eliminar carga de productos (`ProductService`), eliminar construcción de `StringBuffer`
- `server/src/routes/assistant.ts` — agregar `supabase.from('v_products_complete').select('*')` dentro del handler, construir contexto antes de llamar a Gemini

**Archivos a eliminar**:
- Ninguno

**Verificación**:
- `flutter analyze lib/` — 0 issues
- `npx tsc --noEmit` — 0 errors
- El asistente responde sin que Flutter llame a Supabase

---

### Fase G.1.2 — Prompts mejorados

**Objetivo**: Prompt con instrucciones de formato, constraints contra alucinaciones, y estructura de respuesta esperada.

**Dependencias**: G.1.1 (el contexto ya se construye en servidor)

**Archivos a modificar**:
- `server/src/routes/assistant.ts` — reemplazar `_buildPrompt()` con un prompt estructurado que incluya:
  - Rol: "asistente de compras en Costa Rica (colones)"
  - Regla: "Usa SOLO los precios listados. No inventes ni asumas precios."
  - Formato esperado: respuestas claras con producto, precio, tienda
  - Tono: amigable pero preciso
  - Límite: respuestas de máximo 3 párrafos

**Verificación**:
- `npx tsc --noEmit` — 0 errors
- Las respuestas de Gemini son consistentes y no alucinan precios

---

### Fase G.1.3 — Historial de conversación

**Objetivo**: El asistente recuerda preguntas anteriores dentro de la misma sesión.

**Dependencias**: G.1.1

**Opciones**:
- **(A) Simple**: Node.js mantiene `Map<String, Array<{role, content}>>` en memoria (se pierde al reiniciar)
- **(B) Persistente**: nueva tabla Supabase `conversations` y `conversation_messages`

**Recomendación**: Opción A para MVP, Opción B si se requiere persistencia entre sesiones.

**Archivos a modificar**:
- `server/src/routes/assistant.ts` — recibir `conversationId` opcional, almacenar/recuperar historial
- `lib/features/assistant/screens/vibe_ai_assistant.dart` — generar `conversationId` al abrir el sheet, enviarlo en cada request
- `lib/features/assistant/services/assistant_service.dart` — pasar `conversationId`

**Archivos a crear (Opción B)**:
- `server/supabase/migrations/20260725_conversations.sql` — tabla `conversations` + `conversation_messages`
- `server/src/services/conversation.service.ts` — CRUD de mensajes

**Verificación**:
- Preguntar "¿qué pregunté antes?" → la IA responde correctamente
- `flutter analyze lib/` — 0 issues
- `npx tsc --noEmit` — 0 errors

---

### Fase G.1.4 — Cache de productos en servidor

**Objetivo**: Evitar consultar `v_products_complete` en cada pregunta.

**Dependencias**: G.1.1

**Archivos a crear**:
- `server/src/services/product-cache.service.ts` — cache en memoria con TTL configurable

**Archivos a modificar**:
- `server/src/routes/assistant.ts` — usar cache en lugar de consulta directa

**Detalle técnico**:
```typescript
class ProductCache {
  private cache: ProductEntity[] | null = null;
  private lastFetch: number = 0;
  private readonly TTL = 5 * 60 * 1000; // 5 minutos

  async getProducts(): Promise<ProductEntity[]> {
    if (this.cache && Date.now() - this.lastFetch < this.TTL) {
      return this.cache;
    }
    this.cache = await this._fetchAll();
    this.lastFetch = Date.now();
    return this.cache;
  }
}
```

**Verificación**:
- Segunda pregunta en menos de 5 minutos: 0 consultas a Supabase
- `npx tsc --noEmit` — 0 errors

---

### Fase G.1.5 — Smart context pruning

**Objetivo**: Enviar a Gemini solo los productos relevantes a la pregunta, no el catálogo completo.

**Dependencias**: G.1.1, G.1.4

**Estrategias** (orden de prioridad):
1. **Por nombre**: Si pregunta "leche", filtrar `canonical_name ILIKE '%leche%'` vía Supabase
2. **Por categoría**: Si pregunta "lácteos", filtrar por `category_id IN ('cat_lacteos', 'cat_huevos')`
3. **Keyword extraction básica**: Extraer palabras clave de la pregunta y usarlas como filtro de búsqueda

**Archivos a modificar**:
- `server/src/routes/assistant.ts` — extraer keywords de la pregunta, aplicar filtros a la query de Supabase (o al cache)
- `server/src/services/product-cache.service.ts` — exponer método `searchProducts(keywords: string[]): ProductEntity[]`

**Verificación**:
- Pregunta "¿cuánto cuesta la leche?" → solo productos con "leche" en el nombre
- `npx tsc --noEmit` — 0 errors
- Reducción de tokens por pregunta ≥ 80%

---

### Fase G.1.6 — Streaming de respuesta

**Objetivo**: Mostrar la respuesta de Gemini token por token mientras se genera (UX mejorada).

**Dependencias**: G.1.1, G.1.2

**Arquitectura**:
- Gemini 2.0 Flash soporta `stream: true` → SSE (Server-Sent Events)
- Node.js convierte el stream de Gemini a SSE para el cliente
- Flutter usa `dart:io` HttpClient o `dio` con `responseStream` para leer tokens progresivamente

**Archivos a modificar**:
- `server/src/services/gemini.ts` — soportar `generateContentStream()` que devuelve `AsyncIterable<string>`
- `server/src/routes/assistant.ts` — nuevo endpoint `POST /api/v1/assistant/ask/stream` que responde con SSE
- `lib/features/assistant/services/assistant_service.dart` — método `askQuestionStream()` que retorna `Stream<String>`
- `lib/features/assistant/providers/assistant_provider.dart` — manejar stream, exponer `responseStream`
- `lib/features/assistant/screens/vibe_ai_assistant.dart` — suscribirse al stream, mostrar tokens incrementalmente

**Verificación**:
- Las respuestas aparecen carácter por carácter en la burbuja de chat
- `flutter analyze lib/` — 0 issues
- `npx tsc --noEmit` — 0 errors

---

## 6. Orden Recomendado y Dependencias

```
G.1.1 ─────────────────────────────────────────── (sin dependencias)
  │
  ├── G.1.2 (Prompt mejorado) ─── depende de G.1.1
  ├── G.1.3 (Historial) ───────── depende de G.1.1
  ├── G.1.4 (Cache) ───────────── depende de G.1.1
  │     │
  │     └── G.1.5 (Smart pruning) ─── depende de G.1.1 + G.1.4
  │
  └── G.1.6 (Streaming) ───────── depende de G.1.1 + G.1.2
```

**Orden recomendado de implementación**:

| # | Fase | Esfuerzo estimado | Valor |
|---|---|---|---|
| 1 | G.1.1 — Mover carga al servidor | ~45 min | Elimina bug de context truncado, reduce carga de red en Flutter |
| 2 | G.1.2 — Prompts mejorados | ~15 min | Respuestas más precisas, menos alucinaciones |
| 3 | G.1.4 — Cache de productos | ~20 min | Reduce latencia de 2ª pregunta en adelante |
| 4 | G.1.5 — Smart pruning | ~60 min | Reduce costos, mejora calidad de respuesta |
| 5 | G.1.3 — Historial de conversación | ~90 min | Permite follow-up questions naturales |
| 6 | G.1.6 — Streaming | ~120 min | Mejora UX, feedback inmediato |

---

## 7. Resumen de Archivos por Fase

| Fase | Modificar | Crear | Eliminar |
|---|---|---|---|
| G.1.1 | `assistant_service.dart`, `assistant_provider.dart`, `vibe_ai_assistant.dart`, `assistant.ts` | — | — |
| G.1.2 | `assistant.ts` | — | — |
| G.1.3 | `assistant.ts`, `vibe_ai_assistant.dart`, `assistant_service.dart` | `migration.sql`, `conversation.service.ts` (si Opción B) | — |
| G.1.4 | `assistant.ts` | `product-cache.service.ts` | — |
| G.1.5 | `assistant.ts`, `product-cache.service.ts` | — | — |
| G.1.6 | `gemini.ts`, `assistant.ts`, `assistant_service.dart`, `assistant_provider.dart`, `vibe_ai_assistant.dart` | — | — |

**Total**: 9 archivos existentes modificados, 2-3 archivos nuevos, 0 archivos eliminados.
