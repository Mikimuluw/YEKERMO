import { PrismaClient, ActorType, OrderEventType, Prisma } from '@prisma/client';

const prisma = new PrismaClient();

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  NEW: ['ACCEPTED', 'CANCELLED', 'REJECTED'],
  ACCEPTED: ['PREPARING', 'CANCELLED', 'REJECTED'],
  PREPARING: ['READY_FOR_PICKUP', 'CANCELLED', 'REJECTED'],
  READY_FOR_PICKUP: ['OUT_FOR_DELIVERY'],
  OUT_FOR_DELIVERY: ['DELIVERED'],
  PENDING_PAYMENT: ['NEW', 'CANCELLED'],
};

const CANCEL_ALLOWED = ['NEW', 'ACCEPTED'];

export type PlaceOrderPaymentMethod = 'CARD' | 'CASH';

export interface PlaceOrderDraft {
  restaurantId: string;
  fulfillmentMode: string;
  total: number;
  subtotal: number;
  serviceFee: number;
  deliveryFee: number;
  tax: number;
  addressId?: string;
  items: { menuItemId: string; quantity: number }[];
  /** Phase-2: CARD = PENDING_PAYMENT until paid, CASH = NEW immediately */
  paymentMethod?: PlaceOrderPaymentMethod;
  /** Legacy: only used when paying with saved card (Phase-1 style) */
  paymentMethodLegacy?: { brand: string; last4: string };
}

export class OrderService {
  async placeOrder(userId: string, draft: PlaceOrderDraft) {
    const customer = await prisma.customer.findUnique({ where: { userId } });
    if (!customer) throw new Error('Customer not found');

    const method: PlaceOrderPaymentMethod = draft.paymentMethod ?? 'CASH';
    const isCard = method === 'CARD';
    const status = isCard ? 'PENDING_PAYMENT' : 'NEW';
    const paymentStatusLegacy = isCard ? 'unpaid' : 'unpaid';
    const amountSubtotal = Math.round(draft.subtotal * 100);
    const amountTax = Math.round(draft.tax * 100);
    const amountDeliveryFee = Math.round(draft.deliveryFee * 100);
    const amountTotal = Math.round(draft.total * 100);

    const order = await prisma.order.create({
      data: {
        customerId: customer.id,
        restaurantId: draft.restaurantId,
        status,
        fulfillmentMode: draft.fulfillmentMode,
        paymentStatus: paymentStatusLegacy,
        paymentBrand: draft.paymentMethodLegacy?.brand ?? null,
        paymentLast4: draft.paymentMethodLegacy?.last4 ?? null,
        total: draft.total,
        subtotal: draft.subtotal,
        serviceFee: draft.serviceFee,
        deliveryFee: draft.deliveryFee,
        tax: draft.tax,
        addressId: draft.addressId,
        paidAt: isCard ? null : undefined,
        paymentMethod: isCard ? 'CARD' : 'CASH',
        paymentStatusV2: 'UNPAID',
        paymentProvider: isCard ? 'STRIPE' : null,
        currency: 'CAD',
        amountSubtotal,
        amountTax,
        amountDeliveryFee,
        amountTotal,
        items: {
          create: draft.items.map((item) => ({
            menuItemId: item.menuItemId,
            quantity: item.quantity,
          })),
        },
      },
      include: { items: true, address: true },
    });

    await this.appendEvent(order.id, {
      type: 'ORDER_CREATED',
      fromStatus: null,
      toStatus: status,
      actorType: 'CUSTOMER',
      actorId: customer.id,
      metadata: {},
    });

    return this.formatOrder(order);
  }

  async getOrderEvents(userId: string, orderId: string, limit = 50, cursor?: string) {
    const customer = await prisma.customer.findUnique({ where: { userId } });
    if (!customer) throw new Error('Not found');

    const order = await prisma.order.findFirst({
      where: { id: orderId, customerId: customer.id },
      select: { id: true },
    });
    if (!order) throw new Error('Not found');

    const take = limit + 1;
    const events = await prisma.orderEvent.findMany({
      where: { orderId },
      orderBy: { createdAt: 'asc' },
      take,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
    });

    const hasMore = events.length > limit;
    const list = hasMore ? events.slice(0, limit) : events;
    const nextCursor = hasMore ? list[list.length - 1]?.id : null;

    return {
      events: list.map((e) => ({
        id: e.id,
        orderId: e.orderId,
        type: e.type,
        fromStatus: e.fromStatus ?? undefined,
        toStatus: e.toStatus ?? undefined,
        actorType: e.actorType,
        actorId: e.actorId ?? undefined,
        metadata: (e.metadata as Record<string, unknown>) ?? {},
        createdAt: e.createdAt.toISOString(),
      })),
      nextCursor: nextCursor ?? undefined,
    };
  }

  async updateOrderStatus(
    orderId: string,
    status: string,
    opts: { reason?: string; actorType: ActorType; actorId?: string }
  ) {
    const order = await prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new Error('Not found');

    const fromStatus = order.status;
    const allowed = ALLOWED_TRANSITIONS[fromStatus];
    if (!allowed?.includes(status)) {
      throw new Error(`Invalid transition from ${fromStatus} to ${status}`);
    }

    await prisma.$transaction([
      prisma.order.update({
        where: { id: orderId },
        data: { status, updatedAt: new Date() },
      }),
      prisma.orderEvent.create({
        data: {
          orderId,
          type: OrderEventType.STATUS_CHANGED,
          fromStatus,
          toStatus: status,
          actorType: opts.actorType,
          actorId: opts.actorId ?? null,
          metadata: opts.reason ? { reason: opts.reason } : {},
        },
      }),
    ]);

    const orderWithCustomer = await prisma.order.findUnique({
      where: { id: orderId },
      include: { customer: true },
    });
    if (orderWithCustomer?.customer?.userId) {
      await prisma.notificationJob.create({
        data: {
          userId: orderWithCustomer.customer.userId,
          type: 'ORDER_STATUS_CHANGED',
          payload: {
            orderId,
            status,
            title: `Order ${status.replace(/_/g, ' ').toLowerCase()}`,
            body: `Your order status is now ${status}.`,
          },
          status: 'SENT',
        },
      });
    }

    return this.getOrderById(orderId);
  }

  async cancelOrder(userId: string, orderId: string, reason?: string) {
    const customer = await prisma.customer.findUnique({ where: { userId } });
    if (!customer) throw new Error('Not found');

    const order = await prisma.order.findFirst({
      where: { id: orderId, customerId: customer.id },
    });
    if (!order) throw new Error('Not found');
    if (!CANCEL_ALLOWED.includes(order.status)) {
      throw new Error(`Cancel not allowed in status ${order.status}`);
    }

    await prisma.$transaction([
      prisma.order.update({
        where: { id: orderId },
        data: { status: 'CANCELLED', updatedAt: new Date() },
      }),
      prisma.orderEvent.create({
        data: {
          orderId,
          type: OrderEventType.CANCELLED_BY_CUSTOMER,
          fromStatus: order.status,
          toStatus: 'CANCELLED',
          actorType: 'CUSTOMER',
          actorId: customer.id,
          metadata: reason ? { reason } : {},
        },
      }),
    ]);

    return this.getOrderById(orderId);
  }

  async confirmCash(userId: string, orderId: string) {
    const customer = await prisma.customer.findUnique({ where: { userId } });
    if (!customer) throw new Error('Not found');

    const order = await prisma.order.findFirst({
      where: { id: orderId, customerId: customer.id },
    });
    if (!order) throw new Error('Not found');

    await prisma.order.update({
      where: { id: orderId },
      data: {
        paymentMethod: 'CASH',
        paymentStatusV2: 'UNPAID',
        updatedAt: new Date(),
      },
    });

    return this.getOrderById(orderId);
  }

  async getOrderById(orderId: string) {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: { items: { include: { menuItem: true } }, address: true },
    });
    if (!order) throw new Error('Not found');
    return this.formatOrder(order);
  }

  async getOrders(userId: string) {
    const customer = await prisma.customer.findUnique({ where: { userId } });
    if (!customer) return [];

    const orders = await prisma.order.findMany({
      where: { customerId: customer.id },
      orderBy: { placedAt: 'desc' },
      include: { items: { include: { menuItem: true } }, address: true },
    });

    return orders.map((o) => this.formatOrder(o));
  }

  async getOrder(userId: string, orderId: string) {
    const customer = await prisma.customer.findUnique({ where: { userId } });
    if (!customer) throw new Error('Not found');

    const order = await prisma.order.findFirst({
      where: { id: orderId, customerId: customer.id },
      include: { items: { include: { menuItem: true } }, address: true },
    });

    if (!order) throw new Error('Not found');
    return this.formatOrder(order);
  }

  async getLatestOrder(userId: string) {
    const customer = await prisma.customer.findUnique({ where: { userId } });
    if (!customer) return null;

    const order = await prisma.order.findFirst({
      where: { customerId: customer.id },
      orderBy: { placedAt: 'desc' },
      include: { items: { include: { menuItem: true } }, address: true },
    });

    if (!order) return null;
    return this.formatOrder(order);
  }

  /** Internal: append OrderEvent (used by payment webhook too). */
  async appendEvent(
    orderId: string,
    event: {
      type: OrderEventType;
      fromStatus: string | null;
      toStatus: string | null;
      actorType: ActorType;
      actorId?: string | null;
      metadata?: Record<string, unknown>;
    }
  ) {
    await prisma.orderEvent.create({
      data: {
        orderId,
        type: event.type,
        fromStatus: event.fromStatus,
        toStatus: event.toStatus,
        actorType: event.actorType,
        actorId: event.actorId ?? null,
        metadata: (event.metadata ?? {}) as Prisma.InputJsonValue,
      },
    });
  }

  /** Internal: set order status (e.g. after payment). Caller must create OrderEvent if needed. */
  async setOrderStatus(orderId: string, status: string, paymentFields?: { paymentStatusV2: 'PAID'; paidAt: Date }) {
    await prisma.order.update({
      where: { id: orderId },
      data: {
        status,
        ...(paymentFields ?? {}),
        updatedAt: new Date(),
      },
    });
  }

  private formatOrder(order: {
    id: string;
    restaurantId: string;
    status: string;
    fulfillmentMode: string;
    paymentStatus: string;
    paymentBrand: string | null;
    paymentLast4: string | null;
    paymentMethod: 'CARD' | 'CASH' | null;
    paymentStatusV2: 'UNPAID' | 'REQUIRES_ACTION' | 'PAID' | 'FAILED' | 'REFUNDED' | null;
    total: number;
    subtotal: number;
    serviceFee: number;
    deliveryFee: number;
    tax: number;
    amountSubtotal: number | null;
    amountTax: number | null;
    amountDeliveryFee: number | null;
    amountTotal: number | null;
    currency: string | null;
    placedAt: Date;
    paidAt: Date | null;
    address: {
      id: string;
      label: string;
      line1: string;
      city: string;
      neighborhood: string | null;
      notes: string | null;
    } | null;
    items: { menuItemId: string; quantity: number }[];
  }) {
    return {
      id: order.id,
      restaurantId: order.restaurantId,
      status: order.status,
      fulfillmentMode: order.fulfillmentMode,
      paymentStatus: order.paymentStatusV2 ?? order.paymentStatus,
      paymentMethod:
        order.paymentBrand != null
          ? { brand: order.paymentBrand, last4: order.paymentLast4 ?? '' }
          : order.paymentMethod ?? undefined,
      paymentMethodType: order.paymentMethod ?? undefined,
      total: order.total,
      subtotal: order.subtotal,
      serviceFee: order.serviceFee,
      deliveryFee: order.deliveryFee,
      tax: order.tax,
      amountSubtotal: order.amountSubtotal ?? undefined,
      amountTax: order.amountTax ?? undefined,
      amountDeliveryFee: order.amountDeliveryFee ?? undefined,
      amountTotal: order.amountTotal ?? undefined,
      currency: order.currency ?? 'CAD',
      items: order.items.map((item) => ({
        menuItemId: item.menuItemId,
        quantity: item.quantity,
      })),
      address: order.address
        ? {
            id: order.address.id,
            label: order.address.label,
            line1: order.address.line1,
            city: order.address.city,
            neighborhood: order.address.neighborhood ?? undefined,
            notes: order.address.notes ?? undefined,
          }
        : null,
      placedAt: order.placedAt.toISOString(),
      paidAt: order.paidAt?.toISOString() ?? undefined,
    };
  }
}
