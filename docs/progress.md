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

## Phase 6 — Payment & Order Lifecycle (Authority Phase)

**Status:** Documented ✅ (authority phase: documentation + guardrails; implementation follows existing single-flight and Phase 7 retry copy)

**Purpose:**

- Make PRD §4.2 (Ordering Integrity) explicit and testable.
- Define which states exist, which are real today, and which are deferred.
- Ensure UI, copy, and backend speak the same truth.

This phase is mostly documentation and guardrails; it does not introduce new screens or payment providers.

---

### Canonical order/payment state diagram (PRD §4.2)

Textual flow; order of operations must be consistent across UI, copy, and backend.

```
[User taps Pay]
       │
       ▼
┌──────────────────────┐
│ 1. ORDER CREATED     │  (Order record exists; may be unpaid)
│    (draft → order)   │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ 2. PAYMENT AUTHORIZED│  (Funds held; not yet captured)
│    (optional split)  │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ 3. PAYMENT CAPTURED  │  (Charge completed)
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ 4. ORDER ACKNOWLEDGED│  (Restaurant has accepted order)
│    BY RESTAURANT     │
└──────────────────────┘

On any failure:
  → User must know what happened
  → User must know what to do next
  → User must know what was NOT charged
```

---

### Mapping: current implementation → PRD states

| PRD state | Current implementation | Location / notes |
|-----------|------------------------|------------------|
| **Order created** | Order is created when `placeOrder` succeeds, after payment step in same pipeline. | `CheckoutController` (single-flight pay then place); `Order` in `lib/domain/models.dart`. |
| **Payment authorized** | Not modeled separately. Dummy flow: payment success → place order; no hold vs capture. | Simulated as “paid” once order exists. |
| **Payment captured** | Represented by `PaymentStatus.paid` on `Order`. | `Order.paymentStatus`, `Order.paymentMethod`, `Order.paidAt`. |
| **Order acknowledged by restaurant** | Implicit in `OrderStatus`: `received` → `preparing` → `ready` → `completed`. No separate “acknowledged” flag. | `Order.status` (`OrderStatus.received` is first post-placement state). |

**Domain model (current):**

- `OrderStatus`: `received` | `preparing` | `ready` | `completed`
- `PaymentStatus`: `unpaid` | `paid`
- Single-flight: one pipeline (pay then place); no partial “authorized only” order in UI.

---

### What is real now

- **Single-flight checkout** enforced (pay + place in one guarded pipeline); no double submit. (Phase 10.4)
- **PaymentStatus** and **OrderStatus** on every `Order`; persisted in dummy repo.
- **Failure handling:** on payment or place-order failure, user sees error state; copy “Nothing was charged.” and “You can try again.” (Phase 7)
- **Receipt and confirmation** show order and payment method (last-4); no “authorized” vs “captured” wording in UI.
- **Order lifecycle** in UI: confirmation → history → order detail with status labels (Received, Preparing, Ready, Completed).

---

### What is simulated (until Phase 12.2)

- **Payment provider:** dummy; no real authorize or capture. Success/failure is simulated.
- **Authorize vs capture:** not split; “paid” means the dummy payment succeeded and order was placed.
- **Restaurant acknowledgment:** no separate API or state; progression through `OrderStatus` is simulated (e.g. dummy repo returns “preparing” on place).

**Phase 12.2 (Payment Integration)** makes payment real: real provider (test mode), backend separation (intent → confirm → order stored), and **capture only after order stored** so “Nothing was charged.” is honest. See `docs/payment_integration.md`.

---

### What is intentionally hidden

- **“Authorized” vs “captured”** are not shown in the UI. We show “Order received” and payment method (e.g. last-4) and do not distinguish hold vs charge in copy.
- **Partial failures** (e.g. authorized but place failed): in current flow we do not create an order until place succeeds; so we never show “authorized but order not created.” If we add that later, copy rules below apply.

---

### Copy rules per state (guardrails)

Use these when exposing or discussing states in UI, copy, or docs. No blame; no jargon.

| State / scenario | Approved copy / rule |
|------------------|----------------------|
| **Order created** (order exists, payment pending or in progress) | Prefer “Order received” or “We’re confirming your order.” Do not say “authorized” unless we explicitly add that state. |
| **Payment authorized** (if we ever expose it) | Only use “authorized” or “payment held” if the product explicitly supports hold-before-capture. Today: do not show. |
| **Payment captured** | Shown as “paid” or payment method (e.g. “Card •••• 4242”). Receipt says “Total paid” / “Payment method”. No “captured” in user-facing copy. |
| **Order acknowledged by restaurant** | Shown via status: “Received”, “Preparing”, “Ready”, “Completed”. Do not use “acknowledged” in UI unless we add a distinct state. |
| **Payment failed** | “Nothing was charged.” “You can try again.” Retry CTA only. (Phase 7.) |
| **Place order failed (after payment)** | Explain what happened; state what was not charged if applicable; one clear next step. (Today: single-flight avoids “paid but no order”; if we split later, copy must reflect it.) |

---

### Definition of done (Phase 6)

- [x] PRD §4.2 reflected in progress (this entry).
- [x] Canonical state diagram documented.
- [x] Mapping: current implementation → PRD states.
- [x] Real / simulated / hidden explicitly noted.
- [x] Copy rules per state recorded; no new user-facing states without updating these rules.
- [ ] (Future) If backend adds authorize/capture or restaurant ack: update domain, this doc, and UI to stay consistent.

---

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

---

## Phase 11 — Perception Lift & Trust Closure

**Status:** In progress (11.1–11.4 done; exit criteria below)

**Scope (11.x):** Remove broken promises, surface availability and order state clearly, reorder integrity, failure copy audit. No new features—trust-critical behavior named, documented, and enforced.

**11.x work items (reference):**
- **11.1** — Availability as truth: discovery/restaurant show open/closed + service modes; unavailability reason on restaurant detail.
- **11.2** — Reorder integrity: eligibility checklist, disable + reason when ineligible, `AppConfig.enableReorder` kill-switch (see section below).
- **11.3** — Order state visibility: order detail always shows current state; no ambiguous spinners; “The restaurant has received your order.” when status = received.
- **11.4** — Failure taxonomy → copy audit (PRD §6.2): payment/place/closed/service-mode/network listed and audited for what happened / what did not / next step; see `docs/failure_copy_audit.md`.

### Exit criteria for Phase 11.x

Phase 11.x is **done** when all of the following hold:

1. **No PRD “should” left unaddressed in Phases 2–10.4**  
   Every PRD obligation through Phase 10.4 is either implemented, explicitly deferred (with a note), or satisfied by documentation/guardrails.

2. **All trust-critical behavior named, documented, and enforced**  
   Order lifecycle, payment/place failures, reorder eligibility, order state visibility, and failure copy are defined in docs and reflected in code (or explicitly stubbed with known gaps).

3. **App feels boring in a good way**  
   No hype, no urgency copy, no emotional manipulation; calm, predictable, honest. A boring correct experience beats a delightful broken one (PRD §6.1).

4. **Customer app is frozen except for bugfixes**  
   Once the above are met, the customer-facing app is **feature-frozen**. Only bugfixes and non–customer-app work (e.g. backend, ops, support transport) proceed unless explicitly unfrozen.

Use this checklist to confirm before closing Phase 11.

---

## Phase 11.2 — Reorder Integrity (Naming + Guardrails)

**Status:** Documented + light code guards

**Why (PRD §4.3):** Reordering must never lie. Eligibility is explicit; ineligible orders do not get a working Reorder CTA.

### Reorder eligibility checklist (policy)

An order is **eligible for reorder** only when all of the following hold:

1. **Restaurant open** — `isOpenNow(restaurant.hoursByWeekday, now)` (injected clock).
2. **Item still offered** — Every order line's `menuItemId` exists in the current menu (and is offered; availability respected when present).
3. **Service mode unchanged** — The order's `fulfillmentMode` (pickup/delivery) is still in `restaurant.serviceModes`.

If any check fails: **disable** the Reorder CTA and show a **one-line explanation** (e.g. "Restaurant is closed right now.", "Some items are no longer available.", "Pickup or delivery is no longer available for this restaurant.").

### Global kill-switch (documented)

- **`AppConfig.enableReorder`** (default `true`) — When `false`, reorder is disabled app-wide: all Reorder CTAs disabled with one line (e.g. "Reorder is not available.").
- **`AppConfig.enableReorderPersonalization`** (default `true`) — When `false`, reorder-based ranking is off; reorder action remains available unless `enableReorder` is false.

### Implementation notes

- Orders list: `OrderSummary` has `isEligibleForReorder` and `ineligibleReason`; controller computes in `_buildSummary` (clock, menu, restaurant).
- Home reorder card: eligibility from restaurant open + service mode; when ineligible, Reorder disabled and one-line reason shown.
- No new UI metaphors; text-only.

---

## Phase 12 — Customer App Lock & Stability Window

**Goal:** Declare the customer app “done.” No new customer features; only bug fixes, performance, logging, observability.

**Rules:**
- No new customer features.
- Only: bug fixes, performance, logging, observability.

**Deliverables:**
- **STABILITY.md** — supported flows, known limitations, deferred items. See `docs/STABILITY.md`.
- **Crash + error logging** — `FlutterError.onError` and `platformDispatcher.onError` in `bootstrap()` log to `AppLog.error`; place-order and payment failures log via `AppLog.error` in checkout and payment controllers.
- **One full end-to-end “money path” test per service mode** — `test/money_path_e2e_test.dart`: delivery (cart + address → checkout → pay → place) and pickup (cart → checkout → pay → place); assertions: order created, no place-error copy.

---

## Phase 12.1 — Backend Foundation (Non-Negotiable)

**You cannot skip this.** The app must have a real backend for one environment.

**Must be real:**
- **Authentication (even minimal)** — Backend issues session/token; app sends it on requests.
- **Persistent users** — User identity and profile in backend; survive restarts and devices.
- **Persistent orders** — Every placed order stored on backend; order id backend-issued.
- **Persistent order history** — Order history is source of truth from backend.
- **Restaurant availability from backend** — Open/closed and service modes from API, not only app seed.
- **One real environment** — Staging or prod-lite with real backend URL and real auth.

**Still allowed to be simple:**
- One role (customer), one city, one cuisine, one payment provider (even sandbox).
- No optimization. Just truth.

**Deliverables:**
- **docs/backend_foundation.md** — Contracts for auth, users, orders, restaurant availability, and one real environment.
- **Auth abstraction** — Domain session type and `AuthRepository` interface; app can send token when session exists.
- **Environment** — `AppEnv` defines dev/stage/prod; one of stage or prod-lite is the “real” environment; app uses `apiBaseUrl` and `useRealBackend` when running against it.

Implementation: backend can be separate repo or service; app side has contracts and minimal auth/session types so backend can be implemented against them. See `docs/backend_foundation.md`.

---

## Phase 12.2 — Payment Integration (Make Phase 6 Real)

Phase 6 stops being “authority-only.” Real payment and clear backend separation so **“Nothing was charged”** is honest.

**Minimum bar:**
- **Real payment provider** (even test/sandbox mode).
- **Clear backend separation:** payment intent created → payment confirmed (with provider) → order stored. Backend owns all three; capture only after order is stored.
- **“Nothing was charged” is no longer theoretical** — On any failure before order is stored, we do not capture; any authorization is released. So the copy is true.

**You do not need:** refunds automation, multiple providers, edge-case brilliance.  
**You need:** honesty.

**Deliverables:**
- **docs/payment_integration.md** — Honesty rule (capture only after order stored), backend separation (intent → confirm → order stored), and API contract. Single provider (e.g. Stripe test mode) is enough.

Backend implements the sequence; app continues to show Phase 6/7 copy (“Nothing was charged.”, “You can try again.”). See `docs/payment_integration.md`.

---

## Phase 12.3 — Order Lifecycle (Backend Truth)

Tie PRD §4.2 to reality. The **states** must exist somewhere real on the backend.

**Backend must support:**
- **Order created** — Order record stored with id; the order exists in backend storage.
- **Payment confirmed** — Payment (paid) recorded on the order; GET order reflects it.
- **Order received** — Restaurant has received the order; backend stores and exposes this (e.g. `status: received`). Restaurant ack can still be manual or implicit.
- **Order failed** — Either no order created (failure response) or order in a failed state; backend can represent failure in a real way.

**Even if:** restaurant ack is simulated, delivery is restaurant-managed—the **states must exist somewhere real** (backend persistence or authoritative API response).

**Deliverables:**
- **docs/order_lifecycle.md** — Backend contract for the four states, mapping to PRD §4.2 and domain; what can be simulated vs what must be real.

See `docs/order_lifecycle.md`.

---

## Phase 12.4 — UI Grounding (From Skeleton → Adult)

The app stops looking like a wireframe. **Competence polish**, not “design.”

**Required polish:**
- **Consistent spacing and typography** — AppSpacing and context.text everywhere; no ad-hoc padding or one-off styles.
- **Clear primary vs secondary actions** — One primary CTA per screen; secondary actions use AppButtonStyle.secondary; consistent tap targets.
- **Empty states that don’t feel like TODOs** — Calm, final copy (e.g. “No orders yet.”); not placeholder (“X will appear here.”).
- **Loading states that feel intentional** — Text-only or calm copy where appropriate (e.g. order detail); no ambiguous spinners.
- **Receipts that look final, not debug** — Receipt title “Receipt”; clear structure (restaurant, order #, items, fees, total paid); no debug-style chrome.

**No:** animations, brand flourish. **Goal:** visual credibility.

**Deliverables:** `docs/ui_grounding.md` (checklist and reference); code passes the checklist (spacing, typography, primary/secondary, empty copy, loading, receipt).

---

## Phase 12.5 — End-to-End Reality Test

**Before Phase 13 is even discussed:** A real user must complete the full flow against a real (or staging) environment. If it isn’t **boringly reliable**, you don’t move on.

**The flow:**
1. Opens the app  
2. Logs in  
3. Sees real restaurants  
4. Places a real (sandbox) order  
5. Sees it in history  
6. Sees a receipt  
7. Retries safely on failure  

**Gate:** Phase 13 is not started until this flow is boringly reliable. No flakiness; failure path (retry) must work; state must stay consistent.

**Deliverables:** `docs/e2e_reality_test.md` — flow, pass criteria, and gate. Run the test against the real stack (Phase 12.1–12.3); fix any breakage before Phase 13.

---

## Phase 12 exit criteria (the gate)

**You may only move forward when all of the following are true:**

1. **The app can safely take (test) money** — Real payment provider (sandbox/test mode); capture only after order stored; “Nothing was charged.” is honest. (Phase 12.2)
2. **Orders persist across sessions** — Order history is backend-backed; orders survive app restart and device change. (Phase 12.1, 12.3)
3. **Availability is backend-driven** — Restaurant open/closed and service modes come from the backend, not only app seed or dummy data. (Phase 12.1)
4. **UI feels intentional, not placeholder** — Consistent spacing and typography; clear primary/secondary actions; empty and loading states feel final; receipts look final. (Phase 12.4)
5. **Support copy is no longer hypothetical** — Failure and retry copy (“Nothing was charged.”, “You can try again.”) reflects real behavior; support entry and messaging are real or explicitly stubbed with clear scope. (Phase 6/7, 12.2)
6. **You personally trust it enough to hand it to someone else** — The full E2E reality test (Phase 12.5) is boringly reliable; you would give the app to a real user in the real environment without caveats.

**Only after this does Phase 13 make sense.** If any criterion is not met, do not proceed.


- [x] Phase 6: Documented (Payment & Order Lifecycle — authority phase; see entry above).
- [ ] Phase 8: Ops / retention / comms (scope TBD; keep separate from Phase 7 trust recovery).
- [ ] Phase 9: (Define when needed.)
- [x] Phase 10.4: Completed (clock, typed failures, stale status, single-flight checkout).
- [ ] Phase 11.x: Perception lift + trust closure (11.1–11.4 done; exit criteria in progress.md — gate before app freeze).
- [ ] Support transport: Replace log-only handoff with API/email (see Phase 7 known gaps).
- [ ] Receipt PDF: Replace stub with real generation if required.
- [ ] Payment retry: Optional error categorization (network/timeout/unknown).
- [x] Phase 12: Customer app lock & stability window (STABILITY.md, crash/error logging, money-path e2e tests).
- [ ] Phase 12.1: Backend foundation (auth, persistent users/orders, restaurant availability from backend, one real env); see docs/backend_foundation.md and progress Phase 12.1.
- [ ] Phase 12.2: Payment integration (real provider test mode, backend intent→confirm→order stored, capture-only-after-order; “nothing was charged” honest); see docs/payment_integration.md.
- [ ] Phase 12.3: Order lifecycle backend truth (order created, payment confirmed, order received, order failed—states exist real on backend); see docs/order_lifecycle.md.
- [ ] Phase 12.4: UI grounding (spacing, typography, primary/secondary, empty states, loading, receipts—visual credibility); see docs/ui_grounding.md.
- [x] Phase 12.6: UI realization (remove Favorites tab, hide Invite on order; Not found Back to Home; Profile/Settings/Preferences tokens; receipt PDF honest copy; support follow-up line; checkout microcopy).
- [ ] Phase 12.5: E2E reality test (open app → log in → real restaurants → place sandbox order → history → receipt → retry safely); must be boringly reliable before Phase 13; see docs/e2e_reality_test.md.
- [x] Phase 13.0 — Full UI Reassessment (Customer App): Onboarding — deferred full onboarding; added single lightweight entry gate: one Welcome screen (app name, value copy “Order from restaurants you already trust.”, primary CTA “Continue”); no auth, no permissions, no slides; redirect on first launch; `WelcomeStorage` + `welcomeStorageProvider` for testability.
