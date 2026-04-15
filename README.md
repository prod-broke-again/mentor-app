# Mentor-App (монорепо)

Личный финансовый ментор **«Кибер-бро»**: **Laravel 13** (REST API, Inertia + Vue веб-часть, Fortify) + мобильный/десктоп-клиент **[mentor_app](mentor_app/)** на **Flutter** (Android, iOS, macOS).

Подробности по клиенту (запуск, cyber-UI, структура `lib/`) — в [mentor_app/README.md](mentor_app/README.md).

## Репозиторий на GitHub

**https://github.com/prod-broke-again/mentor-app**

## Требования

- PHP 8.3+, Composer, Node (Vite / фронт стартера)
- Flutter SDK (каталог [mentor_app](mentor_app/))
- MySQL или SQLite (в [.env.example](.env.example) по умолчанию — SQLite)

## Laravel API

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
```

Для веб-интерфейса (Vite + Vue): `npm install` и при необходимости `npm run dev` или `npm run build`.

Проверка **Timeweb AI** после заполнения `TIMEWEB_AI_API_KEY` и `TIMEWEB_AI_BASE_URL` в `.env`:

```bash
php artisan ai:test-timeweb
```

Свой текст запроса (модель для Timeweb задаётся в панели Timeweb и в `TIMEWEB_AI_MODEL`, по умолчанию `gemini-2.0-flash`):

```bash
php artisan ai:test-timeweb --prompt="Скажи одно слово: работает."
```

В `.env` настройте провайдеры AI (см. `config/services.php` → `ai`):

- `AI_PROVIDER` — `timeweb` или `gptunnel` (дефолт для DI `AiProviderInterface`)
- Timeweb: `TIMEWEB_AI_API_KEY`, `TIMEWEB_AI_BASE_URL`, опционально `TIMEWEB_AI_MODEL` (должно совпадать с моделью в панели Timeweb, по умолчанию `gemini-2.0-flash`) ([документация Timeweb Cloud](https://timeweb.cloud/docs))
- GPTunnel: `GPTUNNEL_API_KEY`, при необходимости `GPTUNNEL_AI_BASE_URL` ([gptunnel.ru](https://gptunnel.ru))
- Для `/api/ai/process` с **аудио** нужен Whisper на OpenAI: `OPENAI_API_KEY`, при необходимости `OPENAI_BASE_URL`, `OPENAI_TRANSCRIPTION_MODEL`

```bash
php artisan serve
```

### Маршруты API (префикс `/api`)

| Метод | Путь | Описание |
|--------|------|----------|
| POST | `/api/auth/login` | email, password, device_name → Bearer token (Sanctum) |
| POST | `/api/auth/logout` | отзыв текущего токена |
| GET | `/api/user` | текущий пользователь |
| GET | `/api/dashboard` | прогресс цели + последние сообщения ментора |
| POST | `/api/ai/process` | JSON `{ "text": "..." }` или multipart `audio` (Sanctum) |
| POST | `/api/ai/ask` | JSON `{ "prompt": "...", "provider": "gptunnel" }` — smoke-тест провайдера **без Sanctum** |

Пример (Windows `cmd`):

```bash
curl -X POST http://localhost:8000/api/ai/ask ^
  -H "Content-Type: application/json" ^
  -d "{\"prompt\":\"Сделай план запуска продукта\",\"provider\":\"gptunnel\"}"
```

### Клиент Flutter (кратко про UI)

Cyberpunk-интерфейс: палитра через **`ThemeExtension<CyberColors>`** (`mentor_app/lib/core/theme/app_theme.dart`), сетка и виньетка на фоне, кольцо прогресса «Вьетнам», пузыри сообщений с **Markdown** (`flutter_markdown`), шестиугольная кнопка микрофона с неоном и анимацией записи. Детали — в [mentor_app/README.md](mentor_app/README.md).

### Безопасность

`POST /api/ai/ask` оставлен удобным для **локальной** проверки провайдеров. Для production ограничьте доступ (Sanctum, отдельный ключ, отключение маршрута).

## Лицензия

Код распространяется на условиях, которые вы задаёте для своего репозитория; при отсутствии `LICENSE` трактуйте как **all rights reserved**, пока не укажете иное.
