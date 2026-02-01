# Theme tokens

## Colors
Defined in `lib/app/theme.dart` under `AppColors`.

Guidance:
- Dark brown headers feel warm indoors.
- Cream canvas reduces eye fatigue for long browsing.

## Spacing
Defined in `lib/shared/tokens/app_spacing.dart`:

- xs: 8
- sm: 12
- md: 16
- lg: 24
- xl: 32

Use `AppSpacing.pagePadding` and `AppSpacing.cardPadding` for layout.

## Radii
Defined in `lib/shared/tokens/app_radii.dart`:

- r12, r16, r24

## Durations
Defined in `lib/shared/tokens/app_durations.dart`:

- fast, medium, slow

## Typography
Use `context.text` from `lib/shared/extensions/context_extensions.dart` to access
text styles. Avoid custom text styles in feature UI unless required.
