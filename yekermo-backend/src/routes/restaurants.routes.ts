import { Router } from 'express';
import { RestaurantService } from '../services/restaurant.service';

const router = Router();
const restaurantService = new RestaurantService();

router.get('/', (_req, res) => {
  restaurantService
    .listRestaurants()
    .then((data) => res.json(data))
    .catch(() => res.status(500).json({ error: 'Server error', message: 'Failed to load restaurants' }));
});

router.get('/:id/menu', (req, res) => {
  const { id } = req.params;
  restaurantService
    .getRestaurantWithMenu(id)
    .then((data) => res.json(data))
    .catch((err) => {
      if (err.message === 'Restaurant not found') {
        res.status(404).json({ error: 'Not found', message: 'Restaurant not found' });
      } else {
        res.status(500).json({ error: 'Server error', message: err.message });
      }
    });
});

export default router;
