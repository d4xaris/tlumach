# Спека: компонентна діаграма Tlumach

Гілка lab-5-component-diagram, статус: чернетка.

## Намір

Показати архітектуру Tlumach: компоненти, їхні інтерфейси, межу системи і зовнішню інтеграцію. Форма одна: PlantUML component diagram. Назви сутностей і статусів з Завдання 1, номери UC з поточного use-cases.md.

## Компоненти

| Компонент | Відповідальність | Сутності ER | UC |
|---|---|---|---|
| Web UI | інтерфейс усіх ролей | | UC-01…UC-17 |
| Backend API | єдина точка входу | | усі |
| OrderService | створення Order, усі зміни `Order.status` | Order | UC-01, 08, 10, 11, 13, 16 |
| RequestService | розсилка, прийняття й відхилення запитів | Request | UC-05, 06, 07, 17 |
| BillingService | обидві половини оплати, повернення | Payment | UC-03, 04, 12, 14 |
| DocumentService | .docx, `word_count`, результат | Document | UC-02, 09 |
| CatalogService | довідник мов, мови Translator | Language | UC-15 |
| Scheduler | перевіряє `Payment.due_date`, ставить `overdue` | Payment | без UC |
| Platform Config | `rate_per_word`, кількість днів N | | |
| Data Access | читання й запис усіх сутностей | усі | |
| File Storage | файли .docx і результат | | |
| Database | реляційна БД, UNIQUE (`order_id`, `translator_id`) | усі | |

Користувачі (Client, Translator, Editor, Mediator) окремого сервісу не мають: їх обслуговують OrderService і CatalogService.

## Інтерфейси

| Інтерфейс | Provided | Required |
|---|---|---|
| IApi | Backend API | Web UI |
| IRequestService | RequestService | Backend API |
| IOrderService | OrderService | Backend API, RequestService |
| IBillingService | BillingService | Backend API, OrderService, RequestService, Scheduler |
| IDocumentService | DocumentService | Backend API, OrderService |
| ICatalogService | CatalogService | Backend API, RequestService |
| IConfig | Platform Config | OrderService |
| IRepository | Data Access | сервісний шар |
| IFileStorage | File Storage | DocumentService |
| IPaymentGateway | Payment Service | BillingService |
| IPaymentCallback | BillingService | Payment Service |

## Зовнішні інтеграції

Payment Service: підтверджує оплати (UC-03), виконує повернення (UC-14). Лежить поза межею, позначений `<<external>>`.

## Зв'язок з попередніми моделями

- **Лаба 1:** усі сутності ER досяжні через Data Access і Database.
- **Лаба 3:** RequestService викликає IBillingService (оплата першої половини), ICatalogService (перекладачі за мовами), IOrderService (статус `sent_to_translators`).
- **Лаба 4:** зміни `Order.status` виконує OrderService, прострочення `due_date` виконує Scheduler через IBillingService.

## Що не робимо

Автентифікацію, сповіщення (OAuth, Email, SMS), схему розгортання, вибір технологій.

## Критерії прийняття

- AR-001: кожен компонент і залежність трасується до сутності, UC, вимоги, кроку Sequence або переходу лаби 4.
- AR-002: межа системи позначена, Payment Service лежить поза нею.
- AR-003: кожен інтерфейс має provided і хоча б один required.
- AR-004: назви сутностей і статусів збігаються з Завданням 1 літера в літеру.
- AR-005: усі зміни `Order.status` проходять через OrderService.

## Де діаграма не збігається з моделлю

- D-14: RequestService не міняє статус сам, а викликає IOrderService, бо за моделлю статуси змінює Mediator.
- D-15: Scheduler виконує перехід «минув `due_date`», UC для нього немає (D-12).
- D-16: Scheduler, Platform Config і File Storage є архітектурними рішеннями без сутності в ER.