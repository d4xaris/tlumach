# Спека: машина станів життєвого циклу Order

Гілка lab-4-state-machine, статус: чернетка.

## Намір

У Завданні 2 я розібрала UC-05 і сусідні UC. Тут показую, як Order проходить увесь життєвий цикл: з яких станів у які переходить, хто це робить і де хід розгалужується. Форма одна: Mermaid stateDiagram-v2. Назви станів беру з Order.status із Завдання 1 без змін. Номери UC беру з поточного use-cases.md.

## Стани

created, sent_to_translators, in_progress, in_editing, ready, confirmed, closed, cancelled. Стан second_payment_overdue похідний: береться з Payment.status = overdue, нове поле в Order не додаю.

ready означає «редагування завершене, друга оплата ще попереду». Payment second_half створюється, коли Order отримує ready (FR-022), тому ready і є очікуванням другої оплати (G12).

## Переходи

| № | З → У | Хто | UC | Умова |
|---|---|---|---|---|
| 1 | [*] → created | Client | UC-01 | замовлення створено |
| 2 | created → created | Mediator | UC-05 | перша половина не paid або немає перекладачів, розсилку відхилено |
| 3 | created → sent_to_translators | Mediator | UC-05 | перша половина paid і є перекладачі |
| 4 | sent_to_translators → in_progress | Translator | UC-06 | один Request accepted |
| 4a | sent_to_translators → sent_to_translators | Translator | UC-07 | Request rejected, інші ще відкриті |
| 5 | sent_to_translators → cancelled | Mediator | UC-13, UC-14 | ніхто не взявся, перша половина повертається |
| 6 | in_progress → in_editing | Mediator | UC-08 | призначено Editor |
| 7 | in_editing → ready | Mediator | UC-10 | редагування завершене, створюється Payment second_half |
| 8 | ready → confirmed | Mediator | UC-11, UC-12 | друга половина paid, результат виданий |
| 9 | ready → second_payment_overdue | система | без UC | минув due_date |
| 10 | second_payment_overdue → confirmed | Mediator | UC-11, UC-12 | клієнт сплатив, результат виданий |
| 11 | second_payment_overdue → cancelled | Mediator | UC-13 | скасовано після прострочення, перша половина лишається paid |
| 12 | confirmed → closed | Mediator | UC-12 | замовлення закрито |

## Розгалуження

Умови 2 і 3 взаємовиключні. Інші розгалуження: 4/4a/5, 8/9, 10/11. Fork/join немає: паралельної роботи в цьому процесі немає, друга оплата стартує після ready (FR-022, G12).

## Що не робимо

Окремий стан для повторної оплати першої половини (UC-04), сповіщення, сценарії інших UC.

## Критерії прийняття

- SC-001: кожен рядок таблиці має стрілку з тим самим номером, виконавцем і UC у state.mmd і state.svg, і навпаки.
- SC-002: назви станів збігаються з Order.status літера в літеру.
- SC-003: немає недосяжних станів і станів без виходу, крім closed і cancelled.
- SC-004: перехід 7 збігається з FR-022 і G12.

## Де діаграма не збігається з моделлю

- D-10: second_payment_overdue є статусом Payment, а не Order. У діаграмі він стоїть як стан, але нового статусу Order я не додавала.
- D-11: UC-12 покриває і confirmed, і closed, які в моделі окремі, тому переходи 8, 10 і 12 посилаються на нього.
- D-12: перехід 9 виконує система, UC для нього в Завданні 2 немає.
- D-13: за моделлю статуси змінює Mediator, а переходи 4 і 4a виконує Translator (UC-06, UC-07).