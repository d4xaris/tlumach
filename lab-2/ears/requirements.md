# Вимоги (EARS): платформа Tlumach

Пов'язано зі `spec.md`. Назви сутностей, атрибутів і статусів як у моделі Завдання 1. Кожна вимога має мітку форми EARS.

## Створення замовлення

- **FR-001** [Unwanted]: ЯКЩО Client завантажує файл не у форматі .docx, ТО система ПОВИННА відхилити файл і повідомити про помилку формату.
- **FR-002** [Event-driven]: КОЛИ Client завантажує .docx, система ПОВИННА створити Document із `word_count`, розрахованим із вмісту файлу.
- **FR-003** [Event-driven]: КОЛИ Client підтверджує замовлення з Document, `source_language_id` і `target_language_id`, система ПОВИННА створити Order зі статусом `created`.
- **FR-004** [Ubiquitous]: Система ПОВИННА записувати в `Order.rate_per_word` чинну ставку платформи під час створення Order і не змінювати це значення надалі.
- **FR-005** [Event-driven]: КОЛИ створюється Order, система ПОВИННА призначити йому Mediator.
- **FR-006** [Unwanted]: ЯКЩО `source_language_id` дорівнює `target_language_id`, ТО система ПОВИННА відхилити створення Order.

## Оплата першої половини

- **FR-007** [Event-driven]: КОЛИ створено Order, система ПОВИННА створити Payment типу `first_half` зі статусом `pending` і `due_date`, що дорівнює даті `created_at`.
- **FR-008** [Ubiquitous]: Сума кожного Payment ПОВИННА дорівнювати 50% від `word_count` × `rate_per_word`.
- **FR-009** [Event-driven]: КОЛИ Payment Service підтверджує оплату Payment, система ПОВИННА встановити йому статус `paid` і `paid_at`.
- **FR-010** [Unwanted]: ЯКЩО Payment Service повідомляє про відмову в оплаті, ТО система ПОВИННА залишити Payment зі статусом `pending` і дозволити повторну спробу. [D-2]
- **FR-011** [Unwanted]: ЯКЩО Mediator розсилає запити для Order, у якого Payment `first_half` не має статусу `paid`, ТО система ПОВИННА відхилити розсилку.

## Пошук виконавця

- **FR-012** [Event-driven]: КОЛИ Mediator розсилає запити для Order, система ПОВИННА створити Request зі статусом `pending` для кожного Translator, який знає і `source_language_id`, і `target_language_id`.
- **FR-013** [Event-driven]: КОЛИ Mediator розсилає запити для Order зі статусом `created`, система ПОВИННА встановити Order статус `sent_to_translators`.
- **FR-014** [Ubiquitous]: Система ПОВИННА гарантувати унікальність пари `order_id` + `translator_id` у Request.
- **FR-015** [Event-driven]: КОЛИ Translator приймає Request зі статусом `pending`, система ПОВИННА встановити Request статус `accepted` і `responded_at`.
- **FR-016** [Event-driven]: КОЛИ Request отримує статус `accepted`, система ПОВИННА встановити Order статус `in_progress`. [D-6]
- **FR-017** [Unwanted]: ЯКЩО Order уже має Request зі статусом `accepted`, ТО система ПОВИННА відхилити спробу прийняти інший Request цього Order. [D-3]
- **FR-018** [Event-driven]: КОЛИ Translator відхиляє Request, система ПОВИННА встановити Request статус `rejected` і `responded_at`.

## Редагування та результат

- **FR-019** [Event-driven]: КОЛИ Mediator призначає Editor для Order зі статусом `in_progress`, система ПОВИННА записати `editor_id` і встановити Order статус `in_editing`.
- **FR-020** [Event-driven]: КОЛИ Editor завантажує результат, система ПОВИННА записати `result_file_name` і `result_uploaded_at`. [D-1]
- **FR-021** [Event-driven]: КОЛИ Mediator позначає Order зі статусом `in_editing` як готовий, система ПОВИННА встановити Order статус `ready`.
- **FR-022** [Event-driven]: КОЛИ Order отримує статус `ready`, система ПОВИННА створити Payment типу `second_half` зі статусом `pending` і `due_date`. [D-7]

## Оплата другої половини та видача

- **FR-023** [Unwanted]: ЯКЩО Client запитує результат, а Payment `second_half` не має статусу `paid`, ТО система ПОВИННА відмовити в доступі до результату.
- **FR-024** [Event-driven]: КОЛИ Mediator підтверджує Payment `second_half` зі статусом `paid`, система ПОВИННА встановити Order статус `confirmed` і надати Client доступ до результату.
- **FR-025** [Event-driven]: КОЛИ Mediator закриває Order зі статусом `confirmed`, система ПОВИННА встановити статус `closed`.

## Скасування та повернення

- **FR-026** [Event-driven]: КОЛИ Mediator скасовує Order, що не має жодного Request зі статусом `accepted`, система ПОВИННА встановити Order статус `cancelled` і запросити в Payment Service повернення Payment `first_half`. [D-4]
- **FR-027** [Event-driven]: КОЛИ Payment Service підтверджує повернення, система ПОВИННА встановити Payment статус `refunded`.
- **FR-028** [Event-driven]: КОЛИ поточна дата перевищує `due_date` Payment `second_half` зі статусом `pending`, система ПОВИННА встановити йому статус `overdue`.
- **FR-029** [Event-driven]: КОЛИ Mediator скасовує Order, у якого Payment `second_half` має статус `overdue`, а від `due_date` минуло N днів, система ПОВИННА встановити Order статус `cancelled` і залишити Payment `first_half` зі статусом `paid`. [D-5]

## Довідник і перегляд

- **FR-030** [Event-driven]: КОЛИ Mediator додає мову, система ПОВИННА створити Language.
- **FR-031** [Event-driven]: КОЛИ Mediator позначає, що Translator знає мову, система ПОВИННА зберегти цей зв'язок між Translator і Language.
- **FR-032** [Event-driven]: КОЛИ Client відкриває своє замовлення, система ПОВИННА показати поточний `status` Order.