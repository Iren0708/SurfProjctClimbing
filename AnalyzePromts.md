cursor free version

давай ты с учетом @summer-school-2026/01-analysis/0-customer-brief/brief-climbing.md будешь предлагать рекомендлацию к ответу а я выбирать необходимый ответ под номерами

скорректируй@summer-school-2026/01-analysis/1-elicitation/domain-description.md с учетом изменений в @summer-school-2026/01-analysis/1-elicitation/customer-questions.md 
На основе @summer-school-2026/01-analysis/1-elicitation/domain-description.md выведи бизнес требования функциональные и нефункциональные. Также user Story и user case. Каждая – с ID, формулировкой, приоритетом и ссылкой на источник. Не смешивай функциональные и нефункциональные требования. Не добавляй того чего нет в домене. действуй строго в рамках домена 

занеси в соответсующие файлы по примеру их оформления @summer-school-2026/01-analysis/2-requirements/business-requirements.md @summer-school-2026/01-analysis/2-requirements/functional-requirements.md @summer-school-2026/01-analysis/2-requirements/non-functional-requirements.md @summer-school-2026/01-analysis/2-requirements/use-cases.md @summer-school-2026/01-analysis/2-requirements/user-stories.md 

проведи ревью результата последнего запроса, напиши что удалось сделать, что - нет. критические ошибки выдели и исправь

добавь трассировку для отслеживания требований на каждом уровне детализации для возможности отслеживания какие требования из какой части домена, вопросов и брифа заказчика вытекают




@@summer-school-2026/01-analysis/2-requirements/business-requirements.md @summer-school-2026/01-analysis/2-requirements/functional-requirements.md @summer-school-2026/01-analysis/2-requirements/non-functional-requirements.md @summer-school-2026/01-analysis/2-requirements/use-cases.md @summer-school-2026/01-analysis/2-requirements/user-stories.md 
сгенерируй реестр экранов приложения с учетом требований и сформируй требования на дизайн для каждого в отдельном файле. 
примеры:@summer-school-2026/01-analysis/3-design-brief/00-foundations.md @summer-school-2026/01-analysis/3-design-brief/design-brief.md @summer-school-2026/01-analysis/3-design-brief/SCR-001-registration.md 
результирующие файлы должны находиться в папке 3-design-brief

из домена и всех требований собери ER-модель и опиши модели сущностей в системе. Пометь какие сущности приложение только читает ( что приходит из бэкенда), а какие меняет. Нарисуй sequence-диаграмму createBooking c ветками 201/409/410

на основе @01-analysis/3-design-brief/design-brief.md @01-analysis/2-requirements сгенерируй OpenApi спецификацию в папку@01-analysis/api 
в папке уже готовое разделение на логичсекие блоки, возьми за пример такое деление 

используй требования для дизайна @01-analysis/3-design-brief ,готовй api @01-analysis/api и шаблоны ТЗ @01-analysis/5-mobile-app-spec/_LOGIC_TEMPLATE.md @01-analysis/5-mobile-app-spec/_SCREEN_TEMPLATE.md и напиши все ТЗ на приложение в папку @01-analysis/5-mobile-app-spec 

предложи мне варианты по градации скорость/качество/простота реализации для этого планируемого клиент-серверного приложения на каком языке писать бэк на каком фронт с какими фреймворками оптимальнее будет работать
цель создать мобильное приложение с возможностью проверки на функциональность

---

## Зафиксированный стек (2026-07-06)

> Решение принято после сравнения вариантов (Flutter+Go vs Flutter+Spring). Код генерируется через AI; приоритет — скорость до стабильного MVP и меньше ошибок в транзакционной логике бронирования.

### Архитектура

```
Flutter (iOS + Android)  →  REST / OpenAPI  →  один бэкенд  →  PostgreSQL
                                              ↘ Firebase (push)
```

- **Один бэкенд** обслуживает мобильный клиент на обеих платформах.
- **Контракт API** — источник истины: `01-analysis/api/` (OpenAPI 3).
- **MVP:** полноценный бэкенд с PostgreSQL (вариант A); интеграция с существующей инфраструктурой скалодрома — позже.

### Мобильный клиент

| Компонент | Выбор |
|-----------|-------|
| Язык | **Dart** |
| Фреймворк | **Flutter** |
| HTTP | dio |
| Состояние | riverpod (или bloc) |
| Безопасное хранение токенов | flutter_secure_storage (Keychain / Keystore) |
| Push | firebase_messaging (FCM; iOS через APNs) |
| API-клиент | openapi_generator из `01-analysis/api/` |

### Бэкенд

| Компонент | Выбор |
|-----------|-------|
| Язык | **Kotlin** |
| Фреймворк | **Spring Boot 3** |
| Web / REST | Spring Web |
| БД / ORM | Spring Data JPA + **PostgreSQL** |
| Миграции | Flyway |
| Security / JWT | Spring Security |
| Документация API | springdoc-openapi (сверка с `01-analysis/api/`) |
| Push (сервер) | Firebase Admin SDK |
| Напоминания 24ч / 2ч | `@Scheduled` |
| Тесты | JUnit 5 + Testcontainers |

### Домены API (реализация бэкенда)

`auth` · `profile` · `slots` · `bookings` · `instructors` — по структуре `01-analysis/api/`.

### Не в стеке (осознанно)

- Go — отложен (больше ручной работы с транзакциями при AI-генерации).
- Отдельные бэкенды под iOS/Android — не нужны.
- PWA / React Native — не выбраны (нативный mobile-first + push по ТЗ).

### Цель реализации

MVP мобильного приложения «Вертикаль» с функциональной проверкой по UC-1…UC-6; автотесты API (createBooking 201/409/410) + integration tests Flutter. 