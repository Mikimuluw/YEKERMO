import { Router } from 'express';
import { z } from 'zod';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import { OrderService } from '../services/order.service';

const router = Router();
const orderService = new OrderService();

const placeOrderSchema = z.object({
  restaurantId: z.string().min(1),
  fulfillmentMode: z.string().min(1),
  total: z.number(),
  subtotal: z.number(),
  serviceFee: z.number(),
  deliveryFee: z.number(),
  tax: z.number(),
  addressId: z.string().optional(),
  items: z.array(
    z.object({
      menuItemId: z.string(),
      quantity: z.number().int().positive(),
    })
  ),
  paymentMethod: z.enum(['CARD', 'CASH']).optional(),
  paymentMethodLegacy: z
    .object({
      brand: z.string(),
      last4: z.string(),
    })
    .optional(),
});

// Mount auth for all order routes
router.use(authenticateToken);

// Register /orders/latest before /orders/:id so "latest" is not captured as id
router.get('/latest', (req: AuthRequest, res) => {
  const userId = req.userId!;
  orderService
    .getLatestOrder(userId)
    .then((data) => res.json(data))
    .catch(() => res.status(500).json({ error: 'Server error', message: 'Failed to load order' }));
});

router.get('/', (req: AuthRequest, res) => {
  const userId = req.userId!;
  orderService
    .getOrders(userId)
    .then((data) => res.json(data))
    .catch(() => res.status(500).json({ error: 'Server error', message: 'Failed to load orders' }));
});

router.get('/:id', (req: AuthRequest, res) => {
  const userId = req.userId!;
  const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  orderService
    .getOrder(userId, id!)
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Not found') {
        res.status(404).json({ error: 'Not found', message: 'Order not found' });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

router.get('/:id/events', (req: AuthRequest, res) => {
  const userId = req.userId!;
  const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const limit = Math.min(Number(req.query.limit) || 50, 100);
  const cursor = typeof req.query.cursor === 'string' ? req.query.cursor : undefined;
  orderService
    .getOrderEvents(userId, id!, limit, cursor)
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Not found') {
        res.status(404).json({ error: 'Not found', message: 'Order not found' });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

const updateStatusSchema = z.object({
  status: z.string().min(1),
  reason: z.string().optional(),
});

router.patch('/:id/status', (req: AuthRequest, res) => {
  const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const parsed = updateStatusSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: 'Invalid request', message: 'status required' });
    return;
  }
  orderService
    .updateOrderStatus(id!, parsed.data.status, {
      reason: parsed.data.reason,
      actorType: 'SYSTEM',
      actorId: req.userId ?? undefined,
    })
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Not found') {
        res.status(404).json({ error: 'Not found', message: 'Order not found' });
      } else if (err.message.startsWith('Invalid transition')) {
        res.status(400).json({ error: 'Invalid request', message: err.message });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

const cancelSchema = z.object({
  reason: z.string().optional(),
});

router.post('/:id/cancel', (req: AuthRequest, res) => {
  const userId = req.userId!;
  const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  const parsed = cancelSchema.safeParse(req.body ?? {});
  orderService
    .cancelOrder(userId, id!, parsed.success ? parsed.data.reason : undefined)
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Not found') {
        res.status(404).json({ error: 'Not found', message: 'Order not found' });
      } else if (err.message.startsWith('Cancel not allowed')) {
        res.status(400).json({ error: 'Invalid request', message: err.message });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

router.post('/:id/confirm-cash', (req: AuthRequest, res) => {
  const userId = req.userId!;
  const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  orderService
    .confirmCash(userId, id!)
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Not found') {
        res.status(404).json({ error: 'Not found', message: 'Order not found' });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

router.post('/', (req: AuthRequest, res) => {
  const userId = req.userId!;
  const parsed = placeOrderSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: 'Invalid request', message: 'Invalid order payload' });
    return;
  }
  orderService
    .placeOrder(userId, parsed.data)
    .then((data) => res.status(201).json(data))
    .catch((err) => {
      if (err.message === 'Customer not found') {
        res.status(404).json({ error: 'Not found', message: 'Customer not found' });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

export default router;
