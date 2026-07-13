import { BaseTool, ToolInput, ToolOutput } from './baseTool';
import { ExecutionStep } from '../planner/executionPlan';

export class RecipeTool extends BaseTool {
  readonly name = 'recipe';

  canHandle(step: ExecutionStep): boolean {
    return step === 'recipe';
  }

  async execute(input: ToolInput): Promise<ToolOutput> {
    return {
      step: 'recipe',
      success: true,
      data: {
        message: 'Receta no implementada — requiere Gemini en fase posterior',
        requiresAI: true,
        recipe: input.analyzedQuery.entities.recipe,
        products: input.analyzedQuery.entities.products,
      },
    };
  }
}
