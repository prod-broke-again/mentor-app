# Soft UI — smoke checklist

## Flutter (`mentor_app`)

- [ ] Cold start **without** token → login screen, Instrument Sans / system fallback, soft card.
- [ ] Login validation (empty fields) → inline errors.
- [ ] Login API 422 → `email` / `password` field errors or general message.
- [ ] Success → home, calm grid background, message bubbles with soft shadow.
- [ ] Cold start **with** valid token → biometric prompt (if available) → home after `/api/user` 200.
- [ ] Expired token → storage cleared → login.
- [ ] Biometric cancel/fail → login (token may remain until password login replaces it).
- [ ] Logout → login.
- [ ] **Light / dark**: system theme switches `ThemeMode.system` (verify OS appearance).

## Web (Inertia)

- [ ] Auth card: `shadow-soft`, rounded corners, `bg-background` page.
- [ ] Login status banner uses `text-primary`.
- [ ] Dashboard tiles: soft border + `shadow-soft`.
- [ ] Toggle `.dark` / light (app theme switch if present).

## A11y quick pass

- [ ] Focus ring visible on primary button and inputs (web).
- [ ] Contrast: body text on `background` / `card` acceptable in both themes.
- [ ] Tap targets ≥ 44px on Flutter icon buttons / mic (approximate check).
