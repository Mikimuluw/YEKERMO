# Progress Log

## Phase 2 — Discovery → Decision Engine

**Status:** Completed ✅

**Scope (all together):**
- Intent-driven Restaurant Discovery (`/discover`)
- Domain-driven restaurant intelligence (capabilities, prepTimeBand, trustCopy)
- Search shell wired to repository results (light UI)
- Discovery controller + filters using ScreenState + AsyncStateView
- Navigation + repository contract tests updated

**Notes:**
- Home remains a retention surface; intent chips route to Discovery
- No ratings or hype signals; trust conveyed via copy only
- Dummy data only; backend-compatible fields added intentionally
- Discovery controller hardened against stale responses; tests green.
- Discovery UI polished; intent routing, filters, and copy finalized.

## Phase 3 — Belonging Loop: Restaurant → Meal → Cart

**Status:** Completed ✅

**Shipped:**
- Restaurant detail flow with adaptive calm header (intent/returning/first-time)
- Truthfully derived “For you” lane + menu sections
- Meal detail bottom sheet with quantity stepper + “You’ve had this before” chip
- Cart feature with quantity updates/removal + calm copy (“You can change anything.”)
- Cart badge wired into bottom-nav shell
- Data layer expanded with menu DTOs + restaurant menu repository + dummy menus
- In-memory cart repository
- Routing passes intent from Discovery/Search → Restaurant (Search UI unchanged)
- Tests: repo contracts + end-to-end flow (Discovery → Restaurant → Meal → Add → badge increments)

**Constraints upheld:**
- No ratings/stars
- Home kept light
- Copy remains calm / non-hype
- Tests green (flutter analyze, flutter test)

## Phase 4 — Trust & Clarity: Cart → Review Order

**Status:** Completed ✅

**Shipped:**
- OrderDraft state (fulfillment + fees + notes stub) with transparent breakdown
- Review Order screen (checkout route) with Delivery/Pickup toggle
- Address section + minimal address manager (single default, gentle validation; no maps/GPS)
- In-memory address storage + checkout/address controllers and repos
- Cart → Review Order navigation wired
- Tests: checkout fee/address behavior + end-to-end cart->review flow

**Constraints upheld:**
- No payments, promos, tips, scheduling, or order placement
- Calm copy, no pressure language
- Tests green (flutter analyze, flutter test)

## Phase 5 — Memory & Return: Review → Confirmation → History

**Status:** Completed ✅

**Shipped:**
- Order placement creates an Order record and clears cart
- Order confirmation screen with status, fulfillment, address, and timing band
- Orders history list (most recent first) with calm empty state
- Reorder prefills cart and routes back to Review Order with gentle notice on changes
- Home “Your usual” derives from real orders
- Orders repository + controllers for history and detail views
- Tests: order placement, reorder, and end-to-end confirmation flow

**Constraints upheld:**
- No payments or retries
- Calm status copy and honest mocked messaging
- Tests green (flutter analyze, flutter test)

## Phase 7 — Trust Recovery (Support + Receipts + Retry States)

**Goal:** Reduce anxiety after purchase by providing calm support entry, legitimate receipts, and clear payment retry states.

### Scope (Shipped)
- **Order-scoped Support capture**
  - Support primitives: `SupportCategory`, `SupportRequestDraft`, `SupportEntryPoint` (`lib/domain/support.dart`)
  - “Get help” CTA on Order Detail
  - Support request screen: category selection, optional notes, submit confirmation dialog (approved calm copy)
  - Routing: `Routes.orderSupport` + orders routes wiring
  - Analytics: `support_category_selected`

- **Receipts + Sharing**
  - Receipt screen: restaurant name + address, order number, items, fees, total, payment method last-4
  - “View receipt” CTA on Order Detail + route `Routes.orderReceipt`
  - Share via system share sheet (`share_plus`)
  - Analytics: `receipt_viewed`

- **Payment retry states**
  - Checkout error copy updated: “Nothing was charged.” + “You can try again.”
  - Primary CTA becomes “Retry payment”
  - Analytics: `payment_retry_triggered`

- **Domain support for legitimacy**
  - `Restaurant.address` added across domain/DTO/dummy sources/tests
  - Receipt line items include `price` + `lineTotal` (`OrderLineView`)

### Known Gaps / Stubs (Intentional)
- Support submit is log-only (no API/email transport yet); `currentUserEmailProvider` is stubbed.
- Receipt “Download PDF” is stubbed (SnackBar only); share uses text summary (not PDF).
- Payment retry uses same pay flow; no error categorization (network/timeout/unknown).
- Address is dummy/static; no validation.
- Receipt falls back gracefully when fee breakdown is unavailable.
- Line prices default to `0` if menu item missing.

### Out of Scope (Deferred)
- PDF generation + storage
- Support ticket backend (email/POST, persistence, attachments)
- Proactive comms (push/email “receipt ready”, “delivery issue follow-up”)
- Retention/ops workflows
