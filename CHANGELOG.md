# Changelog

## 2.1.0 — 2026-11-24

Hardening release, answering an external code audit point by point
(docs/SCORPION_AUDIT_V3.md).

### Fixed
- Android build: removed the conflicting legacy AGP 4.2.2/Kotlin 1.7.10
  buildscript; coherent Gradle 8.3 + AGP 8.1.1 + Kotlin 1.8.22 toolchain.
- An empty or broken API response can no longer replace good data; malformed
  records are counted and duplicate ids dropped.
- Events with invalid dates are rejected instead of appearing as 1970.
- Events without a published time no longer pretend to start at 09:00: the UI
  says "Time to be confirmed", classification covers the whole day, and the
  calendar export becomes an all-day entry.
- The published cover image (coverMediaUrl) is now used.
- Home's "See all" shortcuts preset the Events tab filters.
- Upcoming program editions sort soonest-first; programs without events appear
  in the catalog.
- Bookmarks of events that left the catalog stay visible with a remove action.
- External links restricted to https/http/mailto.
- Preference reads/writes survive storage failures.

### Added
- Persistent content cache: the last successful fetch is stored on device and
  used at the next cold start (cache → snapshot → live refresh).
- "Happening now" event status.
- City and program filters in Events, combinable with topic/time/search, with
  an active-filter count and reset.
- GitHub Actions CI: analyze, tests and a debug APK on every push.
- Text scaling honoured up to 2.0× (carousels grow with the font size).


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
