# AGENTS.md — WeatherFit Developer Guide

## Hexagonal Architecture

Layers in `lib/`:

- **Entities** — pure Dart business objects
- **Use Cases** → **Repositories** → **Data Sources** (Remote/Local sharedprefs)
- **UI** (`weather/`, `search/`) — BLoC + Flutter widgets
- **Services** — cross-cutting concerns (device type, feedback, widgets,
  updates)

**Rule:** Dependencies point inward. UI → Repos; Repos never import UI.

---

## State Management (BLoC + HydratedBloc)

- Events are sealed classes (Dart 3.0+):
  `final class FetchWeather extends WeatherEvent`
- Dispatch events: `context.read<WeatherBloc>().add(FetchWeather(...))`
- Never call Bloc methods directly
- `HydratedBloc` persists state: temp dir (mobile), IndexedDB (web)
- Bloc observer logs transitions at `lib/weather_bloc_observer.dart`

---

## Multi-Platform Build

### Device Detection

Use from `lib/extensions/build_context_extensions.dart`:

- `context.isExtraSmallScreen` — Wear OS
- `context.isWearDevice` — any watch
- `context.kWideLayoutBreakpoint` — tablet/desktop

### Build Flavours (Two Android flavours)

```bash
flutter run                             # Default: phone
flutter run --flavor wear               # Wear OS
flutter build appbundle --flavor phone  # Release phone
flutter build appbundle --flavor wear   # Release Wear OS
```

**Key:** Debug auto-selects phone; release requires explicit flavour.

---

## Dependency Injection (`lib/di/injector.dart`)

**Order matters:** SharedPrefs → Hydrated Storage → Date formatting →
Repositories

Parallel tasks via `Future.wait()` speed startup. Background widget updates use
`Workmanager`:

- Android respects 15-min frequency
- **iOS ignores frequency hint; OS schedules ~1x/day based on usage/battery**

Don't assume iOS background tasks execute predictably.

---

## Critical Services

| Service                | Purpose                                       | Location                                         |
|------------------------|-----------------------------------------------|--------------------------------------------------|
| `HomeWidgetService`    | Sync weather to native widgets                | `lib/services/home_widget_service*.dart`         |
| `FeedbackService`      | Send feedback email (Resend API)              | `lib/services/feedback_service.dart`             |
| `UpdateService`        | In-app Android updates                        | `lib/services/update_service.dart`               |
| `DeviceTypeService`    | Classify device; called before DI in `main()` | `lib/services/device_type_service.dart`          |
| `Forecast Aggregation` | Logic for Morning/Day/Evening summaries       | `lib/services/forecast_aggregation_service.dart` |

---

## API & Data

**Weather providers (packages/weather_repository/):**

- Primary: OpenMeteo (free)
- Fallback: OpenWeatherMap (API key in `.env`)
- `FallbackWeatherProvider` tries primary; retries secondary on fail
- Debug override: `LocalDataSource.getDebugWeatherProviderOpenWeatherMap()`

**Location:** Nominatim API in `packages/nominatim_api/`

**After API model changes:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Testing

- **BLoC tests:** `test/weather_bloc_test.dart` with `bloc_test` package
- **Widget tests:** `test/*_test.dart` with mock repos
- **Run:** `flutter test`
- **Coverage:**
  `flutter test --coverage && genhtml coverage/lcov.info -o coverage`

---

## Commands & Quick Patterns

```bash
flutter analyze .                                    # ALWAYS before committing
flutter format lib/
flutter build appbundle --release --flavor phone
dart run build_runner build --delete-conflicting-outputs
```

**Access weather state:**

```dart

final weather = context
    .read<WeatherBloc>()
    .state
    .weather;
```

**Add new route:** Enum in `lib/router/app_route.dart` → page file → register in
`routes.dart`

**Add BLoC feature:** `lib/my_feature/bloc/` → register in `WeatherFitApp` → UI
page

---

## Code Style

- Trailing commas on multi-param functions/calls
- Single quotes for strings; `const` constructors
- Always specify types (`final`, not `var`); max 80 chars
- Explicit `else` blocks (no guard clauses)
- Positive conditionals over negation
- One class per file (except Statefull widgets, Bloc events/states)
- No `// ignore:` or `// ignore_for_file:` — fix linter issues properly
- Follow [Effective Dart](https://dart.dev/effective-dart/design): avoid classes
  with only static members; use top-level functions or constants instead.

**CRITICAL:** `flutter analyze .` output must be **completely clean** before
completion.

---

# ⚠️ Line Limit Policy

**This file must never exceed 200 lines.** If new information is needed, remove
something less critical. Keep signal-to-noise ratio high — only essential,
non-obvious patterns stay.

