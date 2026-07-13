import { randomUUID } from 'node:crypto';
import { AssistantValidator, ValidationResult } from './assistantValidator';
import { AssistantContextBuilder, BuiltContext } from './assistantContextBuilder';
import { AssistantResponseFormatter } from './assistantResponseFormatter';
import { AssistantRepository } from '../repositories/assistantRepository';
import { AnalyzerPipeline } from '../analysis/analyzerPipeline';
import { ExecutionPlanner } from '../planner/executionPlanner';
import { ToolExecutor, ExecutionResult } from '../tools/toolExecutor';
import { ToolInput } from '../tools/baseTool';
import { AssistantRequest } from '../types/assistantRequest';
import { AssistantResponse } from '../types/assistantResponse';

export class ShoppingAssistantService {
  private readonly _validator: AssistantValidator;
  private readonly _analyzer: AnalyzerPipeline;
  private readonly _planner: ExecutionPlanner;
  private readonly _executor: ToolExecutor;
  private readonly _contextBuilder: AssistantContextBuilder;
  private readonly _formatter: AssistantResponseFormatter;
  private readonly _repository: AssistantRepository;

  constructor() {
    this._validator = new AssistantValidator();
    this._analyzer = new AnalyzerPipeline();
    this._planner = new ExecutionPlanner();
    this._repository = new AssistantRepository();
    this._executor = new ToolExecutor(this._repository);
    this._contextBuilder = new AssistantContextBuilder();
    this._formatter = new AssistantResponseFormatter();
  }

  async processMessage(request: AssistantRequest): Promise<AssistantResponse> {
    const validation: ValidationResult = this._validator.validate(request);
    if (!validation.isValid) {
      throw new Error(`Validación fallida: ${validation.errors.join('; ')}`);
    }

    const conversationId = request.conversationId ?? randomUUID();

    const analyzedQuery = this._analyzer.run(request.question);
    const executionPlan = this._planner.plan(analyzedQuery);

    const toolInput: ToolInput = {
      analyzedQuery,
      executionPlan,
      userContext: request.context,
    };

    const executionResult: ExecutionResult = await this._executor.execute(executionPlan, toolInput);

    const builtContext: BuiltContext = this._contextBuilder.build({
      analyzedQuery,
      executionPlan,
      toolResults: executionResult.toolResults,
      userContext: request.context,
    });

    const productsFound = executionResult.toolResults
      .filter((r) => r.step === 'catalogSearch' && r.success)
      .reduce((sum, r) => sum + ((r.data.productsFound as number) ?? 0), 0);

    const stepsExecuted = executionResult.toolResults
      .filter((r) => r.success)
      .map((r) => r.step);

    const stepsFailed = executionResult.toolResults
      .filter((r) => !r.success)
      .map((r) => ({ step: r.step, error: r.error }));

    return this._formatter.formatResponse({
      conversationId,
      type: 'answer',
      message: 'Consulta analizada correctamente.',
      payload: {
        intent: analyzedQuery.intent,
        confidence: analyzedQuery.confidence,
        entities: analyzedQuery.entities,
        productsFound,
        stepsExecuted,
        stepsFailed: stepsFailed.length > 0 ? stepsFailed : undefined,
        context: builtContext,
      },
      actions: [],
    });
  }
}
