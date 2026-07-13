import { ExtractedEntities, emptyEntities } from './extractedEntities';

export type Intent =
  | 'searchProduct'
  | 'comparePrices'
  | 'recommendation'
  | 'recipe'
  | 'shoppingList'
  | 'weeklyPlan'
  | 'budget'
  | 'substitution'
  | 'nutrition'
  | 'storeRecommendation'
  | 'generalQuestion'
  | 'unknown';

export interface AnalyzedQuery {
  intent: Intent;
  entities: ExtractedEntities;
  confidence: number;
  requiresAI: boolean;
  requiresCatalog: boolean;
  originalQuestion: string;
}

export function buildAnalyzedQuery(params: {
  intent: Intent;
  entities?: ExtractedEntities;
  confidence: number;
  originalQuestion: string;
}): AnalyzedQuery {
  const aiIntents: Set<Intent> = new Set([
    'recipe',
    'weeklyPlan',
    'substitution',
    'nutrition',
    'generalQuestion',
  ]);

  const catalogIntents: Set<Intent> = new Set([
    'searchProduct',
    'comparePrices',
    'budget',
    'storeRecommendation',
  ]);

  return {
    intent: params.intent,
    entities: params.entities ?? emptyEntities(),
    confidence: params.confidence,
    requiresAI: aiIntents.has(params.intent),
    requiresCatalog: catalogIntents.has(params.intent),
    originalQuestion: params.originalQuestion,
  };
}
