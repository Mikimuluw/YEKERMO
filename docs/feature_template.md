# Feature template (single source of truth)

Use this exact structure for any new feature `X`. No exceptions.
This is the only valid implementation path for Phase-2 features.

## Required files and folders

```
domain/
  # models/value objects if needed

data/
  dto/
  mappers/
  repositories/
  datasources/

features/x/
  x_controller.dart   # Notifier -> ScreenState<XVm>
  x_screen.dart       # AsyncStateView
  x_routes.dart       # owned routes + selectors

observability/
  analytics.dart      # add event name constant(s)

tests/
  repo contract test(s)
  widget test (happy path if cheap)
```

## Naming conventions
- Controller: `XController` (Riverpod `Notifier`)
- View model: `XVm`
- Screen: `XScreen`
- Routes: `x_routes.dart` (single source of truth)

## No exceptions rules
- Use `ScreenState<T>` + `AsyncStateView` on every screen.
- Use design system widgets/tokens only (`App*`, `AppSpacing`, `AppRadii`).
- No raw route strings outside `x_routes.dart`.
- UI reads data only via repository interfaces and providers.

## Done checklist
- [ ] DTO → domain mapping + repository contract tests
- [ ] Controller emits ScreenState (initial/loading/success/empty/error)
- [ ] Screen uses AsyncStateView
- [ ] Feature routes owned in `x_routes.dart`
- [ ] Analytics event constants added (even if stub)
- [ ] Widget test (happy path) added when feasible

## Goldens policy
Goldens are added only after tokens are final. For now, keep them skipped.
