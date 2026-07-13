export class AssistantPromptBuilder {
  buildSystemPrompt(): string {
    return 'Eres un asistente de compras en Costa Rica.';
  }

  buildUserPrompt(question: string): string {
    return `Pregunta del usuario:\n${question}`;
  }
}
