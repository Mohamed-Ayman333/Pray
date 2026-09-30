# Pray

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.8.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)]()
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A privacy-first, fully offline prayer times app for Android.

Pray computes prayer times **on-device** — no servers, no ads, no tracking, no internet permission required to use. It also tracks your daily prayer progress, shows missed prayers (qada), and keeps reminders opt-in so nothing fires unless you ask it to.

---

## Why Pray?

Existing prayer apps tend to:
- Require an internet connection just to show prayer times
- Fill the screen with ads
- Don't track your daily prayer progress
- Fire the adhan sound even when the phone is on silent

Pray was built to fix all four. Prayer times are computed locally using the [adhan](https://pub.dev/packages/adhan) library, all data stays on your device, and notifications are **off by default** — you opt in if and when you want them.

---

## Features

### Prayer times
- Fully offline calculation via the `adhan` library
- 13 calculation methods (MWL, Egyptian, Karachi, Umm al-Qura, Dubai, Moonsighting Committee, ISNA, Kuwait, Qatar, Singapore, Tehran, Turkey, custom)
- Madhab selection (Standard — Shafi/Hanbali/Maliki — or Hanafi)
- Automatic location lookup with a **Cairo fallback** if permission is denied

### Prayer tracking
- Mark each prayer as done with a single tap
- **Day view** — today's six prayers with status
- **30-day table view** — scrollable grid of upcoming prayer times
- **Monthly calendar** — colour-coded history, tap any missed day for a per-prayer breakdown
- **Optional prayer counter** — track sunnah/nafilah with a running counter and daily auto-increment

### Sunnah display
- Optional columns showing **Sunnah Before** / **Sunnah After** rak'ah counts
- Derived Dhuha time (sunrise + 20 min)

### Notifications (opt-in)
- Per-prayer local notifications
- **Sticky notifications** that persist until the prayer is marked done
- **Repeating notification sound** that loops until dismissed
- Background worker keeps sticky notifications alive across reboots
- "Mark as Done" action available directly from the notification shade

### Personalisation
- Light and dark theme
- English and Arabic localisation
- "Don't track prayers" mode — past days display as fully complete
---
## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| State management | `provider` + `ChangeNotifier` |
| Local database | [Isar](https://isar.dev) |
| Prayer calculation | [`adhan`](https://pub.dev/packages/adhan) |
| Notifications | `flutter_local_notifications` |
| Background work | `workmanager` |
| Location | `geolocator` |
| Permissions | `permission_handler` |
| Localisation | `flutter_localizations` + `intl` |

---

## Architecture

The codebase is split into six top-level packages under `lib/`:

- **`core`** — dependency wiring (`AppCore`, `buildAppCore`). One place that builds the entire data layer from a single Isar instance; used by both the foreground app and background isolates.
- **`model/types`** — domain models: `Day`, `Prayer`, `Settings`, `UserState`.
- **`model/storage`** — Isar-backed storage classes and repositories, arranged as a decorator chain (`LocalDaysStorage` → `CalculatedDaysStorage` → `CachingCalculatedDaysStorage` → `DaysRepository`).
- **`controller`** — `SettingsController`, `UserStateController`, `DaysController`. All extend `ChangeNotifier` and are provided via `MultiProvider`.
- **`service`** — notification scheduling and the sticky-notification background worker.
- **`view`** — everything UI: home page, monthly calendar, settings page, and theme definitions.

### Design notes

- The app uses the **repository pattern** for storage so that read sources (locally stored vs. dynamically calculated) can be swapped without touching the controller layer.
- `DaysRepository` decides per-day whether to read from Isar or recalculate — past days read from storage, today and future days are recalculated on demand. When "track prayers" is off, past days are written back as **tombstones** (empty prayer lists) so the UI can distinguish "unknown" from "missed everything".
- Background isolates (`notificationTapBackground`, `stickyNotificationWorkerDispatcher`) rebuild the data layer via `buildAppCore(isar)` rather than hand-constructing it — this keeps the two copies in sync.

---

## Getting started

### Prerequisites

- Flutter SDK 3.x
- Dart SDK `>=3.8.0 <4.0.0`
- Android Studio or VS Code with the Flutter extension
- An Android device or emulator (API 21+)

### Installation

```bash
git clone https://github.com/Mohamed-Ayman333/Pray.git
cd Pray
flutter pub get
```

If the generated `*.g.dart` files are missing (e.g. after a clean clone), regenerate them:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Running

```bash
flutter run
```

### Building for release

```bash
flutter build apk --release
```

The signed APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Project structure

```
lib/
├── main.dart                    App entry point + MyApp lifecycle
├── core/
│   └── app_core.dart            Dependency graph wiring
├── controller/                  ChangeNotifier controllers
├── l10n/                        Generated localisations + .arb sources
├── model/
│   ├── storage/                 Isar-backed storage + repositories
│   └── types/                   Domain models
├── service/
│   ├── notification_service.dart
│   └── sticky_notification_worker.dart
└── view/
    ├── main_shell.dart          Bottom-nav shell
    ├── home/                    Home page + widgets
    ├── calendar/                Monthly calendar page
    ├── settings/                Settings page + widgets
    └── theme/                   AppTheme + PrayerThemeColors
```

---

## Permissions

Every permission is optional — the app runs without granting any of them, using safe fallbacks.

| Permission | Purpose | Fallback |
|---|---|---|
| Location | Accurate prayer times for your position | Falls back to Cairo (30.0444, 31.2357) |
| Notifications | Prayer reminders | Silently disabled |
| Ignore battery optimisations | Keeps sticky notifications alive | Sticky mode won't work reliably |
| Exact alarms (Android 12+) | On-time delivery of scheduled reminders | Falls back to inexact alarms |

---

## Defaults

Almost everything is off by default — you opt in.

| Setting | Default |
|---|---|
| Theme | Dark |
| Notifications | Off |
| Sticky notifications | Off |
| Repeat notification sound | Off |
| Show sunnah prayers | Off |
| Track prayers | **On** |
| Language | English |
| Calculation method | Egyptian General Authority |
| Madhab | Shafi (Standard) |
| Location | Cairo |

---

## Localisation

English and Arabic are supported. Translation strings live in `l10n/app_en.arb` and `l10n/app_ar.arb`; the generated Dart files are produced by `flutter gen-l10n` on build.

To add a new locale:
1. Create `l10n/app_<locale>.arb`
2. Add the locale to `supportedLocales` in the generated `AppLocalizations`
3. Rebuild

---

## Credits

- **[adhan](https://pub.dev/packages/adhan)** by [Batoul Apps](https://github.com/batoulapps) — the astronomical algorithms behind every prayer time in this app. Without it, none of this would work. Thank you.
- The wider Dart & Flutter community for the ecosystem this is built on.

---

## License

This project is licensed under the **GNU General Public License v3.0**. See [LICENSE](LICENSE) for the full text.

In short: you're free to use, modify, and redistribute this software, but any derivative work must also be released under the GPL and must include the source.

---

## Author

**Mohamed Ayman** — [@Mohamed-Ayman333](https://github.com/Mohamed-Ayman333)