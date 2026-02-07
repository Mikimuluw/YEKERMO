# Payment Integration (Phase 12.2 — Make Phase 6 Real)

Phase 6 stops being “authority-only.” Real payment provider and clear backend separation so **“Nothing was charged”** is no longer theoretical.

---

## Minimum bar

- **Real payment provider** (even test/sandbox mode).
- **Clear backend separation:**
  1. **Payment intent created** — Backend creates intent with provider (no charge yet).
  2. **Payment confirmed** — Backend confirms with provider (authorize, or in test mode authorize+capture under the rule below).
  3. **Order stored** — Backend persists order with payment reference.

- **“Nothing was charged” is honest** — We only capture (charge) **after** the order is successfully stored. On any failure before that (intent failed, confirm failed, store failed), we do not capture; any authorization is released. So when we show “Nothing was charged.” we are telling the truth.

---

## Honesty rule (non-negotiable)

**Capture only after order is stored.**

- If payment (authorize/confirm) fails → nothing captured; user sees payment failure; “Nothing was charged.” is true.
- If order storage fails after a successful authorization → release the authorization (do not capture); user sees order failure; “Nothing was charged.” is true.
- If order storage succeeds → then capture; user is charged and has an order.

So the backend sequence is:

1. Create payment intent (or equivalent with provider).
2. Authorize (hold funds); do **not** capture yet.
3. Store order (with payment/intent reference).
4. If step 3 fails: release authorization. Return error. No capture.
5. If step 3 succeeds: capture. Return order.

One provider (e.g. Stripe) in test mode is enough. No refunds automation, multiple providers, or edge-case brilliance—just truth.

---

## Backend separation (contract)

Backend owns:

| Step | Owner | Responsibility |
|------|--------|----------------|
| Intent | Backend | Create intent with real provider; return intent id or client secret if needed. |
| Confirm | Backend | Authorize (hold) with provider; do not capture. |
| Store order | Backend | Persist order with payment/intent reference; only after authorize success. |
| Capture | Backend | Capture only after order is stored; on store failure, release auth. |

App can call a single endpoint (e.g. `POST /orders/place-with-payment`) with draft + payment method; backend runs the sequence above and returns order or a failure that implies “nothing was charged.” Alternatively, two steps (create intent → confirm and place) are fine as long as the honesty rule is enforced.

---

## What you do not need

- Refunds automation
- Multiple payment providers
- Edge-case brilliance (partial capture, retries, etc.)

You need **honesty**: the user is never charged without an order, and when we say “Nothing was charged.” it is true.

---

## Relation to Phase 6

- Phase 6 (authority phase) defined the **states** and **copy rules**; implementation was dummy.
- Phase 12.2 makes it **real**: one real provider, backend enforces the sequence, and copy “Nothing was charged.” is backed by behavior (no capture until order stored; release on failure).

See `docs/progress.md` Phase 6 for state diagram and copy rules; they remain. This doc adds the integration contract and honesty rule.
