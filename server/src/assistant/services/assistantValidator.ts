import { z } from 'zod';
import { assistantRequestSchema } from '../types/assistantRequest';

export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

export class AssistantValidator {
  validate(body: unknown): ValidationResult {
    const result = assistantRequestSchema.safeParse(body);

    if (!result.success) {
      const errors = result.error.issues.map(
        (issue) => `${issue.path.join('.')}: ${issue.message}`,
      );
      return { isValid: false, errors };
    }

    const data = result.data;

    if (!data.question || data.question.trim().length === 0) {
      return { isValid: false, errors: ['question: no puede estar vacía'] };
    }

    return { isValid: true, errors: [] };
  }
}
