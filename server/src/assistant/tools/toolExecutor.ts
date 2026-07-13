import { BaseTool, ToolInput, ToolOutput } from './baseTool';
import { ExecutionPlan } from '../planner/executionPlan';
import { CatalogSearchTool } from './catalogSearchTool';
import { ComparisonTool } from './comparisonTool';
import { RecommendationTool } from './recommendationTool';
import { RecipeTool } from './recipeTool';
import { ShoppingListTool } from './shoppingListTool';
import { WeeklyPlanTool } from './weeklyPlanTool';
import { BudgetTool } from './budgetTool';
import { AssistantRepository } from '../repositories/assistantRepository';

export interface ExecutionResult {
  plan: ExecutionPlan;
  toolResults: ToolOutput[];
}

export class ToolExecutor {
  private readonly _tools: BaseTool[];

  constructor(repository: AssistantRepository) {
    this._tools = [
      new CatalogSearchTool(repository),
      new ComparisonTool(),
      new RecommendationTool(),
      new RecipeTool(),
      new ShoppingListTool(),
      new WeeklyPlanTool(),
      new BudgetTool(),
    ];
  }

  async execute(plan: ExecutionPlan, input: ToolInput): Promise<ExecutionResult> {
    const results: ToolOutput[] = [];

    for (const step of plan.steps) {
      const tool = this._tools.find((t) => t.canHandle(step));

      if (!tool) {
        results.push({
          step,
          success: false,
          data: {},
          error: `No hay herramienta disponible para el paso: ${step}`,
        });
        continue;
      }

      const output = await tool.execute(input);
      results.push(output);
    }

    return { plan, toolResults: results };
  }
}
