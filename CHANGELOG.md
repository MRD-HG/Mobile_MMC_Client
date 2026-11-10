# Changelog

## 2.0.0 — 2026-11-10

Full modernisation of the app. See `docs/AUDIT.md` for the defects it fixes.

### Fixed
- **Compile error** in `Details/Register.dart` (`var respo`).
- Home crash (`LateInitializationError` in `SponsorFooter`).
- Crash on every speaker tap (`speakerId: ''` → `firstWhere` with no match).
- Program → events page that never loaded (`fetchData()` was never called).
- Three nested `MaterialApp`s and a stray `main()` in `Accueil.dart`.
- `AnimationController` leaked for each list item in Events.
- Debug strings shown in the UI ("jmustapha roudani", "here there is description").
- Missing asset `cover.jpg`, a wrong `Image.network` call on an asset path, and social buttons that did nothing (`_launchURL` stub).
- Android: missing `INTERNET` permission in the main manifest, and no `<queries>` for opening links.

### Changed
- **Data**: the dead private API (`http://10.5.28.33…`) was replaced by the real public MMC API, with an offline snapshot of 142 events, 8 speakers and 14 programs.
- New architecture with `app/`, `core/`, `data/` and `features/`, repositories, and `ChangeNotifier` controllers. Removed the `get`, `motion_tab_bar` and `flutter_spinkit` packages.
- Complete redesign: Fluent-inspired blue with the MMC logo colours, a single navigation bar, shared cards and chips, light/dark themes, and FR/EN.
- Images: 32 MB → 2 MB. Photos were resized, and unused or duplicate assets removed.
- The registration form was removed. It posted personal data to a dead server. **Register** now opens the official event page or the organiser's link.

### Added
- Event search (ignores accents), time and topic filters.
- Bookmarks, favourite topics, theme and language settings (stored locally).
- Add to Google Calendar.
- Speaker profiles with bio, MVP badge, social links and the events they spoke at.
- Community page: about, official links, contact, partners, photos.
- Loading, empty, error and retry states, plus an offline banner.
- Deep-link routes such as `/events/<slug>` and a not-found page.
- Tests: models, time parsing, snapshot integrity, controllers, API repository (mocked HTTP), and widget tests for the main flows.
- `tool/update_snapshot.py`, README, architecture and API docs.
