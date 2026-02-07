# Phase-2 Flutter Screens & Routing Map

Aligns with Phase-2 backend and existing GoRouter structure. New/updated screens and routes are called out.

---

## Route ownership (existing pattern)

- Each feature has a `*_routes.dart` that defines its `GoRoute(s)`.
- `lib/app/router.dart` composes: shell branches + root-level routes (`checkout`, `order-tracking`, `address-manager`, `settings`, `welcome`, `not-found`).
- `lib/app/routes.dart` holds path constants and helpers (e.g. `Routes.orderTrackingDetails(id)`).

---

## Current route constants (`Routes`)

| Constant | Path | Notes |
|----------|------|--------|
| `home` | `/` | Shell tab |
| `discovery` | `/discover` | Under home |
| `search` | `/search` | Shell tab |
| `cart` | `/cart` | Shell tab |
| `orders` | `/orders` | Shell tab |
| `account` | `/account` | Shell tab (profile) |
| `settings` | `/settings` | Root |
| `preferences` | `/settings/preferences` | Under settings |
| `restaurant` | `/restaurant/:id` | Under home |
| `restaurantDetail` | `/restaurant-detail/:id` | Under home |
| `cart` | `/cart` | Shell tab |
| `checkout` | `/checkout` | Root |
| `orderTracking` | `/order-tracking/:id` | Root |
| `orderDetailsPath` | `/orders/:id` | Under orders tab |
| `orderConfirmationPath` | `/orders/confirmation/:id` | Under orders tab |
| `orderSupportPath` | `/orders/support/:id` | Under orders tab |
| `orderReceiptPath` | `/orders/receipt/:id` | Under orders tab |
| `addressManager` | `/address-manager` | Root |
| `welcome` | `/welcome` | Root |
| `notFound` | `/not-found` | Root |

---

## Flutter screen list (Phase-2 aligned)

### UX Flow 1: Checkout → Payment

| Screen | Route / Location | Phase-2 changes |
|--------|------------------|------------------|
| **Checkout (review)** | `Routes.checkout` → `/checkout` | Show address, items, fees, total; **payment method: Card / Cash**; CTA “Place order”. |
| **Card payment** | Same screen or modal/sheet | If Card: call `POST /payments/create-intent`, show Stripe payment sheet; on success → navigate to confirmation or poll order; on failure → retry / switch to cash. |
| **Order confirmation** | `Routes.orderConfirmation(id)` → `/orders/confirmation/:id` | Show order number, initial status; **timeline preview** from `GET /orders/:id/events`. |

**Suggested route:** No new path. Checkout stays `/checkout`; after place order with card, stay on checkout for Stripe sheet then push `/orders/confirmation/:id`; with cash, push same confirmation.

---

### UX Flow 2: Order tracking (trust-first)

| Screen | Route / Location | Phase-2 changes |
|--------|------------------|------------------|
| **Order tracking** | `Routes.orderTrackingDetails(id)` → `/order-tracking/:id` | **Top:** status + ETA (optional). **Middle:** **timeline** from `GET /orders/:id/events`. **Bottom:** Cancel (if allowed), Contact support (later), Reorder (later). Data: `GET /orders/:id` + `GET /orders/:id/events`; refresh/poll every ~10–20s while active. |

**Existing route:** `order_tracking_routes.dart` → `orderTrackingRoute(parentNavigatorKey: _rootNavigatorKey)`.

---

### UX Flow 3: Notifications

| Screen | Route / Location | Phase-2 changes |
|--------|------------------|------------------|
| **Notifications list** | **New:** `/notifications` | List from `GET /me/notifications`; tap → open Order Tracking for `payload.orderId`. Mark read: `POST /me/notifications/:id/read`. |

**New route:** Add `Routes.notifications = '/notifications'`; add `notificationsRoute()` and register in `router.dart` (e.g. under account shell or root). Add `lib/features/notifications/notifications_routes.dart` and `NotificationsScreen`.

---

## GoRouter structure (Phase-2)

```
StatefulShellRoute.indexedStack (AppShell)
├── Home branch (_homeNavigatorKey)
│   └── homeRoute("/")
│       ├── restaurantRoute("/restaurant/:id")
│       ├── restaurantDetailRoute("/restaurant-detail/:id")
│       └── discoveryRoute("/discover")
├── Search branch
│   └── searchRoute("/search")
├── Cart branch
│   └── cartRoute("/cart")
├── Orders branch
│   └── ordersRoute("/orders")
│       ├── orderConfirmationSegment ("confirmation/:id")
│       ├── orderDetailsSegment (":id")
│       ├── orderReceiptSegment ("receipt/:id")
│       └── orderSupportSegment ("support/:id")
├── Profile/Account branch
│   └── profileRoute("/account")
│
├── [NEW] notificationsRoute("/notifications")  ← optional: as child of account or root
│
Root-level (parentNavigatorKey: _rootNavigatorKey)
├── checkoutRoute("/checkout")
├── orderTrackingRoute("/order-tracking/:id")
├── addressManagerRoute("/address-manager")
├── settingsRoute("/settings")
├── welcomeRoute("/welcome")
└── notFoundRoute("/not-found")
```

---

## Implementation checklist (Flutter)

- [ ] **Checkout:** Add payment method selector (Card / Cash); on Place order with Card → create order in `PENDING_PAYMENT`, then `POST /payments/create-intent` → Stripe sheet → on success navigate to `/orders/confirmation/:id`; with Cash → `POST /orders` with cash + optional `POST /orders/:id/confirm-cash` if needed, then navigate to confirmation.
- [ ] **Order confirmation:** Call `GET /orders/:id/events` and show timeline preview; display order number and status.
- [ ] **Order tracking:** Integrate `GET /orders/:id/events`; show timeline; add Cancel button (call `POST /orders/:id/cancel` when allowed); poll or refresh every 10–20s while status not terminal.
- [ ] **Notifications feature:** Add `Routes.notifications`, `notifications_routes.dart`, `NotificationsScreen`; implement `GET /me/notifications`, tap → `context.go(Routes.orderTrackingDetails(orderId))`, `POST /me/notifications/:id/read`.
- [ ] **DTOs / models:** Extend Order DTO for Phase-2 (e.g. `paymentMethod`, `paymentStatus` enums, cents fields if needed); add `OrderEvent` model and fromJson; add Notification model for list/read.
- [ ] **Router:** Register notifications route (account tab or root); add `Routes.notifications` and helper if needed.

---

## Navigation flow summary

| User action | From | To |
|-------------|------|----|
| Place order (cash) | Checkout | `/orders/confirmation/:id` |
| Place order (card) | Checkout → Stripe sheet | `/orders/confirmation/:id` |
| View order status | Orders list / confirmation / notification | `/order-tracking/:id` |
| View notifications | Account or shell | `/notifications` → tap → `/order-tracking/:id` |
| Cancel order | Order tracking | Stay; update status to CANCELLED |

This keeps Phase-1 simplicity while layering Phase-2 payment, order lifecycle, and notifications onto the existing GoRouter and screen set.
