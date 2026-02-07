import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class NotificationService {
  async list(userId: string, limit = 20, cursor?: string) {
    const take = limit + 1;
    const items = await prisma.notificationJob.findMany({
      where: { userId, status: 'SENT' },
      orderBy: { createdAt: 'desc' },
      take,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
    });
    const hasMore = items.length > limit;
    const list = hasMore ? items.slice(0, limit) : items;
    const nextCursor = hasMore ? list[list.length - 1]?.id : null;
    return {
      notifications: list.map((n) => ({
        id: n.id,
        type: n.type,
        payload: n.payload as Record<string, unknown>,
        read: n.readAt != null,
        createdAt: n.createdAt.toISOString(),
      })),
      nextCursor: nextCursor ?? undefined,
    };
  }

  async markRead(userId: string, notificationId: string) {
    const n = await prisma.notificationJob.findFirst({
      where: { id: notificationId, userId },
    });
    if (!n) throw new Error('Not found');
    await prisma.notificationJob.update({
      where: { id: notificationId },
      data: { readAt: new Date(), updatedAt: new Date() },
    });
    return { id: n.id, read: true };
  }
}
