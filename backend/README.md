# Backend API — «Вертикаль»

Spring Boot 3 (Kotlin) REST API для мобильного клиента скалодрома.
Контракт: `../01-analysis/api/`.

## Требования

- JDK 21
- PostgreSQL 16 (через Docker Compose — рекомендуется)
- npm — только для lint OpenAPI (`01-analysis/api`)

## Переменные окружения

Скопируйте из корня репозитория:

```bash
cp ../.env.example ../.env
```

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `SPRING_DATASOURCE_URL` | JDBC URL | `jdbc:postgresql://localhost:5432/vertical` |
| `SPRING_DATASOURCE_USERNAME` | Пользователь БД | `vertical` |
| `SPRING_DATASOURCE_PASSWORD` | Пароль БД | `vertical` |
| `JWT_SECRET` | Секрет JWT (≥32 символов) | см. `.env.example` |

## Локальный запуск

### 1. PostgreSQL

Из корня monorepo:

```bash
docker compose up -d postgres
```

### 2. API

```bash
# Windows
.\gradlew.bat bootRun

# Linux / macOS
./gradlew bootRun
```

Проверка:

```bash
curl http://localhost:8080/health
curl http://localhost:8080/actuator/health
```

### 3. API + PostgreSQL в Docker

```bash
docker compose up -d --build
```

## Сборка и тесты

```bash
.\gradlew.bat build
.\gradlew.bat test
```

Интеграционные тесты поднимают **PostgreSQL 16** через Testcontainers (нужен Docker):

```bash
./gradlew test
```

## Миграции

Flyway: `src/main/resources/db/migration/V*.sql`

Миграции применяются при старте приложения (`spring.flyway.enabled=true`).

## Структура пакетов

```
com.vertical/
├── config/
├── common/
├── auth/
├── profile/
├── slots/
├── bookings/
└── instructors/
```

См. также `../.cursor/rules/backend-modules.mdc` и `../02-development/IMPLEMENTATION_CHECKLIST.md`.

## OpenAPI

```bash
npm --prefix ../01-analysis/api run lint
```

Swagger UI: `http://localhost:8080/swagger-ui.html`  
OpenAPI JSON: `http://localhost:8080/v3/api-docs`
