import { BaseTool, ToolInput, ToolOutput } from './baseTool';
import { ExecutionStep } from '../planner/executionPlan';

export class ShoppingListTool extends BaseTool {
  readonly name = 'shoppingList';

  canHandle(step: ExecutionStep): boolean {
    return step === 'shoppingList';
  }

  async execute(input: ToolInput): Promise<ToolOutput> {
    return {
      step: 'shoppingList',
      success: true,
      data: {
        message: 'Lista de compras no implementada — requiere Gemini en fase posterior',
        requiresAI: true,
        products: input.analyzedQuery.entities.products,
      },
    };
  }
}
