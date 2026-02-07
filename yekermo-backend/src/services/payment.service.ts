import { PrismaClient } from '@prisma/client';
import Stripe from 'stripe';
import { env } from '../config/env';
import { OrderService } from './order.service';

const prisma = new PrismaClient();
const orderService = new OrderService();

function getStripe(): Stripe | null {
  const key = env.STRIPE_SECRET_KEY;
  if (!key) return null;
  return new Stripe(key);
}

export class PaymentService {
  async createIntent(userId: string, orderId: string): Promise<{ clientSecret: string; paymentIntentId: string }> {
    const stripe = getStripe();
    if (!stripe) throw new Error('Stripe is not configured');

    const customer = await prisma.customer.findUnique({ where: { userId } });
    if (!customer) throw new Error('Not found');

    const order = await prisma.order.findFirst({
      where: { id: orderId, customerId: customer.id },
    });
    if (!order) throw new Error('Not found');
    if (order.paymentMethod !== 'CARD') {
      throw new Error('Order is not a card payment');
    }
    if (order.paymentStatusV2 !== 'UNPAID' && order.paymentStatusV2 !== 'REQUIRES_ACTION') {
      throw new Error('Order is not awaiting payment');
    }

    const amountCents = order.amountTotal ?? Math.round(order.total * 100);
    const currency = (order.currency ?? 'cad').toLowerCase();

    const pi = await stripe.paymentIntents.create({
      amount: amountCents,
      currency,
      automatic_payment_methods: { enabled: true },
      metadata: { orderId },
    });

    await prisma.paymentAttempt.create({
      data: {
        orderId,
        provider: 'STRIPE',
        intentId: pi.id,
        status: pi.status,
      },
    });

    await prisma.order.update({
      where: { id: orderId },
      data: {
        paymentIntentId: pi.id,
        paymentStatusV2: pi.status === 'requires_action' ? 'REQUIRES_ACTION' : 'UNPAID',
        updatedAt: new Date(),
      },
    });

    if (!pi.client_secret) throw new Error('No client secret from Stripe');
    return { clientSecret: pi.client_secret, paymentIntentId: pi.id };
  }

  async handleWebhook(rawBody: Buffer, signature: string | undefined): Promise<{ received: boolean }> {
    const stripe = getStripe();
    const secret = env.STRIPE_WEBHOOK_SECRET;
    if (!stripe || !secret || !signature) {
      return { received: false };
    }

    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(rawBody, signature, secret);
    } catch {
      throw new Error('Invalid webhook signature');
    }

    if (event.type === 'payment_intent.succeeded') {
      const pi = event.data.object as Stripe.PaymentIntent;
      const orderId = pi.metadata?.orderId;
      if (!orderId) return { received: true };

      const order = await prisma.order.findUnique({
        where: { id: orderId },
        include: { customer: true },
      });
      if (!order) return { received: true };

      await prisma.$transaction([
        prisma.order.update({
          where: { id: orderId },
          data: {
            status: 'NEW',
            paymentStatus: 'paid',
            paymentStatusV2: 'PAID',
            paidAt: new Date(),
            updatedAt: new Date(),
          },
        }),
        prisma.orderEvent.create({
          data: {
            orderId,
            type: 'PAYMENT_SUCCEEDED',
            fromStatus: order.status,
            toStatus: 'NEW',
            actorType: 'SYSTEM',
            metadata: { paymentIntentId: pi.id },
          },
        }),
      ]);

      const user = await prisma.user.findUnique({
        where: { id: order.customer.userId },
      });
      if (user) {
        await prisma.notificationJob.create({
          data: {
            userId: user.id,
            type: 'ORDER_STATUS_CHANGED',
            payload: {
              orderId,
              status: 'NEW',
              title: 'Payment confirmed',
              body: 'Your order has been placed.',
            },
            status: 'SENT',
          },
        });
      }
    } else if (event.type === 'payment_intent.payment_failed') {
      const pi = event.data.object as Stripe.PaymentIntent;
      const orderId = pi.metadata?.orderId;
      if (!orderId) return { received: true };

      const order = await prisma.order.findFirst({ where: { id: orderId } });
      if (!order) return { received: true };

      await prisma.$transaction([
        prisma.order.update({
          where: { id: orderId },
          data: {
            paymentStatusV2: 'FAILED',
            updatedAt: new Date(),
          },
        }),
        prisma.orderEvent.create({
          data: {
            orderId,
            type: 'PAYMENT_FAILED',
            fromStatus: order.status,
            toStatus: order.status,
            actorType: 'SYSTEM',
            metadata: {
              paymentIntentId: pi.id,
              error: (pi as { last_payment_error?: { message?: string } }).last_payment_error?.message,
            },
          },
        }),
      ]);
    }

    return { received: true };
  }
}
