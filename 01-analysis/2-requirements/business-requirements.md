# Бизнес-требования

> Этап 2. Зачем бизнесу продукт: цели, метрики успеха, ограничения верхнего уровня.
>
> **Трассировка:** [traceability-matrix.md](traceability-matrix.md) — сквозная цепочка
> Бриф → Q → Домен → BR → FR/NFR → US → UC.

> **Скоуп — клиентское мобильное приложение и API для него.** Бизнес-цели, обслуживаемые
> существующей инфраструктурой (админка владельца, интерфейс инструктора, отметка оплаты,
> оценки инструкторов), в этот список не входят.

| ID | Требование | Приоритет | Бриф | Q | Домен | ↓ дочерние |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| BR-1 | Устранить ручную путаницу и двойные брони, возникающие при ведении записи через Telegram и тетрадь. Учёт записей должен вестись в единой системе, исключающей конфликты по местам. | Must | [§L15–16](../0-customer-brief/brief-climbing.md) | — | [§Процесс](../1-elicitation/domain-description.md), [§Цель](../1-elicitation/domain-description.md) | M-2; [FR-9](functional-requirements.md), [FR-10](functional-requirements.md); [NFR-3](non-functional-requirements.md), [NFR-5](non-functional-requirements.md); [US-7](user-stories.md); [UC-3](use-cases.md) |
| BR-2 | Дать клиентам возможность самостоятельно записываться на тренировки онлайн без ручного посредничества владельца («люди сами записываются, а я только смотрю»). | Must | [§L17](../0-customer-brief/brief-climbing.md) | [Q-20](../1-elicitation/customer-questions.md) | [§Цель](../1-elicitation/domain-description.md) | M-1; [FR-6](functional-requirements.md); [US-5](user-stories.md); [UC-3](use-cases.md) |
| BR-3 | Снизить простой мест в группе из-за поздних отмен за счёт правила отмены за 2 часа и фиксации поздних отмен без штрафов (контроль без отталкивания клиентов). | Must | [§L25–26](../0-customer-brief/brief-climbing.md) | [Q-7](../1-elicitation/customer-questions.md), [Q-8](../1-elicitation/customer-questions.md) | [§Политика отмен](../1-elicitation/domain-description.md) | M-3; [FR-13](functional-requirements.md)–[FR-15](functional-requirements.md); [NFR-6](non-functional-requirements.md); [US-10](user-stories.md); [UC-4](use-cases.md) |
| BR-4 | Обеспечить прозрачность записи: клиент видит состав слота (время, зона/формат, инструктор, места, цена) и выбирает своё или прокатное снаряжение с учётом раздельных лимитов мест и прокатного фонда. | Must | [§L21–24](../0-customer-brief/brief-climbing.md) | [Q-1](../1-elicitation/customer-questions.md), [Q-2](../1-elicitation/customer-questions.md), [Q-5](../1-elicitation/customer-questions.md) | [§Процесс](../1-elicitation/domain-description.md), [§Объекты](../1-elicitation/domain-description.md) | [FR-3](functional-requirements.md)–[FR-9](functional-requirements.md); [US-2](user-stories.md)–[US-7](user-stories.md); [UC-2](use-cases.md), [UC-3](use-cases.md) |
| BR-5 | Запустить продукт к началу следующего сезона (жёсткий срок ~2 месяца) при ограниченном бюджете, начав с MVP: расписание, запись одного места, отмены, push-напоминания, отображение цены. | Must | [§L30](../0-customer-brief/brief-climbing.md), [§L37–38](../0-customer-brief/brief-climbing.md) | [Q-16](../1-elicitation/customer-questions.md), [Q-19](../1-elicitation/customer-questions.md), [Q-20](../1-elicitation/customer-questions.md) | [§Проект](../1-elicitation/domain-description.md), [§MVP](../1-elicitation/domain-description.md), [§Границы](../1-elicitation/domain-description.md) | M-4; [FR-17](functional-requirements.md); [NFR-8](non-functional-requirements.md), [NFR-11](non-functional-requirements.md), [NFR-12](non-functional-requirements.md); [US-12](user-stories.md); [UC-6](use-cases.md) |
| BR-6 | На старте оплата остаётся офлайн (наличные / перевод на карту на месте); продукт показывает цену и фиксирует бронь. Онлайн-оплата — Phase 2. | Must | [§L31](../0-customer-brief/brief-climbing.md) | [Q-9](../1-elicitation/customer-questions.md), [Q-11](../1-elicitation/customer-questions.md) | [§Оплата офлайн](../1-elicitation/domain-description.md), [§Границы](../1-elicitation/domain-description.md) | [FR-11](functional-requirements.md); [US-8](user-stories.md); [UC-3](use-cases.md) |

## Метрики успеха

> Целевые значения — ориентиры для MVP; точные пороги уточняются при наличии данных.

| ID | Метрика | Целевой ориентир | Бриф | Q | Домен | ↑ BR |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| M-1 | Доля записей, сделанных клиентами онлайн самостоятельно (от общего числа записей за сезон). | Рост относительно текущего уровня (Telegram + тетрадь) | [§L17](../0-customer-brief/brief-climbing.md) | [Q-20](../1-elicitation/customer-questions.md) | [§Цель](../1-elicitation/domain-description.md) | BR-2 |
| M-2 | Число двойных броней / конфликтов по местам. | 0 (полное устранение; гарантия на стороне бэкенда, R-004) | [§L15–16](../0-customer-brief/brief-climbing.md) | — | [§R-004](../1-elicitation/domain-description.md) | BR-1 |
| M-3 | Доля поздних отмен от числа записанных на тренировку. | Снижение относительно текущего уровня за счёт правила 2 часов и напоминаний | [§L25–26](../0-customer-brief/brief-climbing.md), [§L30](../0-customer-brief/brief-climbing.md) | [Q-7](../1-elicitation/customer-questions.md), [Q-16](../1-elicitation/customer-questions.md) | [§Политика отмен](../1-elicitation/domain-description.md), [§Напоминания](../1-elicitation/domain-description.md) | BR-3, BR-5 |
| M-4 | Готовность к старту сезона. | Запуск к началу сезона (~2 месяца) с MVP-набором (расписание, запись, отмены, push, цена) | [§L37–38](../0-customer-brief/brief-climbing.md) | [Q-20](../1-elicitation/customer-questions.md) | [§Проект](../1-elicitation/domain-description.md), [§MVP](../1-elicitation/domain-description.md) | BR-5 |

## Ограничения верхнего уровня

| Ограничение | Бриф | Q | Домен |
| :-- | :-- | :-- | :-- |
| Срок и бюджет (~2 месяца, MVP-подход) | [§L37–38](../0-customer-brief/brief-climbing.md) | [Q-20](../1-elicitation/customer-questions.md) | [§Проект](../1-elicitation/domain-description.md) |
| Одна запись = один клиент | — | [Q-3](../1-elicitation/customer-questions.md) | [§Один клиент](../1-elicitation/domain-description.md) |
| Оплата офлайн; статус «оплачено» — в админке | [§L31](../0-customer-brief/brief-climbing.md) | [Q-9](../1-elicitation/customer-questions.md), [Q-10](../1-elicitation/customer-questions.md) | [§Оплата офлайн](../1-elicitation/domain-description.md), [§Границы](../1-elicitation/domain-description.md) |
| Mobile-first + API | [§L35](../0-customer-brief/brief-climbing.md) | [Q-19](../1-elicitation/customer-questions.md) | [§Технические](../1-elicitation/domain-description.md) |
| Вне скоупа: админка, инструктор, оценки, лояльность, онлайн-оплата | [§L27](../0-customer-brief/brief-climbing.md), [§L33](../0-customer-brief/brief-climbing.md), [§L35–36](../0-customer-brief/brief-climbing.md) | [Q-11](../1-elicitation/customer-questions.md)–[Q-15](../1-elicitation/customer-questions.md), [Q-18](../1-elicitation/customer-questions.md) | [§Границы](../1-elicitation/domain-description.md) |
