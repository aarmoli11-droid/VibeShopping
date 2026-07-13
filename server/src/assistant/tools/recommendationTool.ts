import { BaseTool, ToolInput, ToolOutput } from './baseTool';
import { ExecutionStep } from '../planner/executionPlan';

export class RecommendationTool extends BaseTool {
  readonly name = 'recommendation';

  canHandle(step: ExecutionStep): boolean {
    return step === 'recommendation';
  }

  async execute(input: ToolInput): Promise<ToolOutput> {
    return {
      step: 'recommendation',
      success: true,
      data: {
        message: 'Recomendación no implementada — requiere Gemini en fase posterior',
        requiresAI: true,
        products: input.analyzedQuery.entities.products,
      },
    };
  }
}
