# Yekermo — Product Requirements Document (PRD v1.1)

Design goal: A food ordering system that behaves like a calm, competent human—not a marketplace.

---

## 1. Product Overview (Refined)

Yekermo is a trust-first food ordering application, starting with Ethiopian restaurants in Calgary (YYC), designed for repeat, predictable ordering rather than exploration.

Yekermo is intentionally small in surface area but deep in correctness.

It prioritizes:

- reliability over variety
- predictability over discovery
- clarity over persuasion
- reversibility over experimentation

Yekermo assumes users are adults making routine decisions—not browsers seeking novelty.

---

## 2. Target Users (Expanded with Context)

**Primary User — "The Regular"**

- Lives in Calgary
- Already knows which Ethiopian restaurants they trust
- Orders the same meals repeatedly
- Values timing accuracy, pickup clarity, and non-surprising totals
- Has low tolerance for UI noise, upsells, and "helpful" nudges

**Secondary User — "The Respectful Newcomer"**

- Curious about Ethiopian food
- Wants guidance without being overwhelmed
- Prefers recommendation by confidence, not popularity
- Wants to understand what is safe to order more than what is trendy

**Explicitly NOT the User**

- Deal hunters
- Gamification-driven users
- Review scrapers
- People who want infinite choice

---

## 3. Core Value Proposition (Sharper)

Yekermo answers one question with confidence:

*"Can I place this order right now, and will it go exactly as expected?"*

Everything in the product either:

- reduces uncertainty, or
- increases confidence

Anything else is noise.

---

## 4. Core Capabilities (Deepened)

### 4.1 Availability as Truth (New Emphasis)

Availability is authoritative, not optimistic.

The system must:

- Reflect actual restaurant hours and service modes
- Handle temporary closures gracefully
- Never allow checkout if fulfillment is impossible
- Communicate why something isn't available in plain language

Example: *"Pickup isn't available right now. This restaurant is preparing for dinner service."*

No countdowns. No urgency.

### 4.2 Ordering Integrity

Ordering is treated as a transactional system, not a UI flow.

Requirements:

- Single-flight checkout enforced at all layers
- Explicit confirmation states
- Clear distinction between:
  - order created
  - payment authorized
  - payment captured
  - order acknowledged by restaurant

If any step fails:

- The user must know exactly what happened
- The user must know what to do next
- The user must know what was NOT charged

### 4.3 Reordering (More Adult Logic)

Reordering is a tool, not a shortcut hack.

Rules:

- Reorder only when the restaurant, menu item, and service mode are all valid now
- If anything has changed (price, availability, portion), it must be surfaced
- No blind reorders

Learning behavior:

- Only learned after multiple identical orders
- Never inferred from browsing
- Can be disabled globally

### 4.4 Trust Surfaces (New Section)

Trust is surfaced intentionally in quiet ways:

- Clear receipts
- Consistent language
- Predictable layouts
- Explicit states ("We're checking", "Confirmed", "Nothing charged")

No star ratings as primary signals. No urgency copy. No celebratory animations.

Confidence is the reward.

### 4.5 Preferences (Bounded Power)

Preferences are:

- explicit
- reversible
- advisory, not authoritative

Rules:

- Preferences may influence ordering order, never hide options
- Preferences never override availability
- Preferences never auto-enable themselves

### 4.6 Communication Policy (New)

By default, Yekermo is quiet.

- No push notifications unless explicitly enabled
- No emails unless transactional
- No SMS unless critical

When communication happens:

- It must explain state
- It must not market
- It must not pressure

---

## 5. Explicit Non-Goals (Expanded)

Yekermo will not:

- Optimize for time-on-app
- Encourage "exploration"
- Compete on selection size
- Incentivize ordering frequency
- Train users into habits they didn't choose
- Monetize attention
- Hide system uncertainty behind UI polish

If a feature: increases urgency, increases noise, or obscures state — it is out of scope.

---

## 6. Quality Bar (Adult Version)

### 6.1 Correctness Over Delight

- A boring correct experience beats a delightful broken one
- UI never lies to cover backend uncertainty
- Loading states are honest, not performative

### 6.2 Failure Is a First-Class State

Failures are designed—not patched.

Every failure must:

- Explain what happened
- State what did not happen
- Provide a clear next step
- Leave the user feeling respected

### 6.3 Language Discipline

- Neutral tone
- No blame
- No emotional manipulation
- No "Oops!", "Yay!", or confetti

---

## 7. Operational Discipline (New Section)

### 7.1 Feature Gating

- Every non-core feature must be kill-switchable
- Personalization must be disable-able per user
- Rollbacks must not corrupt order history or receipts

### 7.2 Restaurant Respect

- Restaurants are partners, not content
- No silent menu changes
- No pressure to stay "always on"
- Availability is a contract

---

## 8. Success Criteria (More Measurable)

Yekermo is successful when:

- Users reorder without checking alternatives
- Support tickets trend toward clarification, not complaints
- Users trust the app during failures
- Restaurants feel accurately represented
- Growth does not change the emotional tone of the app

---

## 9. Intentional Omissions (Reaffirmed)

This document does not define:

- Visual style
- Brand voice examples
- Backend architecture
- Growth strategy

Those exist downstream, not upstream.

---

## 10. Authority Clause (Stronger)

This PRD defines the behavioral boundaries of Yekermo.

If: metrics suggest urgency, growth suggests noise, experimentation suggests manipulation — the system must choose restraint.

The product is allowed to grow slower than its competitors. It is not allowed to lose trust faster than it gains users.

If a future feature conflicts with this document, the feature is wrong — not the document.

---

## 11. UI & Behavioral Constraints (Authoritative)

### 11.1 Design Posture

Yekermo’s UI must feel:

- calm
- deliberate
- trustworthy
- institution-grade

The UI must assume confidence, not attempt to persuade.

### 11.2 UI Principles

- One primary intent per screen.
- Reordering known behavior is always easier than exploring new options.
- Availability and constraints are communicated before commitment.
- Visual restraint is preferred over novelty.
- Removal is a valid and often preferred form of progress.

### 11.3 Prohibited UI Patterns

The product must not include:

- urgency cues (countdowns, “ending soon”, flashing CTAs)
- gamification (points, streaks, rewards)
- popularity signals (ratings, “best”, “trending”)
- promotional surfaces (banners, upsells, popups)
- emotional manipulation (celebration, guilt, FOMO)

### 11.4 Copy Discipline

- Copy must be declarative, neutral, and factual.
- Errors must explain:
  - what happened
  - what did not happen
  - what the user can do next
- The product must never ask for trust explicitly.

### 11.5 Authority Rule

If a UI change improves conversion but increases:

- urgency
- persuasion
- cognitive load

…the change violates this PRD and must be reverted.
