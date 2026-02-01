# Branching and PRs

## Branching
- `main` is always deployable.
- Use short-lived feature branches: `feat/<area>` or `fix/<issue>`.

## PR checklist
- Routes use `Routes.*` constants (no raw strings).
- Async screens use `AsyncStateView`.
- UI uses shared tokens (`AppSpacing`, `AppSectionHeader`, `AppCard`).
- No hardcoded colors outside `lib/app/theme.dart`.
- Run `tools/ci.sh` or `tools/ci.ps1`.

## Merge gate
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
