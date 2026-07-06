# Summer School 2026 — «Вертикаль»

Monorepo: аналитика (`01-analysis/`), backend (Spring Boot + Kotlin), mobile (Flutter).

## Стек

| Слой | Технологии |
|------|------------|
| Mobile | Flutter (Dart), dio, riverpod |
| Backend | Spring Boot 3, Kotlin, PostgreSQL, Flyway |
| API-контракт | `01-analysis/api/` (OpenAPI 3) |

Подробнее: [AnalyzePromts.md](AnalyzePromts.md)

## Быстрый старт (Docker)

```bash
# 1. Переменные окружения
cp .env.example .env

# 2. PostgreSQL + API
docker compose up -d

# 3. Проверка
curl http://localhost:8080/health
```

Только база данных (без сборки API):

```bash
docker compose up -d postgres
```

Локальный запуск backend без Docker-образа:

```bash
cd backend
./gradlew bootRun          # Linux/macOS
.\gradlew.bat bootRun      # Windows
```

## GitHub

- Репозиторий: [github.com/Iren0708/SurfProjctClimbing](https://github.com/Iren0708/SurfProjctClimbing)
- Remote: `github` → `https://github.com/Iren0708/SurfProjctClimbing.git`
- `origin` → GitLab (сохранён). Подробнее: **[docs/github-setup.md](docs/github-setup.md)**

CI (GitHub Actions): `.github/workflows/ci.yml` — сборка backend + Docker-образ при push/PR.

## Структура

```
01-analysis/     документация, ТЗ, OpenAPI
backend/         Spring Boot API
mobile/          Flutter (будет добавлен)
docker-compose.yml
```

## Разработка с AI

- Правила агента: `.cursor/rules/`
- Журнал промптов: [РазработкаПромты.md](РазработкаПромты.md)
