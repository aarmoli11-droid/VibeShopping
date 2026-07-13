export type ResponseType =
  | 'answer'
  | 'productSearch'
  | 'recommendation'
  | 'comparison'
  | 'recipe'
  | 'shoppingList'
  | 'budgetAnalysis'
  | 'substitution'
  | 'weeklyPlan'
  | 'promotion'
  | 'nutritionalInfo'
  | 'dietaryAdvice'
  | 'storeGuide';

export interface AssistantResponse {
  conversationId: string;
  type: ResponseType;
  message: string;
  payload: Record<string, unknown>;
  actions: string[];
}
