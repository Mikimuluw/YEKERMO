# QA UI smoke checklist

~5 minute manual pass before release or after major UI/state changes. Run on a single device; no automation required.

---

## 1. Cart single-restaurant (replace + snackbar)

- [ ] **Restaurant A:** From Home or Search, open a restaurant and tap **+ Add** on an item. Cart tab shows that item and restaurant.
- [ ] **Restaurant B:** Open a different restaurant and tap **+ Add** on an item.
  - [ ] Cart contents **replace** with the new restaurant’s item (no mixing).
  - [ ] A **snackbar** appears with copy like “Cart updated for [Restaurant name].” (or “Your cart was updated for this restaurant.”)

---

## 2. Checkout → order in Orders

- [ ] With at least one item in cart, go to **Cart** → **Proceed to checkout**.
- [ ] Complete checkout (address, payment if required) and **place order**.
- [ ] Navigate to **Orders**.
  - [ ] The new order appears (Active or Past depending on status).
  - [ ] Tapping the order / “View receipt” opens the correct order.

---

## 3. Receipt header by status

- [ ] Open **Orders** → **Past** → **View receipt** for an order.
  - [ ] **Completed:** Header shows “Order delivered” (or equivalent).
  - [ ] If you have **cancelled / failed / refunded** orders, receipt header shows “Order cancelled”, “Order not completed”, or “Order refunded” as appropriate.
  - [ ] For in-progress orders (if reachable via deep link), header shows “Order details” with status in subtitle.

---

## 4. Empty states

- [ ] **Cart** empty: Clear, consistent empty state (no broken layout).
- [ ] **Orders** (Active and Past): Empty states look consistent and on-brand.
- [ ] **Search** no results: Empty state is clear and consistent.

---

## 5. Search debounce sanity

- [ ] In **Search**, type quickly (e.g. several characters in a row).
  - [ ] Results don’t flicker into error/empty in a weird way.
  - [ ] Filter chip selection stays in sync with the query (no stale chips or mismatched results).

---

## 6. Back behavior consistency

- [ ] **Home** → open a restaurant **Detail** → **Cart** → **Checkout**.
- [ ] Use **back** at each step.
  - [ ] Each back returns to the expected screen (Detail → Home, Cart → Detail, Checkout → Cart).
  - [ ] No double app bars, no weird jumps or duplicate shells.

---

## 7. Large text / accessibility

- [ ] Enable **large text** (e.g. system font scale 150%+ or largest accessibility size).
  - [ ] Primary CTAs (e.g. “Proceed to checkout”, “Place order”, “View receipt”) remain visible and tappable.
  - [ ] No critical buttons hidden or clipped; layout doesn’t break.

---

## Sign-off

| Date       | Tester | Build/commit | Pass |
| ---------- | ------ | ------------ | ---- |
| __________ | ______ | __________   | [ ]  |
