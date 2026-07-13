import { Intent } from '../types/analyzedQuery';

export type ExecutionStep =
  | 'catalogSearch'
  | 'comparison'
  | 'recommendation'
  | 'recipe'
  | 'shoppingList'
  | 'weeklyPlan'
  | 'budget'
  | 'substitution'
  | 'nutrition'
  | 'storeGuide'
  | 'aiCompletion'
  | 'none';

export interface ExecutionPlan {
  intent: Intent;
  steps: ExecutionStep[];
  requiresAI: boolean;
  requiresCatalog: boolean;
}
