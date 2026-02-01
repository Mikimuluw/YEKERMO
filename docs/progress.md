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
