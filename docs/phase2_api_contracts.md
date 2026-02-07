# Phase-2 API Contract Stubs

Request/response JSON for new or changed endpoints. All monetary amounts in **cents** unless noted. Auth: `Authorization: Bearer <token>` unless stated otherwise.

---

## Payments

### POST `/payments/create-intent`

**Auth:** Required (customer).

**Request:**

```json
{
  "orderId": "clxx..."
}
```

**Response (201):**

```json
{
  "clientSecret": "pi_xxx_secret_xxx",
  "paymentIntentId": "pi_xxx"
}
```

**Errors:**  
- `400` — Invalid request (e.g. order not found, or not `paymentMethod=CARD` / `paymentStatus=UNPAID`).  
- `404` — Order not found or not owned by user.

---

### POST `/payments/webhook`

**Auth:** None (Stripe signature verification only).

**Request:** Raw Stripe webhook body (e.g. `payment_intent.succeeded`, `payment_intent.payment_failed`). Headers must include `Stripe-Signature`.

**Response:** `200` with empty body or `{ "received": true }` after signature verification and DB update.

**Side effects:** Update Order `paymentStatus`, `paidAt`; create/update PaymentAttempt; emit internal `payment.succeeded` / `payment.failed` (e.g. for NotificationJob).

---

### POST `/orders/:id/confirm-cash`

**Auth:** Required (customer owning order, or restaurant/system in later phases).

**Request:** Empty body or `{}`.

**Response (200):**

```json
{
  "id": "clxx...",
  "status": "NEW",
  "paymentMethod": "CASH",
  "paymentStatus": "UNPAID"
}
```

**Errors:**  
- `400` — Order not in valid state for cash confirm.  
- `404` — Order not found.

---

## Order status & lifecycle

### PATCH `/orders/:id/status`

**Auth:** Required (restaurant/system/driver — protect for now).

**Request:**

```json
{
  "status": "ACCEPTED",
  "reason": "Optional note or reason code"
}
```

**Response (200):**

```json
{
  "id": "clxx...",
  "status": "ACCEPTED",
  "updatedAt": "2025-02-06T12:00:00.000Z"
}
```

**Errors:**  
- `400` — Invalid transition (e.g. `DELIVERED` → `PREPARING`).  
- `404` — Order not found.

---

### POST `/orders/:id/cancel`

**Auth:** Required (customer for self-cancel; restaurant/system for other cancels).

**Request:**

```json
{
  "reason": "Changed my mind"
}
```

**Response (200):**

```json
{
  "id": "clxx...",
  "status": "CANCELLED",
  "cancelledAt": "2025-02-06T12:00:00.000Z"
}
```

**Errors:**  
- `400` — Cancel not allowed (e.g. already PREPARING or past time window).  
- `404` — Order not found.

---

### GET `/orders/:id/events`

**Auth:** Required (customer for own order; restaurant for their orders in later phases).

**Query:** Optional `?limit=50&cursor=...` for pagination.

**Response (200):**

```json
{
  "events": [
    {
      "id": "evt_xxx",
      "orderId": "clxx...",
      "type": "ORDER_CREATED",
      "fromStatus": null,
      "toStatus": "PENDING_PAYMENT",
      "actorType": "CUSTOMER",
      "actorId": "cust_xxx",
      "metadata": {},
      "createdAt": "2025-02-06T11:55:00.000Z"
    },
    {
      "id": "evt_yyy",
      "orderId": "clxx...",
      "type": "PAYMENT_SUCCEEDED",
      "fromStatus": "PENDING_PAYMENT",
      "toStatus": "NEW",
      "actorType": "SYSTEM",
      "actorId": null,
      "metadata": { "paymentIntentId": "pi_xxx" },
      "createdAt": "2025-02-06T11:56:00.000Z"
    },
    {
      "id": "evt_zzz",
      "orderId": "clxx...",
      "type": "STATUS_CHANGED",
      "fromStatus": "NEW",
      "toStatus": "ACCEPTED",
      "actorType": "RESTAURANT",
      "actorId": "rest_xxx",
      "metadata": { "reason": "Accepted" },
      "createdAt": "2025-02-06T12:00:00.000Z"
    }
  ],
  "nextCursor": null
}
```

---

## Order response (extended for Phase-2)

**GET `/orders/:id`** and list responses should include Phase-2 fields when available:

```json
{
  "id": "clxx...",
  "restaurantId": "clxx...",
  "status": "NEW",
  "fulfillmentMode": "delivery",
  "paymentMethod": "CARD",
  "paymentStatus": "PAID",
  "paymentProvider": "STRIPE",
  "currency": "CAD",
  "amountSubtotal": 2500,
  "amountTax": 325,
  "amountDeliveryFee": 300,
  "amountTotal": 3125,
  "total": 31.25,
  "subtotal": 25.00,
  "serviceFee": 0,
  "deliveryFee": 3.00,
  "tax": 3.25,
  "paidAt": "2025-02-06T11:56:00.000Z",
  "placedAt": "2025-02-06T11:55:00.000Z",
  "addressId": "clxx...",
  "address": { "id": "...", "label": "Home", "line1": "...", "city": "...", "neighborhood": null, "notes": null },
  "items": [
    { "menuItemId": "clxx...", "quantity": 2 }
  ]
}
```

*(Keep `total`/`subtotal` etc. in dollars for backward compatibility if desired; cents in `amount*`.)*

---

## Notifications

### GET `/me/notifications`

**Auth:** Required.

**Query:** `?limit=20&cursor=...` (optional).

**Response (200):**

```json
{
  "notifications": [
    {
      "id": "notif_xxx",
      "type": "ORDER_STATUS_CHANGED",
      "payload": {
        "orderId": "clxx...",
        "status": "PREPARING",
        "title": "Your order is being prepared",
        "body": "Restaurant has started preparing your order."
      },
      "read": false,
      "createdAt": "2025-02-06T12:00:00.000Z"
    }
  ],
  "nextCursor": null
}
```

---

### POST `/me/notifications/:id/read`

**Auth:** Required.

**Request:** Empty body or `{}`.

**Response (200):**

```json
{
  "id": "notif_xxx",
  "read": true
}
```

**Errors:**  
- `404` — Notification not found or not owned by user.

---

## Enums reference

**OrderStatus:** `DRAFT` | `PENDING_PAYMENT` | `NEW` | `ACCEPTED` | `PREPARING` | `READY_FOR_PICKUP` | `OUT_FOR_DELIVERY` | `DELIVERED` | `CANCELLED` | `REJECTED`

**PaymentMethod:** `CARD` | `CASH`

**PaymentStatus:** `UNPAID` | `REQUIRES_ACTION` | `PAID` | `FAILED` | `REFUNDED`

**OrderEventType:** `ORDER_CREATED` | `PAYMENT_CREATED` | `PAYMENT_SUCCEEDED` | `PAYMENT_FAILED` | `STATUS_CHANGED` | `CANCELLED_BY_CUSTOMER` | `CANCELLED_BY_RESTAURANT` | `REFUND_INITIATED` | `REFUND_COMPLETED` | `NOTE_ADDED`

**ActorType:** `CUSTOMER` | `RESTAURANT` | `SYSTEM` | `DRIVER`
