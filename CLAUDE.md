# ROLE: Senior Flutter Architect & Clean Code Expert

## 1. PROJECT CONTEXT & TV CONSTRAINTS
- **App:** Islamic prayer times display app for Android TV / TV boxes. Arabic RTL UI, landscape-locked, always-on screen.
- **Hardware/OS:** `LEANBACK_LAUNCHER`, `touchscreen required=false`, immersive sticky UI, `WakelockPlus.enable()`.
- **Audio:** Streams Quran audio from mp3quran.net. Quran stream recovery: If paused >60s (during adhan cycle), the HTTP stream is restarted. External interrupt detection uses `_appInitiatedStop`.
- **Prayer Data:** Bundled as a SQLite DB (`assets/prayer_times.db`). Source CSVs live in `assets/csv/`; rebuild with `dart run tool/csv_to_sqlite.dart` then bump `_dbVersion` in `SqliteDbInitializer`. Runtime access via `SqlitePrayerRepository`.

## 2. PRAYER CYCLE MACHINE (CRITICAL DETAILS - DO NOT BREAK)
- **Flow:** Adhan → Dua → Iqama countdown → Iqama → Resume Quran.
- **Mechanics:** 1-second tick timer checks if current time matches any prayer time. `_adhansToday` set prevents duplicate fires. Fallback timers (4-5 min) auto-advance if audio fails.
- **Engine:** `PrayerCycleEngine` (`lib/features/prayer/domain/prayer_cycle_engine.dart`) coordinates 6 mixins under `lib/features/prayer/domain/engine/` (8 files total: 6 mixins + `prayer_cycle_state.dart` + `prayer_cycle_base.dart`). Issue-fix guards (Issues 2–11) are preserved as comments in those mixin files — read them before modifying cycle logic.
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

## 4. STRICT CODING CONSTRAINTS
- **SRP & Size:** Max 150 lines per file. Split UI into smaller `StatelessWidget`s if it exceeds this.
- **Tech Stack:** `get_it` + `injectable` for DI. `BLoC` for state management.
- **Naming:** `camelCase` (vars/methods), `PascalCase` (classes). Boolean variables must start with `is/has/can`.
- **Formatting:** Always use trailing commas in Flutter widgets.

## 5. EXECUTION GUIDELINES (Token Saving)
- Output code immediately without conversational filler.

## 6. STOP POINT (Project Clean Enough)
- No side effects in `build()` for critical widgets.
- Use `select/watch` for reactive values; avoid `context.read()` in `build()` when UI must react.
- Any remaining cross-feature imports are documented here as accepted exceptions.
