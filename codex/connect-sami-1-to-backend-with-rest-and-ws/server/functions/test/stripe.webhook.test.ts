import Stripe from 'stripe';
import * as test from 'firebase-functions-test';

const fft = test({ projectId: 'demo' });
fft.mockConfig({ stripe: { secret: 'sk_test', webhook_secret: 'whsec_test' } });
const { stripeWebhook } = require('../src/stripe/webhooks');

describe('stripe webhook', () => {
  after(() => fft.cleanup());

  it('handles signed event', async () => {
    const stripe = new Stripe('sk_test', { apiVersion: '2023-08-16' });
    const payload = JSON.stringify({ id: 'evt_1', object: 'event', type: 'invoice.paid' });
    const header = stripe.webhooks.generateTestHeaderString({ payload, secret: 'whsec_test' });
    const req: any = { rawBody: Buffer.from(payload), headers: { 'stripe-signature': header } };
    const res: any = {
      json: (_: any) => {},
      status: (c: number) => ({ send: (_m: any) => ({ c }) }),
    };
    await stripeWebhook(req as any, res as any);
  });
});
