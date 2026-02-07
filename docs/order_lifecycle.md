# Order Lifecycle (Phase 12.3 — Backend Truth)

Tie PRD §4.2 to reality. The backend must support the following **states somewhere real** (persisted or authoritatively returned by the API), even if some transitions are simulated or manual.

---

## Backend must support

| State | Meaning | Backend responsibility |
|-------|---------|-------------------------|
| **Order created** | Order record exists (id, items, fulfillment, etc.). Payment may still be pending. | Backend creates and stores the order record; returns order id. Order is the unit of truth for “this order exists.” |
| **Payment confirmed** | Payment has been authorized and captured (per Phase 12.2: capture only after order stored). | Backend records payment status (e.g. `paid`), payment reference, and optionally `paidAt`. GET order reflects this. |
| **Order received** | Restaurant has received the order (acknowledgment). | Backend stores and exposes this state (e.g. `status: received` or equivalent). Transition to “received” can be manual, implicit, or simulated—but the **state** exists in backend data. |
| **Order failed** | The order or the placement failed (payment failed, place failed, or order later invalidated). | Backend either (a) stores a failed order with a failure state/reason, or (b) does not create an order and returns a failure response. Either way, “order failed” is a real outcome the backend can represent or return. |

So: **order created**, **payment confirmed**, **order received**, and **order failed** are not only UI or domain concepts; they exist in backend storage or API responses.

---

## What can still be simulated or manual

- **Restaurant ack** — Moving to “order received” (and beyond: preparing, ready, completed) can be manual (ops), implicit (e.g. time-based), or simulated. The requirement is that the **state** is stored and exposed by the backend, not that the restaurant has a real integration.
- **Delivery** — Can be restaurant-managed (phone, their own system). We only need the lifecycle states (e.g. “ready” for pickup, or “completed” when done); how the restaurant fulfills is out of scope for 12.3.

The states must exist **somewhere real**; the mechanisms that transition between them can be simple or simulated.

---

## Mapping to PRD §4.2 and domain

| PRD §4.2 / Phase 6 | Backend (Phase 12.3) | App domain |
|--------------------|----------------------|------------|
| Order created | Order record stored; id and fields persisted | `Order` with `id`, `OrderStatus`, `PaymentStatus` |
| Payment authorized / captured | Payment confirmed (paid) stored on order | `Order.paymentStatus` = paid, `Order.paidAt`, `Order.paymentMethod` |
| Order acknowledged by restaurant | Order received (and optionally preparing, ready, completed) stored on order | `Order.status`: `received` → `preparing` → `ready` → `completed` |
| (Failure) | Order failed: either no order created (API failure) or order in failed state | Place-order failure; optional `Order.status` or separate failure response |

API contract: GET `/orders`, GET `/orders/:id` (and optionally GET `/orders/latest`) return order(s) with at least: id, status (lifecycle), payment status, and any failure reason when applicable. Place-order endpoint returns the created order (with payment confirmed) or a failure; the backend does not return “order created but payment failed” without also supporting a clear failed state or response so the app can show honest copy.

---

## Definition of done (Phase 12.3)

- [ ] Backend persists and exposes **order created** (order record with id).
- [ ] Backend persists and exposes **payment confirmed** (paid on order).
- [ ] Backend persists and exposes **order received** (and optionally preparing/ready/completed); transition to “received” can be manual or simulated.
- [ ] Backend supports **order failed** (either no order created + failure response, or order with a failed state/reason).
- [ ] App’s order history and order detail consume these states from the backend (GET orders); UI and copy remain aligned with PRD §4.2 and Phase 6 rules.
