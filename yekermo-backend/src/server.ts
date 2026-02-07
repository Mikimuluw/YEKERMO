import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config/env';

import authRoutes from './routes/auth.routes';
import meRoutes from './routes/me.routes';
import restaurantsRoutes from './routes/restaurants.routes';
import ordersRoutes from './routes/orders.routes';
import paymentsRoutes, { handleStripeWebhook } from './routes/payments.routes';

const app = express();

app.use(helmet());
app.use(
  cors({
    origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN.split(',').map((o) => o.trim()),
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);
app.use(morgan('combined'));

// Stripe webhook needs raw body for signature verification (must be before express.json())
app.post('/payments/webhook', express.raw({ type: 'application/json' }), handleStripeWebhook);

app.use(express.json());

app.use('/auth', authRoutes);
app.use('/me', meRoutes);
app.use('/restaurants', restaurantsRoutes);
app.use('/orders', ordersRoutes);
app.use('/payments', paymentsRoutes);

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.listen(env.PORT, () => {
  console.log(`Server running on port ${env.PORT} (${env.NODE_ENV})`);
});
