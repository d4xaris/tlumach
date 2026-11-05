# Аудит AI-виходу

## Мета

Перевірити, як AI допоміг зробити компонентну діаграму Tlumach, і звірити її з ER-моделлю (Завдання 1), вимогами та UC (Завдання 2), Sequence (Завдання 3) і машиною станів UC-12 (Завдання 4). Номери UC за поточним use-cases.md.

AI використовувався для `spec.md` (`ai/01-prompt-spec.md`) і діаграми `component.puml` (`ai/02-prompt-diagram.md`).

Що перевірялось:

* чи кожен компонент трасується до сутності ER, UC або вимоги;
* чи кожна залежність пояснюється кроком Sequence або переходом зі станів;
* чи межа системи чітка, а зовнішні компоненти лежать поза нею;
* чи кожен інтерфейс має provided і required;
* чи назви сутностей і статусів збігаються з моделлю літера в літеру.

---

## Трасування компонентів

| Компонент | Сутності ER | Вимоги | UC | Лаба 3 / лаба 4 |
|---|---|---|---|---|
| Web UI | | NFR-01, NFR-05 | UC-01…UC-17 | |
| Backend API | | NFR-06 | усі | |
| OrderService | Order | FR-004 | UC-01, 08, 10, 11, 13, 16 | `updateStatus` (G01), переходи 0, 1, 3, 4, 5 |
| RequestService | Request | FR-001…FR-006 | UC-05, 06, 07, 17 | G01-G05 |
| BillingService | Payment | FR-001 | UC-03, 04, 12, 14 | `getFirstHalfPayment`, переходи 1, 3 |
| DocumentService | Document | NFR-02 | UC-02, 09 | |
| CatalogService | Language, Translator–Language | FR-003 | UC-15 | `findByLanguages` |
| Scheduler | Payment (`due_date`, `status`) | | без UC | перехід 2 |
| Platform Config | | | | |
| Data Access | усі | | | |
| File Storage | Document.`file_name`, Order.`result_file_name` | NFR-02 | | |
| Database | усі, UNIQUE (`order_id`, `translator_id`) | FR-005, NFR-07 | | |

Усі дев'ять сутностей ER досяжні через Data Access і Database. Користувачі (Client, Translator, Editor, Mediator) окремого сервісу не мають, їх обслуговують OrderService і CatalogService.

## Трасування залежностей

| Залежність | Чому існує |
|---|---|
| RequestService → IBillingService | Sequence, `getFirstHalfPayment`: перевірка першої половини (FR-001) |
| RequestService → ICatalogService | Sequence, `findByLanguages`: Translator, що знають обидві мови (FR-003) |
| RequestService → IOrderService | Sequence, `getOrder` і `updateStatus`: статус `sent_to_translators` (FR-002, FR-004) |
| OrderService → IBillingService | перехід 0: створення Payment `second_half`; переходи 1 і 3: перевірка оплати; UC-14: повернення |
| OrderService → IDocumentService | `word_count` для ціни, результат редагування |
| OrderService → IConfig | `rate_per_word` при створенні Order, кількість днів N |
| Scheduler → IBillingService | перехід 2: `due_date` минув, Payment отримує `overdue` |
| BillingService → IPaymentGateway | UC-03, UC-14: оплата й повернення |
| Payment Service → IPaymentCallback | підтвердження або відмова в оплаті |
| DocumentService → IFileStorage | UC-02, UC-09: файли .docx і результат |
| сервісний шар → IRepository | усі читання й записи сутностей ER |
| Backend API → п'ять сервісів | кожен UC входить через API |

## Перевірка меж, інтерфейсів і назв

| Що перевірялось | Результат |
|---|---|
| Межа системи «Tlumach» чітко позначена | Так |
| Payment Service поза межею, має `<<external>>` | Так |
| Кожен інтерфейс має provided-компонент | Так, 11 з 11 |
| Кожен інтерфейс має хоча б один required | Так |
| Усі залежності діаграми є в таблиці «Інтерфейси» у `spec.md` | Так |
| Назви сутностей і статусів збігаються з ER літера в літеру | Так |
| Усі зміни `Order.status` проходять через OrderService | Так |
| Кожен UC досяжний через Backend API | Так |

---

## Розбіжність 1: хто змінює статус Order (D-14)

**Що виявлено.** У Sequence G01 статус `sent_to_translators` ставить RequestService, а за моделлю Завдання 1 статуси змінює Mediator (D-6 лаби 3).

**Рішення.** RequestService статус сам не змінює: він викликає IOrderService, і всі зміни `Order.status` лишаються в OrderService (AR-005). Модель і Sequence не змінювала.

**Посилання.** Spec: таблиця «Інтерфейси», IOrderService. Лаба 3: G01.

---

## Розбіжність 2: прострочення оплати без UC (D-15)

**Що виявлено.** У лабі 4 перехід 2 («минув `due_date`») виконує система, UC для нього немає (D-12). `second_payment_overdue` є статусом Payment, а не Order (D-10). Компонента, який це робить, у попередніх моделях немає.

**Рішення.** Додано Scheduler, який через IBillingService ставить Payment `overdue`. Нового статусу Order і нового UC не додавала.

**Посилання.** Spec: рядок Scheduler. Лаба 4: перехід 2.

---

## Розбіжність 3: компоненти без сутності в ER (D-16)

**Що виявлено.** Scheduler, Platform Config і File Storage є архітектурними рішеннями. Platform Config тримає `rate_per_word` і N днів, які ER виносить за межі даних замовлення. File Storage зберігає файли, а в ER є лише їхні імена.

**Рішення.** Компоненти залишено й позначено в `spec.md` як уточнення цієї лаби. Нових сутностей у модель не додавала.

**Посилання.** Spec: рядки Scheduler, Platform Config, File Storage.

---

## Що виправлено у виході AI

* Інтерфейс тепер підпис на стрілці з розеткою в required-компонента, окремих вузлів інтерфейсів немає.
* Сервіси згруповано в «Сервісний шар», п'ять ліній до репозиторію замінено однією.
* Під час групування зникла залежність RequestService → IBillingService, її відновлено.
* Прибрано Email Provider: він суперечив припущенню про спілкування поза системою.
* Лінії зроблено прямими (`linetype ortho`), бо хвилясті накладались.
* Номери UC оновлено за поточним use-cases.md, частину старих UC вилучено.
* Прибрано посилання на FR-007…FR-032: у `requirements.md` лишились лише FR-001…FR-006.
* Прибрано FR-022 і підстани `second_payment_wait` з fork/join: лаба 4 їх більше не містить.
* Власні вимоги лаби 5 названо AR-001…AR-005, щоб вони не збігались з FR-номерами.

## Відкрите

* Автентифікації й сповіщень (OAuth, Email, SMS) у попередніх моделях немає. Додавати їх не стала, щоб не вигадувати вимоги.
* IRepository іде від усього сервісного шару, хоча Platform Config і Scheduler самі до даних не звертаються.
* Backend API залежить від п'яти сервісів: це точка концентрації, прийнято як шлюз.
* Editor і Translator працюють через ті самі Web UI і Backend API, окремі кабінети не розділені.
* FR-005 (унікальність пари `order_id` + `translator_id`) забезпечує лише UNIQUE у Database.

## Висновок

Компонентна діаграма трасується до попередніх моделей: сутності ER покриті Data Access і Database, UC входять через Backend API, Sequence лаби 3 відтворюється залежностями RequestService, зміни статусів лаби 4 належать OrderService і Scheduler. Три розбіжності D-14…D-16 записані й пояснені. Модель, вимоги і UC не чіпала.