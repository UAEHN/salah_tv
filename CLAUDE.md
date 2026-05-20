# ROLE: Senior Flutter Architect & Clean Code Expert

## 1. PROJECT CONTEXT & TV CONSTRAINTS
- **App:** Islamic prayer times display app for Android TV / TV boxes. Arabic RTL UI, landscape-locked, always-on screen.
- **Hardware/OS:** `LEANBACK_LAUNCHER`, `touchscreen required=false`, immersive sticky UI, `WakelockPlus.enable()`.

## 2. PRAYER CYCLE MACHINE (CRITICAL DETAILS - DO NOT BREAK)
- **Flow:** Adhan → Dua → Iqama countdown → Iqama → Resume Quran.
- **Mechanics:** 1-second tick timer checks if current time matches any prayer time. `_adhansToday` set prevents duplicate fires. Fallback timers (4-5 min) auto-advance if audio fails.
- **Engine:** `PrayerCycleEngine` (`lib/features/prayer/domain/prayer_cycle_engine.dart`) coordinates 8 mixins under `lib/features/prayer/domain/engine/` (10 files total: 8 mixins + `prayer_cycle_state.dart` + `prayer_cycle_base.dart`). Mixins: `adhan_cycle_mixin`, `iqama_mixin`, `quran_mixin`, `quran_modes_mixin`, `continuous_mode_mixin`, `tick_mixin`, `recovery_mixin`, `settings_mixin`. Issue-fix guards (Issues 2–11) are preserved as comments in those mixin files — read them before modifying cycle logic.
- **Rule:** Never bypass the engine. All cycle transitions (adhan → dua → iqama → quran) must go through engine methods; never call audio or repo directly from the BLoC.

## 3. ARCHITECTURE RULES (CLEAN ARCHITECTURE)
- **Feature-First:** All code in `lib/features/[feature]/domain|data|presentation/`.
- **`domain/`:** Pure Dart — Entities, UseCases, Repository Interfaces. Only `dartz` is allowed (for `Either<Failure, Success>` on async operations). No other external packages. Every cross-layer call goes through a use-case or interface.
- **`data/`:** Models, DataSources, Repository Implementations. Return `Either<Failure, Success>`. No raw exceptions escaping this layer.
- **`presentation/`:** BLoC, Pages, Widgets. Zero business logic in UI. `build()` must be side-effect-free.
- **Feature isolation:** No feature imports another feature's `data/` or `presentation/`. Cross-feature = domain interfaces only.
- **Use-cases:** Every new domain operation crossing a layer boundary gets a thin use-case. Engine tick (1 Hz hot path) may call repo directly — add a comment explaining why.
- **State boundary:** `SettingsProvider` = persistence only. `PrayerBloc`/`PrayerState` = all prayer runtime. Never read `SettingsProvider` for prayer-runtime data; use `PrayerBloc.state`.
- **Bridge:** `_SettingsBridgeWrapper` uses `addListener`, NOT `build()`. Events fire only on real changes.
- **DI:** Async-init services → `app_startup.dart`. Sync-init services → `@injectable` in `injection.dart`. Nothing registered in `main()`.
- **HTTP:** Prefer `Dio` only; do not add `package:http` and remove it if unused. All URLs/keys in `lib/core/app_config.dart`, never inlined.
- **Immutability:** `Map` fields in domain entities use `Map.unmodifiable()` in `copyWith()`. No factory singletons — `getIt` is the sole lifetime owner.
- **`build()` purity:** No state mutations, BLoC dispatches, or audio/network calls in `build()`. Use `didChangeDependencies()` + `addListener`, `BlocListener`, or lifecycle methods for side effects.
- **Cross-feature BLoC access:** Widgets may read/dispatch to another feature's BLoC via the widget tree (`context.read/watch/select`). Direct file-level instantiation of another feature's data or presentation classes is prohibited.
- **Datasource exceptions:** Datasources throw typed exceptions (`ServerException`, `StorageException` in `core/error/failures.dart`). Repositories catch all datasource exceptions and return `Either<Failure, T>`. No raw `Exception` types.
- **UI boundaries:** Never instantiate `UseCase`/Repository inside Widgets. UI only reads state and emits events.
- **Presentation DI guard:** Avoid `context.read<...Repository>()` in page/widget code; allow only in dedicated container/bridge widgets.
- **No logic helpers in widgets:** Time math, filtering, key-policy, and selection rules must live in `presentation/bloc|logic|mapper` files.
- **Startup composition:** Keep `app_startup.dart` as coordinator only; split platform/settings/prayer/feature registration into focused startup files.

## 4. STRICT CODING CONSTRAINTS
- **SRP & Size:** Max 150 lines per file. Split UI into smaller `StatelessWidget`s if it exceeds this.
- **Tech Stack:** `get_it` + `injectable` for DI. `BLoC` for state management.
- **Naming:** `camelCase` (vars/methods), `PascalCase` (classes). Boolean variables must start with `is/has/can`.
- **Formatting:** Always use trailing commas in Flutter widgets.
- **DRY:** If style constants/maps/formatting logic repeat in 2+ places, extract a shared file (`core/` or feature-level `*_style.dart`/`*_visuals.dart`).

## 5. EXECUTION GUIDELINES (Token Saving)
- Output code immediately without conversational filler.

## 6. STOP POINT (Project Clean Enough)
- No side effects in `build()` for critical widgets.
- Use `select/watch` for reactive values; avoid `context.read()` in `build()` when UI must react.
- Any remaining cross-feature imports are documented here as accepted exceptions.

## 7. QUALITY GATE (MANDATORY)
- Run `flutter analyze` before finalizing; app-layer errors must be zero.
- For moved logic (policy/mapper/calculator), add or update focused unit tests.
- Refactors must preserve behavior: no route, prayer-cycle, or settings-flow changes unless requested.
- Any temporary exception to these rules must be documented in this file with rationale.

## 8. ACCEPTED CROSS-FEATURE IMPORT EXCEPTIONS

| Import | Used In | Rationale |
|:---|:---|:---|
| `settings/presentation/logic/location_picker_logic.dart` (via `mobile_location_search_utils.dart`) | `onboarding/presentation/onboarding_state.dart`, `onboarding_country_loader.dart` | `UnifiedCountry` is defined in `settings/presentation/logic/` and used by 12+ files across `settings/presentation/`. Moving it to `settings/domain/entities/` is the correct long-term fix but carries high refactor risk. Accepted until a dedicated domain-layer migration task is scheduled. |
| `settings/presentation/settings_provider.dart` | `notifications/presentation/onboarding/notification_onboarding_gate.dart` | The gate uses `context.read<SettingsProvider>()` — the same widget-tree access pattern already used by `app.dart`, `mobile_shell.dart`, `adhkar/.../mobile_adhkar_reader_screen.dart`, etc. Importing the type only to use it in `context.read<T>()` is the spirit of the §3 widget-tree exception. The gate wraps the provider in a private `INotificationOnboardingFlagPort` adapter so every layer downstream sees only the notifications-domain interface. |

