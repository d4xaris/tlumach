# Специфікація функціоналу: Component Diagram платформи Tlumach

**Гілка:** `lab-5-component-diagram`

**Створено:** 21.10.2026

**Статус:** Чернетка

**Вхідні дані:** ER-модель (Завдання 1), вимоги `ears/requirements.md` FR-001…FR-032 і матриця трасування (Завдання 2), Sequence UC-05 (Завдання 3), машина станів Order (Завдання 4).

## Намір

Показати архітектуру платформи Tlumach: компоненти, provided/required-інтерфейси, залежності, межу системи та зовнішні інтеграції. Кожен компонент трасується до сутностей ER, вимог FR, UC і станів. Реалізація, API-контракти та технології поза межами роботи.

## Межа системи

Усередині межі «Tlumach»: Web UI, Backend API, п'ять сервісів (OrderService, DocumentService, RequestService, BillingService, CatalogService), Scheduler, Platform Config, Data Access, File Storage, Database. Поза межею: користувачі (Client, Mediator, Translator, Editor) і Payment Service. Спілкування між ролями відбувається поза системою і не моделюється (припущення лаби 1).

## Компоненти

Колонка FR посилається на `requirements.md` із Завдання 2.

| Компонент | Відповідальність | Сутності ER | FR | UC |
|---|---|---|---|---|
| Web UI | Кабінети чотирьох ролей, показ статусу | | FR-032 | UC-01…UC-18 |
| Backend API | Єдина точка входу, перевірка ролей, маршрутизація до сервісів | | усі | усі |
| OrderService | Створення Order, призначення Mediator, фіксація `rate_per_word`, усі зміни `Order.status`, видача результату, скасування | Order | FR-003…006, 013, 016, 019, 021, 024, 025, 026, 029, 032 | UC-01, 09, 11, 12, 14, 15, 18 |
| DocumentService | Перевірка .docx, підрахунок `word_count`, збереження вихідного й результатного файлів | Document | FR-001, 002, 020 | UC-02, UC-10 |
| RequestService | Розсилка запитів, прийняття і відхилення, не більше одного `accepted` | Request | FR-011, 012, 014, 015, 017, 018 | UC-05, 07, 08 |
| BillingService | Payment, обчислення суми (50% ціни), статуси `paid`/`refunded`/`overdue`, обмін із Payment Service | Payment | FR-007…010, 022, 023, 027, 028 | UC-03, 04, 06, 13, 16 |
| CatalogService | Довідник мов, зв'язок Translator M:N Language, вибірка Translator за двома мовами | Language, Translator–Language | FR-012, 030, 031 | UC-17 |
| Scheduler | Виставляє `overdue` за `due_date` (уточнення цієї лаби) | | FR-028 | |
| Platform Config | Чинна ставка за слово, кількість днів N (уточнення цієї лаби) | | FR-004, 029 | |
| Data Access | Репозиторії всіх сутностей | усі | | |
| File Storage | Файли .docx і результати (уточнення цієї лаби) | Document.`file_name`, Order.`result_file_name` | FR-002, 020 | |
| Database | Реляційна схема з ER-моделі, UNIQUE (`order_id`, `translator_id`) у Request | усі | FR-014 | |

## Інтерфейси

| Інтерфейс | Provided | Required | Основні операції |
|---|---|---|---|
| IApi | Backend API | Web UI | команди й запити користувачів |
| IOrderService | OrderService | Backend API, RequestService | createOrder, setStatus, getOrder, issueResult, cancelOrder |
| IDocumentService | DocumentService | Backend API, OrderService | upload, saveResult, getResult |
| IRequestService | RequestService | Backend API | sendRequests, accept, reject |
| IBillingService | BillingService | Backend API, OrderService, RequestService, Scheduler | createPayment, isPaid, refund, markOverdue |
| IPaymentCallback | BillingService | Payment Service | confirmPayment, failPayment, confirmRefund |
| ICatalogService | CatalogService | Backend API, RequestService | addLanguage, setTranslatorLanguage, findTranslatorsByLanguages |
| IConfig | Platform Config | OrderService | getRatePerWord, getCancelDays |
| IRepository | Data Access | сервісний шар | CRUD для сутностей ER |
| IFileStorage | File Storage | DocumentService | put, get |
| IPaymentGateway | Payment Service | BillingService | charge, refund |

## Зовнішні інтеграції

- **Payment Service** (актор лаби 2): підтверджує оплати та повернення (FR-009, 010, 026, 027; UC-03, UC-16).
- OAuth/Identity, SMS і Email не моделюються: жодна вимога їх не потребує (див. D-2 в `audit.md`).

## Діаграма

Джерело: `diagrams/component.puml`, рендер: `diagrams/component.svg`.

## Архітектурні вимоги

- **AR-001**: Усі зміни `Order.status` ПОВИННІ виконуватись лише через OrderService.
- **AR-002**: Розсилка запитів ПОВИННА перевіряти оплату першої половини через IBillingService.
- **AR-003**: Вибір Translator для Request ПОВИНЕН іти через ICatalogService за обома мовами пари.
- **AR-004**: Payment Service ПОВИНЕН взаємодіяти з системою лише через BillingService.
- **AR-005**: Сервіси ПОВИННІ звертатись до даних лише через IRepository.
- **AR-006**: Web UI ПОВИНЕН викликати лише Backend API.

## Критерії прийняття

- **SC-001**: Кожен компонент і кожна залежність діаграми мають рядок у таблицях «Компоненти» та «Інтерфейси».
- **SC-002**: Кожен компонент сервісного шару має трасування до сутності ER, FR і UC (або позначку «немає UC»).
- **SC-003**: Кожен інтерфейс має provided-компонент і хоча б один required.
- **SC-004**: Межа системи позначена, зовнішні компоненти розташовані поза нею.
- **SC-005**: Назви сутностей і статусів збігаються з ER-моделлю посимвольно.
- **SC-006**: Аудит містить топ-3 розбіжності.

## Припущення

- Автентифікація й керування користувачами виконуються поза моделлю: у попередніх лабах їх немає.
- Один екземпляр кожного сервісу, розгортання й технології не розглядаються.
- Статуси Order змінює OrderService за командою Mediator або як наслідок події (прийняття запиту, оплата).
- `Order.rate_per_word` і N днів надходять із Platform Config, у даних замовлення N не зберігається.
- Друга половина оплати створюється, коли Order отримує `ready` (FR-022).