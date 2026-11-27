# Response to the external v2 audit ("Scorpion") — v2.1.0

Finding-by-finding status. IDs follow the external audit of 2026-11-24.

## P0

| ID | Finding | Status |
|----|---------|--------|
| MMC-001 | Mixed Android toolchain (AGP 4.2.2 buildscript + AGP 7.3.0 plugins DSL + Gradle 8.3 + Kotlin 1.7.10) | **Fixed.** Legacy `buildscript` block removed; one coherent stack: Gradle 8.3 + AGP 8.1.1 + Kotlin 1.8.22 (the Flutter 3.24 template combination, JDK 17), namespaced Kotlin plugin id, jetifier dropped |
| MMC-002 | `flutter analyze` / `test` / builds never executed | **Mitigated.** `.github/workflows/ci.yml` now runs pub get, analyze, test and a debug APK build (uploaded as an artifact) on every push/PR with pinned Flutter 3.24.5. The sandbox used to write this code still cannot run Flutter; CI is the executing environment |
| MMC-003 | Empty 200 responses could overwrite good data; malformed records silently discarded | **Fixed.** `ApiContentRepository` rejects empty catalogs and mostly-malformed payloads (`SuspiciousDataException`); the controller keeps the current data and shows the offline banner. The parser reports `skippedRecords` and deduplicates ids |

## P1

| ID | Finding | Status |
|----|---------|--------|
| MMC-004 | Live data not persisted across restarts | **Fixed.** Validated fetches are written to a file cache (`ContentCache` + `FileBlobStore`, atomic write). Cold start order: cache → bundled snapshot → background refresh |
| MMC-005 | Event times use the device timezone | **Documented, by design for now.** Times are wall-clock Morocco; classification uses the device clock. Correct for the Moroccan audience; off by the timezone delta elsewhere. A tz database (incl. Ramadan offset changes) is the right fix once the app targets users abroad — noted in `lib/data/models/event.dart` |
| MMC-006 | Invalid dates become 1970 | **Fixed.** Records without parseable dates (or titles) are rejected and counted, never displayed |
| MMC-007 | Unknown times presented as 09:00 + fabricated 8-hour duration | **Fixed.** `timeKnown` flag; UI shows the published label or "Time to be confirmed"; whole-day classification instead of a fake duration; calendar export becomes an all-day entry |
| MMC-008 | `coverMediaUrl` ignored | **Fixed.** Cover image now has priority over gallery media |
| MMC-009 | Only upcoming/past states | **Partially fixed.** `EventStatus {upcoming, ongoing, past}` with a "Happening now" badge. Cancelled/postponed are not exposed by the API — nothing honest to display yet |
| MMC-010 | Register shown based purely on dates | **Partially fixed / documented.** The API publishes no open/closed registration flag. The button never claims in-app registration: it opens the official event page (or the organiser's external link), labelled as such, and only while the event is not past |
| MMC-011 | Home upcoming shortcut didn't filter | **Fixed.** "See all" presets the Events tab (upcoming or past); topic chips already did |
| MMC-012 | Upcoming program editions sorted newest-first | **Fixed.** Soonest first |
| MMC-013 | Programs without events hidden | **Fixed.** Full catalog shown; empty ones say "No editions announced yet" |
| MMC-014 | Bookmarks of removed events vanish | **Fixed.** Kept as "no longer in the catalog" entries with a remove action |
| MMC-015 | No URL scheme policy | **Fixed.** Allowlist https/http/mailto; everything else refused with a message |
| MMC-016 | Global 1.6× text clamp | **Fixed.** Carousels now scale with the text size; clamp relaxed to 2.0× as a safety ceiling |
| MMC-017 | Preference writes unchecked | **Fixed.** Reads and writes are guarded; corrupted values degrade to defaults |

## Release engineering

- `applicationId` is still `com.example.client_mobile` and release builds still use the debug key — **left for the owner**: both choices are permanent once published, and the id should be agreed with MMC.
- `pubspec.lock` is not committed — the authoring sandbox cannot run `pub get`. Run it once locally and commit the lockfile.
- CI added (see MMC-002).

## Data notes

- The bundled snapshot is the full API payload of 2026-11-10 (142 events). It could not be re-verified on 2026-11-24 from the authoring environment; the app now treats it as a floor under the device cache, so staleness self-heals on the first successful refresh.
- Snapshot trimming (1,200-char descriptions, 4 media) applies to the bundled fallback only; live and cached data are complete.

## Scope deliberately not implemented in 2.1.0

Learning Hub, "My MMC" profile, Arabic/RTL, local notifications, ICS export,
in-app event-request drafts, calendar view. These are additive features, not
defects; each is sized in the external roadmap and none blocks a release.
