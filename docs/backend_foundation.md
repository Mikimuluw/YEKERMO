# Backend Foundation (Phase 12.1 — Non-Negotiable)

**You cannot skip this.** The customer app must eventually talk to a real backend. This document defines what “real” means and what stays simple.

---

## Must be real

| Requirement | Meaning | App contract |
|-------------|---------|--------------|
| **Authentication (even minimal)** | Backend issues a session or token; app sends it on API requests. No anonymous-only production. | `AuthRepository`: get session, sign-in, sign-out. Transport sends `Authorization` when session exists. |
| **Persistent users** | User identity and profile live in backend storage; survive restarts and devices. | User/customer data comes from backend (e.g. `/me`, home feed); `Customer.id` is backend user id. |
| **Persistent orders** | Every placed order is stored on the backend; order id is backend-issued. | `OrdersRepository`: `placeOrder` and `getOrders`/`getOrder`/`getLatestOrder` use backend. |
| **Persistent order history** | Order history is the source of truth from backend, not in-memory. | Same as above: `getOrders()` and `getOrder(id)` return backend data. |
| **Restaurant availability from backend** | Open/closed and service modes (and optionally menu) come from backend, not only from app seed/dummy. | `RestaurantRepository` / discovery: restaurant list and `hoursByWeekday`, `serviceModes` from API. |
| **One real environment** | At least one deployable environment (staging or prod-lite) with a real backend URL and real auth. | `AppEnv.current` and `AppEnv.apiBaseUrl`; `useRealBackend` true when running against that environment. |

---

## Allowed to stay simple

- **One role:** customer only (no restaurant admin, no ops UI in this app).
- **One city:** e.g. Calgary; city scoping already in transport.
- **One cuisine:** e.g. Ethiopian; no multi-cuisine backend requirement for 12.1.
- **One payment provider:** single provider (e.g. Stripe sandbox); no multi-provider routing.
- **No optimization:** no caches, CDNs, or performance work beyond “it works.” Just truth.

---

## Environment

- **dev:** Local or dummy; no real backend required.
- **stage (or prod-lite):** The one real environment. Backend URL must be real; auth must be real; orders, users, and restaurant availability must be persisted and served from backend.
- **prod:** Can be same as stage initially or a separate URL later.

App reads `ENV` (e.g. `--dart-define=ENV=stage`) and uses `AppEnv.apiBaseUrl` for API base. When `useRealBackend` is true (e.g. when `ENV=stage`), repositories use API implementations and transport uses a real HTTP client with auth.

---

## Auth (minimal)

- Backend exposes sign-in (e.g. email + password or token exchange); returns a **session** (e.g. JWT or opaque token).
- App stores session (e.g. secure storage) and passes it as `Authorization: Bearer <token>` (or equivalent) on every request.
- Session has a **user id**; backend uses it for “current user” and for scoping orders.
- Sign-out: app clears session and optionally calls backend revoke.

No social login, no MFA, no roles beyond “customer” for 12.1.

---

## API contracts (summary)

Backend must support at least:

1. **Auth:** `POST /auth/sign-in`, response includes token and optionally user id/email. Optional: `POST /auth/sign-out`, `GET /auth/session` or `/me`.
2. **User/me:** `GET /me` or equivalent returning current user/customer (id, name, primaryAddressId, preference).
3. **Orders:** `GET /orders`, `GET /orders/:id`, `GET /orders/latest`, `POST /orders` (place order with payment intent/id). All scoped to current user.
4. **Restaurant availability:** Discovery or restaurant endpoint returns restaurants with `hoursByWeekday` and `serviceModes`; menu endpoint returns menu for a restaurant. Open/closed derived from hours + server time or provided by backend.
5. **Payment:** Already defined by existing payment provider (e.g. charge endpoint); can remain sandbox.

Payload shapes (JSON) to be aligned with app DTOs; see `lib/data/dto/` and repository implementations.

**Transport and auth:** When using the real backend, the HTTP client must send the session token on every request. Example: `request.headers['Authorization'] = 'Bearer ${session.token}'`. The app has `AuthRepository` and `AuthSession` (domain); a real `TransportClient` implementation should read the current session (e.g. from `AuthRepository.getSession()`) and attach it to requests.

---

## Definition of done (Phase 12.1)

- [ ] Backend deployed for one real environment (staging or prod-lite) with real URL.
- [ ] Authentication: backend issues session; app has auth abstraction and sends token on requests.
- [ ] Persistent users: current user and profile from backend.
- [ ] Persistent orders: place order and order history from backend.
- [ ] Restaurant availability: discovery and restaurant data (hours, service modes) from backend.
- [ ] App config: `useRealBackend` true when running against that environment; repositories switch to API implementations.
- [ ] One role, one city, one cuisine, one payment provider; no optimization. Just truth.
