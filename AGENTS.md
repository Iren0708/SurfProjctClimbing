# AGENTS.md — «Вертикаль»

## Repo State

- Monorepo: `01-analysis/` (документация, **read-only** при разработке), `backend/`, `mobile/`.
- Реализация по чеклисту: `02-development/IMPLEMENTATION_CHECKLIST.md`.
- Сохранять ID трассировки: `BR-*`, `FR-*`, `NFR-*`, `UC-*`, `SCR-*`, `BS-*`, `LOGIC-*`.

## Source Of Truth

- Экраны и логики: `01-analysis/5-mobile-app-spec/README.md`, `SCR-*`, `BS-*`, `09_Логики/LOGIC-*`.
- API: `01-analysis/api/redocly.yaml` и домены `auth`, `slots`, `bookings`, `profile`, `instructors`.
- Модель данных: `01-analysis/4-design/data-model.md`.
- Требования: `01-analysis/2-requirements/`.

## Target Stack

| Слой | Технологии |
|------|------------|
| Backend | Spring Boot 3, **Kotlin**, JPA, Flyway, PostgreSQL, Spring Security, JWT |
| Mobile | **Flutter**, dio, riverpod, go_router, flutter_secure_storage |
| Infra | Docker Compose, GitHub Actions |

Не менять стек без явного запроса пользователя.

## Backend Architecture

```
Controller (api/) → Service (@Transactional) → Repository (JPA) → PostgreSQL
```

Пакеты под `com.vertical`:

- `config` — Security, OpenAPI, Jackson, Clock
- `common` — exceptions, ErrorResponse, pagination
- `auth`, `profile`, `slots`, `bookings`, `instructors`
- `push` — **Phase 2** (напоминания, FCM)

Правила:

- `operationId` из OpenAPI = имена эндпоинтов/методов клиента.
- Entity ≠ DTO; ошибки через `@ControllerAdvice` → `{code, message, details}`.
- `createBooking`: `@Transactional`, pessimistic lock, `Idempotency-Key`, 201/409/410.
- Одна бронь = **одно место**, `equipment`: `own` | `rental` (не `seats_count`).

## Mobile Architecture

```
lib/features/<feature>/presentation|domain|data
lib/core/ — api, storage, config, widgets (LOGIC-008)
```

- UI ходит в **реальный backend API**; mock-слои не использовать.
- Состояния экрана: Loading / Content / Empty / Error (LOGIC-008).

## MVP Scope

**В scope:** клиент, OTP, слоты/фильтры, карточка, бронь (1 место), свои брони, отмена, профиль (имя, logout, delete).

**Phase 2:** push (LOGIC-007), смена телефона, `registerPushToken`, scheduler.

**Вне scope:** admin, schedule CRUD, оплата, рейтинги, карта маршрута, loyalty.

## Domain Invariants

- Атомарное бронирование, 0 двойных броней (R-004).
- Отмена: ≥2ч → `cancelled` + освобождение мест/проката; <2ч → `late_cancel`.
- Слоты, zone_format, инструкторы — read-only для клиентского API.
- Не хардкодить лимиты мест/проката — из данных слота.

## API Commands

```bash
npm --prefix 01-analysis/api install
npm --prefix 01-analysis/api run lint
```

## Local Run

```bash
cp .env.example .env
docker compose up -d
cd backend && ./gradlew bootRun
```
