import { Router, Request, Response } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import { PaymentService } from '../services/payment.service';

const router = Router();
const paymentService = new PaymentService();

router.post('/create-intent', authenticateToken, (req: AuthRequest, res: Response) => {
  const userId = req.userId!;
  const orderId = typeof req.body?.orderId === 'string' ? req.body.orderId : undefined;
  if (!orderId) {
    res.status(400).json({ error: 'Invalid request', message: 'orderId required' });
    return;
  }
  paymentService
    .createIntent(userId, orderId)
    .then((data) => res.status(201).json(data))
    .catch((err) => {
      if (err.message === 'Not found') {
        res.status(404).json({ error: 'Not found', message: 'Order not found' });
      } else if (err.message === 'Stripe is not configured') {
        res.status(503).json({ error: 'Service unavailable', message: 'Payments not configured' });
      } else if (err.message.includes('card payment') || err.message.includes('awaiting payment')) {
        res.status(400).json({ error: 'Invalid request', message: err.message });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

export function handleStripeWebhook(req: Request, res: Response) {
  const signature = req.headers['stripe-signature'];
  const rawBody = req.body as Buffer | undefined;
  if (!rawBody || !Buffer.isBuffer(rawBody)) {
    res.status(400).json({ error: 'Bad request', message: 'Raw body required' });
    return;
  }
  paymentService
    .handleWebhook(rawBody, typeof signature === 'string' ? signature : undefined)
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Invalid webhook signature') {
        res.status(401).json({ error: 'Unauthorized', message: err.message });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
}

export default router;
