import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export interface CreateAddressInput {
  label: string;
  line1: string;
  city: string;
  neighborhood?: string;
  notes?: string;
}

export class CustomerService {
  async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { customer: { include: { addresses: true } } },
    });
    if (!user?.customer) throw new Error('Customer not found');

    const c = user.customer;
    return {
      id: c.id,
      name: c.name,
      email: user.email,
      primaryAddressId: c.primaryAddressId,
      preference: {
        favoriteCuisines: c.favoriteCuisines,
        dietaryTags: c.dietaryTags,
      },
      addresses: c.addresses.map((a) => ({
        id: a.id,
        label: a.label,
        line1: a.line1,
        city: a.city,
        neighborhood: a.neighborhood ?? undefined,
        notes: a.notes ?? undefined,
      })),
    };
  }

  async getAddresses(userId: string) {
    const customer = await prisma.customer.findUnique({
      where: { userId },
      include: { addresses: true },
    });
    if (!customer) return [];

    return customer.addresses.map((a) => ({
      id: a.id,
      label: a.label,
      line1: a.line1,
      city: a.city,
      neighborhood: a.neighborhood ?? undefined,
      notes: a.notes ?? undefined,
    }));
  }

  async createAddress(userId: string, input: CreateAddressInput) {
    const customer = await prisma.customer.findUnique({
      where: { userId },
    });
    if (!customer) throw new Error('Customer not found');

    const address = await prisma.address.create({
      data: {
        customerId: customer.id,
        label: input.label,
        line1: input.line1,
        city: input.city,
        neighborhood: input.neighborhood,
        notes: input.notes,
      },
    });

    return {
      id: address.id,
      label: address.label,
      line1: address.line1,
      city: address.city,
      neighborhood: address.neighborhood ?? undefined,
      notes: address.notes ?? undefined,
    };
  }
}
