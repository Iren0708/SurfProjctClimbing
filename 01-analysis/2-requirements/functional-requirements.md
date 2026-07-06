# Функциональные требования

> Этап 2. Что система должна делать (функции, поведение).
> Не путать с нефункциональными ([non-functional-requirements.md](non-functional-requirements.md)).
>
> **Трассировка:** [traceability-matrix.md](traceability-matrix.md).

Приоритеты по MoSCoW: **Must** — обязательно к запуску (MVP); **Should** — желательно при наличии времени; **Won't** — вне границ скоупа / Phase 2.

> **Скоуп — клиентское мобильное приложение и API для него.** Функции инструктора, владельца
> и администратора обеспечиваются **существующей инфраструктурой** и здесь не описываются.

## Границы скоупа (клиентское приложение + API)

- **Слоты, зоны/форматы и инструкторы** поступают из существующего бэкенда через API (read-only). *(Бриф [§уточн:R-028](../0-customer-brief/brief-climbing.md); Q-4, Q-19; Домен §Технические)*
- Экранов создания и редактирования расписания в клиентском приложении нет.

## Авторизация (клиент)

| ID | Требование | Приоритет | Бриф | Q | Домен | ↑ BR | ↓ US | ↓ UC |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| FR-1 | Система должна позволять клиенту пройти лёгкую регистрацию, указав имя и номер телефона, без сложных паролей. | Must | — | [Q-6](../1-elicitation/customer-questions.md) | [§Клиент](../1-elicitation/domain-description.md), [§Границы](../1-elicitation/domain-description.md) | — | [US-1](user-stories.md) | [UC-1](use-cases.md) |
| FR-2 | Система должна авторизовать клиента по номеру телефона (SMS-код или аналог). | Must | — | [Q-6](../1-elicitation/customer-questions.md) | [§Границы](../1-elicitation/domain-description.md) | — | [US-1](user-stories.md) | [UC-1](use-cases.md) |

## Просмотр и фильтрация слотов (клиент)

| ID | Требование | Приоритет | Бриф | Q | Домен | ↑ BR | ↓ US | ↓ UC |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| FR-3 | Система должна показывать клиенту список предстоящих слотов на **ближайшие 7 дней** от текущего момента (R-027). Более длинный период — через фильтр дат. Состав слота в списке: дата/время старта, зона/формат, инструктор, всего мест, свободно мест, цена. При отсутствии слотов — empty state «Пока нет доступных тренировок». | Must | [§L23](../0-customer-brief/brief-climbing.md), [§уточн:R-027](../0-customer-brief/brief-climbing.md) | [Q-5](../1-elicitation/customer-questions.md) | [§Период слотов](../1-elicitation/domain-description.md), [§Слот](../1-elicitation/domain-description.md) | BR-4 | [US-2](user-stories.md) | [UC-2](use-cases.md) |
| FR-4 | Система должна позволять клиенту фильтровать список слотов по дате/периоду, типу тренировки (зона/формат), наличию свободных мест и инструктору. | Must | [§L23](../0-customer-brief/brief-climbing.md) | [Q-5](../1-elicitation/customer-questions.md) | [§Границы](../1-elicitation/domain-description.md) | BR-4 | [US-3](user-stories.md) | [UC-2](use-cases.md) |
| FR-5 | Система должна показывать клиенту карточку слота со всеми параметрами: дата/время, зона/формат (в т.ч. длительность тренировки), инструктор, всего/свободно мест, цена, доступность прокатного снаряжения. | Must | [§L21](../0-customer-brief/brief-climbing.md), [§L23](../0-customer-brief/brief-climbing.md) | [Q-5](../1-elicitation/customer-questions.md) | [§Зона/Формат](../1-elicitation/domain-description.md), [§Слот](../1-elicitation/domain-description.md) | BR-4 | [US-4](user-stories.md) | [UC-3](use-cases.md) |

## Запись на тренировку (клиент)

| ID | Требование | Приоритет | Бриф | Q | Домен | ↑ BR | ↓ US | ↓ UC |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| FR-6 | Система должна позволять клиенту записаться на выбранный слот, забронировав **одно место** (одна запись = один клиент). | Must | [§L24](../0-customer-brief/brief-climbing.md) | [Q-3](../1-elicitation/customer-questions.md) | [§Бронь](../1-elicitation/domain-description.md), [§Один клиент](../1-elicitation/domain-description.md) | BR-2, BR-4 | [US-5](user-stories.md) | [UC-3](use-cases.md) |
| FR-7 | Система должна позволять клиенту при записи выбрать вариант снаряжения: **своё** или **прокатное** (скальники, страховочная система). | Must | [§L24](../0-customer-brief/brief-climbing.md) | [Q-2](../1-elicitation/customer-questions.md) | [§Снаряжение](../1-elicitation/domain-description.md) | BR-4 | [US-6](user-stories.md) | [UC-3](use-cases.md) |
| FR-8 | При записи клиент указывает вариант снаряжения (своё / прокатное); бэкенд проверяет **раздельно** лимит мест в группе и лимит прокатного фонда: своё снаряжение занимает место в группе, но не прокатный фонд. | Must | [§L24](../0-customer-brief/brief-climbing.md) | [Q-2](../1-elicitation/customer-questions.md) | [§Лимит проката](../1-elicitation/domain-description.md) | BR-4 | [US-6](user-stories.md) | [UC-3](use-cases.md) |
| FR-9 | При бронировании бэкенд отклоняет запись, если превышен лимит мест `min(потолок типа тренировки, свободные места в слоте)` (новичковый ≤ 8, опытный ≤ 16) или нет свободного прокатного снаряжения (при выборе проката); клиентское приложение отображает результат проверки. | Must | [§L23](../0-customer-brief/brief-climbing.md) | [Q-1](../1-elicitation/customer-questions.md), [Q-2](../1-elicitation/customer-questions.md) | [§Лимит мест](../1-elicitation/domain-description.md), [§Лимит проката](../1-elicitation/domain-description.md) | BR-1, BR-4 | [US-7](user-stories.md) | [UC-3](use-cases.md) |
| FR-10 | Клиентское приложение при бронировании полагается на ответы бэкенда (R-004) и корректно обрабатывает отказ, если мест или прокатного снаряжения уже нет; гарантия «0 двойных броней» обеспечивается на стороне бэкенда. | Must | [§L15–16](../0-customer-brief/brief-climbing.md), [§уточн:R-004](../0-customer-brief/brief-climbing.md) | — | [§R-004](../1-elicitation/domain-description.md) | BR-1 | [US-7](user-stories.md) | [UC-3](use-cases.md) |
| FR-11 | Система должна показывать клиенту цену тренировки и фиксировать бронь; оплата производится офлайн (наличные / перевод на карту на месте). | Must | [§L31](../0-customer-brief/brief-climbing.md) | [Q-9](../1-elicitation/customer-questions.md) | [§Оплата](../1-elicitation/domain-description.md), [§MVP](../1-elicitation/domain-description.md) | BR-6 | [US-8](user-stories.md) | [UC-3](use-cases.md) |

## Мои бронирования и отмены (клиент)

| ID | Требование | Приоритет | Бриф | Q | Домен | ↑ BR | ↓ US | ↓ UC |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| FR-12 | Система должна показывать клиенту список своих бронирований с актуальным статусом и параметрами слота (дата/время, зона/формат, инструктор, вариант снаряжения). | Must | [§L17](../0-customer-brief/brief-climbing.md) | [Q-20](../1-elicitation/customer-questions.md) | [§Цель](../1-elicitation/domain-description.md) | BR-2 | [US-9](user-stories.md) | [UC-4](use-cases.md), [UC-5](use-cases.md) |
| FR-13 | Система должна позволять клиенту отменить свою запись до старта тренировки. | Must | [§L25](../0-customer-brief/brief-climbing.md) | [Q-7](../1-elicitation/customer-questions.md) | [§Отмена](../1-elicitation/domain-description.md) | BR-3 | [US-10](user-stories.md) | [UC-4](use-cases.md) |
| FR-14 | Система должна при отмене не позднее чем за **2 часа** до старта освобождать забронированное место (и прокатный фонд, если бронировался прокат). | Must | [§L25](../0-customer-brief/brief-climbing.md) | [Q-7](../1-elicitation/customer-questions.md) | [§Политика отмен](../1-elicitation/domain-description.md) | BR-3 | [US-10](user-stories.md) | [UC-4](use-cases.md) |
| FR-15 | Система должна при поздней отмене (менее чем за 2 часа до старта) фиксировать запись статусом поздней отмены без денежных штрафов; место не освобождается. | Must | [§L25–26](../0-customer-brief/brief-climbing.md) | [Q-8](../1-elicitation/customer-questions.md) | [§Политика отмен](../1-elicitation/domain-description.md) | BR-3 | [US-10](user-stories.md) | [UC-4](use-cases.md) |
| FR-16 | Система должна отображать брони, отменённые скалодромом: бронь не удаляется, переходит в статус **«Отменена скалодромом»** с указанием причины; повторная запись на этот слот запрещена. | Must | [§L32](../0-customer-brief/brief-climbing.md), [§уточн:R-008](../0-customer-brief/brief-climbing.md) | [Q-17](../1-elicitation/customer-questions.md) | [§Отмена скалодромом](../1-elicitation/domain-description.md) | — | [US-9](user-stories.md), [US-11](user-stories.md) | [UC-5](use-cases.md) |
| FR-17 | Система должна напоминать клиенту о предстоящей записи через системный push **за 24 ч и за 2 ч** до старта (`reminder_hours = [24, 2]`, R-006). | Must | [§L30](../0-customer-brief/brief-climbing.md), [§уточн:R-006](../0-customer-brief/brief-climbing.md) | [Q-16](../1-elicitation/customer-questions.md) | [§Напоминания](../1-elicitation/domain-description.md) | BR-5 | [US-12](user-stories.md) | [UC-6](use-cases.md) |
| FR-18 | Система должна отправлять клиенту push-уведомление при отмене тренировки скалодромом (в т.ч. из-за профилактики). | Must | [§L32](../0-customer-brief/brief-climbing.md), [§уточн:R-008](../0-customer-brief/brief-climbing.md) | [Q-17](../1-elicitation/customer-questions.md) | [§Отмена скалодромом](../1-elicitation/domain-description.md) | — | [US-11](user-stories.md) | [UC-5](use-cases.md) |

---

## Вне скоупа (Won't / Phase 2)

| ID | Требование | Приоритет | Бриф | Q | Домен |
| :-- | :-- | :-- | :-- | :-- | :-- |
| FR-W1 | Групповая бронь: запись нескольких людей одним аккаунтом. | Won't | — | [Q-3](../1-elicitation/customer-questions.md) | [§Один клиент](../1-elicitation/domain-description.md) |
| FR-W2 | Онлайн-оплата в клиентском приложении. | Won't (Phase 2) | [§L31](../0-customer-brief/brief-climbing.md) | [Q-11](../1-elicitation/customer-questions.md) | [§Границы](../1-elicitation/domain-description.md) |
| FR-W3 | Оценка инструктора (звёзды 1–5, без текста) и публичный рейтинг. | Won't (Phase 2) | [§L27](../0-customer-brief/brief-climbing.md) | [Q-12](../1-elicitation/customer-questions.md), [Q-13](../1-elicitation/customer-questions.md), [Q-20](../1-elicitation/customer-questions.md) | [§Границы](../1-elicitation/domain-description.md), [§MVP](../1-elicitation/domain-description.md) |
| FR-W4 | Программа лояльности для постоянных клиентов. | Won't (Phase 2) | [§L33](../0-customer-brief/brief-climbing.md) | [Q-18](../1-elicitation/customer-questions.md) | [§Границы](../1-elicitation/domain-description.md) |
| FR-W5 | Создание/редактирование расписания, отметка оплаты, явка/неявка, управление инструкторами. | Won't (инфраструктура) | [§L35–36](../0-customer-brief/brief-climbing.md) | [Q-4](../1-elicitation/customer-questions.md), [Q-10](../1-elicitation/customer-questions.md), [Q-14](../1-elicitation/customer-questions.md), [Q-15](../1-elicitation/customer-questions.md) | [§Роли](../1-elicitation/domain-description.md), [§Границы](../1-elicitation/domain-description.md) |
| FR-W6 | Напоминания по SMS, WhatsApp, email. | Won't (Phase 2) | — | [Q-16](../1-elicitation/customer-questions.md) | [§Напоминания](../1-elicitation/domain-description.md) |
| FR-W7 | Автоматический учёт профилактики по календарю. | Won't (Phase 2) | [§L32](../0-customer-brief/brief-climbing.md) | [Q-17](../1-elicitation/customer-questions.md) | [§Границы](../1-elicitation/domain-description.md) |
