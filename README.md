# CineBook — Production-Grade Movie Ticket Booking Platform

A BookMyShow-style platform built as a clean, scalable, interview-ready reference implementation.

| Layer       | Tech                                                                 |
| ----------- | -------------------------------------------------------------------- |
| Backend     | Ruby on Rails 7.1 (API mode) · PostgreSQL · Redis · Sidekiq · ActionCable |
| Frontend    | React 18 · Vite · TypeScript · TailwindCSS · React Query · Zustand   |
| Auth        | JWT access token + refresh token (rotated, jti-tracked)              |
| Payments    | Stripe (Payment Intents + Webhooks) — provider-agnostic adapter      |
| Realtime    | ActionCable (Redis subscription adapter)                             |
| Storage     | Active Storage + AWS S3                                              |
| Containers  | Docker + docker-compose                                              |
| CI/CD       | GitHub Actions (lint → test → build → deploy)                        |
| Deployment  | AWS EC2 + Nginx (TLS) + Sidekiq systemd                              |

---

## Repo layout

```
cinebook/
├── backend/                Rails 7.1 API
│   ├── app/
│   │   ├── controllers/api/v1/   user-facing endpoints
│   │   ├── controllers/api/v1/admin/   admin endpoints
│   │   ├── models/
│   │   ├── services/             service objects (Booking, Payments, Auth)
│   │   ├── policies/             Pundit
│   │   ├── serializers/          Blueprinter
│   │   ├── jobs/                 Sidekiq workers
│   │   ├── channels/             ActionCable
│   │   └── mailers/
│   ├── config/
│   ├── db/
│   │   ├── migrate/
│   │   └── seeds.rb
│   └── spec/                     RSpec
├── frontend/                React + Vite SPA
│   ├── src/
│   │   ├── api/
│   │   ├── components/
│   │   ├── features/             auth, movies, booking, admin
│   │   ├── hooks/
│   │   ├── pages/
│   │   ├── routes/
│   │   └── store/
│   └── public/
├── deploy/                  nginx + systemd + scripts
├── docs/                    architecture, API, ADRs
├── .github/workflows/       ci.yml + deploy.yml
├── docker-compose.yml
└── README.md
```

---

## Quick start (local, without Docker)

See the full step-by-step guide:

- **Markdown:** [`docs/LOCAL_SETUP.md`](docs/LOCAL_SETUP.md)
- **PDF:** [`docs/LOCAL_SETUP.pdf`](docs/LOCAL_SETUP.pdf)

Short version:

```bash
# 1. Install: Ruby 3.2.2, Node 20, PostgreSQL 16, Redis 7
# 2. Backend
cd backend && cp .env.local.example .env && bundle install
bundle exec rails db:create db:migrate db:seed
bundle exec rails server -p 3000          # terminal 1
bundle exec sidekiq -C config/sidekiq.yml # terminal 2

# 3. Frontend
cd frontend && cp .env.example .env && npm install
npm run dev                               # terminal 3 → http://localhost:5173
```

## Quick start (Docker)

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

docker compose build
docker compose up -d postgres redis
docker compose run --rm backend bin/rails db:create db:migrate db:seed
docker compose up -d
```

App: `http://localhost:5173` · API: `http://localhost:3000` · Sidekiq UI: `http://localhost:3000/sidekiq`

### Demo credentials (seeded)

| Role  | Email                | Password    |
| ----- | -------------------- | ----------- |
| Admin | admin@cinebook.test  | Admin@12345 |
| User  | user@cinebook.test   | User@12345  |

---

## Documentation

- [`docs/LOCAL_SETUP.md`](docs/LOCAL_SETUP.md) / [`docs/LOCAL_SETUP.pdf`](docs/LOCAL_SETUP.pdf) — local dev setup without Docker
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — system design, request lifecycles, booking concurrency model
- [`docs/API.md`](docs/API.md) — REST endpoint reference (OpenAPI also served at `/api-docs`)
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) — EC2 + Nginx + SSL + GitHub Actions
- [`docs/ADR/`](docs/ADR/) — architecture decision records

---

## License

MIT (sample/reference project).
