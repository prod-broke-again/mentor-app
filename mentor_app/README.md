# mentor_app — Flutter-клиент Mentor

Клиент **Mentor-App** к Laravel API из корня монорепо: авторизация (Sanctum), дашборд цели «Вьетнам», сообщения ментора, текст и удержание микрофона для AI.

Родительский проект и API: [корневой README](../README.md).  
Репозиторий на GitHub: **https://github.com/prod-broke-again/mentor-app**

## UI (Minimalist Soft UI)

- **`ThemeExtension<SoftUiColors>`** — семантические цвета (фон, surface, акцент, границы, сетка) в [lib/core/theme/soft_ui_colors.dart](lib/core/theme/soft_ui_colors.dart), темы **light/dark** в [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) (Material 3 + **Instrument Sans** через `google_fonts`).
- **Быстрый вход:** при сохранённом токене — опциональный запрос биометрии (`local_auth`), затем проверка сессии `GET /api/user` ([lib/app.dart](lib/app.dart), [lib/core/security/biometric_auth.dart](lib/core/security/biometric_auth.dart)).
- **[lib/features/finance/presentation/widgets/](lib/features/finance/presentation/widgets/)**
  - `ambient_background.dart` — спокойный фон и едва заметная сетка.
  - `vietnam_progress_ring.dart` — мягкое кольцо прогресса без неона.
  - `mentor_message_bubble.dart` — карточка сообщения + Markdown.
  - `soft_mic_button.dart` — круглая кнопка микрофона (soft shadow).
- **[lib/features/finance/presentation/widgets/home/](lib/features/finance/presentation/widgets/home/)** — `HomeTopBar`, `HomeInputRow`, `HomeProgressHeaderDelegate` (вынесены из `home_page`).
- **[lib/features/finance/presentation/pages/home_page.dart](lib/features/finance/presentation/pages/home_page.dart)** — основной экран чата и прогресса.

Зависимость **`flutter_markdown`** указана в [pubspec.yaml](pubspec.yaml).

## Требования

- Flutter SDK (см. `environment.sdk` в [pubspec.yaml](pubspec.yaml))

## Установка и запуск

```bash
cd mentor_app
flutter pub get
```

Базовый URL API по умолчанию — **продакшен** `https://n1mail.online` ([lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart)). Пути к API добавляются как `/api/...`.

Локальная разработка против Laragon:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

На Android-эмуляторе к хосту ПК: `--dart-define=API_BASE_URL=http://10.0.2.2:8000`. Cleartext в debug: [android/app/src/debug/AndroidManifest.xml](android/app/src/debug/AndroidManifest.xml).

Вход в приложение — те же **email / password**, что у пользователя Laravel (регистрация через веб-часть Fortify).

## Структура `lib/`

| Путь | Назначение |
|------|------------|
| `core/theme/` | `AppTheme`, `SoftUiColors` |
| `core/network/` | `ApiService`, `ApiException` |
| `core/security/` | `BiometricAuth` |
| `core/storage/` | `TokenStorage` (Sanctum token) |
| `features/auth/` | экран входа |
| `features/finance/` | BLoC, репозиторий, виджеты, `home_page` |

## Тесты

```bash
flutter test
```

## Заметка по пакету markdown

`flutter_markdown` может помечаться как discontinued в пользу `flutter_markdown_plus`; при миграции обновите импорты и стили.
