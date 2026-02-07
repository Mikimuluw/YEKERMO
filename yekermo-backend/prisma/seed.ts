import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('password123', 10);

  const user = await prisma.user.upsert({
    where: { email: 'test@yekermo.ca' },
    update: {},
    create: { email: 'test@yekermo.ca', password: passwordHash },
  });

  const customer = await prisma.customer.upsert({
    where: { userId: user.id },
    update: {},
    create: {
      userId: user.id,
      name: 'Test User',
      favoriteCuisines: ['Ethiopian'],
      dietaryTags: [],
    },
  });

  const address = await prisma.address.create({
    data: {
      customerId: customer.id,
      label: 'home',
      line1: '123 Test St',
      city: 'Calgary',
    },
  });

  await prisma.customer.update({
    where: { id: customer.id },
    data: { primaryAddressId: address.id },
  });

  const restaurant = await prisma.restaurant.create({
    data: {
      name: 'Test Ethiopian Restaurant',
      address: '456 Calgary St',
      tagline: 'Authentic Ethiopian cuisine',
      prepTimeBand: 'standard',
      serviceModes: ['delivery', 'pickup'],
      tags: ['familySize'],
      trustCopy: 'Trusted local favorite',
      dishNames: ['Injera', 'Doro Wat'],
      hoursByWeekday: {
        1: '11:00-21:00',
        2: '11:00-21:00',
        3: '11:00-21:00',
        4: '11:00-21:00',
        5: '11:00-22:00',
        6: '11:00-22:00',
        7: '12:00-20:00',
      },
      rating: 4.5,
      maxMinutes: 45,
    },
  });

  const category = await prisma.menuCategory.create({
    data: {
      restaurantId: restaurant.id,
      title: 'Main Dishes',
      sortOrder: 1,
    },
  });

  await prisma.menuItem.create({
    data: {
      restaurantId: restaurant.id,
      categoryId: category.id,
      name: 'Doro Wat',
      description: 'Spicy chicken stew',
      price: 16.5,
      tags: ['quickFilling'],
      available: true,
    },
  });

  console.log('Seed data created successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
