# Промпт #2: Sequence Diagram (sequence.mmd) (Завдання 3: взаємодія)

**Модель ШІ:** Claude Sonnet 5.5 (Anthropic)

**Додано до промпту як вхідні файли:** `spec.md` із Завдання 3, `use-cases.md` із Завдання 2, `spec.md` із Завдання 1.

## Промпт

```text
тепер зроби sequence-діаграму в Mermaid за цим spec.md, UC-05 з лаби 2

потрібно:
виклики з нормальними назвами (типу sendRequests(), createRequest())
кожен виклик має return
alt для помилок, loop для розсилки, opt для дублів
назви сутностей як у моделі з лаби 1
```

## Що видала

Файл `diagrams/sequence.mmd` з учасниками Mediator, RequestService, Order, Payment, Translator, Request. Є гілки: `alt` (перша половина не оплачена), вкладений `alt` (немає перекладачів), `loop` по перекладачах і `opt` для дубля запиту.

## Що виправлено

- `updateStatus(orderId, newStatus)` замінено на `updateStatus(orderId, "sent_to_translators")`.
- `findByLanguagePair(languagePair)` замінено на `findByLanguages(sourceLanguageId, targetLanguageId)`, бо пара в моделі це два поля.
- Перевірено, що кожен виклик має return-повідомлення.
- Кроки діаграми звірено з основним потоком UC-05 і UC-06.
- З діаграми зроблено `sequence.svg` через mermaid.live.