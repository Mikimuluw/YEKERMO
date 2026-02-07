# End-to-End Reality Test (Phase 12.5)

**Before Phase 13 is even discussed:** A real user must complete this flow against a real (or staging) environment. If it isn’t **boringly reliable**, you don’t move on.

The full **Phase 12 exit criteria (the gate)** are in `docs/progress.md`: safe test money, orders persist, availability backend-driven, UI intentional, support copy real, and personal trust to hand it to someone else. Only after all are met does Phase 13 make sense.

---

## The flow

A real user:

1. **Opens the app** — App launches; shell and navigation work.
2. **Logs in** — Authenticates (real auth against backend); session is established; user identity is real.
3. **Sees real restaurants** — Discovery (or home) shows restaurants from the backend; not dummy or seed-only data.
4. **Places a real (sandbox) order** — Adds items to cart, goes to checkout, enters payment (sandbox card), taps Pay and place order; order is placed with real payment provider in test mode and stored on the backend.
5. **Sees it in history** — Orders list shows the order; order detail opens and shows correct data.
6. **Sees a receipt** — From order detail, opens receipt; receipt shows restaurant, order #, items, fees, total paid, payment method.
7. **Retries safely on failure** — If payment or place fails, user sees clear error state (“Nothing was charged.”, “You can try again.”); retry does not double-charge or double-place; flow can be repeated without corruption.

---

## Pass criteria

| Step | Pass |
|------|------|
| Open app | App opens; no crash; shell and tabs visible. |
| Log in | User signs in; session persists; API requests are authenticated. |
| Real restaurants | Restaurant list and detail come from backend; open/closed or availability from backend (or clearly simulated with real data). |
| Place sandbox order | Cart → checkout → pay (sandbox) → place; order created on backend; payment confirmed (sandbox); user sees confirmation. |
| See in history | Orders list includes the order; order detail loads and shows correct items, total, status. |
| See receipt | Receipt screen shows order; content matches order (restaurant, items, fees, total paid, payment method). |
| Retry safely | On payment or place failure: error shown, “Nothing was charged.” and “You can try again.”; retry works; no duplicate order or charge. |

---

## Gate

**Phase 13 is not started until this flow is boringly reliable.**

- Run the flow repeatedly (same user, new orders); it should succeed consistently.
- Run the failure path (e.g. decline card, or force a failure); retry should work and state should stay consistent.
- No “it works on my machine” or “we’ll fix it later.” If any step is flaky or broken, fix it before Phase 13.

---

## Environment

This test is run against the **real** environment (staging or prod-lite) with:

- Real backend (Phase 12.1)
- Real auth (Phase 12.1)
- Real payment provider in sandbox/test mode (Phase 12.2)
- Order lifecycle and persistence on backend (Phase 12.3)

The automated money-path tests in `test/money_path_e2e_test.dart` use dummy repos and prove the app flow; the **E2E reality test** proves the same flow against the real stack.
