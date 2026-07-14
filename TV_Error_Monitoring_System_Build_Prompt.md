# BUILD PROMPT: Integrated Error Observability & Control Room System (Flutter TV App)

## ROLE

You are a senior Flutter engineer and observability architect. You specialize in building production-grade error monitoring systems for Android TV / Google TV applications. You do not build prototypes or partial demos — you deliver complete, working, production-ready systems.

## CONTEXT

- **Target app**: An existing Flutter application, TV version only (Android TV / Google TV). This is a separate app from any mobile/game project — do not assume mobile-specific concerns apply.
- **Developer**: Solo developer. Follows strict architectural discipline: Single Responsibility Principle, no God classes, no God files, feature-based folder structure, clear separation of concerns.
- **Design language already established for this developer's products**: clean and flat. No gradients, no colored card stripes, no emoji icons, no decorative badges. Professional, minimal, high signal-to-noise visual style.
- **Before writing any code**, scan the existing codebase to detect: state management library in use (Riverpod / Bloc / Provider / GetX / other), dependency injection approach, existing folder structure, and current logging/analytics packages already installed. Do not assume — verify from the code.

## MISSION

Build a complete, integrated **Error & Functional Health Observability System** made of four layers. All four are mandatory. None may be skipped, stubbed, or left as "future work."

1. **Instrumentation Layer** — captures and enriches every error inside the app.
2. **Ingestion & Storage Layer** — receives, deduplicates, stores, and pushes errors in real time.
3. **Functional Health Monitoring Layer** — detects *silent failures*: cases where a critical user-facing behavior did not happen as expected, even though no exception was thrown.
4. **Control Room Layer** — a separate, dedicated, beautiful real-time dashboard where the developer watches both errors and functional health as they happen.

## HARD REQUIREMENTS (non-negotiable)

- No placeholder code. No `// TODO: implement this`. No silently-swallowed exceptions anywhere in the app.
- Every error type must be captured: fatal crashes, caught/handled exceptions, failed network/API calls, corrupted local data/cache errors, video playback errors, navigation/focus errors, and unexpected UI/render errors (e.g. layout overflow).
- **Every captured error record must include:**
  - Exact origin: file name, class/widget name, method/function name (and line number when available)
  - The screen/route that was active when the error occurred
  - A human-readable category (e.g. "Video Playback", "Remote Navigation", "Authentication", "Content API", "Local Storage")
  - Full, symbolicated stack trace (never obfuscated/minified in the report)
  - A breadcrumb trail: the last 15–20 user actions, navigation events, focus changes, and API calls leading up to the error
  - TV-specific device context: device model, Android TV OS version, screen resolution, remote input type (D-pad vs. voice vs. air-mouse), available RAM / memory pressure at the moment of the error
  - App context: app version, build number, environment (dev/staging/prod), anonymized session ID
  - Network state at time of error: connected/disconnected, WiFi/Ethernet, and latency if relevant to the error
  - Severity classification: Fatal / Error / Warning / Info
  - First-seen timestamp, last-seen timestamp, and occurrence count — identical errors must be grouped by fingerprint, never duplicated as separate entries
  - A short "likely cause" hint for recognizable/common Flutter or Android TV error patterns (e.g. "RenderFlex overflow — check widget constraints on this screen")
- The system must remain reliable with unstable/no internet: buffer errors locally and auto-sync once connectivity returns. TVs frequently have unreliable WiFi — this is not optional.
- The error-reporting system must be defensively coded so that it can **never itself cause a crash** while trying to report a crash.
- Not every problem throws an exception. Critical user-facing behaviors (see Functional Health Monitoring Layer below) must be tracked by explicit success/failure events, not inferred from the absence of an error.

## ARCHITECTURE TO IMPLEMENT

### 1. Instrumentation Layer
- A centralized `ErrorReportingService` (interface + implementation), injected through whatever DI pattern already exists in the codebase. Single Responsibility only — do not let this class do logging, analytics, AND UI concerns at once; split into collaborators if needed.
- Hook all global error sources:
  - `FlutterError.onError`
  - `PlatformDispatcher.instance.onError`
  - Wrap the app entry point in `runZonedGuarded`
  - Bridge native-side (Kotlin/Java) crashes on Android TV through a platform channel so native crashes are captured too, not just Dart-side errors
- Build a lightweight `BreadcrumbRecorder`: appends an entry on every navigation change, remote/D-pad focus change, button press, and outbound API call. Keep it a rolling buffer (bounded size) so it never grows unbounded.
- Use a `Result`/`Either`-style return type at repository and use-case boundaries so *expected* failures (e.g. API timeout) are reported with full context instead of being caught-and-ignored.

### 2. Ingestion & Storage Layer
- **Backend: Firebase (Firestore + Cloud Functions).** This is fixed — do not consider or propose alternatives. The Firebase project/infrastructure already exists in this app; inspect the existing codebase to find the current Firebase configuration (project ID, existing collections, existing Cloud Functions) and integrate with it rather than creating a new, separate Firebase setup. Only ask the developer if you genuinely cannot locate the existing Firebase configuration.
- Local offline queue (Hive/Isar/SQLite — pick whichever is already used in the project, or the lightest option if none is) to buffer error events when offline; auto-flush in order once back online.
- A server-side function that: deduplicates incoming errors by fingerprint (hash of error type + location + top stack frame), assigns/confirms severity, and triggers an alert (push notification, Telegram bot, Discord webhook, or email — ask the developer which channel they want) whenever a brand-new error type appears or an existing error spikes in frequency.

### 3. Functional Health Monitoring Layer
This layer exists because not every failure throws an exception. A feature can silently fail to do what it's supposed to do — audio that never plays, a countdown that freezes, the wrong prayer showing up next — and the standard error layer above will see nothing wrong. This layer catches exactly that class of problem. This app's core purpose is telling the user about prayer times correctly and on time, so this layer is not optional polish — it is the most important layer in the whole system.

Implement these two specific flows (mandatory, not illustrative examples):

**A. Adhan alert flow — per prayer**
Track each of the 5 daily prayers independently by name (Fajr, Dhuhr, Asr, Maghrib, Isha). For each one, log this exact sequence as it happens:
`countdown_reached_zero` (the countdown for this prayer hit 0) → `alert_screen_shown` (did the adhan screen actually render and become visible) → `adhan_audio_started` (did the audio player actually begin playback — not just "was called," confirm playback actually started) → `adhan_audio_completed` (did it finish, or did it get cut off/error out partway).
- If `countdown_reached_zero` fires but `alert_screen_shown` never follows: log a silent failure — "Adhan screen did not appear for [prayer name]."
- If `alert_screen_shown` fires but `adhan_audio_started` doesn't fire within a few seconds: log a silent failure — "Adhan screen appeared but no sound started for [prayer name]" (this is the single most user-visible failure mode for this app — treat it as Fatal severity).
- If `adhan_audio_started` fires but `adhan_audio_completed` never follows: log a silent failure — "Adhan audio for [prayer name] started but did not finish" — capture how many seconds of audio actually played before it stopped.
- **Cross-check against flow B below**: if a `prayer_transition` event fires (the app moves on to counting down the next prayer) but `adhan_audio_started` was never logged for the prayer that just ended, log a Fatal silent failure — "Adhan never triggered for [prayer] — app silently moved to the next prayer without sounding it." This is distinct from a sequence skip: the order of prayers was correct, but the adhan itself for the finished prayer never actually played.

**A2. Iqama alert flow — per prayer (only if this app has an Iqama feature; confirm from the codebase/settings before implementing)**
Same pattern as adhan, offset by the configured Iqama delay: `iqama_scheduled` (fires N minutes after `adhan_audio_completed`, per the app's configured delay) → `iqama_triggered` (did the Iqama announcement actually play).
- If `iqama_scheduled` fires but `iqama_triggered` never follows within the expected window, log a silent failure — "Iqama did not sound for [prayer name]."

**B. Prayer sequence integrity check**
This directly targets a real bug class this app has had before: the countdown for one prayer ends and the app jumps to the wrong next prayer (e.g. Asr's countdown finishes and the app jumps straight to Fajr instead of correctly moving to Maghrib).
- Define the fixed daily order: Fajr → Dhuhr → Asr → Maghrib → Isha → (next day) Fajr.
- Every time the app transitions its "currently active/next prayer" state, log a `prayer_transition` event containing: the previous prayer shown, the new prayer now shown, and the timestamp.
- Compare every transition against the fixed order above. If the new prayer is not the correct immediate next one in sequence (i.e. a prayer got skipped), log this as a **Fatal** silent failure — "Prayer sequence skipped: went from [previous] to [new], expected [correct next]." Include full state at the time: device local time, timezone setting, and whichever prayer-time calculation data was active.
- This check must run on every single transition, not sampled — it is cheap to check and a skipped prayer is a serious, high-visibility bug for this app specifically.

For continuously-running UI state like the countdown timer itself: instrument a periodic self-check (the countdown widget reports "still ticking" on an interval); if no report arrives for longer than the interval allows, treat it as a stall and report it the same way as a silent failure, tagged with which prayer's countdown froze.

Only these flows are required for launch. Do not attempt to auto-instrument every other feature in the app under this layer — this layer covers exactly the behaviors named above, where a silent failure would defeat the entire purpose of the app.

### 4. Control Room Dashboard (separate, real-time)
This is a **hard requirement**, not optional. A generic third-party crash console (e.g. the default Firebase Crashlytics UI) is not sufficient on its own — a dedicated dashboard tailored to this app is required.
- Recommended: a Flutter Web dashboard (keeps a single language/toolchain with the rest of the project). Acceptable alternative: a Next.js dashboard, if the developer prefers a web-native stack.
- Visual style: dark-mode-first, flat, clean. No gradients. No decorative badges. No emoji icons. No colored card stripes. High information density without clutter.
- Functional requirements:
  - Live feed of incoming errors via real-time listener — no manual refresh
  - Errors grouped by fingerprint (collapsible), showing count + last-occurred time per group
  - Silent failure incidents (from the Functional Health layer) appear in the same live feed, clearly labeled by which flow/step failed — not hidden in a separate, easy-to-forget tab
  - Filters: severity, screen/module, app version, date range, and flow name
  - Detail drill-down per error: full stack trace, visual breadcrumb timeline, full device/context panel, and a small occurrence-over-time graph
  - Detail drill-down per silent failure: which steps of the flow completed, which step never arrived, and how long it waited before timing out
  - Search bar across error messages and categories
  - A top-level health summary: crash-free session rate, error count today vs. yesterday, top 5 most frequent current errors, and success rate per critical flow (e.g. "adhan playback succeeded 98.4% of sessions today")
  - Optional: a subtle visual/sound alert when a new Fatal error or silent failure arrives while the dashboard is open

### 5. Optional (nice-to-have, modern touch)
When a brand-new error fingerprint is first seen, optionally call an LLM API to generate a one-sentence, plain-language root-cause hypothesis based on the stack trace and breadcrumb trail, and display it in the drill-down panel. This is a bonus feature — do not let it block or complicate the core requirements above.

## DELIVERABLES

1. Full working instrumentation code, integrated into the existing app under a clearly separated module (e.g. `lib/core/error_reporting/...`), following the project's existing folder conventions.
2. Backend setup: data schema/collections, server-side functions code, and security rules.
3. The Control Room Dashboard as a complete, runnable application.
4. A numbered, step-by-step **Manual Setup Guide** covering everything that cannot be automated — e.g. creating the backend project, enabling the database, generating and placing service account keys, deploying server-side functions, setting environment variables/secrets, and any required Android TV manifest permissions. Write it for someone doing this for the very first time — exact steps, exact screens, exact commands.
5. A short README covering: system architecture overview, how to trigger a test error to verify the pipeline end-to-end, and notes on how this could later be extended to a mobile version of the app.

## QUALITY BAR

- Production-grade, not a prototype.
- Strict SOLID / Single Responsibility — no God classes, no God files.
- Fully typed, with comments explaining *why* a decision was made, not just *what* the code does.
- Include basic unit tests for the fingerprinting/deduplication logic at minimum.

## WHAT TO AVOID

- Do not just wrap code in try/catch and `print()` to console.
- Do not rely solely on a third-party crash console's default UI as the only way to view errors.
- Do not skip or generalize away TV-specific context — this is explicitly a TV app, not a mobile app.
- Do not deliver any file containing "implement the rest here"-style comments.
- Do not guess silently on consequential decisions (alert channel, whether to reuse existing Firebase collections vs. new ones) — ask.

## FIRST STEP

Do not explain the idea back or produce a general walkthrough before starting — investigate the existing codebase yourself (state management, DI approach, folder structure, any backend already in use) and proceed directly to building.

The only exception: if you hit a genuinely blocking decision that materially changes the architecture (e.g. you cannot locate the existing Firebase configuration, or there's no clear alert channel to use), stop and flag that specific point to the developer directly — do not silently guess on a decision of that weight, and do not wrap it in a long explanatory report.
