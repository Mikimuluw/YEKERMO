# Customer App — Stability Window (Phase 12)

**Goal:** Declare the customer app “done.” No new customer features; only bug fixes, performance, logging, and observability.

**Phase 12 exit criteria (the gate):** You may only move to Phase 13 when: (1) the app can safely take test money, (2) orders persist across sessions, (3) availability is backend-driven, (4) UI feels intentional not placeholder, (5) support copy is no longer hypothetical, (6) you personally trust it enough to hand it to someone else. Full criteria in `docs/progress.md`. Only after this does Phase 13 make sense.

---

## Supported flows

These flows are in scope for stability and regression testing.

| Flow | Description | Notes |
|------|-------------|--------|
| **Discovery → Restaurant → Meal → Cart** | User discovers restaurants, opens one, adds items from menu to cart. | Discovery uses dummy data; filters and search wired. |
| **Cart → Review order (Checkout)** | User reviews items, fulfillment (Delivery/Pickup), fees, notes, address (delivery). | Address required for delivery; single default address. |
| **Checkout → Pay → Place order → Confirmation** | User enters payment (card), taps Pay and place order; order is placed and user sees order confirmation. | Single-flight: pay then place; dummy payment (last4 `0000` = fail). |
| **Orders list → Order detail** | User views past orders and opens an order for status, items, fulfillment, receipt. | Stale loading shows calm copy after threshold. |
| **Order detail → View receipt** | User opens receipt (restaurant, items, fees, payment method); can share. | Share = text summary; PDF stubbed. |
| **Order detail → Get help** | User opens support request, picks category, optional notes, submits. | Submit is log-only (no API/email yet). |
| **Reorder (from Orders or Home)** | User taps Reorder on an order; cart is prefilled and user can go to checkout. | Eligibility: restaurant open, service mode match, items on menu; ineligible = disabled CTA + reason. |
| **Home → Discovery / Search / Cart / Orders / Profile** | Shell navigation and home sections (intent chips, your usual, reorder card). | No favorites tab; deprecated routes show not-found. |

---

## Known limitations

- **Data:** All backend is dummy or in-memory (restaurants, menus, cart, address, orders, payments). No persistence across process restarts.
- **Payments:** Dummy provider; card ending `0000` simulates failure; no real authorize/capture.
- **Support:** Support request submit is log-only; no email or ticket backend.
- **Receipt:** “Download PDF” is stubbed (SnackBar); share uses text summary.
- **Address:** Single default address; no validation or maps.
- **Order status:** Mocked (e.g. preparing); no live status from restaurant.
- **Availability:** Open/closed and service modes come from seed/dummy data and injected clock.

---

## Deferred items (not in stability window)

- Real payment provider (authorize/capture)
- Support ticket backend (API/email, persistence)
- Receipt PDF generation and storage
- Address validation and maps
- Proactive comms (push/email)
- Ops/retention/comms (Phase 8)
- Payment retry error categorization (network/timeout/unknown)

See `docs/progress.md` for full phase log and future phases.

---

## Crash and error logging

- **Flutter framework errors:** `FlutterError.onError` in `bootstrap()` logs to `AppLog.error` and presents error.
- **Platform errors:** `WidgetsBinding.instance.platformDispatcher.onError` logs uncaught errors and returns `true` (handled).
- **App log sink:** `lib/observability/app_log.dart` uses `dart:developer.log` (level, message, error, stackTrace). No remote backend by default; can be replaced or wrapped for a crash-reporting service.

---

## Regression coverage (money path)

- **Delivery:** One end-to-end test from cart with delivery address → checkout → pay (successful card) → place order → order confirmation.
- **Pickup:** One end-to-end test from cart → checkout (pickup) → pay → place order → order confirmation.

Both live in `test/money_path_e2e_test.dart`.

These exercises the full “money path” per service mode without new customer features.

---

## Phase 12.5 — E2E reality test (gate before Phase 13)

Before Phase 13 is discussed, a **real user** must complete the full flow against the real (staging) stack: open app → log in → see real restaurants → place a sandbox order → see it in history → see receipt → retry safely on failure. If it isn’t boringly reliable, you don’t move on. See `docs/e2e_reality_test.md`.
