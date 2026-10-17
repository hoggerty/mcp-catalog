## Для мейнтейнера

Описания серверов лежат в `servers/*.yaml`, у каждого образа закреплена версия (не `latest`).

Обновить сервер:
1. Выпустить релиз в репозитории сервера (`git tag -a vX.Y.Z`), дождаться образа.
2. Поменять `image:` в `servers/<name>.yaml`, проверить `make check` и `make test`.
3. Обновить таблицу «Что внутри», «Текущую версию» и «Изменения» в README, закоммитить.
4. `make release VERSION=v<N+1>`.

Первый релиз: после `make release` сделать пакет `mcp-catalog` публичным в GHCR
(Package settings → Change visibility → Public).