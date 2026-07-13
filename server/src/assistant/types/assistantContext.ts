import { z } from 'zod';

export const conversationSummarySchema = z.object({
  conversationId: z.string(),
  summary: z.string(),
  messageCount: z.number().int(),
  keyTopics: z.array(z.string()).optional(),
  lastMessageAt: z.string(),
});

export const assistantContextSchema = z.object({
  storeIds: z.array(z.string()).optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  budget: z.number().optional(),
  dietaryRestrictions: z.array(z.string()).optional(),
  activeListId: z.string().optional(),
  favoriteProductIds: z.array(z.string()).optional(),
  conversationSummary: conversationSummarySchema.optional(),
});

export interface AssistantContext extends z.infer<typeof assistantContextSchema> {}
export interface ConversationSummary extends z.infer<typeof conversationSummarySchema> {}
