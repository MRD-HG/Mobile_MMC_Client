# Architecture

## Layers

| Layer | Folder | Rules |
|-------|--------|-------|
| Presentation | `lib/features/*`, `lib/core/widgets` | Widgets only. They read state from controllers and never call HTTP or assets |
| State | `lib/app/controllers.dart` | `ChangeNotifier`s: `ContentController`, `BookmarksController`, `SettingsController` |
| Data | `lib/data/repositories` | `ContentRepository.load()` returns a `ContentBundle` |
| Models | `lib/data/models` | Immutable, with `fromApi` factories that tolerate bad input |

Dependencies are passed through `AppScope`, an `InheritedWidget`. There is no service locator and no state-management package. The dependencies are `http`, `shared_preferences`, `url_launcher`, `intl` and `flutter_localizations`.

## Navigation

- There is **one** `MaterialApp`, in `app/app.dart`.
- `HomeShell` has one `Scaffold` and one `NavigationBar` with 5 tabs. Tabs are built lazily, kept alive in an `IndexedStack`, and Back returns to Home first.
- Detail pages use path routes, which makes deep links possible:
  `/events/<id|slug>`, `/speakers/<id|slug>`, `/programs/<id>`, `/community`, `/settings`.
  Unknown paths open a "not found" page.

## Content loading (offline-first)

`ContentController.load()`:

1. loads `SnapshotContentRepository` (bundled JSON). The UI shows it at once.
2. starts `ApiContentRepository.refresh()` in the background. The large JSON payload is decoded in an isolate (`compute`).
3. on failure it keeps the snapshot and sets `refreshFailed`. Home then shows an offline banner with Retry.

`MmcApiParser` maps the API schema, and both repositories use it. A malformed record is skipped instead of breaking the whole list.

## Design system

- Brand blue `#0F6CBD` (inspired by Fluent 2), plus the four MMC logo colours (red, green, blue, yellow) for accents, topic chips and the `LogoStripe`.
- Spacing scale `MmcSpacing` (4 → 32) and radii `MmcRadius`.
- Shared widgets: `MmcCard`, `SectionHeader`, `TopicChip`, `Pill`, `MessageView` (empty/error), `LoadingView`, `AppImage` (asset or network with branded fallback), `AvatarImage` (network → bundled photo → initials).
- Light and dark themes come from one `ColorScheme.fromSeed`.

## Localisation

`core/l10n/strings.dart` holds compile-checked EN/FR getters, with no code generation. To add Arabic, extend `S._t`, add `Locale('ar')`, and check RTL layouts.
