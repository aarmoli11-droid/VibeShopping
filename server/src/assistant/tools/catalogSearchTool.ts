import { BaseTool, ToolInput, ToolOutput } from './baseTool';
import { ExecutionStep } from '../planner/executionPlan';
import { AssistantRepository } from '../repositories/assistantRepository';

export class CatalogSearchTool extends BaseTool {
  readonly name = 'catalogSearch';

  private readonly _repository: AssistantRepository;

  constructor(repository: AssistantRepository) {
    super();
    this._repository = repository;
  }

  canHandle(step: ExecutionStep): boolean {
    return step === 'catalogSearch';
  }

  async execute(input: ToolInput): Promise<ToolOutput> {
    try {
      const result = await this._repository.search(input.analyzedQuery);

      return {
        step: 'catalogSearch',
        success: true,
        data: {
          products: result.products,
          stores: result.stores,
          statistics: result.statistics,
          productsFound: result.statistics.totalProducts,
        },
      };
    } catch (error) {
      return {
        step: 'catalogSearch',
        success: false,
        data: {},
        error: error instanceof Error ? error.message : 'Error en búsqueda de catálogo',
      };
    }
  }
}
