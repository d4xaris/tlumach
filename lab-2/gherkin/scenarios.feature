# language: uk
Функціонал: Замовлення перекладу на платформі Tlumach

  Передумова:
    Дано в довіднику Language є мови "uk" і "en"
    І є Translator, який знає мови "uk" і "en"

  @G01 @FR-002 @FR-003 @FR-004 @FR-005 @FR-007 @FR-008
  Сценарій: Client створює замовлення з коректним документом
    Дано Client завантажив .docx із 1000 слів
    Коли Client обирає source_language "uk", target_language "en" і підтверджує замовлення
    Тоді створено Document з word_count 1000
    І створено Order зі статусом "created" і призначеним Mediator
    І в Order.rate_per_word записано чинну ставку платформи 0.50
    І створено Payment типу "first_half" зі статусом "pending", due_date дорівнює даті created_at, сума 250

  @G02 @FR-001
  Сценарій: Файл не у форматі .docx відхиляється
    Коли Client завантажує файл "contract.pdf"
    Тоді система відхиляє файл і повідомляє про помилку формату
    І Document не створюється

  @G03 @FR-006
  Сценарій: Однакові мови в парі відхиляються
    Коли Client обирає source_language "en" і target_language "en"
    Тоді система відхиляє створення Order

  @G04 @FR-009
  Сценарій: Успішна оплата першої половини
    Дано є Order зі статусом "created" і Payment "first_half" зі статусом "pending"
    Коли Payment Service підтверджує оплату
    Тоді Payment отримує статус "paid" і заповнений paid_at

  @G05 @FR-010
  Сценарій: Відмова в оплаті не змінює статус платежу
    Дано є Payment "first_half" зі статусом "pending"
    Коли Payment Service повідомляє про відмову в оплаті
    Тоді Payment лишається зі статусом "pending"
    І Client може повторити спробу

  @G06 @FR-011
  Сценарій: Розсилка запитів без сплаченої першої половини відхиляється
    Дано є Order зі статусом "created", Payment "first_half" має статус "pending"
    Коли Mediator розсилає запити
    Тоді система відхиляє розсилку
    І жоден Request не створюється

  @G07 @FR-012 @FR-013
  Сценарій: Mediator розсилає запити відповідним перекладачам
    Дано є Order зі статусом "created", Payment "first_half" має статус "paid"
    І є Translator "A", який знає "uk" і "en", та Translator "B", який знає лише "en"
    Коли Mediator розсилає запити
    Тоді створено Request зі статусом "pending" лише для Translator "A"
    І Order отримує статус "sent_to_translators"

  @G08 @FR-015 @FR-016
  Сценарій: Translator приймає запит
    Дано є Request зі статусом "pending" для Order зі статусом "sent_to_translators"
    Коли Translator приймає Request
    Тоді Request отримує статус "accepted" і заповнений responded_at
    І Order отримує статус "in_progress"

  @G09 @FR-017
  Сценарій: Другий запит того ж замовлення прийняти не можна
    Дано Order має Request зі статусом "accepted"
    І є інший Request цього Order зі статусом "pending"
    Коли інший Translator намагається прийняти свій Request
    Тоді система відхиляє спробу
    І в Order лишається один Request зі статусом "accepted"

  @G10 @FR-018
  Сценарій: Translator відхиляє запит
    Дано є Request зі статусом "pending"
    Коли Translator відхиляє Request
    Тоді Request отримує статус "rejected" і заповнений responded_at

  @G11 @FR-019 @FR-020 @FR-021 @FR-022
  Сценарій: Редагування та готовність замовлення
    Дано є Order зі статусом "in_progress"
    Коли Mediator призначає Editor
    Тоді Order отримує editor_id і статус "in_editing"
    Коли Editor завантажує результат "result.docx"
    Тоді в Order заповнені result_file_name і result_uploaded_at
    Коли Mediator позначає Order як готовий
    Тоді Order отримує статус "ready"
    І створено Payment типу "second_half" зі статусом "pending" і due_date

  @G12 @FR-023
  Сценарій: Результат не видається без другої оплати
    Дано є Order зі статусом "ready", Payment "second_half" має статус "pending"
    Коли Client запитує результат
    Тоді система відмовляє в доступі до результату

  @G13 @FR-009 @FR-024 @FR-025
  Сценарій: Друга оплата, видача результату та закриття
    Дано є Order зі статусом "ready", Payment "second_half" має статус "pending"
    Коли Payment Service підтверджує оплату Payment "second_half"
    Тоді Payment отримує статус "paid"
    Коли Mediator підтверджує оплату
    Тоді Order отримує статус "confirmed" і Client отримує доступ до результату
    Коли Mediator закриває Order
    Тоді Order отримує статус "closed"

  @G14 @FR-026 @FR-027
  Сценарій: Скасування, якщо ніхто не взявся за переклад
    Дано є Order зі статусом "sent_to_translators", усі Request мають статус "rejected"
    І Payment "first_half" має статус "paid"
    Коли Mediator скасовує Order
    Тоді Order отримує статус "cancelled"
    І система запитує в Payment Service повернення першої половини
    Коли Payment Service підтверджує повернення
    Тоді Payment "first_half" отримує статус "refunded"

  @G15 @FR-028 @FR-029
  Сценарій: Прострочена друга оплата та скасування
    Дано є Order зі статусом "ready", Payment "second_half" має статус "pending"
    Коли поточна дата перевищує due_date
    Тоді Payment "second_half" отримує статус "overdue"
    Коли від due_date минуло N днів і Mediator скасовує Order
    Тоді Order отримує статус "cancelled"
    І Payment "first_half" лишається зі статусом "paid"

  @G16 @FR-030 @FR-031
  Сценарій: Mediator додає мову і пов'язує її з Translator
    Коли Mediator додає мову "de" в довідник
    І позначає, що Translator "A" знає мову "de"
    Тоді в Language є запис "de"
    І Translator "A" пов'язаний з Language "de"

  @G17 @FR-032
  Сценарій: Client бачить статус свого замовлення
    Дано є Order Client'а зі статусом "in_progress"
    Коли Client відкриває своє замовлення
    Тоді система показує статус "in_progress"