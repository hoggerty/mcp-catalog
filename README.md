# hoggerty MCP catalog

Каталог MCP-серверов для [Docker MCP Toolkit](https://docs.docker.com/ai/mcp-catalog-and-toolkit/).
Подключается одной командой, токены у каждого свои и хранятся локально в Docker.

**Текущая версия каталога:** `ghcr.io/hoggerty/mcp-catalog:v0.0.1`

## Что внутри

| Сервер | Версия | Что умеет | Исходники |
|---|---|---|---|
| Yandex Tracker | 0.1.1 | задачи, очереди, доски, спринты, пользователи, ворклоги | [mcp-yandex-tracker](https://github.com/hoggerty/mcp-yandex-tracker) |

## Подключение

Нужен Docker Desktop с включённым MCP Toolkit.

1. **Импортируйте каталог.** Docker Desktop → MCP Toolkit → Catalog → **Import catalog** →
   `ghcr.io/hoggerty/mcp-catalog:v1`.
   Или из терминала: `docker mcp catalog pull ghcr.io/hoggerty/mcp-catalog:v1`
2. **Добавьте нужные серверы в профиль.** В каталоге выберите сервер → **Add to** → существующий или новый профиль.
3. **Настройте сервер** (см. ниже) в профиле: секреты и параметры.
4. **Подключите клиента** (Claude, Cursor и т.д.) к профилю: в Docker Desktop в настройках профиля
   или командой `docker mcp client connect <client> --profile <profile>` (список клиентов — `docker mcp client ls`).

## Настройка серверов

### Yandex Tracker

| Поле | Обязательно | Что указать |
|---|---|---|
| token (секрет) | да | OAuth-токен с доступом к Tracker API — [как получить](https://yandex.ru/support/tracker/ru/concepts/access) |
| org_id | одно из двух | ID организации Яндекс 360 |
| cloud_org_id | одно из двух | ID организации Yandex Cloud |
| tools_mode | нет | `read-only`, `read-write` (по умолчанию) или `full` |
| tools | нет | какие тулы показывать: glob-паттерны через запятую, `*` — все. Пусто — разумный набор по умолчанию |

ID организации указан в Трекере: Администрирование → Организации.
Заполните **только одно** из `org_id` / `cloud_org_id` — в зависимости от того, где ваша организация.

## Обновление

Когда выходит новая версия каталога, импортируйте её заново (тот же шаг 1 с новым тегом).
Настройки и секреты в профиле сохраняются.

## Изменения

- **v1** — Yandex Tracker 0.1.1.

## Проблемы

Issues — в репозиторий соответствующего сервера (ссылки в таблице выше).

