# Mobile — «Вертикаль»

Flutter-клиент для iOS и Android. Спецификация: `../01-analysis/5-mobile-app-spec/`.

> **Статус:** MVP завершён (QA-01…03). Phase 2: push, смена телефона.

## Версия Flutter

Зафиксирована в [`.fvmrc`](.fvmrc): **3.44.4** (stable). С FVM: `fvm install && fvm flutter pub get`.

## Структура

```
mobile/lib/
├── main.dart
├── app/
│   ├── vertical_app.dart
│   ├── theme/           # VerticalTheme, VerticalTokens
│   ├── router/          # go_router, MainShellScreen
│   └── presentation/    # SplashScreen
├── core/
│   ├── api/             # VerticalApiClient, DTO, dio
│   ├── storage/         # flutter_secure_storage
│   ├── config/          # API_BASE_URL
│   ├── domain/policies/  # LOGIC-002–005
│   └── widgets/         # StateContainer, LoadableState (LOGIC-008)
└── features/
    ├── auth/            # SCR-001
    ├── slots/           # SCR-002, SCR-003, BS-001
    ├── bookings/        # SCR-004–006, BS-002, BS-003
    └── profile/         # SCR-007
```

Слои внутри feature: `presentation/` → `domain/` → `data/` (см. `.cursor/rules/mobile-modules.mdc`).

## Стек

- Flutter (Dart) · **dio** · **riverpod** · **go_router** · **flutter_secure_storage**

## Запуск

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/v1
```

`10.0.2.2` — host machine из Android-эмулятора. iOS Simulator: `http://localhost:8080/v1`.

Backend: `docker compose up` или `cd backend && ./gradlew bootRun`.

## Тестирование

Приложение ходит в **реальный backend API** — без mock-слоя.

```bash
flutter analyze
flutter test
```

### E2E smoke (MOB-17)

Против локального API (`docker compose up`). В docker-профиле OTP фиксирован: **1234**.

```powershell
# из корня репо (Windows)
.\scripts\e2e-smoke.ps1
```

```bash
# Linux / macOS
./scripts/e2e-smoke.sh
```

Или вручную:

```bash
docker compose up -d
cd mobile
flutter test test/e2e/api_smoke_test.dart --dart-define=RUN_E2E=true
```

Переменные: `API_BASE_URL` (default `http://localhost:8080/v1`), `E2E_PHONE`, `E2E_OTP`.

### Навигация (MOB-18)

Контрактные и widget-тесты: `test/app/router/app_navigation_*_test.dart` — сверка с `feature-list.md` §3.

См. `../02-development/IMPLEMENTATION_CHECKLIST.md`.
