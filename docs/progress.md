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
