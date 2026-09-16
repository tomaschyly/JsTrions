# JT-139 — Sentry for crash reporting
Started: 2026-09-16

Scope: add crash and error reporting for all desktop builds (macOS, Windows MSIX, Linux Snap) using Sentry, because
Firebase Crashlytics does not support Windows or Linux. Release target: 1.7.0.

## Meeting focus

Label legend:
- `**[DECISION]**` — needs a product or architecture choice before implementation can be finalized.
- `**[VERIFY]**` — needs review or validation, but likely does not need a product decision.
- `**[BLOCKER]**` — blocks dependent implementation work.

Current focus:
- [ ] **[DECISION]** **[BLOCKER]** Sentry SaaS vs. self-hosted GlitchTip (Phase 1) — blocks Phase 2
- [ ] **[DECISION]** Consent model: opt-in vs. opt-out with Settings toggle (Phase 1)
- [ ] **[DECISION]** Which data is allowed in events: breadcrumbs, file paths, screen names (Phase 1)
- [ ] **[VERIFY]** Native crash capture works inside MSIX, strict Snap and macOS sandbox (Phase 4)

## Current state

| Area | Location | Notes |
| --- | --- | --- |
| Entry point | `lib/main.dart:4` | plain `runApp(App())`, no error handlers |
| App init | `lib/app.dart:80` | `onAppInitStart` → `initDesktop()`, `onAppInitEnd` → `initOpenAIClient()` |
| Global error handling | — | no `FlutterError.onError`, `PlatformDispatcher.instance.onError` or `runZonedGuarded` |
| Prefs | `lib/core/app_preferences.dart:1` | int prefs map + `clearAllAppPrefs()` |
| Settings UI | `lib/ui/screens/settings_screen.dart:212` | `_GeneralWidget` is the natural place for a reporting toggle |
| macOS sandbox | `macos/Runner/Release.entitlements` | `network.client` already enabled |
| Snap | `snap/snapcraft.yaml` | `confinement: strict`, `network` plug present |
| MSIX | `pubspec.yaml:91` | `capabilities: "internetClient"` |

Package check (2026-09-16, re-verify before adding):
- `sentry_flutter` latest stable `9.30.0` (2026-09-10), newest eligible 30+ days: `9.27.0` (2026-08-13)
- `10.0.0` is still alpha (`10.0.0-alpha.5`, 2026-09-08), requires Flutter `>=3.44.0` — do not use until stable and 30+ days old

## Constraints

- Dependency rule: only versions public for 30+ days, verify release dates on pub.dev and note the choice here.
- JsTrions works with users' own project files: no file contents, translation values, API keys or PII in events.
- Services stay functional and stateless-style in `lib/service/`.
- All user-facing text through `tt(...)`, new keys scoped to their context, no translation file edits unless asked.
- DSN must not be committed in a way that makes forks report into the official project (pass at build time).
- App must start and work normally when Sentry is disabled, DSN is missing or network is unavailable.

### Phase 1 — Decisions and setup

- [ ] **[DECISION]** **[BLOCKER]** Sentry SaaS (Developer plan) vs. self-hosted GlitchTip, check current free quotas
- [ ] **[DECISION]** Consent model: opt-in on first start (welcome flow, `kPrefsWelcome`) vs. opt-out toggle in Settings
- [ ] **[DECISION]** Allowed event data: breadcrumbs (navigation, http), screen/route names, OS info; scrub home dir paths
- [ ] Create Sentry project(s): one project with `environment` per platform/store vs. one project per platform
- [ ] Configure inbound filters, rate limits and data scrubbing on the Sentry side
- [ ] DSN delivery: `--dart-define=SENTRY_DSN=...` (empty in debug / forks → Sentry disabled)

### Phase 2 — SDK integration

- [ ] Add `sentry_flutter` pinned to the eligible version, record version and release date here
- [ ] Crash reporting service in `lib/service/` (init options, enabled check, `beforeSend` scrubbing)
- [ ] `lib/main.dart`: `SentryFlutter.init` wrapping `runApp` when enabled, plain `runApp` otherwise
- [ ] Options: `sendDefaultPii = false`, `release` from `package_info_plus` (`js_trions@x.x.x+build`), `environment`
      (`debug` / `release`), `dist` / tag for store (`msix`, `snap`, `macos`)
- [ ] `beforeSend` / `beforeBreadcrumb`: strip user home paths, project paths, translation values, OpenAI API key patterns
- [ ] Navigation breadcrumbs via `SentryNavigatorObserver` next to `BotToastNavigatorObserver` in `lib/app.dart`, if allowed by Phase 1
- [ ] Report handled errors in existing catch blocks where failures are unexpected (file IO, analysis, AI translate) — review each, do not report valid user states

### Phase 3 — Consent UI and prefs

- [ ] Pref for crash reporting in `lib/core/app_preferences.dart` (default per Phase 1 decision), include in `clearAllAppPrefs()`
- [ ] Settings toggle in `_GeneralWidget` with short description of what is sent
- [ ] Apply toggle without restart (close / re-init Sentry) or clearly state restart is needed
- [ ] Opt-in prompt in welcome flow, if chosen in Phase 1

### Phase 4 — Platform builds and native crashes

- [ ] macOS: debug + release build, verify Dart error and native crash reach Sentry from sandboxed app
- [ ] Windows: verify native crash handler (crashpad) works when installed from MSIX
- [ ] Linux: verify native crash handler inside strict Snap (crashpad handler executable, writable cache dir), Dart errors at minimum
- [ ] **[VERIFY]** Native crash capture per platform, document what does not work
- [ ] Check app size increase per platform

### Phase 5 — Symbols and release process

- [ ] `sentry_dart_plugin` (eligible version) or `sentry-cli` for debug symbols upload per platform
- [ ] Decide on Dart obfuscation (`--obfuscate --split-debug-info`) and upload of the mapping
- [ ] Auth token only in local env / CI secrets, never committed
- [ ] Document build commands with `--dart-define` for MSIX, Snap and macOS release in README or release notes
- [ ] Verify release version shown in Sentry matches `pubspec.yaml` after the 1.7.0 bump

### Phase 6 — Privacy and store listings

- [ ] Privacy policy on website: crash reporting, data sent, provider, retention, how to disable
- [ ] Mac App Store privacy label (Crash Data, Diagnostics — not linked to user)
- [ ] Microsoft Store and Snap Store listing / privacy info update
- [ ] Final check: trigger test error in release build per platform, confirm event content has no private data
