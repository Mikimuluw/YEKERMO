# PR shape: UI kit + screen migrations

Split into two PRs so reviewers can focus. Even if already merged locally, this is the intended mental model.

---

## PR 1: UI kit + routing alignment

**Goal:** Shared components and route structure in place; no screen behavior changes beyond “Account” tab and back/empty/link consistency.

**Includes:**
- **Kit:** ScreenWithBack, EmptyState, LinkButton, AppBarWithBack, ImagePlaceholder, AppFilterChip.
- **Routing:** Account as shell tab (path `/account`); `/profile` redirects to `/account`. Routes.account constant; profile deprecated.
- **Style debt:** `context.muted` (semantic muted text); AppCard uses ColorTokens.cardShadow; all “back” screens use AppBarWithBack (including Cart/Checkout).
- **Profile → Account:** Shell tab label “Account”; profile branch builds AccountScreen at path `/account`; ProfileScreen unused (can be removed in cleanup).

**Does not include:** Changing screen content or flows (e.g. Orders/Receipt body layout, Home cards, Search results). Those stay as-is so PR 1 is purely “kit + routing + style tokens.”

**Review focus:** One place for back, empty, link, and card shadow; no new one-off styling; route and UI both say “Account.”

---

## PR 2: Screen migrations

**Goal:** Each screen uses the kit and tokens; discovery and order flows feel consistent.

**Includes:**
- **Orders + Tracking + Receipt:** ScreenWithBack, EmptyState for active empty, LinkButton for “View receipt” / “Get help.”
- **Cart + Checkout:** AppBarWithBack; reassurance copy uses `context.muted`; PriceRow/CTA unchanged.
- **Home + Restaurant detail + Search:** ImagePlaceholder for all image areas; AppFilterChip for Search; EmptyState for “No matches”; context.text/context.colors (and muted where appropriate).
- **Favorites + placeholders:** Favorites uses EmptyState; PlaceholderScreen uses EmptyState.

**Does not include:** New features or backend wiring; only “swap custom UI for kit + tokens.”

**Review focus:** No duplicate empty states or link styling; restaurant cards and chips consistent; small screens (e.g. Cart/Checkout) don’t have CTA overlapping content.

---

## Verification checklist (manual)

Before marking done, run on device/simulator:

- [ ] Shell tab “Account” shows AccountScreen; nothing references ProfileScreen in the flow.
- [ ] Receipt + Order tracking: back button works; no double app bars or odd padding.
- [ ] Past orders: “View receipt” is left-aligned and looks like a link (not a full-width button).
- [ ] Search: chip selected state is clear; chip row scrolls without overflow.
- [ ] EmptyState: Orders active empty, Search “No matches,” Favorites empty share icon/title/message spacing.
- [ ] Cart/Checkout: bottom CTA does not overlap content on small or large-text screens.

---

## Future: keyboard avoidance (pinned CTA screens)

If Checkout (or any screen with a pinned CTA) gets text inputs later (e.g. promo code, address notes), avoid CTA/keyboard clash by either: using `CustomScrollView` for the scrollable and enabling `resizeToAvoidBottomInset: true` on the scaffold, or wrapping content with `Padding(bottom: MediaQuery.viewInsetsOf(context).bottom)`.
