# MMC Mobile — Technical Audit (baseline commit `ed7f923`)

Scope: every file under `lib/`, `test/`, `pubspec.yaml`, `android/`, `assets/`.
Size: 19 Dart files, ~2,000 lines; 27 image assets (~32 MB).

## Verdict

The app **does not compile** in its current state, and even after fixing the
compile error **no screen can load data**: every screen calls a private LAN
API (`http://10.5.28.33:45459/gateway`) that is unreachable outside the original
developer's network. The home screen additionally crashes on first frame.

## P0 — Blocking defects (app cannot build or run)

| # | File | Evidence | Effect |
|---|------|----------|--------|
| 1 | `lib/Details/Register.dart:43` | `var respo` dangling statement (missing `;`, unused) | **Compile error** — whole app fails to build |
| 2 | `lib/controller/Constant.dart:2` | `apiUrl = "http://10.5.28.33:45459/gateway"` | Private IP + plain HTTP. Home, Events, Programs, Speakers, Register all fail |
| 3 | `lib/Details/SponsorCard.dart:27` | `late Future<List<Sponsor>> _futureSponsors;` never assigned in `initState` | `LateInitializationError` on Home build → red screen |
| 4 | `android/app/src/main/AndroidManifest.xml` | No `INTERNET` permission (only in `debug/`), no cleartext config | Release APK cannot reach any network |
| 5 | `lib/view/Speaker.dart:63` → `SpeakerDetails.dart:15` | Passes `speakerId: ''`, then `speakersData.firstWhere(id == '')` with no `orElse` | `StateError` crash on every speaker tap |
| 6 | `lib/Details/programDetails.dart:27` | `initState` never calls `fetchData()` | Program → events page spins forever |
| 7 | `test/widget_test.dart` | Default "counter" test against a splash screen | `flutter test` fails |

## P1 — Architecture & navigation

- **Nested `MaterialApp`s** (3): `main.dart` (`LodingPage` *and* `Loding` each
  build one) and `view/Accueil.dart` builds another inside the tab shell. This
  breaks theming, `Navigator` scopes, back button and `MediaQuery`.
- Stray `void main()` in `view/Accueil.dart:485`.
- **Name collisions**: widget `Event` vs model `Event`, widget `Program` vs
  model `Program`, widget `Speaker` vs model `Speaker`, two `Sponsor` classes,
  plus a third ad-hoc `Events` model inside `Accueil.dart`.
- Data handled as raw `dynamic` maps in 5 screens; models in `lib/models/` are
  not used by those screens. Two parallel data sources (HTTP vs `lib/data/`).
- No separation of UI / data access: every screen does its own `http.get`.
- `get` (GetX) is pulled in solely to hold one tab index.
- Splash uses a fixed 5-second `Future.delayed` and `Navigator` on a context
  inside its own nested `MaterialApp`.

## P1 — Runtime bugs

- `view/Event.dart:150` creates a new `AnimationController` **inside
  `itemBuilder` on every build** and never disposes it → memory leak + ticker
  warnings.
- `view/Event.dart:173` falls back to `Image.network('assets/images/blue.jpg')`
  — wrong loader *and* wrong case (file is `Blue.jpg`).
- `view/Event.dart:57` shows a dialog from a failed future after the widget may
  be unmounted.
- `Details/SpeakerDetails.dart:47` references `assets/images/cover.jpg` —
  **missing asset**. `Accueil._buildSponsors` references `sponsor1..3.png` —
  missing (dead code).
- `Details/SpeakerDetails.dart:118` `_launchURL` is an empty stub → social
  buttons do nothing.
- `Details/Register.dart`: posts the participant then posts
  `EventParticipant` even when the first call failed (`idParticipant == null`);
  no email/phone validation; user never sees success or failure (`Text("Success")`
  is created and discarded); `gender` not validated.
- Every image is `Image.network` with no `errorBuilder` / placeholder.
- No loading / empty / error / retry states except a one-off dialog in Events.

## P1 — Content quality

- Debug strings shipped in UI: `'... jmustapha roudani'`, `'... here there is
  description'` (`view/Speaker.dart:104,112`). Every speaker card shows
  `said_wahid.jpg`.
- `lib/data/event.dart` contains a junk record ("Jit Event", address "Lhih",
  start `2222-02-21`, end `2123-03-04`, end before start).
- HTML in descriptions (`<p>description<br></p>`) rendered as raw text.

## P2 — Assets & build

- 7 speaker photos are 3024×4032 JPEGs (~1 MB each); `mmc.png` is
  7333×3601 (2.2 MB); `firstMeet.png` 2.6 MB. Displayed at ≤ 150 px →
  heavy APK and decode jank.
- One asset filename contains spaces (`404 Error Page not Found ... .svg`) and
  SVG is not renderable without `flutter_svg`.
- `pubspec.yaml`: name `client_mobile`, description "A new Flutter project",
  `flutter_lints ^2.0.0` (outdated), `banner.png` declared twice.
- Android: `applicationId com.example.client_mobile`, label `client_mobile`,
  release signed with debug keys, Java 1.8 target.
- README is the Flutter template.

## Screen map (before)

```
LodingPage(MaterialApp) → Loding(MaterialApp, 5 s) → MontionTabBarPage
  ├─ Accueil (MaterialApp!)  → EventDetailsPage → RegisterForm
  ├─ Program                 → EventProgram (never loads) → RegisterForm
  ├─ Event                   → RegisterForm
  └─ Speaker                 → SpeakerDetailsPage (crashes)
Unused: Sessions, Error404, BottomNavigationController.textValue
```

## Data source discovered during the audit

The official website exposes a public read-only JSON API
(`https://moroccomicrosoftcommunity.com/api/events|speakers|programs`, 142
events on 2026-11-10). Version 2.0 uses it instead of the dead private gateway,
with a bundled snapshot as the offline fallback. See `docs/API.md`.

## Toolchain note

`flutter` could not be installed in the audit environment (SDK and pub.dev
downloads blocked), so `flutter analyze` / `flutter test` were not executed
there. Findings above come from reading the code; see `docs/TEST_REPORT.md`
for what was verified and the commands to run locally.
