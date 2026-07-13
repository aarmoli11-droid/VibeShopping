import { BaseTool, ToolInput, ToolOutput } from './baseTool';
import { ExecutionStep } from '../planner/executionPlan';

export class ComparisonTool extends BaseTool {
  readonly name = 'comparison';

  canHandle(step: ExecutionStep): boolean {
    return step === 'comparison';
  }

  async execute(input: ToolInput): Promise<ToolOutput> {
    return {
      step: 'comparison',
      success: true,
      data: {
        message: 'Comparación no implementada — requiere Gemini en fase posterior',
        requiresAI: true,
        products: input.analyzedQuery.entities.products,
      },
    };
  }
}
