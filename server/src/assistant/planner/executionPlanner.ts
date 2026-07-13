import { AnalyzedQuery, Intent } from '../types/analyzedQuery';
import { ExecutionPlan, ExecutionStep } from './executionPlan';

type StepMap = Record<Intent, { steps: ExecutionStep[]; requiresAI: boolean; requiresCatalog: boolean }>;

const STEP_MAP: StepMap = {
  searchProduct:       { steps: ['catalogSearch'],                   requiresAI: false, requiresCatalog: true },
  comparePrices:       { steps: ['catalogSearch', 'comparison'],     requiresAI: false, requiresCatalog: true },
  recommendation:      { steps: ['catalogSearch', 'recommendation'], requiresAI: true,  requiresCatalog: true },
  recipe:              { steps: ['recipe'],                          requiresAI: true,  requiresCatalog: false },
  shoppingList:        { steps: ['shoppingList'],                    requiresAI: true,  requiresCatalog: false },
  weeklyPlan:          { steps: ['weeklyPlan'],                      requiresAI: true,  requiresCatalog: false },
  budget:              { steps: ['catalogSearch', 'budget'],         requiresAI: false, requiresCatalog: true },
  substitution:        { steps: ['catalogSearch', 'substitution'],   requiresAI: true,  requiresCatalog: true },
  nutrition:           { steps: ['nutrition'],                       requiresAI: true,  requiresCatalog: false },
  storeRecommendation: { steps: ['storeGuide'],                      requiresAI: false, requiresCatalog: false },
  generalQuestion:     { steps: ['aiCompletion'],                    requiresAI: true,  requiresCatalog: false },
  unknown:             { steps: ['none'],                            requiresAI: false, requiresCatalog: false },
};

export class ExecutionPlanner {
  plan(analyzed: AnalyzedQuery): ExecutionPlan {
    const mapped = STEP_MAP[analyzed.intent];

    return {
      intent: analyzed.intent,
      steps: mapped.steps,
      requiresAI: mapped.requiresAI,
      requiresCatalog: mapped.requiresCatalog,
    };
  }
}
