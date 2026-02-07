# UI Grounding (Phase 12.4 — From Skeleton → Adult)

The app stops looking like a wireframe. This is **competence polish**, not “design.”

---

## Required polish

| Area | Requirement | Reference |
|------|-------------|-----------|
| **Consistent spacing and typography** | Use `AppSpacing` (pagePadding, cardPadding, vXs–vXl, hXs–hXl) everywhere; use `context.text` for all text styles. No ad-hoc padding or one-off font sizes. | `lib/shared/tokens/app_spacing.dart`, `lib/app/theme.dart`, `context_extensions.dart` |
| **Clear primary vs secondary actions** | One primary CTA per screen (e.g. “Pay and place order”, “Review order”); secondary actions use `AppButtonStyle.secondary`. Buttons have consistent tap target (AppSpacing.tapTarget). | `AppButton`, `AppButtonStyle.primary` / `.secondary` |
| **Empty states that don’t feel like TODOs** | Copy is calm and final (“No orders yet.”, “Receipt isn’t available.”), not placeholder (“X will appear here.”). Use `emptyBuilder` with intentional copy; default empty uses a single, consistent fallback. | Per-screen `emptyBuilder`; `_DefaultEmptyView` |
| **Loading states that feel intentional** | No ambiguous spinners where calm text is better (e.g. order detail: text-only “Loading order details.”). Stale loading shows calm copy, not spinner. | `AppLoading(textOnly: true)`, `_StaleLoadingView`, per-screen `loadingBuilder` |
| **Receipts that look final, not debug** | Receipt screen title is “Receipt”; order number and structure (restaurant, order #, items, fees, total paid, payment method) are clear. No debug-style titles or raw ids in the chrome. | Receipt screen, order detail view |

---

## Not required

- **No animations** — None needed for 12.4.
- **No brand flourish** — No custom illustrations, mascots, or decorative elements.

**Goal:** Visual credibility. The app should feel finished and consistent, not like a prototype.

---

## Checklist (implementation)

- [ ] All screens use `AppSpacing.pagePadding` for main content and `AppSpacing.cardPadding` for cards.
- [ ] All text uses `context.text` (titleLarge, titleMedium, titleSmall, bodyMedium, bodySmall) or theme; no hardcoded TextStyle with font size.
- [ ] Primary action per screen is a single FilledButton (AppButtonStyle.primary); secondary actions are OutlinedButton (AppButtonStyle.secondary).
- [ ] Empty states use calm, final copy; no “will appear here” or “details will show here” unless the context is explicitly “waiting for data.”
- [ ] Loading: order detail and confirmation use text-only loading; other screens may use default AppLoading (spinner + optional message); stale loading is always calm copy only.
- [ ] Receipt: title is “Receipt”; body has clear sections (restaurant, order #, items, fees, total paid, payment method); no debug-only title text.
