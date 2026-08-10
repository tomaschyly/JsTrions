# Tomas Chyly Appliable Core — Agent Instructions

These instructions apply to the whole repository unless a deeper `AGENTS.md` overrides them.

## Branch safety rule

- For implementation work (any non-planning/non-question-only task), if current branch is `main` or `master`, ask the user first whether to switch to a new `feature/*` branch before making edits.
- Do not start code changes on `main`/`master` until the user confirms how to proceed.
- **Exception — version bumps:** When the user asks to bump the app version, automatically create and switch to the `version/x.x.x` branch without asking.

## Release versioning rule

- Files that must be updated for each app version bump:
  - `pubspec.yaml`
    - `version: x.x.x+build`
    - `msix_config.msix_version: x.x.x.0`
  - `snap/snapcraft.yaml`
    - `version: x.x.x`
  - `windows/runner/Runner.rc`
    - `VERSION_AS_NUMBER x,x,x`
    - `VERSION_AS_STRING "x.x.x"`

- When user asks to bump app to `x.x.x`, follow this order:
  1. Ensure branch `version/x.x.x` exists and is checked out — create and switch to it automatically if missing, without asking the user.
  2. Update version values in all files listed above.
  3. Commit all version changes with message: `Next version`.

## General coding conventions

### Imports

- Always use absolute imports (`package:...`) instead of relative imports.
- When encountering errors with extensions or methods not found, first check if the required import is missing by finding working examples in similar files in the codebase.

### Code commenting

- Add comments for functions at minimum.
- Add additional comments around special or non-obvious logic.
- Follow the pattern of comments in Flutter, e.g., avoid last sentence dots.

### Runtime invariant handling

- Do not hide logically impossible `null` states with silent guard returns.
- If a value should always exist at that point in the flow, prefer a loud failure (`!`, thrown error, assertion, or equivalent) so runtime bugs are visible in logs.
- Use guard returns only for valid user/runtime states, not for broken invariants that should be investigated.

### Pattern consistency

- In every change, follow established patterns from related contexts in this project (similar screen, feature, layer, or widget type).
- Prefer consistency with existing structure and naming over introducing a new approach.
- If multiple patterns exist, choose the one used in the closest relevant files unless the user explicitly asks otherwise.
- When adding or moving methods, widget helpers, fields, constants, route entries, configuration values, or service functions, place them with the related code instead of at the end of the file or the first convenient location.
- Before editing a file, scan nearby declarations for the existing grouping/order pattern (for example fields before lifecycle methods, lifecycle methods before build helpers, callbacks near related UI, route display order, domain workflow order, or alphabetical order) and preserve it.
- For cross-file lists or registries that represent the same domain concept, keep the order consistent across the related files.

### Helpers and services architecture

- Keep generic helpers in `lib/service/`
- Keep helpers inside component files only when they are used exclusively by that component
- Write services in a functional, stateless style (function-based utilities), not OOP-style service classes with internal state

### TODO ownership format

- When adding TODO comments, use the format: `// TODO(name) some text`.
- Prefer `name` from `git config user.name` of the user running the agent.
- If the name is unknown, ask the user once, then remember and reuse it consistently.
- When completing user requests, treat existing TODOs as informational only; do not execute or integrate them unless the user explicitly asks for that TODO work.

### Enum conventions

- When creating enums, add `none` as the first option unless explicitly instructed otherwise.

### Dart dot shorthands (Flutter 3.38+)

- Prefer Dart dot shorthands in new/edited code when the type is inferable (for example `.start` instead of `MainAxisAlignment.start`, `.all(8)` instead of `EdgeInsets.all(8)`).
- Use dot shorthands for named constructors and enum/static values where it improves conciseness and readability.

### Date handling

- Prefer `Jiffy` for user-facing date/time formatting and for date operations (for example start/end of ranges, unit-based comparisons, and relative-style formatting), especially when it makes the code simpler.
- Use `DateTime` for basic timestamp parsing/storage and straightforward conversions (for example `DateTime.fromMillisecondsSinceEpoch(...)`) where no richer date operations are needed.
- Keep consistency with the surrounding file: if nearby code already follows one approach and it is reasonable, continue with that approach instead of refactoring unrelated code.

### `copyWith` nullable clear pattern

- When `copyWith` must support both “keep old value” and “explicitly clear to null” for nullable fields, use a companion clear flag.
- Follow the pattern `field` + `clearField` (for example `projectId` + `clearProjectId`).
- In mapping, prefer: `field: clearField == true ? null : (field ?? this.field)`.
- Do not use sentinel placeholders (for example `_copyWithUndefined`) for this use case unless explicitly requested.

## Screens & routing

### Screen architecture

- For new screens, follow the architecture from the latest similar existing screen in this project.
- Keep screen registration and navigation behavior consistent with nearby screens.

### Routing consistency (`lib/core/app_router.dart`)

- Register every new screen route in `onGenerateRoute`.
- Keep route entries ordered consistently with related navigation and screen declarations.

### Routing arguments typing

- Treat routing arguments as strings by default.
- When converting routing argument values to numeric types (`int`, `double`), use `supercharged` parsing extensions (`.toInt()`, `.toDouble()`) instead of manual parsing helpers.

## Localization & text

### Translation handling

- Use `tt('key')` for all user-facing text; never hardcode strings unless the text cannot be available through the translator during app initialization.
- Do not add key entries to translation files or fill in translated text unless the user explicitly asks for it.
- Follow the translation-key namespace pattern used by the closest related screen, dialog, widget, or service; do not invent a new prefix when an established context exists.
- Only `common.*` keys may be reused across unrelated screens, dialogs, or components. Other keys belong to their existing context.
- When adding a new screen, dialog, or component, create keys scoped to it. Reuse `common.*` keys only when the meaning genuinely applies across contexts.
- If the correct key pattern is unclear, ask the user or add a `// TODO(name)` comment next to the translation call rather than guessing.
- For keys with placeholders (for example `$label`, `$date`, `$diff`), call `tt('key').parameters({...})` instead of chaining `.replaceAll(...)` manually.

## Security

### Dependency updates

- Because package ecosystems are exposed to supply-chain attacks, do not update any pub package, framework, library, or dependency to a version that has been publicly available for fewer than 30 days.
- Before choosing the “latest” version, verify the release date from an official source such as the package registry, vendor release notes, or repository release page.
- If the latest version is newer than 30 days, select the newest version that is at least 30 days old and explain the choice in the handoff.
- Exception: urgent security fixes may use a newer version only when the user explicitly approves that specific update.

## Development workflow

### Context-first preparation

- Before proposing a plan or starting code changes, review related files in the same domain/context to identify established patterns and structure.
- Use those nearby implementations as the primary reference for architecture, naming, state handling, and UI composition decisions.
- If patterns conflict, prefer the closest feature-equivalent example and call out the choice in your summary.

### Tool fallback (`rg`)

- Prefer `rg`/`rg --files` for search when available.
- If `rg` is not available or not working in the current environment, immediately fall back to `grep`/`find` and provide the user with concise `ripgrep` installation instructions for their OS, including at least one web reference.

### Validation

- After finishing code changes, run `dart format` on the changed Dart files first, then run `flutter analyze` and resolve issues introduced by your changes before handoff.
- Prefer targeting both commands at the changed Dart files (for example `dart format lib/path/a.dart lib/path/b.dart` followed by `flutter analyze lib/path/a.dart lib/path/b.dart`) unless there is a clear reason to run them on the whole project.

### Handoff summary format

- After code changes and validation, include a short summary of changed files in your final response.
- Use plain text (non-clickable) project-relative file references only.
- For each relevant change block, include the starting line number using the `path:line` format (for example `lib/ui/widgets/device/device_form_widget.dart:890`).
- Do not use markdown file links for handoff file references.
- Keep this summary concise and focused on user-impacting or logic-impacting edits.
