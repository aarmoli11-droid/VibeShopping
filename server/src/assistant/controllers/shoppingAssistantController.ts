import { FastifyInstance } from 'fastify';
import { authMiddleware } from '../../middleware/auth';
import { ShoppingAssistantService } from '../services/shoppingAssistantService';

export async function shoppingAssistantController(app: FastifyInstance): Promise<void> {
  const service = new ShoppingAssistantService();

  app.addHook('onRequest', authMiddleware);

  app.post('/shopping-assistant/chat', {
    config: { rateLimit: { max: 30, timeWindow: '1 minute' } },
    handler: async (request, reply) => {
      request.log.info({
        questionLength: (request.body as Record<string, unknown>)?.question?.toString().length ?? 0,
      }, 'POST /api/v2/shopping-assistant/chat');

      const response = await service.processMessage(request.body as Parameters<typeof service.processMessage>[0]);
      reply.send({ success: true, data: response });
    },
  });
}
