# Промпт #2: діаграма компонентів (component.puml) (Завдання 5: архітектура)

**Модель ШІ:** Claude Sonnet 5.5 (Anthropic)

**Додано до промпту як вхідні файли:** `spec.md` лаби 5 із таблицями компонентів та інтерфейсів.

## Промпт

```text
зроби component diagram в PlantUML за таблицями компонентів та інтерфейсів зі spec.md
межа системи має бути чітко позначена, Payment Service поза межею як external
у кожного інтерфейсу має бути provided і required
```

## Що видала

Файл `diagrams/component.puml`: пакет «Tlumach (межа системи)» з UI, API, п'ятьма сервісами, Scheduler, Platform Config, Data Access, File Storage і Database, а також зовнішній Payment Service.

## Що виправлено

- Інтерфейси з окремих вузлів зроблено підписами на стрілках, сервіси згруповано в один «Сервісний шар».
- Лінії зроблено ламаними (`linetype polyline`), бо хвилясті накладались.
- Додано IConfig для ставки за слово та N днів.
- Рендер перевірено в PlantUML і збережено як `diagrams/component.svg`.