import { z } from 'zod';

export const assistantContextSchema = z.object({
  storeIds: z.array(z.string()).optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  budget: z.number().optional(),
  dietaryRestrictions: z.array(z.string()).optional(),
  activeListId: z.string().optional(),
  favoriteProductIds: z.array(z.string()).optional(),
  conversationSummary: z.object({
    conversationId: z.string(),
    summary: z.string(),
    messageCount: z.number().int(),
    keyTopics: z.array(z.string()).optional(),
    lastMessageAt: z.string(),
  }).optional(),
});

export const assistantMetadataSchema = z.object({
  appVersion: z.string(),
  platform: z.string(),
  language: z.string(),
  timezone: z.string(),
  buildNumber: z.string().optional(),
});

export const assistantRequestSchema = z.object({
  question: z.string().min(1).max(5000),
  conversationId: z.string().optional(),
  context: assistantContextSchema.optional(),
  metadata: assistantMetadataSchema.optional(),
});

export interface AssistantRequest {
  question: string;
  conversationId?: string;
  context?: z.infer<typeof assistantContextSchema>;
  metadata?: z.infer<typeof assistantMetadataSchema>;
}
