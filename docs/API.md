# MMC API — integration guide

Base URL: `https://moroccomicrosoftcommunity.com/api`. It is public, read-only JSON, used by the official website. It was observed on 10 Nov 2026, and `GET /health` returned `{"status":"ok","database":"connected"}`.

Override it at build time with `--dart-define=MMC_API_BASE_URL=...`.

## Endpoints used by the app

### `GET /events` → `Event[]` (~1.7 MB, 142 items)

| Field | Used as |
|-------|---------|
| `id`, `slug` | identity, deep link, official page `https://moroccomicrosoftcommunity.com/events/<slug>` |
| `title`, `description` (HTML) | text (HTML stripped) |
| `date`, `endDate` (`YYYY-MM-DD`), `time` (free text) | `start` / `end`; `parseTimeRange` handles `9:30`, `09:00 AM - 05:00 PM`, `9:00am - 4:00pm`, `10h00 - 13h30`, `19h`… |
| `location`, `city`, `isOnline` | venue / city / online badge |
| `registrationMode` (`internal`/`external`), `externalRegistrationUrl` | Register button target |
| `programId` | link to `/programs` |
| `media[] {type, url, thumbnail}` | cover + gallery (images only; video thumbnails when present) |
| `speakers[] {id, sessionTitle, sessionDuration, …}` | sessions list |
| `partners[] {name, …}`, `club {name}` | partner chips |
| `status` | only `published` is shown |

Ignored: email settings, `teamsLink`, counters (`registeredCount`, `likesCount`…).

### `GET /speakers` → `Speaker[]`

`id, name, slug, title, bio, avatar, social{linkedin,twitter,github}`.
Social links are classified **by host**, because some profiles store, for example, an Instagram URL under `twitter`. Bare placeholders such as `https://x.com/` and `#` are dropped. A relative `avatar` (`/speakers/x.jpg`) is resolved against the website.

### `GET /programs` → `Program[]`

`id, name, description, image, order, isCommunityProgram`.

### Not used yet

`GET /cities`, and the website's auth/registration endpoints.

## Adding in-app registration later

Registration currently opens the official page. To register inside the app, MMC would need to publish an authenticated endpoint. Then:

1. add a `RegistrationRepository` in `lib/data/repositories/`;
2. keep the website link as a fallback;
3. never store credentials in `AppConfig`, which only holds public values.

## Changing the backend

Implement `ContentRepository` and return a `ContentBundle`. Nothing else in the app needs to change.
