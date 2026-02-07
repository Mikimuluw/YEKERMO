# Phase-2: What You Need On Your Side

Backend and Flutter order lifecycle + payments + notifications are implemented. Here’s what **you** need to do so everything works end-to-end.

---

## 1. Environment variables (backend)

In **yekermo-backend** `.env` (or Railway env vars):

| Variable | Required | Description |
|--------|----------|-------------|
| `DATABASE_URL` | ✅ | PostgreSQL connection string (you already set this for Railway). |
| `JWT_SECRET` | ✅ | At least 32 characters; keep secret. |
| `STRIPE_SECRET_KEY` | For card payments | Stripe secret key (e.g. `sk_test_...` for test, `sk_live_...` for live). If missing, card flow returns 503. |
| `STRIPE_WEBHOOK_SECRET` | For card payments | Webhook signing secret (e.g. `whsec_...`) from Stripe Dashboard → Developers → Webhooks. |

- **Cash-only:** You can leave `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` unset. Place order with `paymentMethod: "CASH"` and the order goes to `NEW` without Stripe.
- **Card payments:** Set both Stripe vars. Create a webhook in Stripe pointing to `https://your-api-host/payments/webhook` and use the secret they give you.

---

## 2. Stripe setup (for card payments)

1. **Stripe account**  
   Sign up at [stripe.com](https://stripe.com). Use **Test mode** while developing.

2. **API keys**  
   Dashboard → Developers → API keys: copy **Secret key** → `STRIPE_SECRET_KEY`.

3. **Webhook**  
   - Dashboard → Developers → Webhooks → Add endpoint.  
   - URL: `https://your-backend-url/payments/webhook` (e.g. Railway or ngrok for local).  
   - Events: at least `payment_intent.succeeded`, `payment_intent.payment_failed`.  
   - Copy the **Signing secret** → `STRIPE_WEBHOOK_SECRET`.

4. **Local testing**  
   Use [Stripe CLI](https://stripe.com/docs/stripe-cli) to forward webhooks:  
   `stripe listen --forward-to localhost:3000/payments/webhook`  
   and use the printed `whsec_...` as `STRIPE_WEBHOOK_SECRET` in `.env`.

---

## 3. Flutter: API base URL

Ensure the app’s **transport client** (or env) points at your deployed backend (e.g. Railway), not only `localhost`, when you run the app on a device or from a different machine.

---

## 4. Optional: Checkout payment method (Flutter)

Backend already supports:

- **POST /orders** with `paymentMethod: "CASH"` or `"CARD"`.  
- **POST /payments/create-intent** with `orderId` (for CARD).  
- **POST /payments/webhook** (Stripe).

On the Flutter side you can add:

- **Checkout screen:** A payment method selector (Card / Cash). When the user taps “Place order”:  
  - If **Cash:** send `paymentMethod: "CASH"` in the place-order body → then navigate to order confirmation.  
  - If **Card:** send `paymentMethod: "CARD"` → create order in `PENDING_PAYMENT` → call **POST /payments/create-intent** → show Stripe payment sheet (e.g. `flutter_stripe`) → on success, navigate to order confirmation.
- **Order confirmation:** Optionally call **GET /orders/:id/events** and show a short timeline preview.

The API contracts are in **docs/phase2_api_contracts.md**.

---

## 5. Summary

| You need to | So that |
|-------------|--------|
| Set `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` (if using card) | Create intent and webhook work; orders move from PENDING_PAYMENT → NEW after payment. |
| Create a Stripe webhook endpoint pointing to `/payments/webhook` | Backend can confirm payment and update order status. |
| Point Flutter at your backend URL | App talks to the real API (orders, events, cancel, notifications). |
| (Optional) Add Card/Cash selector + Stripe sheet in checkout | Full “pay now” card flow in the app. |

If you run without Stripe, use **Cash** only: send `paymentMethod: "CASH"` when placing an order and the rest of the flow (order, events, tracking, cancel) works as implemented.
