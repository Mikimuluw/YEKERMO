# UI Enforcement Policy

Yekermo treats UI calm and trust as a **production requirement**, not aesthetics.

---

## Merge Policy

Any PR that violates:

- **UI Guardrails** ([docs/ui_guardrails.md](ui_guardrails.md))
- **Design tokens** ([docs/theme_tokens.md](theme_tokens.md), [lib/theme/tokens.dart](../lib/theme/tokens.dart))
- **PR UI checklist** ([docs/ui_quality_checklist.md](ui_quality_checklist.md))

**must be rejected**, even if:

- The feature works
- The code is correct
- The change is small

---

## Rationale

Visual inconsistency compounds faster than technical debt.

We choose:

- Fewer features
- Higher trust
- Slower UI evolution

over:

- Rapid UI drift
- Fragmented taste
- Inconsistent screens

---

## Reviewer Guidance

If unsure:

- **Default to less**
- **Remove before adding**
- **Ask: “Does this increase calm?”**

If the answer is no, reject.
