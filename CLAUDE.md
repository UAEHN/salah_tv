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

## 5. QUALITY GATE (MANDATORY — BLOCKING)
- Run `flutter analyze` before finalizing; **zero errors AND zero warnings** in `lib/`. New `// ignore:` / `// ignore_for_file:` are forbidden unless added to §8 with rationale.
- Run `dart format .` before finalizing. No mixed formatting in PRs.
- For moved logic (policy/mapper/calculator), add or update focused unit tests in `test/`.
- Refactors must preserve behavior: no route, prayer-cycle, or settings-flow changes unless explicitly requested.
- Any temporary exception to these rules must be documented in §8 with: file, reason, and removal condition.
- **Definition of Done:** analyze clean + format clean + tests pass + manual smoke on the affected screen (TV or mobile) + no new TODOs left behind without a tracking note.

## 6. ACCEPTED CROSS-FEATURE IMPORT EXCEPTIONS

| Import | Used In | Rationale |
|:---|:---|:---|
| `settings/presentation/logic/location_picker_logic.dart` (via `mobile_location_search_utils.dart`) | `onboarding/presentation/onboarding_state.dart`, `onboarding_country_loader.dart` | `UnifiedCountry` is defined in `settings/presentation/logic/` and used by 12+ files across `settings/presentation/`. Moving it to `settings/domain/entities/` is the correct long-term fix but carries high refactor risk. Accepted until a dedicated domain-layer migration task is scheduled. |
| `settings/presentation/settings_provider.dart` | `notifications/presentation/onboarding/notification_onboarding_gate.dart` | The gate uses `context.read<SettingsProvider>()` — the same widget-tree access pattern already used by `app.dart`, `mobile_shell.dart`, `adhkar/.../mobile_adhkar_reader_screen.dart`, etc. Importing the type only to use it in `context.read<T>()` is the spirit of the §3 widget-tree exception. The gate wraps the provider in a private `INotificationOnboardingFlagPort` adapter so every layer downstream sees only the notifications-domain interface. |
| `quran/presentation/bloc/mushaf_reader_cubit.dart` + `quran/domain/entities/quran_bookmark.dart` | `today/presentation/widgets/bento/bento_mushaf_continue_tile.dart` | The «متابعة القراءة» shortcut on the Today tab reads the saved bookmark via `context.select<MushafReaderCubit, QuranBookmark?>()` — the cubit is hoisted above the IndexedStack in `mobile_shell.dart`, identical to how the Today screen reads `QiblaCubit`. Navigation itself goes through `MobileShell.openMushafReader(context)` so Today never instantiates the reader screen directly. |

## 7. PERFORMANCE & NO-JANK RULES (TV ALWAYS-ON CRITICAL)
- **60 FPS budget:** every frame ≤ 16 ms. The TV stays on 24/7 — a leak that's invisible on mobile becomes a crash overnight on TV.
- **`const` everything:** every widget that can be `const` must be `const`. Static lists/maps in widgets must be `static const` at file scope, never rebuilt inside `build()`.
- **Selective rebuilds:** prefer `BlocSelector` / `context.select` over `BlocBuilder` / `context.watch`. A `BlocBuilder` without a `buildWhen` on a 1 Hz stream (like `PrayerEngineRefreshed`) is a bug.
- **Heavy lists:** `ListView.builder` / `GridView.builder` only — never `ListView(children: [...])` for >10 items. Add `itemExtent` when row height is fixed.
- **Images:** always use `cacheWidth`/`cacheHeight` matched to display size. Network images go through `CachedNetworkImage` with explicit `memCacheWidth`. Never `Image.network` raw in widgets that scroll.
- **No `setState` in tick paths:** anything that fires per-second (clocks, countdowns) goes through a `ValueListenableBuilder` or a scoped `Bloc` — never a full-screen `setState`.
- **`build()` must be O(1) in widgets, not O(n) in data:** any list filtering, sorting, or time math must be done in BLoC/logic and cached in state. Widgets read prepared data only.
- **Animations:** prefer `AnimatedBuilder` with a single `AnimationController` per screen. Dispose every controller in `dispose()`. Long-lived animations on TV must pause when the screen is not visible.
- **Isolates for heavy work:** CSV parsing, JSON parsing >100 KB, image decoding pipelines → `compute()` or a dedicated isolate. Never block the UI thread.
- **Profile mode required:** before declaring a perf-sensitive change done, run in `--profile` and confirm no red bars in DevTools timeline.

## 8. CRASH & FREEZE PREVENTION (ZERO-TOLERANCE)
- **No raw `throw` in production paths:** every async boundary returns `Either<Failure, T>`. UI never sees an unhandled exception.
- **Global guard:** `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.instance.onError` must be wired in `main.dart` and route to the analytics/crashlytics sink. Never silently swallow.
- **Null safety:** no `!` (bang) operator outside `core/` utilities. Use pattern matching, `?.`, or explicit `if (x == null) return …`. A single `!` on a hot path can crash the TV daily.
- **Timers & subscriptions:** every `Timer`, `StreamSubscription`, `AnimationController`, `FocusNode`, `ScrollController`, `TextEditingController` MUST be cancelled/disposed in `close()` / `dispose()`. Add a `// disposed in <method>` comment at the declaration if non-obvious.
- **Audio resilience:** every audio call has a 5-min fallback timer (already in `PrayerCycleEngine` mixins). Audio failures must never block the cycle from advancing.
- **Network resilience:** every `Dio` call has a timeout (connect 10s, receive 15s) and returns `Either<NetworkFailure, T>`. Retries only via a single shared interceptor, never ad-hoc in repos.
- **DB resilience:** every `sqflite` write is wrapped in a transaction. Schema migrations bump `_dbVersion` and ship a tested migration path — never drop-and-recreate user data.
- **Platform channels:** every `MethodChannel` call is wrapped in `try/catch` returning `Either<PlatformFailure, T>`. Missing native implementations must degrade gracefully (TV detection falls back to `defaultTargetPlatform`).
- **No `async` in `initState`:** kick off async work via `Future.microtask` or `WidgetsBinding.instance.addPostFrameCallback`. Direct `await` in `initState` causes white-screen freezes.
- **`mounted` guard:** every `setState` after `await` MUST be preceded by `if (!mounted) return;`. Every BLoC `emit` after `await` MUST check `if (isClosed) return;`.

## 9. MEMORY & RESOURCE DISCIPLINE (24/7 UPTIME)
- **Singletons via `getIt` only:** never `static final _instance = …;`. Lifetime is `getIt`'s job.
- **Streams:** prefer `broadcast` streams for multi-listener cases. Single-subscription streams that leak listeners are the #1 cause of zombie BLoCs.
- **Image cache cap:** `PaintingBinding.instance.imageCache.maximumSizeBytes` must be capped (50 MB TV / 30 MB mobile) at startup.
- **No unbounded growth:** any `List`/`Map`/`Set` accumulated over time (history, logs, `_adhansToday`) must have an eviction rule (daily reset, max size, LRU). Document the rule next to the field.
- **Logs:** `debugPrint` in dev only. Production logs go through a single `core/logging/` sink with level gating. No `print()` anywhere.
- **Assets:** large assets (audio, fonts, images) are referenced from `pubspec.yaml` precisely — no `assets/` folder wildcards that pull unused files into the APK.

## 10. SCALABILITY & FUTURE-PROOFING
- **New feature checklist:** create `lib/features/<name>/{domain,data,presentation}/` skeleton + `i_<name>_repository.dart` interface + at least one use-case + a registration entry in `lib/core/startup/startup_features.dart`. Never bolt features onto existing folders.
- **No god-files:** if a BLoC exceeds 200 lines or a use-case exceeds 80 lines, split it. Engine-style mixin decomposition is the reference pattern (see §2).
- **Interfaces over concretions:** every cross-feature dependency is an `I<Something>` interface in `domain/`. Implementations are bound in startup. Swapping a backend (e.g. moving from `adhan_dart` to a server-rendered source) must require zero changes in `presentation/`.
- **Feature flags:** new behavior that can be toggled goes through `AppSettings` + `SettingsProvider`, never a hardcoded `bool`. This keeps rollback to a settings change instead of a code revert.
- **Public API of a feature = its `domain/` folder.** Anything in `data/` or `presentation/` is private to the feature. Adding a new public type means adding it to `domain/`.
- **No circular deps:** `core/` → nothing. `features/*/domain/` → `core/` only. `features/*/data/` → own domain + `core/`. `features/*/presentation/` → own domain + `core/`. Cross-feature only through domain interfaces. CI-equivalent check: `dart run import_lint` or manual grep before merge.
- **Localization:** every user-visible string goes through `AppLocalizations` (`l10n/*.arb`). No hardcoded Arabic/English literals in widgets — they cannot be translated later without a refactor.
- **Theming:** every color/text-style/spacing comes from `core/app_colors.dart` / a `*_style.dart` file. No `Color(0xFF...)` or `TextStyle(fontSize: ...)` inline in widgets.

## 11. BACKEND ↔ FRONTEND CONTRACT (TIGHT COUPLING, LOOSE BINDING)
- **One source of truth per data type:** an entity is defined ONCE in `features/<x>/domain/entities/`. Data-layer `Model`s extend or map to the entity via an explicit `*_mapper.dart`. Presentation never sees raw JSON.
- **State is derived, not duplicated:** if `PrayerState` exposes `nextPrayer`, the widget reads `nextPrayer` — it does NOT recompute it from `prayerTimes + DateTime.now()`. The BLoC owns derivation; the UI is a pure projection.
- **Events are intentions, not commands:** `PrayerAdhanStopped` (intention) ✅, not `CallAudioStopThenSetFlag` (command). The BLoC translates intention → engine call → state.
- **No partial states:** `PrayerState` always represents a fully consistent snapshot. Never `emit` mid-mutation. Build the new state, then emit once.
- **Repo contract = `Either<Failure, T>` always.** Presentation pattern-matches with `fold((failure) => …, (data) => …)`. No `try/catch` in widgets or BLoCs around repo calls.
- **DTO ≠ Entity:** if the JSON shape changes, only the `Model` + `Mapper` change. Entity stays stable. This is what makes the backend swappable.
- **Versioned cache keys:** cached responses include a schema version. Bumping the entity shape bumps the cache key prefix — no stale-deserialize crashes after an update.

## 12. SAFE-CHANGE PROTOCOL (BEFORE EDITING CRITICAL CODE)
Before touching any file under `prayer/domain/engine/`, `prayer/data/`, `audio/`, `notifications/` (native Kotlin), or `app_startup.dart`:
1. **Read the whole file**, not just the target line. Engine mixins have inline Issue-2..11 guards that look removable but aren't.
2. **Search for callers** with Grep before changing a signature. A method used by 3 mixins cannot be "simplified" in isolation.
3. **State your hypothesis** in one sentence before editing ("I'm changing X because Y, and Z should still hold").
4. **Make the smallest possible change.** No "while I'm here" refactors in critical paths.
5. **After editing:** `flutter analyze` → unit tests → manual smoke of the full adhan cycle on at least one prayer (use `PrayerAdhanTested` event).
6. **One phase at a time.** If a change is multi-step, stop after each phase and let the user verify on-device before continuing. (See `feedback_phased_execution.md`.)
7. **Behavior preservation is the default.** If a "cleanup" changes observable behavior (timing, order of events, state values), it is no longer a cleanup — it is a feature change and requires explicit user approval.
