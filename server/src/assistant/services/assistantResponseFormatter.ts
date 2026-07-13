import { AssistantResponse, ResponseType } from '../types/assistantResponse';

export class AssistantResponseFormatter {
  formatResponse(params: {
    conversationId: string;
    type?: ResponseType;
    message?: string;
    payload?: Record<string, unknown>;
    actions?: string[];
  }): AssistantResponse {
    return {
      conversationId: params.conversationId,
      type: params.type ?? 'answer',
      message: params.message ?? 'Procesando tu solicitud...',
      payload: params.payload ?? {},
      actions: params.actions ?? [],
    };
  }
}
