# Activity tracking API (Windows agent → Laravel)

## Аутентификация

Используется **Laravel Sanctum**: Personal Access Token.

1. `POST /api/auth/login` с телом `email`, `password`, опционально `device_name`.
2. В ответе поле `token` передаётся как заголовок: `Authorization: Bearer <token>`.

## `POST /api/v1/activity/sessions`

Создаёт или обновляет запись сессии активности по паре `(user, client_session_id)`.

### Заголовки

- `Authorization: Bearer <token>`
- `Content-Type: application/json`
- `Accept: application/json`

### Поля JSON

| Поле | Тип | Обязательно | Описание |
|------|-----|-------------|----------|
| `client_session_id` | UUID | да | Стабильный ID сессии на клиенте (один на «сидение» в одном окне) |
| `exe` | string | да | Имя исполняемого файла, например `chrome.exe` |
| `window_title` | string | нет | Заголовок активного окна |
| `started_at` | ISO 8601 | да | Начало сессии |
| `ended_at` | ISO 8601 | для `session_end` | Конец сессии; для `heartbeat` можно опустить — подставится текущее время |
| `duration_seconds` | int | да | Накопленная длительность (секунды) |
| `device_name` | string | нет | Подпись устройства, например `win-desktop` |
| `event` | string | нет | `heartbeat` — промежуточное обновление; `session_end` (по умолчанию) — финализация |

При `event: session_end` после сохранения ставится в очередь `AnalyzeActivitySessionJob` (заглушка под LLM).

### Ответ

- `201` — создана новая запись
- `200` — обновлена существующая (тот же `client_session_id`)

Тело: `{ "id", "client_session_id", "is_final" }`.

### Рекомендации по приватности

Не отправляйте полный путь к `.exe`, аргументы командной строки и скриншоты. `window_title` может содержать чувствительные данные — учитывайте это в продукте.

## Realtime (опционально)

Для MVP достаточно REST: советы ментора можно отдавать при следующем заходе в приложение или через обычные push. **Laravel Reverb / WebSockets** не требуются для приёма активности; при необходимости их можно добавить позже только для мгновенной доставки сообщений в UI.
