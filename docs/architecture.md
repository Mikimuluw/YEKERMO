# Architecture contracts

These contracts are frozen for Phase 1 and are not to be changed without an
explicit design decision.

## Navigation contract
- Centralized route constants live in `lib/app/routes.dart`.
- No raw route strings outside `lib/app/router.dart`.
- Bottom tabs use nested navigation; each tab retains its own stack.
- Not found routes render `NotFoundScreen`.
- Deep links follow: `/meal/:id`, `/restaurant/:id`, `/search?q=...`.

## State contract
Every async screen uses the same structure:
`Loading → Empty → Error → Data`

Use `AsyncStateView<T>` from `lib/shared/widgets/async_state_view.dart`.

## Data contract
- UI depends on repository interfaces only.
- Dummy repositories implement the interfaces.
- Result handling uses `Result<T>` in `lib/data/result.dart`.
- DTO mapping boundary lives in `lib/data/dto/`.

## Import rules (hard)
- `features/**` must not import `data/datasources` or `dummy_*`.
- `domain/**` must not import Flutter.
- `shared/**` must not import `features/**`.

## Design contract
- Tokens live in `lib/app/theme.dart` and `lib/shared/tokens/app_spacing.dart`.
- No hardcoded colors outside `lib/app/theme.dart`.
- Spacing uses `AppSpacing` tokens.
- Text widgets must use theme text styles or `context.text`.
- Shared UI components live in `lib/shared/widgets/`.

## Folder contract
- `lib/app`: router, theme, bootstrap/di, env.
- `lib/domain`: pure entities/value objects.
- `lib/data`: datasources, DTOs, mappers, repositories.
- `lib/features`: UI + controllers.
- `lib/shared`: reusable UI, tokens, extensions, state.
