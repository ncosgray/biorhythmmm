# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

Biorhythmmm is a Flutter mobile app (Android 7+/iOS 13+) that charts personal
biorhythm cycles. Published to Google Play and the App Store as
`com.nathanatos.Biorhythmmm`. Free, open source, BSD-licensed.

## Commands

- `flutter pub get` — install dependencies
- `flutter analyze` — static analysis (uses flutter_lints plus extra rules in
  `analysis_options.yaml`; keep new code lint-clean, e.g. `cascade_invocations`
  and `prefer_single_quotes` are enforced)
- `flutter test` — run unit/widget tests in `test/`
- `flutter test test/<file>` — run a single test file
- `./run_screenhots.sh` — automated localized screenshot collection via the
  integration test in `integration_test/` (requires emulators/simulators;
  don't run casually)
- Releases are managed with fastlane (`fastlane/`)

## Architecture

- `lib/main.dart` — app init: preferences, locale, time zone, notifications
- `lib/data/biorhythm.dart` — core domain: `Biorhythm` enum (7 cycles with
  cycle lengths, colors), sine-wave point calculation, trend/critical logic
- `lib/data/app_state.dart` — single `AppStateCubit` (flutter_bloc) holding
  `AppState`; every setter persists to `Prefs` then emits
- `lib/data/prefs.dart` — static `Prefs` wrapper over
  `SharedPreferencesWithCache`, including legacy pref migration and the
  `BirthdayEntry` JSON model
- `lib/data/localization.dart` — custom JSON-based localization
  (`AppString` enum keys → `langs/<locale>.json` files); falls back to
  English for missing keys
- `lib/common/` — helpers (date math in `helpers.dart` uses the `timezone`
  package), notifications scheduling, themes, styles, platform-adaptive
  buttons/modals (via `dart:io Platform.isIOS` checks)
- `lib/widgets/` — UI: `home_page.dart`, `biorhythm_chart.dart` (fl_chart,
  interactive), `settings_sheet.dart`, birthday/compare managers

## Conventions

- Source files start with the standard copyright header block; keep it when
  creating new files
- Platform-adaptive UI: iOS gets Cupertino-style widgets, everything else
  Material — follow the `Platform.isIOS` pattern in `lib/common/buttons.dart`
- User-facing strings must be added as `AppString` enum values and to
  `langs/en.json` (other language files fall back to English until translated)
- Dates are compared as calendar days via `dateDiff` in
  `lib/common/helpers.dart` (time-zone/DST aware); don't use raw
  `DateTime.difference`

## Testing

- Tests live in `test/`; shared setup is in `test/test_helpers.dart`
  (`initTestEnvironment()` wires in-memory shared preferences, a fake
  notifications platform, time zone data, and English localizations)
- In widget tests, call `initTestEnvironment()` INSIDE the `testWidgets`
  body (see `pumpTestApp`), never in `setUp`: asset/localization futures
  created outside the test's fake-async zone deadlock when awaited, and
  `rootBundle` futures cached by a previous test's zone do the same
  (`initTestEnvironment` calls `rootBundle.clear()` to guard against this)
- CI runs `flutter analyze` and `flutter test` on pushes to main and PRs
  (`.github/workflows/tests.yml`)
