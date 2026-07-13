import { BaseTool, ToolInput, ToolOutput } from './baseTool';
import { ExecutionStep } from '../planner/executionPlan';

export class BudgetTool extends BaseTool {
  readonly name = 'budget';

  canHandle(step: ExecutionStep): boolean {
    return step === 'budget';
  }

  async execute(input: ToolInput): Promise<ToolOutput> {
    return {
      step: 'budget',
      success: true,
      data: {
        message: 'Análisis de presupuesto no implementado — requiere Gemini en fase posterior',
        requiresAI: true,
        budget: input.analyzedQuery.entities.budget,
        products: input.analyzedQuery.entities.products,
      },
    };
  }
}
