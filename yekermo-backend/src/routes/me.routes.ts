import { Router } from 'express';
import { z } from 'zod';
import { authenticateToken, AuthRequest } from '../middleware/auth';
import { CustomerService } from '../services/customer.service';
import { NotificationService } from '../services/notification.service';

const router = Router();
const customerService = new CustomerService();
const notificationService = new NotificationService();

router.use(authenticateToken);

const createAddressSchema = z.object({
  label: z.string().min(1),
  line1: z.string().min(1),
  city: z.string().min(1),
  neighborhood: z.string().optional(),
  notes: z.string().optional(),
});

router.get('/', (req: AuthRequest, res) => {
  const userId = req.userId!;
  customerService
    .getProfile(userId)
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Customer not found') {
        res.status(404).json({ error: 'Not found', message: 'Profile not found' });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

router.get('/addresses', (req: AuthRequest, res) => {
  const userId = req.userId!;
  customerService
    .getAddresses(userId)
    .then((data) => res.json(data))
    .catch(() => res.status(500).json({ error: 'Server error', message: 'Failed to load addresses' }));
});

router.post('/addresses', (req: AuthRequest, res) => {
  const userId = req.userId!;
  const parsed = createAddressSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: 'Invalid request', message: 'label, line1, and city are required' });
    return;
  }
  customerService
    .createAddress(userId, parsed.data)
    .then((data) => res.status(201).json(data))
    .catch((err) => {
      if (err.message === 'Customer not found') {
        res.status(404).json({ error: 'Not found', message: 'Customer not found' });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

router.get('/notifications', (req: AuthRequest, res) => {
  const userId = req.userId!;
  const limit = Math.min(Number(req.query.limit) || 20, 100);
  const cursor = typeof req.query.cursor === 'string' ? req.query.cursor : undefined;
  notificationService
    .list(userId, limit, cursor)
    .then((data) => res.json(data))
    .catch(() => res.status(500).json({ error: 'Server error', message: 'Failed to load notifications' }));
});

router.post('/notifications/:id/read', (req: AuthRequest, res) => {
  const userId = req.userId!;
  const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
  notificationService
    .markRead(userId, id!)
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Not found') {
        res.status(404).json({ error: 'Not found', message: 'Notification not found' });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

export default router;
