import { AnalyzedQuery, buildAnalyzedQuery } from '../types/analyzedQuery';
import { IntentAnalyzer } from './intentAnalyzer';
import { EntityExtractor } from './entityExtractor';

export class AnalyzerPipeline {
  private readonly _intentAnalyzer: IntentAnalyzer;
  private readonly _entityExtractor: EntityExtractor;

  constructor() {
    this._intentAnalyzer = new IntentAnalyzer();
    this._entityExtractor = new EntityExtractor();
  }

  run(question: string): AnalyzedQuery {
    const intentResult = this._intentAnalyzer.analyze(question);
    const entities = this._entityExtractor.extract(question);

    return buildAnalyzedQuery({
      intent: intentResult.intent,
      entities,
      confidence: intentResult.confidence,
      originalQuestion: question,
    });
  }
}
