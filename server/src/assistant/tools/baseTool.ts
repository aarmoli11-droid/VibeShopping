import { AnalyzedQuery } from '../types/analyzedQuery';
import { AssistantContext } from '../types/assistantContext';
import { ExecutionPlan, ExecutionStep } from '../planner/executionPlan';

export interface ToolInput {
  analyzedQuery: AnalyzedQuery;
  executionPlan: ExecutionPlan;
  userContext?: Partial<AssistantContext>;
}

export interface ToolOutput {
  step: ExecutionStep;
  success: boolean;
  data: Record<string, unknown>;
  error?: string;
}

export abstract class BaseTool {
  abstract readonly name: string;

  abstract canHandle(step: ExecutionStep): boolean;

  abstract execute(input: ToolInput): Promise<ToolOutput>;
}
