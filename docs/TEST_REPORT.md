# Test report — 2026-11-10

## Summary

| Check | Result |
|-------|--------|
| `flutter analyze` | **Not run.** The build environment could not download the Flutter SDK or pub.dev packages (network policy) |
| `flutter test` | **Not run**, for the same reason. The test suite is written and ready (see below) |
| `flutter build apk` | **Not run** |
| Dart syntax check (tree-sitter Dart grammar) on all 40 `.dart` files | **Pass, 0 errors.** This checker does detect the original `var respo` compile error |
| Cross-file import check (script) | Pass: no missing project imports |
| Member-reference check (script) | Pass: every `s.*`, `data.*`, `event.*`, `speaker.*`, `Formatters.*`, `AppRouter.*`… resolves to a declared member |
| Time parser checked against all **24 distinct `time` formats** in the real API | Pass for every format, including `19h` and `10:00am - 4:00pm (UTC +1)` |
| Snapshot integrity | 142 events, 8 speakers, 14 programs; IDs are unique and every session speaker exists |

A syntax check is **not** a type check. Run the commands below before you rely on the build.

## Run locally

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Test suite

| File | Covers |
|------|--------|
| `test/unit/models_test.dart` | `parseTimeRange` (real formats), event mapping, registration URLs, topics, accent-insensitive search, speaker link cleaning, names, avatars |
| `test/unit/snapshot_test.dart` | Bundled snapshot parses, referential integrity, assets exist |
| `test/unit/content_test.dart` | `ContentBundle` queries, `filterEvents`, offline → live flow, network failure fallback, retry, bookmark/settings persistence, `ApiContentRepository` with mocked HTTP (drafts hidden, HTTP errors) |
| `test/widget/app_test.dart` | Home, Events search and filters, event details (Register, sessions, bookmark), past event, speaker page, not-found route, error → retry, FR switch |

## Manual checks still to do on a device

- [ ] Small (360 dp) and large phones, landscape
- [ ] Airplane mode at first launch → snapshot and offline banner
- [ ] Register / Add to calendar / social links open the right apps
- [ ] Dark mode on every screen
- [ ] TalkBack pass on Home, Events and Event details
- [ ] Text size at 160 %
