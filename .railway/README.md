# Railway deployment (backend)

This repo is a monorepo: Flutter app at root, Node backend in a subfolder.

**Backend root directory:** `yekermo-backend`  
(Also recorded in `backend-root` for scripts.)

For the backend service on Railway, set **Root Directory** to:

```
yekermo-backend
```

- In Railway: Service → **Settings** → **Root Directory** → `yekermo-backend`
- Config file path (if asked): `yekermo-backend/railway.toml`

See [yekermo-backend/README.md](../yekermo-backend/README.md) for full deploy steps.
