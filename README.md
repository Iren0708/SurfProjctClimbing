# Summer School 2026 — «Вертикаль» (SurfProjctClimbing)

Monorepo клиентского приложения скалодрома: аналитика, Spring Boot API, Flutter mobile.

**«Вертикаль»** — мобильное приложение для самостоятельной записи на групповые тренировки в скалодроме: просмотр слотов, бронирование одного места, отмена, профиль.

| Слой | Путь | Стек |
|------|------|------|
| Аналитика / OpenAPI | `01-analysis/` | Markdown, OpenAPI 3 |
| Backend | `backend/` | Spring Boot 3, Kotlin, PostgreSQL, Flyway |
| Mobile | `mobile/` | Flutter, dio, riverpod, go_router |

Чеклист реализации: [`02-development/IMPLEMENTATION_CHECKLIST.md`](02-development/IMPLEMENTATION_CHECKLIST.md)

---

## Стек приложения

```
Flutter (iOS + Android)  →  REST / OpenAPI  →  Spring Boot API  →  PostgreSQL
```

| Слой | Технологии |
|------|------------|
| **Mobile** | Flutter 3.44 (Dart), dio, riverpod, go_router, flutter_secure_storage |
| **Backend** | Spring Boot 3 (Kotlin), Spring Web, Spring Data JPA, Spring Security (JWT) |
| **БД** | PostgreSQL, миграции Flyway |
| **API-контракт** | OpenAPI 3 — `01-analysis/api/` (домены: auth, profile, slots, bookings, instructors) |
| **Документация API** | springdoc-openapi (Swagger UI на `:8080`) |
| **Инфра** | Docker Compose (PostgreSQL + API), GitHub Actions (CI) |
| **Тесты** | Backend: JUnit 5 + Testcontainers · Mobile: flutter test |

**MVP (реализовано):** OTP-авторизация, слоты и фильтры, бронь одного места (own/rental), свои брони, отмена (правило 2 ч), профиль.

**Phase 2:** push-напоминания (FCM + firebase_messaging), смена телефона, `@Scheduled` на бэкенде.

Подробнее: [`AGENTS.md`](AGENTS.md) · [`AnalyzePromts.md`](AnalyzePromts.md)

---

## Быстрый старт «с нуля»

### 1. Требования

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (PostgreSQL + API)
- JDK 21 — только если запускаете backend без Docker-образа
- Flutter 3.44.4 — [`mobile/.fvmrc`](mobile/.fvmrc)
- Node.js 20+ — lint OpenAPI (`01-analysis/api`)

### 2. Переменные окружения

```bash
cp .env.example .env
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

### 3. Backend (PostgreSQL + API)

```bash
docker compose up -d --build
curl http://localhost:8080/health
```

Ожидаемый ответ: `{"status":"UP",...}`.

**OTP в docker/dev:** код **`1234`** (фиксированный генератор в профиле `docker`).

Swagger UI: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)

Только БД (API через Gradle локально):

```bash
docker compose up -d postgres
cd backend
./gradlew bootRun          # Linux/macOS
.\gradlew.bat bootRun      # Windows
```

### 4. Mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/v1
```

| Платформа | `API_BASE_URL` |
|-----------|----------------|
| Android Emulator | `http://10.0.2.2:8080/v1` |
| iOS Simulator | `http://localhost:8080/v1` |
| Физическое устройство | `http://<IP-PC>:8080/v1` |

### 5. Проверка сценария (E2E smoke)

```powershell
# Windows — из корня репо
.\scripts\e2e-smoke.ps1
```

```bash
# Linux / macOS
./scripts/e2e-smoke.sh
```

Сценарий: auth → list slots → book → list bookings → cancel.

---

## Тесты и качество

```bash
# OpenAPI lint (01-analysis)
npm --prefix 01-analysis/api install
npm --prefix 01-analysis/api run lint

# Backend (Testcontainers + OpenApiContractTest)
cd backend && ./gradlew test

# Mobile
cd mobile && flutter analyze && flutter test
```

Ручной прогон UC: [`02-development/QA_UC_CHECKLIST.md`](02-development/QA_UC_CHECKLIST.md)

---

## Структура репозитория

```
01-analysis/          ТЗ, use cases, OpenAPI-контракты
02-development/       Чеклист, QA
backend/              REST API `/v1/*`
mobile/               Flutter-клиент
docker-compose.yml    PostgreSQL + API
scripts/              e2e-smoke.ps1 / .sh
docs/github-setup.md  Remote GitHub
```

---

## GitHub

- Репозиторий: [github.com/Iren0708/SurfProjctClimbing](https://github.com/Iren0708/SurfProjctClimbing)
- CI: [`.github/workflows/ci.yml`](.github/workflows/ci.yml) — backend, mobile, Docker, OpenAPI lint

---

## Разработка с AI

- Правила: [`.cursor/rules/`](.cursor/rules/), [`AGENTS.md`](AGENTS.md)
- Журнал промптов: [`РазработкаПромты.md`](РазработкаПромты.md)
- Стек и контекст: [`AnalyzePromts.md`](AnalyzePromts.md)
