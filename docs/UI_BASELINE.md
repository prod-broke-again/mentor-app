# UI baseline (pre–Soft UI redesign)

Reference snapshot for the redesign scope.

## Flutter (`mentor_app/`)

| Area | Stack | Notes |
|------|--------|--------|
| Framework | Flutter 3.x, Material 3 | `useMaterial3: true` |
| State | `flutter_bloc` | `HomeBloc` on dashboard |
| HTTP / auth | `http`, `flutter_secure_storage` | Sanctum PAT, `/api/auth/login` |
| Markdown | `flutter_markdown` | Mentor bubbles |
| Fonts (before) | System + `monospace` hardcoded | No bundled fonts |
| Icons | Material Icons | — |

**Key UI files:** `lib/core/theme/app_theme.dart`, `lib/features/auth/presentation/login_page.dart`, `lib/features/finance/presentation/pages/home_page.dart`, widgets under `lib/features/finance/presentation/widgets/`.

## Web (`resources/`)

| Area | Stack | Notes |
|------|--------|--------|
| UI | Vue 3 + Inertia | Pages under `js/pages/` |
| Styling | Tailwind CSS v4 | `resources/css/app.css` (`@import 'tailwindcss'`) |
| Components | Reka UI + CVA | `js/components/ui/` |
| Icons | `lucide-vue-next` | — |
| Auth UI | Fortify views | `js/pages/auth/*.vue` |

**Shell:** single Blade host `resources/views/app.blade.php`.

## Backend auth (reference)

- API: `POST /api/auth/login`, `GET /api/user` (Sanctum), `POST /api/auth/logout`
- Web: Laravel Fortify + Inertia (session), separate from mobile token flow
