# Phase-2 Backend Extensions — PRD Checklist

Copy/paste into Cursor as tasks. Order follows “fastest path”: OrderStatus/events → cash flow → Stripe → notifications.

---

## 2.1 Schema & migrations

- [ ] Add to Order: `paymentMethod` enum (`CARD` \| `CASH`), `paymentStatus` enum (`UNPAID` \| `REQUIRES_ACTION` \| `PAID` \| `FAILED` \| `REFUNDED`), `paymentProvider` enum (`STRIPE`), `paymentIntentId` (string nullable), `paidAt` (datetime nullable), `currency` (string default `CAD`), `amountSubtotal` / `amountTax` / `amountDeliveryFee` / `amountTotal` (int, cents)
- [ ] Create `PaymentAttempt` table: `id`, `orderId`, `provider`, `intentId`, `status`, `lastError` (nullable), timestamps
- [ ] Add OrderStatus enum and use in Order: `DRAFT` \| `PENDING_PAYMENT` \| `NEW` \| `ACCEPTED` \| `PREPARING` \| `READY_FOR_PICKUP` \| `OUT_FOR_DELIVERY` \| `DELIVERED` \| `CANCELLED` \| `REJECTED`
- [ ] Create `OrderEvent` table: `id`, `orderId`, `type` (OrderEventType), `fromStatus`, `toStatus`, `actorType` (`CUSTOMER` \| `RESTAURANT` \| `SYSTEM` \| `DRIVER`), `actorId`, `metadata` (JSON), `createdAt`
- [ ] Create `NotificationJob` table: `id`, `userId`, `type`, `payload` (JSON), `status` (`PENDING` \| `SENT` \| `FAILED`), `attemptCount`, timestamps
- [ ] Run Prisma migrations and keep Phase-1 fields backward-compatible where needed (e.g. `total`/`subtotal` etc. can coexist with cents fields during transition)

---

## 2.2 Order totals (cents)

- [ ] Store and compute all monetary amounts in cents (ints); ensure `amountSubtotal`, `amountTax`, `amountDeliveryFee`, `amountTotal` are set on Order create/update
- [ ] API responses expose amounts in cents (and/or keep a `total` in dollars for backward compatibility per product decision)

---

## 2.3 Order lifecycle & events

- [ ] Define allowed status transitions (e.g. `NEW` → `ACCEPTED` → `PREPARING` → `READY_FOR_PICKUP` → `OUT_FOR_DELIVERY` → `DELIVERED`; cancel from `NEW`/`ACCEPTED`)
- [ ] On order create/update/status change: create `OrderEvent` records (append-only audit log)
- [ ] Implement `PATCH /orders/:id/status` (body: `{ status, reason? }`); validate transitions; auth for restaurant/system/driver (for now protect endpoint)
- [ ] Implement `POST /orders/:id/cancel` (customer cancel rules: only before `PREPARING` or within X minutes); emit event and update status
- [ ] Implement `GET /orders/:id/events`; return audit log for UI timeline

---

## 2.4 Payments — cash

- [ ] On order create with `paymentMethod: CASH`: set `paymentStatus: UNPAID`, order status `NEW` (no payment intent)
- [ ] Implement `POST /orders/:id/confirm-cash` to set `paymentMethod: CASH` and leave `paymentStatus: UNPAID` (restaurant/driver can mark paid later)

---

## 2.5 Payments — Stripe (card)

- [ ] Implement `POST /payments/create-intent`: input `orderId`; only when `paymentMethod=CARD` and `paymentStatus=UNPAID`; output `clientSecret`, `paymentIntentId`; create/update PaymentAttempt
- [ ] Orders created with card start in `PENDING_PAYMENT`; move to `NEW` only after payment confirmed
- [ ] Implement `POST /payments/webhook` (Stripe): verify signature; on success update `paymentStatus`, `paidAt`; on failure update status; emit internal events `payment.succeeded` / `payment.failed`
- [ ] Optional: auto-cancel order after TTL if payment fails

---

## 2.6 Notifications (event-first)

- [ ] On important changes (e.g. order status, payment result): create `OrderEvent` and enqueue `NotificationJob` (outbox)
- [ ] Worker (cron or background process) processes pending `NotificationJob`s; Phase-2: in-app only (store as “notification” or use same table with status)
- [ ] Implement `GET /me/notifications` (paginated)
- [ ] Implement `POST /me/notifications/:id/read` (mark read)

---

## 2.7 E2E & quality

- [ ] E2E: place order with cash → order in `NEW`, no payment intent
- [ ] E2E: place order with card → create intent → complete payment (test mode) → order moves to `NEW`, `paidAt` set
- [ ] E2E: status updates (e.g. NEW → ACCEPTED → PREPARING) and timeline visible via `GET /orders/:id/events`

---

## Phase-2 “Done” summary

- [ ] Prisma schema updated + migrations applied
- [ ] Order totals stored in cents and computed consistently
- [ ] Stripe PaymentIntent create + webhook verify in place
- [ ] OrderStatus + transitions validated on `PATCH /orders/:id/status`
- [ ] OrderEvent log created for all material changes
- [ ] Notification outbox + worker runner implemented
- [ ] E2E: place order (cash + card), status updates, timeline visible
