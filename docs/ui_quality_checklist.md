# UI Quality Checklist (Required)

**This PR modifies UI. All items below must be satisfied.**

If any item is unchecked, this PR must not be merged.

Reference: [UI Guardrails](ui_guardrails.md), [Design tokens](theme_tokens.md), [CI UI Enforcement](ci_ui_enforcement.md).

---

## Visual Calm & Hierarchy

- [ ] Screen reads calmly at a glance (no visual noise)
- [ ] Vertical spacing feels slow and breathable
- [ ] Section separation is achieved via space, not dividers
- [ ] Typography hierarchy uses weight + opacity, not size jumps

## Color Discipline

- [ ] `#5B0E14` is used only for anchors (nav / CTA / selected state)
- [ ] `#F1E194` is used only as canvas or breathing space
- [ ] Neutral colors dominate content surfaces
- [ ] No new colors introduced without justification

## Cards & Layout

- [ ] All cards use the same corner radius token
- [ ] Cards use elevation, not borders
- [ ] Internal padding matches spacing tokens
- [ ] Images feel warm, real, and tactile (no placeholders)

## Navigation & Behavior

- [ ] Header feels resting, not dividing
- [ ] Navigation does not compete with content
- [ ] Search screens are exploratory, not empty

## Copy & Tone

- [ ] No hype, urgency, emojis, or marketing language
- [ ] Copy is calm, grounded, descriptive

## Final Acceptance

- [ ] Scrolling feels slow even when fast
- [ ] Brand colors feel intentional, not frequent
- [ ] Screen feels established, not experimental

---

**If any item is unchecked, this PR must not be merged.**

*Agents and reviewers: explain any violation; do not merge until resolved.*
