# Theme tokens

**Authoritative lock:** `lib/theme/tokens.dart` — see also **docs/ui_guardrails.md**.

```
lib/theme/
  ├── tokens.dart        # Canonical values (lock once)
  ├── color_tokens.dart  # Colors from tokens + card shadows
  ├── text_styles.dart   # Typography token names
  ├── spacing.dart      # AppSpacing from tokens
  └── radii.dart         # AppRadii from tokens (radiusMd = cards)
```

## Colors (`lib/theme/color_tokens.dart`) — Yekermo UI freeze

- **Primary canvas:** `#F1E194` (`ColorTokens.background`). App background; space and hierarchy lead.
- **Primary anchor:** `#5B0E14` (`ColorTokens.primary`). App bar, active nav, selected pill, single primary CTA per screen. Never large content backgrounds.
- **Cards:** off-white cream (`ColorTokens.surface`); contrast against canvas. Soft elevation via `ColorTokens.cardShadow`; no borders.
- **Muted text:** `ColorTokens.muted`; use `context.muted` for metadata (60–70% visual weight). No bold metadata.

## Spacing (`lib/theme/spacing.dart`)

- Vertical +10–12%: xs: 9, sm: 13, md: 18, lg: 27, xl: 35
- Section rhythm: `vSectionTitle` (12–16px after title), `vSection` (24–32px before next section). No dividers.
- Use `AppSpacing.pagePadding` and `AppSpacing.cardPadding` for layout.
- Re-exported from `lib/shared/tokens/app_spacing.dart`.

## Radii (`lib/theme/radii.dart`)

- **Consistent 12–16:** r12, r16 for cards, inputs, buttons; r24 for large elements.
- Re-exported from `lib/shared/tokens/app_radii.dart`.

## Durations

Defined in `lib/shared/tokens/app_durations.dart`: fast, medium, slow.

## Typography

Use `context.text` from `lib/shared/extensions/context_extensions.dart`. Token names in `lib/theme/text_styles.dart`. Avoid custom text styles in feature UI unless required.

**Scale (reference, from guardrails):** titleLarge 22 / SemiBold, sectionHeader 16 / Medium, body 15, meta 13. Metadata opacity 0.65.
