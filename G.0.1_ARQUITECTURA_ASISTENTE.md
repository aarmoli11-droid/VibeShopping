# G.0.1 — Arquitectura del Nuevo Asistente de Compras Inteligente

> **Fase**: G.0.1 (diseño únicamente — sin código)
> **Propósito**: Auditar el feature actual, diseñar el reemplazo completo y planificar la migración en fases pequeñas.

---

## Índice

1. [Inventario del feature actual](#1-inventario-del-feature-actual)
2. [Arquitectura propuesta](#2-arquitectura-propuesta)
3. [Flujo completo](#3-flujo-completo)
4. [Tipos de mensajes soportados](#4-tipos-de-mensajes-soportados)
5. [Respuestas estructuradas (modelos JSON)](#5-respuestas-estructuradas-modelos-json)
6. [Ciclo de conversación](#6-ciclo-de-conversación)
7. [Diseño de la interfaz](#7-diseño-de-la-interfaz)
8. [Plan de migración por fases](#8-plan-de-migración-por-fases)

---

## 1. Inventario del Feature Actual

### 1.1 Árbol completo de archivos

```
Flutter (lib/)
├── features/assistant/
│   ├── services/
│   │   └── assistant_service.dart                 22 LoC
│   ├── providers/
│   │   └── assistant_provider.dart                90 LoC
│   └── screens/
│       └── vibe_ai_assistant.dart                286 LoC
│
├── core/
│   ├── di/
│   │   └── app_providers.dart              (líneas 18-19, 91-101)
│   └── api_client.dart                     (comentario línea 8)
│
├── features/explorer/screens/
│   └── market_explorer_view.dart            (líneas 8, 156)
│
└── features/products/
    ├── models/product.dart                  (comentarios líneas 9, 17)
    ├── providers/product_provider.dart       (comentarios líneas 10, 75)
    └── services/product_service.dart         (consumido por vibe_ai_assistant.dart)
```

```
Server (server/src/)
├── routes/
│   ├── assistant.ts                        132 LoC (endpoint + prompt)
│   └── index.ts                            (líneas 34, 52, 63, 74, 115-116)
├── services/
│   └── gemini.ts                           211 LoC (cliente Gemini API)
├── middleware/
│   └── auth.ts                             (comentario línea 8)
└── config/
    ├── env.ts                              (línea 50: GEMINI_API_KEY)
    └── supabase.ts                         (comentario línea 10)
```

### 1.2 Resumen de archivos por capa

| Capa | Archivos | LoC total | Estado |
|------|----------|-----------|--------|
| **Flutter — UI** | 1 | 286 | Será reemplazado |
| **Flutter — Provider** | 1 | 90 | Será reemplazado |
| **Flutter — Service** | 1 | 22 | Será reemplazado |
| **Flutter — DI** | 1 (parcial) | ~10 líneas | Será reemplazado |
| **Flutter — Core (ApiClient)** | 1 (comentario) | 0 | Sin cambios |
| **Server — Route** | 1 | 132 | Será reemplazado |
| **Server — Service (Gemini)** | 1 | 211 | Será reemplazado |
| **Server — Middleware** | 1 (comentario) | 0 | Sin cambios |
| **Server — Config (env)** | 1 (línea) | 1 | Modificar (nuevas vars) |
| **Server — Route index** | 1 (parcial) | ~3 líneas | Modificar (nuevo registro) |

### 1.3 Dependencias directas del feature

| Dependencia | Tipo | Uso |
|-------------|------|-----|
| `provider` ^6.1.5+1 | Flutter pub | `ChangeNotifier`, `context.read<>()` |
| `dio` ^5.7.0 | Flutter pub | `ApiClient` HTTP calls |
| `supabase_flutter` ^2.12.4 | Flutter pub | JWT token del `ApiClient` interceptor |
| `fastify` ^5.0.0 | Node npm | Plugin de rutas |
| `@fastify/rate-limit` ^10.0.0 | Node npm | 20 req/min |
| `zod` ^3.23.0 | Node npm | Validación request body |
| `@supabase/supabase-js` ^2.45.0 | Node npm | JWT validation en authMiddleware |
| `dotenv` ^16.4.0 | Node npm | Carga GEMINI_API_KEY |
| `pino` ^9.0.0 | Node npm | Logging |

### 1.4 Endpoints actuales

| Método | Ruta | Request | Response | Rate Limit |
|--------|------|---------|----------|------------|
| POST | `/api/v1/assistant/ask` | `{ question, context? }` | `{ success, data: { response } }` | 20/min |

### 1.5 Endpoints externos llamados

| API | URL | Propósito |
|-----|-----|-----------|
| Gemini 2.0 Flash | `POST .../models/gemini-2.0-flash:generateContent?key=...` | Generación de texto IA |

### 1.6 Archivos que serán eliminados

| Archivo | Razón |
|---------|-------|
| `lib/features/assistant/services/assistant_service.dart` | Reemplazado por nuevo `assistant_api_service.dart` |
| `lib/features/assistant/providers/assistant_provider.dart` | Reemplazado por nuevos providers |
| `lib/features/assistant/screens/vibe_ai_assistant.dart` | Reemplazado por nuevas screens |
| `server/src/services/gemini.ts` | Reemplazado por nuevo `gemini.service.ts` |
| `server/src/routes/assistant.ts` | Reemplazado por nuevo `assistant.routes.ts` |

### 1.7 Archivos que serán modificados

| Archivo | Cambio |
|---------|--------|
| `lib/core/di/app_providers.dart` | Reemplazar registros de AssistantService/Provider |
| `lib/features/explorer/screens/market_explorer_view.dart` | Reemplazar FAB de `VibeAiAssistant` por nuevo widget |
| `server/src/routes/index.ts` | Reemplazar registro de `assistantRoutes` por nuevas rutas |
| `server/src/config/env.ts` | Agregar nuevas variables de entorno |

### 1.8 Archivos sin cambios

| Archivo | Razón |
|---------|-------|
| `lib/core/api_client.dart` | ApiClient sigue siendo el HTTP client compartido |
| `server/src/middleware/auth.ts` | JWT middleware sigue siendo el mismo |
| `server/src/config/supabase.ts` | Cliente Supabase no cambia |

---

## 2. Arquitectura Propuesta

### 2.1 Árbol del nuevo módulo

```
lib/features/shopping_assistant/
│
├── domain/                              # Modelos puros del dominio
│   ├── chat_message.dart                # Mensaje individual (role, content, timestamp, type)
│   ├── conversation.dart                # Sesión de conversación (id, messages, createdAt, summary)
│   ├── assistant_response.dart          # Contenedor genérico de respuesta estructurada
│   ├── response_types.dart              # Enums: ResponseType (recipe, shoppingList, recommendation, etc.)
│   ├── product_recommendation.dart      # Recomendación individual (productId, storeId, price, reason)
│   ├── shopping_plan.dart               # Plan semanal (days[], total, budget)
│   ├── meal_recipe.dart                 # Receta (ingredients[], steps[], estimatedCost, storeIds)
│   ├── budget_analysis.dart             # Análisis de presupuesto (total, byStore, savings, tips)
│   ├── substitution.dart                # Sustitución (original, alternative, reason, savings)
│   └── quick_action.dart                # Acción rápida predefinida (label, icon, promptTemplate)
│
├── data/                                # Comunicación con backend
│   ├── dto/
│   │   ├── chat_request_dto.dart        # { question, conversationId?, storeIds?, budget? }
│   │   ├── chat_response_dto.dart       # { type, payload, timestamp, conversationId }
│   │   ├── history_request_dto.dart     # { conversationId, limit? }
│   │   └── history_response_dto.dart    # { messages[], summary }
│   └── repositories/
│       └── assistant_repository.dart    # Abstracts HTTP calls to Node.js
│
├── services/                            # Lógica de negocio pura
│   ├── conversation_service.dart        # Historial local (Hive) + resumen + limpieza
│   └── intent_classifier.dart           # Clasifica la intención del usuario (recipe, budget, etc.)
│
├── providers/                           # Estado para la UI
│   ├── chat_provider.dart               # Estado del chat: messages[], isTyping, error
│   └── quick_actions_provider.dart      # Lista de acciones rápidas predefinidas
│
├── widgets/                             # Componentes reutilizables del chat
│   ├── chat_bubble.dart                 # Burbuja de mensaje (user vs assistant)
│   ├── typing_indicator.dart            # Animación "escribiendo..."
│   ├── quick_action_chip.dart           # Chip de acción rápida
│   ├── product_card_inline.dart         # Tarjeta de producto dentro del chat
│   ├── recipe_card.dart                 # Tarjeta de receta
│   ├── shopping_list_card.dart          # Tarjeta de lista de compras generada por IA
│   ├── comparison_table.dart            # Tabla de comparación de precios
│   └── budget_chart.dart                # Gráfico de presupuesto
│
└── screens/                             # Pantallas
    ├── assistant_button.dart            # Botón IA flotante (reemplaza VibeAiAssistant.buildFloatingButton)
    └── assistant_chat_screen.dart       # Pantalla completa de chat
```

### 2.2 Responsabilidad de cada carpeta

| Carpeta | Responsabilidad | Reglas |
|---------|----------------|--------|
| `domain/` | Modelos puros del dominio, sin dependencias de Flutter ni HTTP. Solo clases dart. Sin anotaciones `@freezed`, sin serialización. | Pueden ser importados por cualquier otra capa. No importan nada. |
| `data/dto/` | Objetos de transferencia para comunicación con Node.js. Mapean JSON de ida/vuelta. | Importan solo `dart:convert` y clases de `domain/`. |
| `data/repositories/` | Implementación concreta que usa `ApiClient` para llamar al backend. | Importa DTOs y `core/api_client.dart`. |
| `services/` | Lógica de negocio: gestión de historial (Hive), clasificación de intención, resumen de conversación. | Importan solo `domain/` y paquetes de infraestructura (`hive`). |
| `providers/` | `ChangeNotifier`s que exponen estado a la UI. | Importan `services/` y `domain/`. No importan `data/` directamente. |
| `widgets/` | Widgets reutilizables del chat. | Importan `domain/` y `providers/`. No importan `data/` ni `services/`. |
| `screens/` | Pantallas completas (bottom sheet, pantalla completa). | Importan `widgets/` y `providers/`. |

### 2.3 Responsabilidad de cada archivo

#### domain/

| Archivo | Responsabilidad |
|---------|----------------|
| `chat_message.dart` | Define `ChatMessage` con `{ id, role (user|assistant|system), content, type: ResponseType?, timestamp }`. Inmutable. |
| `conversation.dart` | Define `Conversation` con `{ id, messages: List<ChatMessage>, summary: String?, createdAt, updatedAt }`. |
| `assistant_response.dart` | Envoltura genérica: `{ type: ResponseType, payload: Map<String, dynamic>, confidence: double? }`. |
| `response_types.dart` | Enum `ResponseType { answer, recommendation, recipe, shoppingList, budgetAnalysis, substitution, comparison, weeklyPlan, promotion }`. |
| `product_recommendation.dart` | Modelo: `{ productId, productName, storeId, storeName, price, savingsVsAvg?, reason }`. |
| `shopping_plan.dart` | Modelo: `{ days: List<ShoppingDay>, totalBudget, totalEstimated, tips[] }`. |
| `meal_recipe.dart` | Modelo: `{ name, ingredients: List<Ingredient>, steps: List<String>, estimatedCost, preparationTime, storeIds[] }`. |
| `budget_analysis.dart` | Modelo: `{ totalSpending, byStore: Map<storeId, amount>, savings: List<SavingTip>, warnings[] }`. |
| `substitution.dart` | Modelo: `{ originalProduct, alternativeProduct, reason, savings, sameStore? }`. |
| `quick_action.dart` | Modelo: `{ id, iconName, label, promptTemplate, category? }`. |

#### data/

| Archivo | Responsabilidad |
|---------|----------------|
| `dto/chat_request_dto.dart` | Serializa `{ question, conversationId?, storeIds?, budget?, dietaryRestrictions? }`. |
| `dto/chat_response_dto.dart` | Deserializa `{ type, payload: ResponsePayload, conversationId, timestamp }`. |
| `dto/history_request_dto.dart` | Serializa `{ conversationId, limit?, beforeTimestamp? }`. |
| `dto/history_response_dto.dart` | Deserializa `{ messages[], summary }`. |
| `repositories/assistant_repository.dart` | Implementa `askQuestion(chatRequest)`, `getHistory(conversationId)`, `clearHistory(conversationId)`. Usa `ApiClient`. |

#### services/

| Archivo | Responsabilidad |
|---------|----------------|
| `conversation_service.dart` | CRUD local de conversaciones con Hive. Crea/resume/archiva conversaciones. Genera resúmenes automáticos cada N mensajes. Limpia conversaciones inactivas > 7 días. |
| `intent_classifier.dart` | Toma el texto del usuario y devuelve `ResponseType` estimado. Puede ser rule-based inicialmente (keywords) y evolucionar a ML-based. |

#### providers/

| Archivo | Responsabilidad |
|---------|----------------|
| `chat_provider.dart` | `ChangeNotifier` que expone `messages`, `isTyping`, `error`, `conversation`. Métodos: `sendMessage(text)`, `retry()`, `clearConversation()`, `loadHistory(id)`. |
| `quick_actions_provider.dart` | `ChangeNotifier` con lista de `QuickAction`s. Se carga desde configuración (JSON local o endpoint). |

#### widgets/

| Archivo | Responsabilidad |
|---------|----------------|
| `chat_bubble.dart` | Renderiza un `ChatMessage`. Si role=assistant, muestra avatar + nombre + contenido. Si role=user, alineación derecha. Soporta payload estructurado como child widget (RecipeCard, ComparisonTable, etc.). |
| `typing_indicator.dart` | Tres puntos con animación de rebote. |
| `quick_action_chip.dart` | Chip con icono + texto, al tocarlo inserta el promptTemplate en el campo de texto y envía. |
| `product_card_inline.dart` | Tarjeta horizontal compacta con imagen, nombre, precio, tienda y botón "Agregar a lista". |
| `recipe_card.dart` | Tarjeta expandible con nombre, ingredientes, pasos, tiempo de preparación, costo estimado y botón "Agregar ingredientes a lista". |
| `shopping_list_card.dart` | Lista de productos generada por IA con checkbox, precio estimado, tienda sugerida y botón "Guardar como lista manual". |
| `comparison_table.dart` | Tabla comparativa de precios del mismo producto en distintas tiendas con highlight del más barato. |
| `budget_chart.dart` | Gráfico de barras simple (usando `CustomPainter` o paquete ligero) mostrando gasto por tienda/categoría, más tarjetas de consejos. |

#### screens/

| Archivo | Responsabilidad |
|---------|----------------|
| `assistant_button.dart` | Widget stateless que renderiza el botón flotante estilo glassmorphism (reemplaza `VibeAiAssistant.buildFloatingButton`). Al tocarlo abre `assistant_chat_screen.dart`. |
| `assistant_chat_screen.dart` | Pantalla completa con `Scaffold`, `AppBar`, `ListView` de mensajes, `QuickActionChip`s, campo de texto, botón de enviar. Soporta entrada como bottom sheet y como pantalla independiente. |

---

## 3. Flujo Completo

### 3.1 Diagrama de secuencia

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌────────┐
│ Usuario │    │  Flutter │    │  Node.js │    │ Supabase │    │ Gemini │
└────┬────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬───┘
     │              │               │              │              │
     │ 1. Abre chat │               │              │              │
     │◄────────────►│               │              │              │
     │              │               │              │              │
     │ 2. QuickActions              │              │              │
     │◄────────────►│               │              │              │
     │              │               │              │              │
     │ 3. Escribe   │               │              │              │
     │────pregunta──►│               │              │              │
     │              │               │              │              │
     │              │ 4. POST /ask  │              │              │
     │              │──{question,───►│              │              │
     │              │  conversation │              │              │
     │              │  id,filter?}  │              │              │
     │              │               │              │              │
     │              │               │ 5. Auth JWT │              │
     │              │               │    (verify)  │              │
     │              │               │              │              │
     │              │               │ 6. Load      │              │
     │              │               │    products  │              │
     │              │               │──────GET─────►              │
     │              │               │  v_products_ │              │
     │              │               │  complete◄───              │
     │              │               │              │              │
     │              │               │ 7. Cargar    │              │
     │              │               │    historial  │              │
     │              │               │──(memoria o──►              │
     │              │               │  Supabase)◄──              │
     │              │               │              │              │
     │              │               │ 8. Classify  │              │
     │              │               │    intent    │              │
     │              │               │              │              │
     │              │               │ 9. Build     │              │
     │              │               │    prompt    │              │
     │              │               │ + contexto   │              │
     │              │               │              │              │
     │              │               │ 10. POST     │              │
     │              │               │──generate───►              │
     │              │               │  Content     │              │
     │              │               │  (stream)    │              │
     │              │               │◄───tokens────              │
     │              │               │              │              │
     │              │ 11. SSE stream│              │              │
     │◄─────────────│─(tokens)──────│              │              │
     │              │               │              │              │
     │ 12. Renderiza│               │              │              │
     │    respuesta │               │              │              │
     │    estructu- │               │              │              │
     │    rada      │               │              │              │
     │◄────────────►│               │              │              │
     │              │               │              │              │
     │ 13. Guarda   │               │              │              │
     │     his-     │               │              │              │
     │     torial   │               │              │              │
     │              │               │ 14. Save     │              │
     │              │               │────INSERT────►              │
     │              │               │              │              │
```

### 3.2 Flujo detallado paso a paso

**Paso 1 — Apertura del chat**
1. Usuario toca botón flotante IA (`assistant_button.dart`)
2. Se abre `assistant_chat_screen.dart` (ModalBottomSheet o navegación completa)
3. `ChatProvider` genera o recupera un `conversationId` desde `ConversationService`
4. Se cargan `QuickAction`s predefinidos desde `QuickActionsProvider`
5. Si existe historial previo (misma sesión), se restaura desde Hive local

**Paso 2 — Envío de pregunta**
1. Usuario escribe texto o toca un `QuickActionChip`
2. `ChatProvider.sendMessage(text)` se invoca
3. El mensaje del usuario se agrega a `messages` inmediatamente (optimistic UI)
4. Se clasifica la intención mediante `IntentClassifier` (lado Flutter, rule-based)
5. Se construye `ChatRequestDto` con `{ question, conversationId, storeIds?, budget? }`
6. `AssistantRepository.askQuestion(dto)` → `ApiClient.post('/api/v1/assistant/ask')`

**Paso 3 — Procesamiento en servidor**
1. `authMiddleware` valida JWT
2. Zod valida request body
3. Servidor carga historial de conversación desde Supabase (tabla `conversation_messages`) o memoria
4. Servidor carga productos desde `v_products_complete` (con cache si aplica)
5. Servidor clasifica la intención (server-side, más robusta que Flutter)
6. Servidor construye sistema de prompt con:
   - Instrucciones del sistema (rol, reglas, restricciones)
   - Historial de conversación (últimos N mensajes, o resumen si es largo)
   - Catálogo de productos relevantes (filtrados por intención)
   - Pregunta del usuario
7. Servidor llama a Gemini (modo streaming si está habilitado)
8. Gemini devuelve respuesta estructurada JSON

**Paso 4 — Respuesta estructurada**
1. Servidor parsea respuesta JSON de Gemini
2. Valida contra el esquema Zod del tipo de respuesta esperado
3. Almacena la interacción en Supabase (o memoria)
4. Devuelve `{ conversationId, type, payload, timestamp }` a Flutter

**Paso 5 — Renderizado en Flutter**
1. `AssistantRepository` recibe `ChatResponseDto`
2. `ChatProvider` lo convierte a `ChatMessage` + `AssistantResponse` del `domain/`
3. Se agrega a `messages` y se notifica
4. `ChatBubble` detecta el `ResponseType` y renderiza el widget correspondiente:
   - `answer` → texto plano
   - `recipe` → `RecipeCard`
   - `shoppingList` → `ShoppingListCard`
   - `comparison` → `ComparisonTable`
   - `budgetAnalysis` → `BudgetChart`
   - etc.

---

## 4. Tipos de Mensajes Soportados

| # | Tipo | Descripción | Ejemplo de pregunta |
|---|------|-------------|---------------------|
| 1 | `answer` | Respuesta textual general sin estructura específica | "¿Cuál es el horario del súper?" |
| 2 | `productSearch` | Búsqueda de productos con precios y tiendas | "Buscame leche deslactosada" |
| 3 | `recommendation` | Recomendación de producto basada en criterios | "¿Cuál es la mejor leche calidad-precio?" |
| 4 | `comparison` | Comparación del mismo producto en distintas tiendas | "¿Dónde es más barata la leche?" |
| 5 | `recipe` | Receta con ingredientes, pasos y costo estimado | "Dame una receta con pollo y verduras" |
| 6 | `shoppingList` | Generación de lista de compras | "Haceme una lista para una cena de 4 personas" |
| 7 | `budgetAnalysis` | Análisis de gasto por tienda y consejos de ahorro | "¿Cómo puedo ahorrar en el súper?" |
| 8 | `substitution` | Sustitución de producto por alternativa más barata/saludable | "¿Con qué puedo reemplazar la crema?" |
| 9 | `weeklyPlan` | Planificación semanal de comidas | "Planificame el menú de la semana" |
| 10 | `promotion` | Promociones o descuentos disponibles | "¿Qué promociones hay esta semana?" |
| 11 | `nutritionalInfo` | Información nutricional de un producto | "¿Cuántas calorías tiene esta leche?" |
| 12 | `dietaryAdvice` | Consejos para restricciones alimenticias | "¿Qué puedo comprar sin gluten?" |
| 13 | `storeGuide` | Información sobre una tienda específica | "¿El Walmart de San José tiene panadería?" |

---

## 5. Respuestas Estructuradas (Modelos JSON)

### 5.1 Envoltura general (siempre igual)

```json
{
  "success": true,
  "data": {
    "conversationId": "uuid",
    "type": "recipe",
    "payload": { ... },
    "timestamp": "2026-07-11T12:00:00Z"
  }
}
```

### 5.2 ChatResponse (tipo: `answer`)

```json
{
  "type": "answer",
  "payload": {
    "text": "La leche Dos Pinos la encontrás en Walmart a ₡2.500 y en MaxiPalí a ₡2.300.",
    "sources": [
      { "productId": "uuid", "storeId": "uuid", "price": 2300 }
    ],
    "quickReplies": [
      "¿Y en la Bomba?",
      "¿Hay descuento por cantidad?"
    ]
  }
}
```

### 5.3 ProductSearchResponse (tipo: `productSearch`)

```json
{
  "type": "productSearch",
  "payload": {
    "query": "leche deslactosada",
    "results": [
      {
        "productId": "uuid",
        "masterProductId": "uuid",
        "name": "Leche Dos Pinos Deslactosada",
        "brand": "Dos Pinos",
        "imageUrl": "https://...",
        "prices": [
          { "storeId": "uuid", "storeName": "Walmart", "price": 2500, "currency": "CRC" },
          { "storeId": "uuid", "storeName": "MaxiPalí", "price": 2300, "currency": "CRC" }
        ],
        "bestPrice": { "storeId": "uuid", "storeName": "MaxiPalí", "price": 2300 },
        "savingsTip": "Ahorrás ₡200 comprando en MaxiPalí"
      }
    ],
    "totalResults": 3,
    "filterApplied": "category: lacteos"
  }
}
```

### 5.4 Recommendation (tipo: `recommendation`)

```json
{
  "type": "recommendation",
  "payload": {
    "productId": "uuid",
    "name": "Leche Dos Pinos Deslactosada",
    "recommendedStore": {
      "storeId": "uuid",
      "name": "MaxiPalí",
      "price": 2300,
      "currency": "CRC"
    },
    "alternatives": [
      {
        "name": "Leche Santa Clara Deslactosada",
        "storeId": "uuid",
        "storeName": "Walmart",
        "price": 2450
      }
    ],
    "reason": "Mejor relación calidad-precio. ₡200 más barata que en Walmart.",
    "comparisonSummary": "Precio promedio en otras tiendas: ₡2.600"
  }
}
```

### 5.5 RecipeResponse (tipo: `recipe`)

```json
{
  "type": "recipe",
  "payload": {
    "name": "Pechuga de pollo al horno con verduras",
    "preparationTime": "35 min",
    "difficulty": "fácil",
    "servings": 4,
    "ingredients": [
      { "name": "Pechuga de pollo", "quantity": "2", "unit": "unidades", "estimatedPrice": 3500, "storeId": "uuid" },
      { "name": "Brócoli", "quantity": "1", "unit": "cabeza", "estimatedPrice": 1200, "storeId": "uuid" },
      { "name": "Zanahoria", "quantity": "2", "unit": "unidades", "estimatedPrice": 500, "storeId": "uuid" }
    ],
    "steps": [
      "Precalentar el horno a 180°C.",
      "Sazonar las pechugas con sal, pimienta y especias al gusto.",
      "Cortar las verduras en trozos medianos.",
      "Colocar todo en una bandeja para horno y cocinar por 25 min."
    ],
    "totalEstimatedCost": 5200,
    "currency": "CRC",
    "storeIds": ["uuid", "uuid"],
    "nutritionalInfo": {
      "caloriesPerServing": 350,
      "protein": "32g",
      "carbs": "15g",
      "fat": "12g"
    }
  }
}
```

### 5.6 ShoppingListResponse (tipo: `shoppingList`)

```json
{
  "type": "shoppingList",
  "payload": {
    "title": "Cena de 4 personas — Italiana",
    "items": [
      { "name": "Pasta spaghetti", "quantity": "1", "unit": "paquete (500g)", "estimatedPrice": 1200, "storeId": "uuid", "category": "abarrotes" },
      { "name": "Salsa de tomate", "quantity": "1", "unit": "tarro", "estimatedPrice": 800, "storeId": "uuid", "category": "enlatados" },
      { "name": "Carne molida", "quantity": "500", "unit": "gramos", "estimatedPrice": 3500, "storeId": "uuid", "category": "carnes" },
      { "name": "Queso parmesano", "quantity": "100", "unit": "gramos", "estimatedPrice": 1500, "storeId": "uuid", "category": "lacteos" }
    ],
    "totalEstimatedCost": 7000,
    "currency": "CRC",
    "bestStore": { "storeId": "uuid", "name": "Walmart", "totalCost": 6500 },
    "savingsTip": "Comprando todo en Walmart ahorrarías ₡500"
  }
}
```

### 5.7 BudgetAnalysisResponse (tipo: `budgetAnalysis`)

```json
{
  "type": "budgetAnalysis",
  "payload": {
    "totalSpending": 85000,
    "currency": "CRC",
    "period": "semanal",
    "byStore": [
      { "storeId": "uuid", "storeName": "Walmart", "amount": 35000, "percentage": 41 },
      { "storeId": "uuid", "storeName": "MaxiPalí", "amount": 28000, "percentage": 33 },
      { "storeId": "uuid", "storeName": "Súper Ahorro", "amount": 22000, "percentage": 26 }
    ],
    "byCategory": [
      { "categoryId": "cat_carnes", "categoryName": "Carnes", "amount": 30000, "percentage": 35 },
      { "categoryId": "cat_lacteos", "categoryName": "Lácteos", "amount": 15000, "percentage": 18 }
    ],
    "savingsOpportunities": [
      { "tip": "Comprar carnes en Súper Ahorro podría ahorrarte hasta ₡5.000/semana", "estimatedSavings": 5000 },
      { "tip": "Revisar promociones de lácteos en MaxiPalí", "estimatedSavings": 2000 }
    ],
    "warnings": [
      "Gastás 35% de tu presupuesto en carnes, arriba del promedio (25%)"
    ]
  }
}
```

### 5.8 SubstitutionResponse (tipo: `substitution`)

```json
{
  "type": "substitution",
  "payload": {
    "originalProduct": {
      "name": "Crema Dulce Dos Pinos",
      "price": 1800,
      "storeId": "uuid"
    },
    "alternatives": [
      {
        "name": "Crema Dulce Santa Clara",
        "price": 1500,
        "storeId": "uuid",
        "storeName": "MaxiPalí",
        "savings": 300,
        "reason": "Mismo gramaje, ₡300 más barata",
        "sameStore": false
      },
      {
        "name": "Leche Evaporada (alternativa baja en grasa)",
        "price": 900,
        "storeId": "uuid",
        "storeName": "Walmart",
        "savings": 900,
        "reason": "Opción más saludable y económica",
        "sameStore": false
      }
    ],
    "bestAlternative": {
      "name": "Crema Dulce Santa Clara",
      "savings": 300
    }
  }
}
```

### 5.9 WeeklyPlanResponse (tipo: `weeklyPlan`)

```json
{
  "type": "weeklyPlan",
  "payload": {
    "title": "Menú semanal — Ahorro y salud",
    "days": [
      {
        "day": "Lunes",
        "meals": [
          {
            "type": "cena",
            "name": "Pechuga al horno con verduras",
            "recipeId": "uuid",
            "estimatedCost": 5200,
            "preparationTime": "35 min"
          }
        ]
      }
    ],
    "totalEstimatedCost": 45000,
    "currency": "CRC",
    "shoppingListSummary": {
      "uniqueItems": 22,
      "estimatedTotal": 45000,
      "bestStore": "Walmart"
    }
  }
}
```

### 5.10 ComparisonResponse (tipo: `comparison`)

```json
{
  "type": "comparison",
  "payload": {
    "productName": "Leche Dos Pinos Entera 1L",
    "masterProductId": "uuid",
    "prices": [
      { "storeId": "uuid", "storeName": "Walmart", "price": 2500, "logoUrl": "..." },
      { "storeId": "uuid", "storeName": "MaxiPalí", "price": 2300, "logoUrl": "..." },
      { "storeId": "uuid", "storeName": "Súper Ahorro", "price": 2400, "logoUrl": "..." }
    ],
    "bestPrice": { "storeId": "uuid", "storeName": "MaxiPalí", "price": 2300 },
    "priceRange": { "min": 2300, "max": 2500, "average": 2400 },
    "savingsByChoosingBest": {
      "vsMostExpensive": 200,
      "vsAverage": 100
    }
  }
}
```

---

## 6. Ciclo de Conversación

### 6.1 Gestión del historial

| Aspecto | Decisión | Justificación |
|---------|----------|---------------|
| **Almacenamiento** | Hive (local) + Supabase (opcional, server) | Hive para respuesta instantánea offline, Supabase para persistencia entre dispositivos |
| **Formato** | `conversation_messages { id, conversation_id, role, content, type, payload, created_at }` | Tabla normalizada, indexada por `conversation_id + created_at` |
| **Límite de historial** | Últimos 50 mensajes enviados al prompt | Costo de tokens: 50 mensajes × ~100 tokens c/u = ~5K tokens |
| **Resumen automático** | Cada 20 mensajes, se genera resumen y se incluye en lugar de mensajes antiguos | Evita crecimiento ilimitado del contexto manteniendo coherencia |
| **Limpieza** | Conversaciones inactivas > 7 días se archivan (Hive) o eliminan (Supabase) | Política de retención |
| **Reutilización** | Si el usuario vuelve dentro de 24h, la conversación continúa. Si > 24h, se crea nueva pero el historial es accesible | Balance entre continuidad y costo de tokens |

### 6.2 Ciclo de vida de una conversación

```
Creación (usuario abre el chat)
    │
    ▼
Activa (usuario envía mensajes)
    │
    ├── Cada mensaje se almacena en Hive + Supabase
    ├── Cada 20 mensajes → generación de resumen
    │   (Gemini: "Resumí esta conversación en 3 oraciones")
    └── Resumen reemplaza mensajes antiguos en el prompt
    │
    ▼
Inactiva (usuario cierra el chat o pasan 24h)
    │
    ▼
Archivada (7 días sin actividad)
    │
    ▼
Eliminada (30 días después de archivada)
```

### 6.3 Cómo se construye el prompt con historial

```
Sistema: [instrucciones + reglas + formato esperado]
Resumen de conversación: [generado por Gemini cada 20 turnos]  ← si existe
Historial reciente (últimos 50 mensajes): [
  { role: "user", content: "..." },
  { role: "assistant", content: "...", type: "recipe" },
  ...
]
Contexto de productos: [productos relevantes filtrados por intención]
Pregunta del usuario: [...]
```

### 6.4 Cuándo se limpia el historial

| Evento | Acción |
|--------|--------|
| Usuario cierra el chat y pasan > 24h | Nueva conversación. Anterior disponible en "Historial" |
| Usuario explícitamente "Nueva conversación" | Conversación actual se archiva, se crea nueva |
| 7 días sin actividad | Conversación se marca como archivada |
| 30 días en archivado | Conversación se elimina permanentemente |
| Límite de 50 mensajes alcanzado | Mensajes más antiguos se reemplazan por resumen |

### 6.5 Reutilización del historial

- **Misma sesión (< 24h)**: La conversación continúa. El `conversationId` se mantiene en `ConversationService`.
- **Entre sesiones**: El usuario puede ver el historial de conversaciones anteriores (título + resumen + primeros mensajes).
- **Entre dispositivos**: Si se implementa Supabase como backend de historial, el usuario puede retomar en otro dispositivo.

---

## 7. Diseño de la Interfaz

### 7.1 Botón IA junto al buscador

```
┌─────────────────────────────────────────────────────┐
│  MarketExplorerView                                  │
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │  Buscar producto...              [🔍] [✨] │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  (Los productos se muestran normalmente)             │
│                                                      │
│                                   [✨ Botón IA]      │
└─────────────────────────────────────────────────────┘
```

- El botón `[✨]` aparece junto al buscador principal (ícono `auto_awesome`)
- El botón flotante se mantiene como acceso rápido alternativo
- Ambos abren `assistant_chat_screen.dart`

### 7.2 Pantalla completa

```
┌─────────────────────────────────────────────────────┐
│  ←  Asistente de Compras                    [⋮]     │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Ejemplos rápidos:                                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │ ¿Qué     │ │ Receta   │ │ Lista    │ │ Ahorro │ │
│  │ compro?  │ │ con pollo│ │ semanal  │ │ en el  │ │
│  │          │ │          │ │          │ │ súper  │ │
│  └──────────┘ └──────────┘ └──────────┘ └────────┘ │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │  Asistente de VibeShopping                    │   │
│  │  ¡Hola! ¿En qué puedo ayudarte hoy?           │   │
│  │  Podés preguntarme sobre productos, precios,  │   │
│  │  recetas, o planificar tus compras.           │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │  Usuario                                       │   │
│  │  ¿Cuál es la leche más barata?                │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │  Asistente de VibeShopping                    │   │
│  │  Acá tenés la comparación de precios:        │   │
│  │                                               │   │
│  │  ┌────────────────────────────────────────┐   │   │
│  │  │  Comparación: Leche Dos Pinos 1L       │   │   │
│  │  │  ┌──────────┬────────┬─────────────┐   │   │   │
│  │  │  │ Tienda   │ Precio │  Ahorro     │   │   │   │
│  │  │  ├──────────┼────────┼─────────────┤   │   │   │
│  │  │  │ 🏪 Maxi  │ ₡2.300 │  Mejor  🏆 │   │   │   │
│  │  │  │ 🏪 Walmart│ ₡2.500 │  -₡200     │   │   │   │
│  │  │  │ 🏪 S.A.  │ ₡2.450 │  -₡150     │   │   │   │
│  │  │  └──────────┴────────┴─────────────┘   │   │   │
│  │  └────────────────────────────────────────┘   │   │
│  │                                               │   │
│  │  ¿Querés ver más opciones de lácteos?         │   │
│  │  [Ver más productos] [Agregar a lista]        │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │  [...input field...]            [📎] [📤]  │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### 7.3 Componentes de UI

| Componente | Descripción | Estado |
|------------|-------------|--------|
| **QuickActionChip** | Chips horizontales scrolleables con ejemplos predefinidos. Al tocarlos, se inserta el texto y se envía automáticamente. | Diseñado |
| **ChatBubble** | Burbuja de mensaje. El asistente tiene avatar, nombre, timestamp y contenido. El usuario tiene alineación derecha. | Diseñado |
| **InlineCard** | Contenedor dentro del chat para respuestas estructuradas (tarjetas, tablas, listas). | Diseñado |
| **TypingIndicator** | Animación de 3 puntitos mientras Gemini genera. | Diseñado |
| **InputBar** | Campo de texto con botón de enviar. Soporta: texto plano, adjuntar imagen (futuro), enviar. | Diseñado |
| **HistoryDrawer** | Drawer lateral (opcional) con lista de conversaciones anteriores. | Futuro |

### 7.4 Acciones rápidas predefinidas

| Acción | Icono | Prompt que se envía |
|--------|-------|---------------------|
| ¿Qué compro? | `shopping_cart` | "Ayudame a planificar las compras de la semana" |
| Receta con pollo | `restaurant` | "Dame una receta fácil con pollo" |
| Lista semanal | `calendar_month` | "Generame una lista de compras para la semana" |
| Ahorrar en el súper | `savings` | "¿Cómo puedo ahorrar en el supermercado?" |
| Comparar precios | `compare_arrows` | "Compará los precios de la leche en todas las tiendas" |
| Sin gluten | `gluten_free` (custom) | "¿Qué productos sin gluten hay?" |
| Cena rápida | `timer` | "Dame una receta rápida para cenar (menos de 20 min)" |

---

## 8. Plan de Migración por Fases

### Fase G.1.1 — Estructura del nuevo módulo (vacía)

**Objetivo**: Crear el esqueleto del nuevo módulo `shopping_assistant/` con toda la estructura de carpetas vacía. No rompe nada porque no hay imports nuevos.

**Archivos nuevos**:
- `lib/features/shopping_assistant/domain/chat_message.dart`
- `lib/features/shopping_assistant/domain/conversation.dart`
- `lib/features/shopping_assistant/domain/assistant_response.dart`
- `lib/features/shopping_assistant/domain/response_types.dart`
- `lib/features/shopping_assistant/domain/product_recommendation.dart`
- `lib/features/shopping_assistant/domain/shopping_plan.dart`
- `lib/features/shopping_assistant/domain/meal_recipe.dart`
- `lib/features/shopping_assistant/domain/budget_analysis.dart`
- `lib/features/shopping_assistant/domain/substitution.dart`
- `lib/features/shopping_assistant/domain/quick_action.dart`
- `lib/features/shopping_assistant/data/dto/chat_request_dto.dart`
- `lib/features/shopping_assistant/data/dto/chat_response_dto.dart`
- `lib/features/shopping_assistant/data/repositories/assistant_repository.dart`
- `lib/features/shopping_assistant/services/conversation_service.dart`
- `lib/features/shopping_assistant/services/intent_classifier.dart`
- `lib/features/shopping_assistant/providers/chat_provider.dart`
- `lib/features/shopping_assistant/providers/quick_actions_provider.dart`
- `lib/features/shopping_assistant/widgets/chat_bubble.dart`
- `lib/features/shopping_assistant/widgets/typing_indicator.dart`
- `lib/features/shopping_assistant/widgets/quick_action_chip.dart`
- `lib/features/shopping_assistant/screens/assistant_button.dart`
- `lib/features/shopping_assistant/screens/assistant_chat_screen.dart`

**Archivos modificados**: Ninguno

**Archivos eliminados**: Ninguno

**Riesgos**: Ninguno (archivos nuevos no referenciados desde ningún lado)

**Criterios de finalización**: `flutter analyze lib/features/shopping_assistant/` — 0 issues. Todos los archivos existen con clases/esqueletos compilables.

---

### Fase G.1.2 — Migrar endpoint Node.js

**Objetivo**: Reemplazar `server/src/routes/assistant.ts` por el nuevo `shopping-assistant.routes.ts` que soporte respuestas estructuradas y carga de productos desde Supabase. El endpoint anterior se mantiene como wrapper que redirige al nuevo por compatibilidad.

**Archivos nuevos**:
- `server/src/routes/shopping-assistant.routes.ts` — nuevo endpoint con:
  - Zod schema para request estructurado: `{ question, conversationId?, storeIds?, budget? }`
  - Zod schema para response estructurado: `{ type, payload, conversationId, timestamp }`
  - Carga de productos desde `v_products_complete`
  - Construcción de prompt con historial
  - Parseo de respuesta JSON de Gemini

**Archivos modificados**:
- `server/src/routes/index.ts` — agregar registro de `shoppingAssistantRoutes`
- `server/src/config/env.ts` — agregar `MAX_CONTEXT_TOKENS` (default 10000) y `SHOPPING_ASSISTANT_MODEL` (default gemini-2.0-flash)

**Archivos eliminados**: Ninguno (viejo `assistant.ts` se redirige al nuevo)

**Riesgos**: 
- Medio: El formato de respuesta cambia de `{ response: string }` a `{ type, payload }`. Flutter actual no lo entiende.
- Mitigación: El viejo endpoint se convierte en wrapper que llama al nuevo y convierte la respuesta a formato legacy.

**Criterios de finalización**:
- `npx tsc --noEmit` — 0 errors
- `curl POST /api/v1/shopping-assistant/ask {"question":"..."}` → devuelve `{ type, payload, conversationId }`
- `curl POST /api/v1/assistant/ask {"question":"..."}` → sigue devolviendo `{ response }` (compatibilidad)

---

### Fase G.1.3 — Flutter: nuevo repository + providers

**Objetivo**: Implementar `AssistantRepository`, `ChatProvider` y `QuickActionsProvider` en Flutter. Conectar con el nuevo endpoint Node.js. El módulo antiguo sigue funcionando en paralelo.

**Archivos nuevos**: (rellenar los esqueletos de G.1.1)
- `lib/features/shopping_assistant/data/repositories/assistant_repository.dart` — implementar `askQuestion()` llamando al nuevo endpoint
- `lib/features/shopping_assistant/providers/chat_provider.dart` — implementar `sendMessage()`, `retry()`, `clearConversation()`
- `lib/features/shopping_assistant/providers/quick_actions_provider.dart` — lista hardcodeada de QuickActions

**Archivos modificados**:
- `lib/core/di/app_providers.dart` — agregar registros de `AssistantRepository`, `ChatProvider`, `QuickActionsProvider`

**Archivos eliminados**: Ninguno

**Riesgos**: Bajo. Los nuevos providers no son usados por ninguna UI todavía.

**Criterios de finalización**:
- `flutter analyze lib/` — 0 issues
- `app_providers.dart` registra los nuevos providers sin errores

---

### Fase G.1.4 — Server: clasificación de intención + prompt engineering

**Objetivo**: Implementar clasificación de intención en Node.js y prompt engineering con respuestas JSON estructuradas.

**Archivos nuevos**:
- `server/src/prompts/assistant.system.txt` — prompt del sistema (instrucciones para Gemini)
- `server/src/prompts/assistant.examples.json` — ejemplos few-shot

**Archivos modificados**:
- `server/src/routes/shopping-assistant.routes.ts` — integrar clasificación de intención, construir prompt con system instructions + few-shot examples, parsear respuesta JSON de Gemini

**Archivos eliminados**: Ninguno

**Riesgos**:
- Medio: Gemini puede devolver JSON mal formado. Mitigación: Zod valida la respuesta; si falla, Gemini se re-intenta 1 vez con "devolvé SOLO JSON válido".
- Bajo: Los prompts en archivos separados requieren `fs.readFileSync` en tiempo de inicialización.

**Criterios de finalización**:
- `npx tsc --noEmit` — 0 errors
- Pregunta "receta con pollo" → `type: "recipe"` con payload válido
- Pregunta "¿dónde es más barato?" → `type: "comparison"` con payload válido

---

### Fase G.1.5 — Flutter: widgets del chat

**Objetivo**: Implementar todos los widgets del chat (ChatBubble, RecipeCard, ShoppingListCard, ComparisonTable, etc.) y la pantalla completa.

**Archivos nuevos**: (rellenar esqueletos)
- `lib/features/shopping_assistant/widgets/chat_bubble.dart`
- `lib/features/shopping_assistant/widgets/typing_indicator.dart`
- `lib/features/shopping_assistant/widgets/quick_action_chip.dart`
- `lib/features/shopping_assistant/widgets/product_card_inline.dart`
- `lib/features/shopping_assistant/widgets/recipe_card.dart`
- `lib/features/shopping_assistant/widgets/shopping_list_card.dart`
- `lib/features/shopping_assistant/widgets/comparison_table.dart`
- `lib/features/shopping_assistant/widgets/budget_chart.dart`
- `lib/features/shopping_assistant/screens/assistant_chat_screen.dart`

**Archivos modificados**: Ninguno

**Archivos eliminados**: Ninguno

**Riesgos**: Bajo. Los widgets no son referenciados desde fuera del módulo.

**Criterios de finalización**:
- `flutter analyze lib/` — 0 issues
- Los widgets renderizan correctamente datos mock en hot reload

---

### Fase G.1.6 — Integrar botón IA en MarketExplorerView

**Objetivo**: Reemplazar el FAB y el botón del buscador actuales por el nuevo `AssistantButton`.

**Archivos nuevos**: (rellenar esqueleto)
- `lib/features/shopping_assistant/screens/assistant_button.dart` — implementar widget completo

**Archivos modificados**:
- `lib/features/explorer/screens/market_explorer_view.dart` — reemplazar `VibeAiAssistant.buildFloatingButton(context)` por `AssistantButton()`

**Archivos eliminados**: Ninguno (módulo antiguo sigue existiendo hasta G.1.8)

**Riesgos**:
- Bajo: Si `AssistantChatScreen` tiene bugs, el usuario no puede abrir el asistente. Mitigación: `AssistantButton` puede tener un fallback que abre el antiguo `VibeAiAssistant.showAssistantSheet`.

**Criterios de finalización**:
- `flutter analyze lib/` — 0 issues
- Botón IA abre la nueva pantalla de chat
- Botón IA en buscador abre la misma pantalla

---

### Fase G.1.7 — Historial + ConversationService

**Objetivo**: Implementar el historial de conversación completo con Hive y Supabase, resumen automático y ciclo de vida.

**Archivos nuevos**: (rellenar esqueleto)
- `lib/features/shopping_assistant/services/conversation_service.dart` — implementar CRUD con Hive
- `server/src/services/conversation.service.ts` — implementar CRUD con Supabase

**Archivos modificados**:
- `lib/features/shopping_assistant/providers/chat_provider.dart` — integrar `ConversationService`
- `server/src/routes/shopping-assistant.routes.ts` — integrar `ConversationService`

**Archivos nuevos (server)**:
- `server/supabase/migrations/20260725_conversations.sql` — tabla `conversations` + `conversation_messages`

**Archivos eliminados**: Ninguno

**Riesgos**:
- Medio: Hive requiere inicialización en `main.dart`. Si no se inicializa, el módulo falla. Mitigación: `ConversationService` maneja estado "no disponible" y el chat funciona sin historial persistente.
- Bajo: La tabla nueva requiere migración en produción.

**Criterios de finalización**:
- `flutter analyze lib/` — 0 issues
- `npx tsc --noEmit` — 0 errors
- Conversación se mantiene al cerrar y reabrir el chat
- Resumen automático se genera cada 20 mensajes
- Preguntar "¿qué te pregunté antes?" → la IA responde correctamente

---

### Fase G.1.8 — Eliminar módulo antiguo

**Objetivo**: Eliminar todos los archivos del módulo `assistant/` antiguo y el endpoint legacy.

**Archivos eliminados**:
- `lib/features/assistant/services/assistant_service.dart`
- `lib/features/assistant/providers/assistant_provider.dart`
- `lib/features/assistant/screens/vibe_ai_assistant.dart`
- `lib/features/assistant/` (directorio vacío)
- `server/src/routes/assistant.ts`
- `server/src/services/gemini.ts`

**Archivos modificados**:
- `lib/core/di/app_providers.dart` — eliminar imports y registros de AssistantService/AssistantProvider
- `server/src/routes/index.ts` — eliminar registro de `assistantRoutes`

**Archivos nuevos**: Ninguno

**Riesgos**:
- Medio: Verificar que ningún archivo importe el módulo antiguo. Usar `grep` antes de eliminar.
- Mitigación: Si algún import residual se descubre, la compilación falla y se corrige antes del commit.

**Criterios de finalización**:
- `flutter analyze lib/` — 0 issues
- `npx tsc --noEmit` — 0 errors
- `grep -r "features/assistant" lib/` — 0 resultados
- `grep -r "assistantRoutes\|gemini.ts" server/src/` — 0 resultados
- El asistente funciona correctamente con el nuevo módulo

---

### Fase G.1.9 — Smart context pruning (optimización)

**Objetivo**: Reducir tokens enviados a Gemini filtrando productos por relevancia.

**Archivos nuevos**:
- `server/src/services/product-cache.service.ts` — cache en memoria con TTL de 5 minutos
- `server/src/services/product-filter.service.ts` — filtra productos por keywords extraídas de la pregunta

**Archivos modificados**:
- `server/src/routes/shopping-assistant.routes.ts` — integrar cache y filtro

**Archivos eliminados**: Ninguno

**Riesgos**:
- Bajo: El filtro puede excluir productos relevantes si las keywords no coinciden. Mitigación: Siempre incluir top 5 productos de categorías relacionadas.
- Bajo: Cache puede devolver datos desactualizados si hay cambios en Supabase. Mitigación: TTL de 5 minutos, o webhook de invalidación.

**Criterios de finalización**:
- `npx tsc --noEmit` — 0 errors
- Pregunta "leche" → solo productos con "leche" en el nombre
- Segunda pregunta en <5 min → 0 consultas a Supabase

---

### Fase G.1.10 — Streaming (optimización UX)

**Objetivo**: Mostrar respuesta token por token mientras Gemini genera.

**Archivos modificados**:
- `server/src/services/gemini.service.ts` (nuevo, reemplaza `gemini.ts`) — soportar `generateContentStream()` con SSE
- `server/src/routes/shopping-assistant.routes.ts` — endpoint stream con `response.type = 'text/event-stream'`
- `lib/features/shopping_assistant/data/repositories/assistant_repository.dart` — método `askQuestionStream()` que retorna `Stream<String>`
- `lib/features/shopping_assistant/providers/chat_provider.dart` — manejar stream, exponer mensaje parcial
- `lib/features/shopping_assistant/widgets/chat_bubble.dart` — soportar contenido parcial (texto que crece)

**Archivos nuevos**: Ninguno

**Riesgos**:
- Medio: SSE requiere manejo cuidadoso de conexión, reconexión y cancelación. Mitigación: El timeout de 15s de Gemini se mantiene.
- Bajo: Flutter `dart:io` HttpClient o `dio` con `responseTransformer: streamedResponse: true` para leer SSE.

**Criterios de finalización**:
- `flutter analyze lib/` — 0 issues
- `npx tsc --noEmit` — 0 errors
- Las respuestas aparecen carácter por carácter en el chat
- Cancelar navegación cierra el stream correctamente

---

## Resumen de migración

```
Fase     │ Archivos nuevos  │ Modificados  │ Eliminados  │ Esfuerzo
─────────┼──────────────────┼──────────────┼─────────────┼─────────
G.1.1    │ 22 (esqueletos)  │ 0            │ 0           │ ~30 min
G.1.2    │ 1 (server)       │ 2            │ 0           │ ~60 min
G.1.3    │ 3 (Flutter)      │ 1            │ 0           │ ~40 min
G.1.4    │ 2 (prompts)      │ 1            │ 0           │ ~45 min
G.1.5    │ 10 (Flutter UI)  │ 0            │ 0           │ ~120 min
G.1.6    │ 1 (botón)        │ 1            │ 0           │ ~15 min
G.1.7    │ 3 (historial)    │ 2            │ 0           │ ~90 min
G.1.8    │ 0                │ 2            │ 6           │ ~15 min
G.1.9    │ 2 (cache)        │ 1            │ 0           │ ~40 min
G.1.10   │ 0                │ 5            │ 0           │ ~90 min
─────────┼──────────────────┼──────────────┼─────────────┼─────────
Total    │ ~44 nuevos       │ ~15 modif.   │ 6 elim.     │ ~8-9 hrs
```

**Leyenda**: Las fases G.1.1 a G.1.6 son **críticas** (el asistente funciona). G.1.7 a G.1.10 son **mejoras** (el asistente funciona mejor).
