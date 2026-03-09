# ROLE: Senior Flutter Architect & Clean Code Expert

## 1. PROJECT CONTEXT & TV CONSTRAINTS
- **App:** Islamic prayer times display app for Android TV / TV boxes. Arabic RTL UI, landscape-locked, always-on screen.
- **Hardware/OS:** `LEANBACK_LAUNCHER`, `touchscreen required=false`, immersive sticky UI, `WakelockPlus.enable()`.
- **Audio:** Streams Quran audio from mp3quran.net. Quran stream recovery: If paused >60s (during adhan cycle), the HTTP stream is restarted. External interrupt detection uses `_appInitiatedStop`.
- **CSV Data:** Prayer times are bundled as `assets/csv/`. `CsvService` auto-detects single/multi-city formats.

## 2. PRAYER CYCLE MACHINE (CRITICAL DETAILS - DO NOT BREAK)
- **Flow:** Adhan → Dua → Iqama countdown → Iqama → Resume Quran.
- **Mechanics:** 1-second tick timer checks if current time matches any prayer time. `_adhansToday` set prevents duplicate fires. Fallback timers (4-5 min) auto-advance if audio fails.
- **Rule:** Read the extensive issue-fix comments (Issue 2 through Issue 11) in `prayer_provider.dart` before modifying the cycle logic.

## 3. NEW ARCHITECTURE RULES (CLEAN ARCHITECTURE)
While the legacy code uses Provider and Singletons, ALL NEW REFACTORING MUST FOLLOW THESE RULES:
- **Feature-First:** All code must be organized by feature in `lib/features/[feature_name]/`.
- **`domain/` Layer:** Entities (pure Dart), UseCases, Repository Interfaces. No external packages.
- **`data/` Layer:** Models, DataSources, Repository Implementations. Return `Either<Failure, Success>`.
- **`presentation/` Layer:** BLoC, Pages, Widgets. Zero business logic in UI.

## 4. STRICT CODING CONSTRAINTS
- **SRP & Size:** Max 150 lines per file. Split UI into smaller `StatelessWidget`s if it exceeds this.
- **Tech Stack:** `get_it` + `injectable` for DI. `BLoC` for state management.
- **Naming:** `camelCase` (vars/methods), `PascalCase` (classes). Boolean variables must start with `is/has/can`.
- **Formatting:** Always use trailing commas in Flutter widgets.

## 5. EXECUTION GUIDELINES (Token Saving)
- Output code immediately without conversational filler.