# Execution Plan — Phase 12 Gate + UI System Improvements

**Created:** 2026-02-06
**Purpose:** Clear, prioritized roadmap to get past Phase 12 gate and systematically improve UI

---

## Part 1: Phase 12 Gate (Backend Foundation) — CRITICAL PATH

### Current State
- ✅ Auth abstraction exists (`AuthRepository`, `AuthSession`, domain models)
- ✅ Environment system exists (`AppEnv`, `Environment.dev/stage/prod`)
- ✅ Config kill-switches exist (`AppConfig.useRealBackend`)
- ✅ Transport abstraction exists (`TransportClient`, request/response/error types)
- ✅ Some API repos scaffolded (`ApiOrdersRepository`, `ApiAuthRepository`, `ApiPaymentsRepository`)
- ❌ **No real HTTP transport** (currently uses `FakeTransportClient`)
- ❌ **Providers hardwired to dummy repos** (except auth/payments which check `useRealBackend`)
- ❌ **No backend deployed**
- ❌ **ApiOrdersRepository.placeOrder throws UnimplementedError**

### Strategy: Parallel Tracks

**Track A: Frontend Readiness (Can Start Now)**
1. Real HTTP transport client
2. Wire all API repositories
3. Complete missing API repository methods
4. Update providers to respect `useRealBackend`

**Track B: Backend Deployment (Separate Work)**
1. Choose backend stack (Node/Express, Django, Rails, Go — your choice)
2. Deploy minimal staging environment
3. Implement contracts from `docs/backend_foundation.md`

### Track A: Frontend Readiness (Priority Order)

#### A1. Real HTTP Transport Client
**File:** Create `lib/core/transport/http_transport_client.dart`

**Requirements:**
- Implement `TransportClient.send()`
- Use `package:http` or `package:dio`
- Inject `AppEnv.apiBaseUrl` as base URL
- Attach `Authorization: Bearer {token}` when session exists
- Map HTTP errors to `TransportError` with correct `TransportErrorKind`
- Handle timeouts, network errors, server errors (4xx/5xx)

**Provider update:** `transportClientProvider` should return `HttpTransportClient` when `useRealBackend`, else `FakeTransportClient`

**Estimated effort:** 2-4 hours

---

#### A2. Complete API Repositories

**Missing implementations:**

1. **ApiOrdersRepository.placeOrder** (`lib/data/repositories/api_orders_repository.dart:74`)
   - POST `/orders` with `OrderDraft` payload + `paymentMethod`
   - Return `Order` on success
   - Map errors to domain exceptions

2. **ApiRestaurantRepository** (doesn't exist yet)
   - Create `lib/data/repositories/api_restaurant_repository.dart`
   - Implement `RestaurantRepository` interface
   - GET `/restaurants` → List<Restaurant>
   - GET `/restaurants/:id` → Restaurant
   - GET `/restaurants/:id/menu` → RestaurantMenu

3. **ApiMealsRepository** (doesn't exist yet)
   - Create `lib/data/repositories/api_meals_repository.dart`
   - Implement `MealsRepository` interface
   - May share same endpoint as restaurant menu

4. **ApiCartRepository** (doesn't exist yet)
   - Backend-persisted cart OR keep in-memory client-side
   - **Decision needed:** Cart persistence strategy
   - **Recommendation:** Keep cart client-side (in-memory) for Phase 12.1; backend persistence is Phase 13+

5. **ApiAddressRepository** (doesn't exist yet)
   - GET `/me/addresses` → List<Address>
   - POST `/me/addresses` → Address
   - PUT `/me/addresses/:id` → Address
   - DELETE `/me/addresses/:id`

**Estimated effort:** 4-8 hours

---

#### A3. Update Providers to Respect useRealBackend

**File:** `lib/app/providers.dart`

**Changes needed:**
```dart
// Orders
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiOrdersRepository(ref.watch(transportClientProvider))
      : DummyOrdersRepository(clock: ref.watch(clockProvider));
});

// Restaurants
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiRestaurantRepository(ref.watch(transportClientProvider))
      : DummyRestaurantRepository(ref.watch(dummyRestaurantDataSourceProvider));
});

// Meals
final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiMealsRepository(ref.watch(transportClientProvider))
      : DummyMealsRepository(ref.watch(dummyMealsDataSourceProvider));
});

// Address
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiAddressRepository(ref.watch(transportClientProvider))
      : DummyAddressRepository();
});

// Search (may remain dummy; backend can provide POST /search)
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? ApiSearchRepository(ref.watch(transportClientProvider))
      : DummySearchRepository(ref.watch(dummySearchDataSourceProvider));
});

// Transport
final transportClientProvider = Provider<TransportClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.useRealBackend
      ? HttpTransportClient(
          baseUrl: AppEnv.apiBaseUrl,
          authRepository: ref.watch(authRepositoryProvider),
          cityContext: ref.watch(cityContextProvider),
        )
      : FakeTransportClient();
});
```

**Estimated effort:** 1-2 hours

---

#### A4. Auth Session Persistence

**Currently:** `AuthRepository` exists but session storage not implemented

**File:** Create `lib/core/storage/auth_storage.dart`

**Requirements:**
- Store/retrieve `AuthSession` securely
- Use `package:flutter_secure_storage` for token
- ApiAuthRepository should persist session on signIn, clear on signOut

**Estimated effort:** 2-3 hours

---

### Track B: Backend Deployment

#### B1. Backend Stack Decision

**Options:**
1. **Node.js + Express + PostgreSQL** (familiar, fast to prototype)
2. **Django + DRF** (batteries included, admin panel)
3. **Go + Gin + PostgreSQL** (performant, typed)
4. **Rails** (convention over configuration)

**Recommendation:** Node.js + Express + PostgreSQL (fastest to MVP)

---

#### B2. Minimal Backend API (Contract from docs/backend_foundation.md)

**Required endpoints:**

```
POST   /auth/sign-in              → { token, userId, email }
POST   /auth/sign-out             → 204
GET    /me                        → { id, email, name }

GET    /restaurants               → [{ id, name, hours, serviceModes, ... }]
GET    /restaurants/:id           → { id, name, hours, serviceModes, ... }
GET    /restaurants/:id/menu      → { sections: [...], items: [...] }

GET    /orders                    → [{ id, status, total, ... }]
GET    /orders/:id                → { id, status, items, ... }
GET    /orders/latest             → { id, status, items, ... }
POST   /orders                    → { id, status, ... }

GET    /me/addresses              → [{ id, street, city, ... }]
POST   /me/addresses              → { id, street, city, ... }

// Payment handled by Stripe SDK; backend creates payment intents
POST   /payment/intent            → { clientSecret, amount }
POST   /payment/confirm           → { status, chargeId }
```

**Database schema:**
- `users` (id, email, password_hash, name, created_at)
- `restaurants` (id, name, address, hours_json, service_modes_json, ...)
- `menu_items` (id, restaurant_id, name, price, ...)
- `orders` (id, user_id, restaurant_id, status, payment_status, total, created_at, ...)
- `order_items` (id, order_id, menu_item_id, quantity, price)
- `addresses` (id, user_id, street, city, postal_code, ...)

---

#### B3. Deployment

**Staging environment:**
- Deploy to Render/Railway/Fly.io (free tier)
- PostgreSQL database (managed)
- Environment URL: `https://yekermo-staging.fly.dev` (example)
- Update `lib/app/env.dart`:
  ```dart
  case Environment.stage:
    return 'https://yekermo-staging.fly.dev';
  ```

**Seed data:**
- 3-5 Ethiopian restaurants in Calgary
- Realistic menus (10-20 items per restaurant)
- Realistic hours

---

### Phase 12.1 Definition of Done Checklist

- [ ] Real HTTP transport client implemented and wired
- [ ] All API repositories completed (orders, restaurants, meals, address)
- [ ] Auth session persistence (secure storage)
- [ ] Providers respect `useRealBackend` flag
- [ ] Backend deployed to staging with real URL
- [ ] All endpoints from backend_foundation.md implemented
- [ ] Seed data loaded (restaurants, menus)
- [ ] Can run app with `--dart-define=ENV=stage` and see real data
- [ ] Can sign in, browse restaurants, view menu (from backend)
- [ ] Can place order (end-to-end: cart → checkout → pay → POST /orders → confirmation)
- [ ] Orders persist and appear in history (across app restarts)

---

## Part 2: UI System Improvements — SYSTEMATIC POLISH

### Current State Analysis

**Strengths:**
- ✅ Good token system (`AppTokens`, locked values)
- ✅ Spacing system (`AppSpacing.xs/sm/md/lg/xl`, vertical/horizontal helpers)
- ✅ Radii system (`AppTokens.radiusSm/Md/Lg`)
- ✅ Some shared components (`EmptyState`, `ScreenWithBack`, `AppButton`, `AppCard`)
- ✅ Theme uses `context.text` and `context.colors` extensions
- ✅ UI heuristics documented

**Weaknesses:**
- ❌ **Muted/secondary text uses ad-hoc alpha values** (0.7, 0.85, 0.6, 0.65, 0.35)
- ❌ **Card shadows defined but not applied** (`ColorTokens.cardShadow` vs `CardTheme.elevation`)
- ❌ **Profile vs Account confusion** (Account screen orphaned, not routed)
- ❌ **Dual component locations** (`lib/ui/` vs `lib/shared/widgets/` both have app_button, app_card, etc.)
- ❌ **No semantic color for muted text** (should be a token, not inline alpha)
- ❌ **Link buttons inconsistent** (TextButton vs custom onTap + Text)
- ❌ **Back button pattern scattered** (some screens use custom AppBar, some don't)

---

### UI Improvements: Priority Order

#### UI-1. Consolidate Semantic Color Tokens

**Problem:** Muted text uses `onSurface.withValues(alpha: 0.7)` inconsistently across files

**Solution:** Add semantic colors to theme/tokens

**File:** `lib/theme/color_tokens.dart`

**Add:**
```dart
// Semantic text colors
static const Color textMuted = Color(0xFF6E5A54); // Already exists as textSecondary
static const Color textTertiary = Color(0xFF8A7770); // Even lighter for metadata

// Or use alpha consistently via theme
```

**File:** `lib/shared/extensions/context_extensions.dart`

**Add:**
```dart
extension ThemeContext on BuildContext {
  // ... existing ...

  /// Muted text color (secondary hierarchy). Use for supporting text, metadata, labels.
  Color get textMuted => ColorTokens.muted;

  /// Tertiary text (low emphasis). Use for timestamps, helper text.
  Color get textTertiary => colors.onSurface.withValues(alpha: 0.5);
}
```

**Migration:** Replace all instances of:
- `.withValues(alpha: 0.7)` → `context.textMuted`
- `.withValues(alpha: 0.85)` → `context.textMuted`
- `.withValues(alpha: 0.5)` or `0.35` → `context.textTertiary`

**Estimated effort:** 1-2 hours

---

#### UI-2. Fix Card Shadow System

**Problem:** `ColorTokens.cardShadow` exists but `CardTheme` uses Material elevation

**Solution:** Apply custom shadows to AppCard

**File:** `lib/ui/app_card.dart`

**Update:**
```dart
@override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      boxShadow: ColorTokens.cardShadow, // Use token shadow
    ),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Padding(
          padding: padding ?? AppSpacing.cardPadding,
          child: child,
        ),
      ),
    ),
  );
}
```

**Estimated effort:** 30 minutes

---

#### UI-3. Consolidate Component Locations

**Problem:** Duplicate components in `lib/ui/` and `lib/shared/widgets/`

**Files to audit:**
- `lib/ui/app_button.dart` vs `lib/shared/widgets/app_button.dart`
- `lib/ui/app_card.dart` vs `lib/shared/widgets/app_card.dart`
- etc.

**Decision (from ui_review_summary.md):**
- **`lib/ui/`** → Layout primitives (scaffold, card, button, list tile, section header)
- **`lib/shared/widgets/`** → State/data widgets (loading, error, async state view, text field, chip)

**Action:** Delete duplicates from `lib/shared/widgets/` (keep app_text_field, app_loading, async_state_view, app_chip)

**Estimated effort:** 1 hour

---

#### UI-4. Fix Profile vs Account Confusion

**Problem:**
- `ProfileScreen` is in bottom nav
- `AccountScreen` exists but is orphaned (not routed)
- Both show similar content (profile info + settings links)

**Decision options:**
1. **Merge Account into Profile** — ProfileScreen shows profile row + settings links (delete AccountScreen)
2. **Profile → Account navigation** — ProfileScreen is landing; tapping profile row → AccountScreen (wire route)

**Recommendation:** **Option 1 (Merge)** — simpler, less duplication

**Actions:**
- Move profile row from `AccountScreen` to `ProfileScreen`
- Delete `lib/features/account/account_screen.dart`
- Update ProfileScreen to show: profile row (avatar, name, email) + Settings list tile + Preferences list tile

**Estimated effort:** 1-2 hours

---

#### UI-5. Standardize Empty States

**Current:** `EmptyState` widget exists and is good

**Action:** Audit all screens for ad-hoc empty states and replace with `EmptyState`

**Screens to check:**
- Orders (no active, no past)
- Favorites
- Discovery (no results)
- Search (no results)
- Cart (empty)

**Estimated effort:** 1-2 hours

---

#### UI-6. Standardize Back Button Pattern

**Current:** `ScreenWithBack` widget exists but not used everywhere

**Action:** Audit all secondary screens and migrate to `ScreenWithBack`

**Screens that need back:**
- Receipt
- Order tracking
- Order detail
- Support request
- Restaurant detail
- Checkout
- Address manager
- Settings
- Preferences

**Estimated effort:** 2-3 hours

---

#### UI-7. Typography Audit

**Goal:** Ensure all text uses `context.text`, no hardcoded font sizes

**Action:** Search for `TextStyle(fontSize:` and replace with theme styles

**Search pattern:** `TextStyle\(.*fontSize:`

**Estimated effort:** 1-2 hours

---

#### UI-8. Spacing Audit

**Goal:** Ensure all padding uses `AppSpacing` tokens, no magic numbers

**Action:** Search for `EdgeInsets.` and `SizedBox(` with hardcoded values

**Search patterns:**
- `EdgeInsets.all\([0-9]`
- `EdgeInsets.symmetric\(.*[0-9]`
- `SizedBox\(height: [0-9]`
- `SizedBox\(width: [0-9]`

**Estimated effort:** 2-3 hours

---

#### UI-9. Primary vs Secondary CTA Audit

**Goal:** One primary CTA per screen (FilledButton), secondary actions use OutlinedButton

**Action:** Audit all screens for button usage

**Checklist:**
- Checkout → "Pay and place order" (primary)
- Cart → "Checkout" (primary)
- Orders → "Track order" (primary on active cards)
- Receipt → "Order again" (primary), "Get help" (secondary)

**Estimated effort:** 1-2 hours

---

### UI Improvements Definition of Done

- [ ] Semantic muted/tertiary text colors added to tokens and extensions
- [ ] All `withValues(alpha: ...)` replaced with `context.textMuted` or `context.textTertiary`
- [ ] AppCard uses `ColorTokens.cardShadow` instead of Material elevation
- [ ] Duplicate components removed from `lib/shared/widgets/`
- [ ] Account screen merged into Profile (or route wired if kept separate)
- [ ] All empty states use `EmptyState` widget
- [ ] All secondary screens use `ScreenWithBack` wrapper
- [ ] No hardcoded font sizes (all use `context.text`)
- [ ] No magic number padding/spacing (all use `AppSpacing`)
- [ ] Primary vs secondary CTAs consistent across all screens
- [ ] UI quality checklist (docs/ui_quality_checklist.md) passes for all screens

---

## Execution Order (Recommended)

**Week 1: Backend Foundation (Track A + B in parallel)**
- Day 1-2: A1 (HTTP transport) + A4 (auth storage)
- Day 2-3: A2 (API repositories)
- Day 3-4: A3 (provider wiring)
- Day 1-5: B1-B3 (backend deployment, can run in parallel with frontend)

**Week 2: UI System Cleanup**
- Day 1: UI-1 (semantic colors)
- Day 2: UI-2 (card shadows) + UI-3 (consolidate components)
- Day 3: UI-4 (Profile/Account) + UI-5 (empty states)
- Day 4: UI-6 (back button pattern)
- Day 5: UI-7 (typography audit) + UI-8 (spacing audit) + UI-9 (CTA audit)

**Week 3: Integration & Testing**
- Day 1-2: E2E reality test (docs/e2e_reality_test.md)
- Day 3: Fix bugs found in E2E
- Day 4-5: Phase 12.4 UI grounding checklist

**Total estimated effort:** ~2-3 weeks (1 person, full-time)

---

## Phase 12 Exit Criteria Mapping

| Criterion | How we satisfy it |
|-----------|-------------------|
| 1. App can safely take test money | Phase 12.2 (payment integration) — deferred; can use dummy payments with backend for 12.1 |
| 2. Orders persist across sessions | ✅ Backend stores orders; ApiOrdersRepository fetches from backend |
| 3. Availability is backend-driven | ✅ Backend serves restaurant hours/serviceModes; ApiRestaurantRepository |
| 4. UI feels intentional | ✅ UI improvements (UI-1 through UI-9) |
| 5. Support copy no longer hypothetical | ✅ Already done (Phase 7); support log-only is acceptable for 12.1 |
| 6. You trust it enough to hand to someone else | ✅ E2E reality test passes (Week 3) |

**Note:** Phase 12.2 (real payment integration) is separate from 12.1. For 12.1, dummy payments with backend storage is acceptable.

---

## Quick Wins (Can Do Today)

1. **UI-2: Fix card shadows** (30 min)
2. **UI-1: Add semantic color tokens** (1 hour)
3. **UI-3: Delete duplicate components** (1 hour)
4. **A1: HTTP transport client** (2-4 hours)

**Total quick wins:** 4.5-6.5 hours → visible progress in one day

---

## Risk Mitigation

**Risk 1:** Backend takes longer than expected
**Mitigation:** Frontend Track A can complete independently; use `ENV=dev` (dummy) until backend ready

**Risk 2:** API contracts mismatch between frontend and backend
**Mitigation:** Define JSON schemas in `docs/backend_foundation.md` before implementation; use TypeScript on backend for type safety

**Risk 3:** UI changes break existing screens
**Mitigation:** Run `flutter test` after each UI change; keep changes isolated (one component at a time)

**Risk 4:** Auth flow breaks on real backend
**Mitigation:** Test auth separately first (sign-in → GET /me → sign-out); use Postman/curl to verify backend before wiring frontend

---

## Success Metrics

**Phase 12.1 Success:**
- [ ] Can run `flutter run --dart-define=ENV=stage` and app uses real backend
- [ ] Can sign in with email/password
- [ ] Can see real restaurants from backend
- [ ] Can place order and it persists in backend database
- [ ] Can see order in history after app restart
- [ ] Can see receipt with real order data
- [ ] E2E reality test passes without manual fixes

**UI System Success:**
- [ ] All screens use semantic color tokens (no ad-hoc alpha)
- [ ] All spacing uses tokens (no magic numbers)
- [ ] All typography uses theme (no hardcoded sizes)
- [ ] UI quality checklist passes
- [ ] App feels "finished" not "prototype" (subjective but measurable via external review)

---

*This plan is a living document. Update as work progresses.*
