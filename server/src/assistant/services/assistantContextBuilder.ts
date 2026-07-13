import { AnalyzedQuery } from '../types/analyzedQuery';
import { AssistantContext } from '../types/assistantContext';
import { ExecutionPlan } from '../planner/executionPlan';
import { ToolOutput } from '../tools/baseTool';

export interface BuiltContext {
  analyzedQuery: AnalyzedQuery;
  executionPlan: ExecutionPlan;
  toolResults: ToolOutput[];
  user: AssistantContext;
}

export class AssistantContextBuilder {
  build(params: {
    analyzedQuery: AnalyzedQuery;
    executionPlan: ExecutionPlan;
    toolResults: ToolOutput[];
    userContext?: Partial<AssistantContext>;
  }): BuiltContext {
    return {
      analyzedQuery: params.analyzedQuery,
      executionPlan: params.executionPlan,
      toolResults: params.toolResults,
      user: {
        storeIds: params.userContext?.storeIds,
        budget: params.userContext?.budget,
        dietaryRestrictions: params.userContext?.dietaryRestrictions,
        activeListId: params.userContext?.activeListId,
        favoriteProductIds: params.userContext?.favoriteProductIds,
      },
    };
  }
}
