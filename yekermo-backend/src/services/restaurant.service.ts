import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class RestaurantService {
  async listRestaurants() {
    const restaurants = await prisma.restaurant.findMany({
      orderBy: { name: 'asc' },
    });

    return restaurants.map((r) => ({
      id: r.id,
      name: r.name,
      address: r.address,
      tagline: r.tagline,
      prepTimeBand: r.prepTimeBand,
      serviceModes: r.serviceModes,
      tags: r.tags,
      trustCopy: r.trustCopy,
      dishNames: r.dishNames,
      hoursByWeekday: r.hoursByWeekday as Record<string, string>,
      rating: r.rating ?? undefined,
      maxMinutes: r.maxMinutes ?? undefined,
    }));
  }

  async getRestaurantWithMenu(restaurantId: string) {
    const restaurant = await prisma.restaurant.findUnique({
      where: { id: restaurantId },
      include: {
        categories: { orderBy: { sortOrder: 'asc' }, include: { items: { where: { available: true } } } },
      },
    });

    if (!restaurant) throw new Error('Restaurant not found');

    return {
      id: restaurant.id,
      name: restaurant.name,
      address: restaurant.address,
      tagline: restaurant.tagline,
      prepTimeBand: restaurant.prepTimeBand,
      serviceModes: restaurant.serviceModes,
      tags: restaurant.tags,
      trustCopy: restaurant.trustCopy,
      dishNames: restaurant.dishNames,
      hoursByWeekday: restaurant.hoursByWeekday as Record<string, string>,
      rating: restaurant.rating ?? undefined,
      maxMinutes: restaurant.maxMinutes ?? undefined,
      categories: restaurant.categories.map((cat) => ({
        id: cat.id,
        title: cat.title,
        items: cat.items.map((item) => ({
          id: item.id,
          restaurantId: item.restaurantId,
          categoryId: item.categoryId,
          name: item.name,
          description: item.description,
          price: item.price,
          tags: item.tags,
        })),
      })),
    };
  }
}
