# UI Review Summary — Ready for Critique and Major Enhancements

**Purpose:** Single reference for design and product critique and for planning UI/UX enhancements. Covers structure, tokens, components, screens, gaps, and improvement opportunities.

---

## 1. Design system and tokens

| Layer | Location | Notes |
|-------|----------|--------|
| **Colors** | `lib/theme/color_tokens.dart` | Warm cream background (`#F7F1E7`), dark brown primary CTA (`#4A2F1B`), surface (`#FFFBF4`). Semantic: error, muted, divider. Dark mode tokens (night*). Card shadows (soft, not heavy elevation). |
| **Spacing** | `lib/theme/spacing.dart` | xs=8, sm=12, md=16, lg=24, xl=32; `pagePadding`, `cardPadding`, `tapTarget` (48). Vertical/horizontal `SizedBox` helpers (vXs–vXl, hXs–hXl). Re-exported via `lib/shared/tokens/app_spacing.dart`. |
| **Radii** | `lib/theme/radii.dart` | r12, r16, r24; `brCard`, `brInput`, `brButton` (12–16 range). |
| **Typography** | `lib/app/theme.dart` + `lib/theme/text_styles.dart` | Theme applies Material 2021 typography with onSurface and semibold for title/headline. TextStyles documents token names (headlineSmall, titleLarge, bodyMedium, etc.). UI uses `context.text` (from `context_extensions.dart`) rather than raw TextStyles. |
| **Theme** | `lib/app/theme.dart` | Light and dark ColorScheme from tokens; CardTheme (elevation 0.4, br16); BottomNav; InputDecoration (filled, br16); ChipTheme. AppBar: primary bg, onPrimary fg. |

**Gaps for critique:** No explicit type scale (e.g. responsive or accessibility scaling). Muted/secondary text is ad-hoc `onSurface.withValues(alpha: 0.7)` (or 0.85, 0.6) in screens rather than a named token. ColorTokens.cardShadow exists but CardTheme uses Material elevation; cards may not feel as “soft” as doc suggests.

---

## 2. Component kit

**Primary kit (`lib/ui/`):** AppScaffold, AppAppBar, AppCard, AppListTile, AppButton, AppSectionHeader, PriceRow. Used by most feature screens. No AppTextField here (lives in shared/widgets).

**Shared widgets (`lib/shared/widgets/`):** AppLoading, AppErrorView, AsyncStateView, AppTextField, AppChip, and legacy duplicates (app_button, app_card, app_list_tile, app_scaffold, app_section_header) that are **not** the ones features import. Features import from `lib/ui/` for scaffold/card/button/list_tile/section_header and from `shared/widgets` for loading, error, async state, text field, chip.

**Observations:**
- **Dual locations:** `lib/ui/` vs `lib/shared/widgets/` split is intentional (ui = layout/atoms; shared = state/loading/input/chips) but the “app_” naming exists in both; can confuse where to add new components.
- **AppScaffold:** No default body padding; callers use `AppSpacing.pagePadding` on content. Supports `title`, `actions`, or custom `appBar`. Back button not built-in; screens that need back use custom `appBar` with `IconButton(Icons.arrow_back)` + `context.pop()`.
- **AppButton:** Primary (Filled) and secondary (Outlined); full-width, tapTarget height; no icon slot in current usage in some screens (widget supports it).
- **AppCard:** Uses theme Card + InkWell; default cardPadding; optional onTap; padding can be zero for list-style content.
- **AppListTile:** Title, optional subtitle, leading, trailing, onTap; uses theme text and s16 padding.
- **No shared empty-state widget:** Empty states are built per screen (e.g. “No orders yet”, “Receipt isn’t available”) or via AsyncStateView’s emptyBuilder and a default empty view.

**Gaps for critique:** No standard app bar with back button; no shared “section card” (section header + list of tiles); no link-style button component (screens use TextButton or custom text + onTap). List tile styling (e.g. chevron color) is repeated.

---

## 3. Screen inventory and patterns

| Screen | Route / usage | Data source | App bar | Primary CTA | Notes |
|--------|----------------|-------------|---------|-------------|--------|
| **Home** | Shell (tab) | Stub in file | Title “Yekermo”, actions | Implicit (cards tap) | Greeting, address card, “Your usual”, nearby list. Uses Theme + color_tokens + radii. |
| **Discovery** | Shell (tab) | Controller + AsyncStateView | Title “Discovery” | — | Filters (chips), results. Empty/loading/error via AsyncStateView. |
| **Restaurant** | Route | Controller | Title from data | “View menu” etc. | Restaurant list/detail; restaurant_screen vs restaurant_detail_screen. |
| **Cart** | Shell (tab) | Controller / stub | Title “Cart” | “Checkout” | Items, fees (PriceRow), bottom CTA. |
| **Checkout** | Route | Controller | Title “Checkout” | “Pay and place order” | Address, summary, price breakdown. |
| **Orders** | Shell (tab) | Stub in file | Title “Orders” | “Track order” (active) | Segmented tabs: Active / Past. Active card + empty state; past cards with “View receipt”. |
| **Order tracking** | Route `/order-tracking/:id` | Stub in file | “Order #2847” + back | “Contact driver” | Status banner, delivery icon placeholder, timeline steps. No maps. |
| **Order confirmation** | Route | Controller + AsyncStateView | — | — | Post-place success. |
| **Order detail** | Route | Controller + AsyncStateView | — | — | Order info, receipt/support links. |
| **Receipt** | Route `/orders/receipt/:id` | Stub in file | “Receipt” + back | “Order again” | Delivered header, details card, items card, “Get help” secondary. |
| **Support request** | Route | — | — | — | Form for order support. |
| **Profile** | Shell (tab) | — | Title “Profile” | — | Short copy + “Settings” list tile. |
| **Settings** | Route | — | Title “Settings” | — | List of options. |
| **Preferences** | Route | — | Title “Preferences” | — | Preference toggles. |
| **Account** | **Not routed** | Stub in file | Title “Account” | — | Profile row (avatar, name, email), “Account settings”, “Profile information” tile. Orphan screen. |
| **Search** | — | Stub / controller | — | — | Search bar, filters, results. |
| **Address manager** | Route | Controller + AsyncStateView | — | — | Address list/edit. |
| **Welcome** | Route | — | — | — | Onboarding entry. |
| **NotFound** | Fallback | — | Title “Not found” | “Back to Home” | Centered message + CTA. |
| **Placeholder** | Used by Favorites etc. | — | Param title | — | PlaceholderScreen(title, subtitle). |
| **Favorites** | — | — | — | — | Delegates to PlaceholderScreen(“Favorites”, “Not available.”). |

**Patterns:**
- **Stub-only screens:** Order tracking, Receipt, Orders, Account, Home (partial), Search (partial), Cart (partial), Restaurant detail (partial). Stub data lives in the screen file; no backend wiring.
- **Controller + AsyncStateView:** Discovery, Restaurant (list), Order detail, Order confirmation, Address manager. Loading/empty/error handled in one place.
- **Back button:** Implemented locally (Order tracking, Receipt) with custom AppBar + IconButton + `context.pop()`. Profile/Settings/Orders use default app bar (no back when from shell).
- **Primary CTA:** One main action per screen in most cases; secondary actions use AppButtonStyle.secondary. UI heuristics doc (“one primary action per screen”) is largely followed.

**Gaps for critique:** Account not in shell or routes. Profile vs Account overlap (Profile has “Account and settings” copy and Settings tile; Account has profile row and “Profile information”). Favorites is a placeholder. Inconsistent use of “Back” (some screens need back, some don’t; no shared pattern).

---

## 4. Gaps and inconsistencies

- **Back button and app bar:** No shared “screen with back” scaffold; each screen that needs back builds its own AppBar. Title style and back affordance can drift.
- **Muted text:** No single token; screens use 0.7, 0.85, 0.6 alpha on onSurface. Could be a named semantic (e.g. “muted”, “secondary”) in theme or tokens.
- **Cards and elevation:** Theme uses CardTheme elevation 0.4; ColorTokens define cardShadow/cardShadowElevated but they are not applied in CardTheme. Cards may look flatter or different from “soft floating” in the mock.
- **Empty states:** Copy and layout are per screen; no shared EmptyState component with icon + title + optional subtitle + optional action.
- **Loading states:** AsyncStateView + AppLoading (spinner or textOnly) and _StaleLoadingView are consistent; some screens may still use raw CircularProgressIndicator.
- **Form and input:** AppTextField in shared/widgets; input decoration comes from theme. Support request and address forms use it; consistency of error state and labels not audited.
- **List tile trailing:** Chevron style (e.g. color, size) is repeated (Account, Profile, Settings); could be one component or style.
- **Navigation shell:** Bottom nav: Home, Browse, Cart (badge), Orders, Profile. No Account tab; “Profile” leads to ProfileScreen, not AccountScreen.

---

## 5. Opportunities for major enhancements

**Structure and navigation**
- Decide Profile vs Account: merge into one “Account” flow (profile row + settings) or keep Profile as shell and Account as a deeper “account details” screen; wire Account into routes.
- Add a shared “screen with back” layout (e.g. AppScaffold.withBack or a wrapper) so back behavior and title are consistent.
- Consider a single “Account” or “More” tab that leads to Account (profile + settings) and reduces duplication with current Profile.

**Design system**
- Introduce a small set of semantic text/color roles (e.g. muted, secondary, caption) and use them instead of ad-hoc alpha on onSurface.
- Align Card with “warm, soft” contract: e.g. use ColorTokens.cardShadow in CardTheme or a custom card wrapper that applies it.
- Document when to use which component (when to use AppCard vs raw Container, when to use AppSectionHeader vs plain title).

**Components**
- Shared empty state: icon + title + optional body + optional action button; use in Orders (no active), Receipt (unavailable), Discovery, etc.
- Optional link-style button (text only, theme primary, no heavy border) for “View receipt”, “Get help” where secondary is too strong.
- Optional “section card”: section header + list of list tiles in one card (e.g. Account settings, Settings).

**Screens**
- Favorites: replace PlaceholderScreen with a real empty state and, later, list of saved items.
- Order tracking: when wiring backend, consider ETA countdown or status copy refresh; keep “no maps” per current spec.
- Receipt: when wired, ensure “Order again” and “Get help” go to correct flows; consider share/export later.
- Consistency pass: ensure every screen that is a “detail” or “sub” screen has a back button and uses the same back pattern.

**Accessibility and polish**
- Ensure all interactive elements meet tap target (AppSpacing.tapTarget); audit IconButton-only app bars.
- Consider focus order and screen reader labels for key actions (e.g. “Track order”, “Order again”).
- UI grounding checklist (docs/ui_grounding.md): run through “all screens use pagePadding/cardPadding”, “all text uses context.text”, “one primary CTA”, “empty states calm and final”, “loading intentional”, “receipt clear and final”.

**Copy and tone**
- Align all user-facing strings with ui_heuristics.md: declarative, no urgency, no hype. Audit for consistency (e.g. “Not available” vs “isn’t available” vs “No … yet”).

---

## 6. Checklist for reviewers

- [ ] Token usage: Are all screens using theme/tokens (no hardcoded colors or font sizes)?
- [ ] Component split: Is the boundary between `lib/ui/` and `lib/shared/widgets/` clear and consistent?
- [ ] Primary CTA: Does each screen have at most one primary action, with secondary actions clearly secondary?
- [ ] Empty and loading: Are they calm, final, and consistent across screens?
- [ ] Back and navigation: Is “back” behavior consistent for all secondary screens?
- [ ] Profile vs Account: Is the intended hierarchy and routing clear and implemented?
- [ ] Cards and shadows: Do cards match the intended “warm, minimal, rounded” look?
- [ ] Favorites and placeholders: Which screens are intentionally placeholder and which should be enhanced first?

---

*Summary generated for critique and planning. Update this doc as decisions are made and enhancements are implemented.*
