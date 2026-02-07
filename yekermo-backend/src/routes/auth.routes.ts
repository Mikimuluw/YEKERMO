import { Router } from 'express';
import { z } from 'zod';
import { AuthService } from '../services/auth.service';

const router = Router();
const authService = new AuthService();

const signInSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

router.post('/sign-in', async (req, res) => {
  try {
    const parsed = signInSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: 'Invalid request', message: 'Email and password are required' });
      return;
    }
    const { email, password } = parsed.data;
    const data = await authService.signIn(email, password);
    res.status(200).json(data);
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Sign in failed';
    if (message === 'Invalid credentials') {
      res.status(401).json({ error: 'Invalid credentials', message: 'Email or password is incorrect' });
    } else {
      res.status(500).json({ error: 'Server error', message: 'Sign in failed' });
    }
  }
});

export default router;
