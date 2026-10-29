# language: uk
@UC-05
Функціонал: Розсилка запитів перекладачам
  Як Mediator,
  я хочу розіслати запити перекладачам, які знають обидві мови пари,
  щоб хтось із них узявся за переклад.

  Передумова:
    Дано в довіднику Language є мови "uk", "en" і "de"
    І Translator "A" знає "uk" і "en"
    І Translator "B" знає лише "en"
    І Translator "C" знає "uk" і "en"

  @G01 @FR-003 @FR-004
  Сценарій: Основний. Запити йдуть лише тим, хто знає обидві мови
    Дано є Order зі статусом "created", source_language "uk", target_language "en"
    І Payment "first_half" цього Order має статус "paid"
    Коли Mediator розсилає запити
    Тоді створено Request зі статусом "pending" для Translator "A" і "C"
    І для Translator "B" Request не створено
    І Order отримує статус "sent_to_translators"

  @G02 @FR-001
  Сценарій: Помилковий. Перша половина не сплачена
    Дано є Order зі статусом "created"
    І Payment "first_half" цього Order має статус "pending"
    Коли Mediator розсилає запити
    Тоді система відхиляє розсилку
    І жоден Request не створено
    І Order лишається зі статусом "created"

  @G03 @FR-006
  Сценарій: Крайовий. Немає жодного підходящого Translator
    Дано є Order зі статусом "created", source_language "uk", target_language "de"
    І Payment "first_half" цього Order має статус "paid"
    Коли Mediator розсилає запити
    Тоді жоден Request не створено
    І Order лишається зі статусом "created"
    І Mediator бачить повідомлення, що для пари "uk" → "de" немає перекладачів

  @G04 @FR-003 @FR-004 @FR-005
  Сценарій: Крайовий. Повторна розсилка не дублює запити
    Дано є Order зі статусом "sent_to_translators", source_language "uk", target_language "en"
    І Translator "A" і "C" мають Request зі статусом "pending" для цього Order
    І Translator "D" щойно додано, він знає "uk" і "en"
    Коли Mediator розсилає запити ще раз
    Тоді для Translator "D" створено Request зі статусом "pending"
    І Translator "A" і "C" не отримують другого Request
    І Order має 3 Request і статус "sent_to_translators"

  @G05 @FR-002
  Сценарій: Помилковий. Розсилка для Order, який уже в роботі
    Дано є Order зі статусом "in_progress"
    Коли Mediator розсилає запити
    Тоді система відхиляє розсилку
    І нових Request не створено