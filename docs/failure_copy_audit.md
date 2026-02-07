# Failure Taxonomy → Copy Audit (11.4)

**Why (PRD §6.2):** Failures must explain state, not emotion.

**Scope:** One-time sweep. Copy audit only—no feature work.

---

## PRD §6.2 requirements (checklist per failure)

Every failure must:

- **Explain what happened**
- **State what did not happen**
- **Provide a clear next step**
- Leave the user feeling respected (neutral tone, no blame)

---

## 1. Payment failed

| Aspect | Current implementation | Audit |
|--------|------------------------|--------|
| **Source** | `PaymentResult.message` from payments repo; `PaymentController` sets `Failure(result.message ?? "Payment didn't go through. Nothing was charged.")`. Dummy repo: last4 `0000` → failure. API repo: any exception → `_fallbackFailure()`. |
| **User sees** | Checkout: when `hasPaymentError` (ErrorState from payment controller), copy shown is **"Nothing was charged."** + **"You can try again."** + button **"Retry payment"**. The stored `Failure.message` ("Payment didn't go through. Nothing was charged.") is not displayed in the checkout body. |
| **What happened** | Implied by repo message: payment didn’t go through. On-screen only "Nothing was charged." — so **what happened** (payment didn’t complete) is understated. |
| **What did NOT happen** | ✅ "Nothing was charged." is explicit. |
| **Next step** | ✅ "You can try again." + "Retry payment" is clear. |
| **Gap** | **What happened** could be stated explicitly in UI (e.g. "Payment didn’t go through.") so the full triad is visible, not only "what did not happen" + next step. |

**Verdict:** Mostly aligned. Recommend surfacing one short line for *what happened* (e.g. "Payment didn’t go through.") in addition to "Nothing was charged." and "You can try again."

---

## 2. Place failed (order placement after payment)

| Aspect | Current implementation | Audit |
|--------|------------------------|--------|
| **Source** | `CheckoutController.payAndPlaceOrder` catches `PlaceOrderException`, maps code to `Failure`; otherwise `Failure('Unable to place order right now.')`. Rendered via `AsyncStateView` → `AppErrorView(message: failure.message)` + "Try again" button. |
| **What happened** | Shown only via the single `Failure.message` (see below per code). |
| **What did NOT happen** | Not stated (e.g. "Your order was not placed." / "Nothing was charged." depending on flow). |
| **Next step** | ✅ "Try again" button. No explicit "You can try again." text. |
| **Gap** | For place failure, **what did not happen** (order not placed; and whether anything was charged) is not in copy. PRD/Phase 7: "Nothing was charged." + "You can try again." — currently only the generic error message + button. |

**Verdict:** Partial. Add one line for *what did not happen* (order not placed; charge clarity if applicable) and optional short "You can try again." for consistency.

---

## 3. Restaurant closed (place failure)

| Aspect | Current implementation | Audit |
|--------|------------------------|--------|
| **Source** | `PlaceOrderFailureCode.restaurantClosed` → `Failure('Restaurant is closed.')`. |
| **User sees** | `AppErrorView`: "Restaurant is closed." + "Try again" button. |
| **What happened** | ✅ "Restaurant is closed." — clear state. |
| **What did NOT happen** | ❌ Not stated (order was not placed; nothing charged per current flow). |
| **Next step** | ✅ "Try again" (button). |

**Verdict:** Good on *what happened*. Add *what did not happen* (order not placed; nothing charged) for full §6.2 alignment.

---

## 4. Service mode unavailable (place failure)

| Aspect | Current implementation | Audit |
|--------|------------------------|--------|
| **Source** | `PlaceOrderFailureCode.serviceModeUnavailable` (e.g. delivery requested but restaurant doesn’t offer delivery) → same as unknown: `Failure('Unable to place order right now.')`. |
| **User sees** | "Unable to place order right now." + "Try again" button. |
| **What happened** | ❌ Vague. "Unable to place order" doesn’t say *why* (e.g. delivery not available for this restaurant). |
| **What did NOT happen** | ❌ Not stated. |
| **Next step** | ✅ "Try again" button. |

**Verdict:** Weak. Copy should explain *what happened* (e.g. "Delivery isn’t available for this restaurant right now.") and *what did not happen* (order not placed; nothing charged). Consider distinct message for `serviceModeUnavailable` instead of reusing "Unable to place order right now."

---

## 5. Network / timeout

| Aspect | Current implementation | Audit |
|--------|------------------------|--------|
| **Source** | `TransportError` (e.g. `network`, `timeout`, `server`, `unknown`). API payments repo catches it and returns `_fallbackFailure()` → same as generic payment failure. No distinct copy for network/timeout. |
| **User sees** | Same as **payment failed**: "Nothing was charged." + "You can try again." (and in stored state: "Payment didn't go through. Nothing was charged."). |
| **What happened** | Not distinguished from other payment failures. User doesn’t know if it was network, timeout, or card/processor. |
| **What did NOT happen** | ✅ "Nothing was charged." |
| **Next step** | ✅ "You can try again." / "Retry payment." |

**Verdict:** Acceptable for a first version (state, not emotion). If we want to explain *what happened* without being technical, one option is a single line like "We couldn’t reach the payment service." for network/timeout, while keeping "Nothing was charged." and "You can try again." No code change required for audit; document as future improvement.

---

## Summary table

| Failure type | What happened | What did NOT happen | Next step | Notes |
|--------------|---------------|---------------------|-----------|--------|
| **Payment failed** | Implied (repo message); not in checkout UI | ✅ Nothing was charged | ✅ You can try again / Retry payment | Add one line for *what happened* in UI. |
| **Place failed (generic)** | ✅ Unable to place order right now | ❌ | ✅ Try again | Add *what did not happen* (order not placed; nothing charged). |
| **Restaurant closed** | ✅ Restaurant is closed | ❌ | ✅ Try again | Add *what did not happen*. |
| **Service mode unavailable** | ❌ Vague | ❌ | ✅ Try again | Use specific copy (e.g. delivery not available); add *what did not happen*. |
| **Network/timeout** | Not distinguished | ✅ Nothing was charged | ✅ You can try again | Optional: "We couldn’t reach the payment service." later. |

---

## Where copy lives (reference)

| Failure | Message source | Shown in |
|---------|----------------|----------|
| Payment failed | `PaymentResult.message` (dummy/api repos: "Payment didn't go through. Nothing was charged."); checkout body shows only "Nothing was charged." + "You can try again." | Checkout screen (payment error block) |
| Place failed (all codes) | `CheckoutController._failureForPlaceOrderCode` → `Failure.message` | Checkout screen (`AsyncStateView` → `AppErrorView`) |
| Restaurant closed | `Failure('Restaurant is closed.')` | Same as above |
| Service mode unavailable | `Failure('Unable to place order right now.')` | Same as above |
| Network/timeout (payment) | Same as payment failed (no distinct message) | Same as payment failed |

---

## Recommendation (copy only)

1. **Payment failed (checkout):** Add one line stating *what happened*, e.g. "Payment didn’t go through." above "Nothing was charged." and "You can try again."
2. **Place failed (all):** Add one line for *what did not happen*, e.g. "Your order was not placed. Nothing was charged." (or equivalent), and optionally "You can try again." alongside the Try again button.
3. **Service mode unavailable:** Use distinct copy that explains state, e.g. "Delivery isn’t available for this restaurant right now." (and keep what did not happen + next step).
4. **Network/timeout:** Leave as-is for now; optionally document as future: "We couldn’t reach the payment service." when `TransportError` kind is network/timeout.

This audit does not require code changes; implement the above as a follow-up copy pass if desired.
