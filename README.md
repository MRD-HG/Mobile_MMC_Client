# MMC Mobile

The mobile app of the **Morocco Microsoft Community (MMC)**. It lists events, programs and speakers, with bookmarks, search, calendar export, light/dark themes and French/English.

The data is **real**. It comes from the public API that powers
[moroccomicrosoftcommunity.com](https://moroccomicrosoftcommunity.com): 142 events from 2019 to 2026, 8 speakers and 14 programs (snapshot of 10 Nov 2026). The app also bundles a copy of that data, so it works offline.

## Requirements

- Flutter **3.24 or later** (Dart ≥ 3.5)
- Android SDK (minSdk is the Flutter default), or Xcode for iOS

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run                                        # live data + offline fallback
flutter run --dart-define=MMC_OFFLINE_ONLY=true    # bundled data only
```

Release builds:

```bash
flutter build apk --release
flutter build appbundle --release
```

> Android release builds are still signed with the debug key
> (`android/app/build.gradle`). Add a real signing config, and change
> `applicationId` (currently `com.example.client_mobile`) before you publish to the Play Store.

## Features

| Area | What it does |
|------|--------------|
| Home | Upcoming events, latest editions, topics, programs, speakers, an "About MMC" card, and an offline banner when needed |
| Events | Search (ignores accents), All / Upcoming / Past filters, topic chips, event count |
| Event details | Date/time, venue or online, official **Register** button (opens the MMC site or the organiser's link), add to Google Calendar, sessions with their speakers, partners, gallery |
| Programs | Event series with their editions |
| Speakers | Grid with search, MVP badge, profile with bio, social links and the events they spoke at |
| Saved | Bookmarked events stored on the device |
| Community | About, focus areas, official social links, contact email, partners, photos |
| Settings | Theme (system/light/dark), language (device/FR/EN), favourite topics, data source and a refresh button |
| Accessibility | Semantic labels, 48 dp touch targets, text scaling up to 1.6×, contrast-checked palette |

## Data flow

```
start ─▶ device cache (last successful fetch) ─▶ else bundled snapshot ─▶ UI usable
      └▶ GET https://moroccomicrosoftcommunity.com/api/{events,speakers,programs}
            ├─ validated → UI switches to live data, fetch persisted to cache
            ├─ empty/broken payload → treated as failure (data kept)
            └─ failure → keeps cache/snapshot + "Offline" banner with Retry
```

To refresh the bundled snapshot before a release:

```bash
python tool/update_snapshot.py
```

Static community info (about text, social links, partners) lives in
`assets/data/community.json`.

## Project structure

```
lib/
├── main.dart                 # wiring: storage, repositories, controllers
├── app/                      # MaterialApp, router, shell, controllers, theme
├── core/                     # config, l10n (EN/FR), storage, utils, widgets
├── data/
│   ├── models/               # MmcEvent, Speaker, Program, CommunityInfo
│   └── repositories/         # API, snapshot, parser
└── features/                 # home, events, programs, speakers, bookmarks,
                              # community, settings, splash
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/API.md](docs/API.md), [docs/AUDIT.md](docs/AUDIT.md), [docs/TEST_REPORT.md](docs/TEST_REPORT.md) and [CHANGELOG.md](CHANGELOG.md).

## Note on the API

The app only **reads** the same public endpoints that the official website calls from the browser. It does not register users itself: the Register button opens the official event page. Before you publish, confirm with the MMC team that the app may use these endpoints.
