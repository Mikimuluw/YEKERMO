# Yekermo Backend (Phase 12.1)

Production-ready Node.js + Express + Prisma backend for the Yekermo Flutter app.

## Where and how: 3 steps

### Step 1 — Run the backend locally

**Where:** In a terminal, use the **backend folder** (this repo):

- Full path: `c:\Users\user\dev\Yekermo\yekermo-backend`
- Or from repo root: `cd yekermo-backend`

**How:**

1. Open the file **`yekermo-backend\.env`** (same folder as `package.json`). Edit:
   - **DATABASE_URL** — Use a real PostgreSQL URL. Examples:
     - Local Postgres: `postgresql://postgres:YOUR_PASSWORD@localhost:5432/yekermo`
     - Or install Postgres (e.g. via Docker, or [postgresql.org](https://www.postgresql.org/download/windows/)) and create a DB named `yekermo`.
   - **JWT_SECRET** — Must be at least 32 characters. Generate one:
     - PowerShell: `[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }) -as [byte[]])`
     - Or replace with any long random string (e.g. 32+ letters/numbers).

2. In the terminal, from **`yekermo-backend`**:
   ```bash
   npm install
   npx prisma migrate dev --name init
   npm run db:seed
   npm run dev
   ```
3. You should see: `Server running on port 3000 (development)`. Test: open `http://localhost:3000/health` in a browser → `{"status":"ok"}`.

---

### Step 2 — Deploy to Railway and run migrations

**Where:** On the web (railway.app) and in a terminal linked to the same backend code.

**How:**

1. **Railway (web):**
   - Go to [railway.app](https://railway.app) and sign in (e.g. with GitHub).
   - **New Project** → **Deploy from GitHub repo** → choose the repo that contains `yekermo-backend` (or the whole Yekermo repo).
   - In the project: **New** → **Database** → **PostgreSQL**. Railway will set `DATABASE_URL` for your service.
   - Open your **backend service** → **Variables** and add:
     - `NODE_ENV` = `production`
     - `JWT_SECRET` = (generate with e.g. `openssl rand -base64 32` in a terminal, or any 32+ char secret)
     - `JWT_EXPIRES_IN` = `30d`
     - `CORS_ORIGIN` = `*`
   - Deploy (push to the connected branch if needed). Copy the **public URL** (e.g. `https://yekermo-backend-production.up.railway.app`).

2. **Run migrations (terminal):**
   - Install Railway CLI: [docs](https://docs.railway.app/develop/cli) (e.g. `npm i -g @railway/cli`), then `railway login`.
   - In your repo, go to the backend folder: `cd yekermo-backend`.
   - Link the project if needed: `railway link` (select the project and the backend service).
   - Run:
     ```bash
     railway run npx prisma migrate deploy
     railway run npm run db:seed
     ```

3. **Point the Flutter app at that URL:**
   - Open **`lib/app/env.dart`** in the **Yekermo Flutter app** (folder `c:\Users\user\dev\Yekermo`).
   - Find the `stage` case (around line 26–27) and set the URL to your Railway URL, e.g.:
     ```dart
     case Environment.stage:
       return 'https://YOUR-RAILWAY-URL.up.railway.app';
     ```

---

### Step 3 — E2E test with the Flutter app (stage backend)

**Where:** In a terminal, use the **Flutter app root** (the repo that contains `pubspec.yaml` and `lib/`):

- Full path: `c:\Users\user\dev\Yekermo`
- Not inside `yekermo-backend`.

**How:**

1. Run the app against the **stage** backend:
   ```bash
   flutter run --dart-define=ENV=stage
   ```
   (Pick a device/emulator when prompted.)

2. In the app, verify:
   - Sign in with **test@yekermo.ca** / **password123** (seed user).
   - Open Discover/restaurants (if your UI loads them from the backend).
   - Place an order (cart → checkout → place order).
   - Open Orders — the order appears.
   - Fully close the app and open it again with the same command — sign in again, open Orders; the order should still be there (persistence).

---

## Tech stack

- **Runtime:** Node.js 20+
- **Framework:** Express.js
- **ORM:** Prisma with PostgreSQL
- **Auth:** JWT (jsonwebtoken) + bcrypt
- **Validation:** Zod
- **Security:** helmet, cors

## Setup

1. **Install dependencies**

   ```bash
   npm install
   ```

2. **Environment**

   Copy `.env` and set at least:

   - `DATABASE_URL` – PostgreSQL connection string
   - `JWT_SECRET` – at least 32 characters (e.g. `openssl rand -base64 32`)

3. **Database**

   ```bash
   npx prisma migrate dev --name init
   npx prisma generate
   npm run db:seed
   ```

4. **Run**

   ```bash
   npm run dev
   ```

   Server runs at `http://localhost:3000`. Health: `GET /health`.

## API endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/auth/sign-in` | No | Sign in (email, password) → `{ userId, token, email }` |
| GET | `/me` | Bearer | Current customer profile |
| GET | `/me/addresses` | Bearer | List addresses |
| POST | `/me/addresses` | Bearer | Create address |
| GET | `/restaurants` | No | List restaurants |
| GET | `/restaurants/:id/menu` | No | Restaurant + menu by category |
| GET | `/orders` | Bearer | Order history |
| GET | `/orders/latest` | Bearer | Latest order |
| GET | `/orders/:id` | Bearer | Order by id |
| POST | `/orders` | Bearer | Place order |

## Seed user

- Email: `test@yekermo.ca`
- Password: `password123`

## Deployment (Railway)

### Fix: "error creating build plan with railpack"

Your repo root is the **Flutter** app; the backend lives in **`yekermo-backend/`**. Railway must build from that subfolder:

1. In Railway, open your **backend service** (the one from this repo).
2. Go to **Settings**.
3. Find **Root Directory** (or **Source** → Root Directory).
4. Set it to: **`yekermo-backend`** (no leading slash).
5. Save and **Redeploy**.

Railway will then use only `yekermo-backend` for the build, see `package.json`, and create the build plan correctly.

---

### Deploy steps

1. New Project → Deploy from GitHub repo.
2. Add PostgreSQL (Database).
3. Set variables: `NODE_ENV=production`, `JWT_SECRET=<random 32+ chars>`, `JWT_EXPIRES_IN=30d`, `CORS_ORIGIN=*`.
4. Deploy; then run migrations:

   ```bash
   railway run npx prisma migrate deploy
   railway run npm run db:seed
   ```

5. Use the public URL in the Flutter app (`lib/app/env.dart` for stage).
