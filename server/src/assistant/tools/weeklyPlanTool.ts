import { BaseTool, ToolInput, ToolOutput } from './baseTool';
import { ExecutionStep } from '../planner/executionPlan';

export class WeeklyPlanTool extends BaseTool {
  readonly name = 'weeklyPlan';

  canHandle(step: ExecutionStep): boolean {
    return step === 'weeklyPlan';
  }

  async execute(input: ToolInput): Promise<ToolOutput> {
    return {
      step: 'weeklyPlan',
      success: true,
      data: {
        message: 'Plan semanal no implementado — requiere Gemini en fase posterior',
        requiresAI: true,
        servings: input.analyzedQuery.entities.servings,
        budget: input.analyzedQuery.entities.budget,
      },
    };
  }
}
