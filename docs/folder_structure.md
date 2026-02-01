# Folder structure

```
lib/
  app/                # router, theme, bootstrap/di, env
  domain/             # pure entities/value objects
  data/               # datasources, DTOs, repositories
  features/           # feature screens and controllers
  observability/      # logging, analytics
  shared/             # reusable UI, tokens, extensions, state
test/                 # widget and unit tests
tools/                # CI scripts
docs/                 # architecture and dev guides
```

Rules:
- UI code lives in `features/` or `shared/`.
- Do not place data logic in UI files.
- Use `shared/` for any reusable component or token.
