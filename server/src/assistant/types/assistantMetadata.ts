import { z } from 'zod';

export const assistantMetadataSchema = z.object({
  appVersion: z.string(),
  platform: z.string(),
  language: z.string(),
  timezone: z.string(),
  buildNumber: z.string().optional(),
});

export interface AssistantMetadata extends z.infer<typeof assistantMetadataSchema> {}
