# mentor_app — Flutter-клиент Mentor

Клиент **Mentor-App** к Laravel API из корня монорепо: авторизация (Sanctum), дашборд цели «Вьетнам», сообщения ментора, текст и удержание микрофона для AI.

Родительский проект и API: [корневой README](../README.md).  
Репозиторий на GitHub: **https://github.com/__GITHUB_OWNER__/mentor-app**

## UI (cyberpunk redesign)

Интерфейс выводился отдельной итерацией дизайна. Сейчас в коде:

- **`ThemeExtension<CyberColors>`** — палитра (neon cyan `#00FFFF`, neon green `#39FF14`, neon magenta, surface deep `#000000`, линии сетки) через `Theme.of(context).extension<CyberColors>()` в [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart).
- **[lib/features/finance/presentation/widgets/](lib/features/finance/presentation/widgets/)**
  - `cyber_grid_background.dart` — фон: сетка + виньетирование.
  - `vietnam_progress_ring.dart` — кольцо прогресса (`CustomPainter`, свечение, градиент дуги, подпись Destination: Vietnam).
  - `mentor_message_bubble.dart` — стеклянный пузырь (`BackdropFilter`), разметка текста через **`MarkdownBody`** + `MarkdownStyleSheet`.
  - `cyber_mic_button.dart` — шестиугольник, неоновая обводка, анимация при записи.
- **[lib/features/finance/presentation/pages/home_page.dart](lib/features/finance/presentation/pages/home_page.dart)** — `CyberGridBackground`, `CustomScrollView`, закреплённый sliver с прогресс-кольцом (compact при скролле), blur.

Зависимость **`flutter_markdown`** указана в [pubspec.yaml](pubspec.yaml).

## Требования

- Flutter SDK (см. `environment.sdk` в [pubspec.yaml](pubspec.yaml))

## Установка и запуск

```bash
cd mentor_app
flutter pub get
```

Базовый URL API (по умолчанию `http://localhost:8000` в [lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart)):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

На Android-эмуляторе для доступа к хосту ПК используйте `10.0.2.2`. На реальном устройстве — LAN IP машины с Laragon / `php artisan serve`. Cleartext в debug: [android/app/src/debug/AndroidManifest.xml](android/app/src/debug/AndroidManifest.xml).

Вход в приложение — те же **email / password**, что у пользователя Laravel (регистрация через веб-часть Fortify).

## Структура `lib/`

| Путь | Назначение |
|------|------------|
| `core/theme/` | `AppTheme`, `CyberColors` |
| `core/network/` | `ApiService`, исключения |
| `core/storage/` | `TokenStorage` (Sanctum token) |
| `features/auth/` | экран входа |
| `features/finance/` | BLoC, репозиторий, **presentation/widgets**, `home_page` |

## Тесты

```bash
flutter test
```

## Заметка по пакету markdown

`flutter_markdown` может помечаться как discontinued в пользу `flutter_markdown_plus`; при миграции обновите импорты и стили.
