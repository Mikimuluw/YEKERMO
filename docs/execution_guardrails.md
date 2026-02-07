# Execution Guardrails v1 (Locked)

## Execution Rules

### No feature expansion

- Do not add new flows, tabs, or CTAs

### No backend assumptions

- UI must not imply real-time behavior not yet implemented

### No redesigns

- No new visual language, animations, or metaphors

### System consistency

- All screens must use:
  - AppScaffold
  - AppSpacing
  - AppButton
  - context.text

### CTA discipline

- One primary CTA per screen
- Secondary actions are text-only

### State honesty

- No fake loading
- No "coming soon" SnackBars
- Disabled > hidden

### Copy safety

- No urgency
- No hype
- No celebration

### Removal > replacement

- If unsure, remove

### Navigation invariants

- Bottom nav fixed at 5 tabs
- No dead-end routes

### Pre-commit check

- Re-read PRD §§4–6 and UI Heuristics
- If violated → revert
