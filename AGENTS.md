# Tomas Chyly Appliable Core — Agent Instructions

These instructions apply to the whole repository unless a deeper `AGENTS.md` overrides them.

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
  1. Ensure branch `version/x.x.x` exists and is checked out (create it if missing).
  2. Update version values in all files listed above.
  3. Commit all version changes with message: `Next version`.

## General coding conventions

### Imports

- Always use absolute imports (`package:...`) instead of relative imports.

### Code commenting

- Add comments for functions at minimum.
- Add additional comments around special or non-obvious logic.

### Pattern consistency

- In every change, follow established patterns from related contexts in this project (similar screen, feature, layer, or widget type).
- Prefer consistency with existing structure and naming over introducing a new approach.
- If multiple patterns exist, choose the one used in the closest relevant files unless the user explicitly asks otherwise.

### Helpers and services architecture

- Keep generic helpers in `lib/service/`
- Keep helpers inside component files only when they are used exclusively by that component
- Write services in a functional, stateless style (function-based utilities), not OOP-style service classes with internal state

### TODO ownership format

- When adding TODO comments, use the format: `// TODO(name) some text`.
- Prefer `name` from `git config user.name` of the user running the agent.
- If the name is unknown, ask the user once, then remember and reuse it consistently.

### Enum conventions

- When creating enums, add `none` as the first option unless explicitly instructed otherwise.

### Dart dot shorthands (Flutter 3.38+)

- Prefer Dart dot shorthands in new/edited code when the type is inferable (for example `.start` instead of `MainAxisAlignment.start`, `.all(8)` instead of `EdgeInsets.all(8)`).
- Use dot shorthands for named constructors and enum/static values where it improves conciseness and readability.

### Date handling

- Prefer `Jiffy` for user-facing date/time formatting and for date operations (for example start/end of ranges, unit-based comparisons, and relative-style formatting), especially when it makes the code simpler.
- Use `DateTime` for basic timestamp parsing/storage and straightforward conversions (for example `DateTime.fromMillisecondsSinceEpoch(...)`) where no richer date operations are needed.
- Keep consistency with the surrounding file: if nearby code already follows one approach and it is reasonable, continue with that approach instead of refactoring unrelated code.

## Development workflow

### Context-first preparation

- Before proposing a plan or starting code changes, review related files in the same domain/context to identify established patterns and structure.
- Use those nearby implementations as the primary reference for architecture, naming, state handling, and UI composition decisions.
- If patterns conflict, prefer the closest feature-equivalent example and call out the choice in your summary.

### Validation

- After finishing code changes, run `flutter analyze` and resolve issues introduced by your changes before handoff.
- Prefer targeting `flutter analyze` to changed files first (for example `flutter analyze lib/path/a.dart lib/path/b.dart`) unless there is a clear reason to run it on the whole project.

### Handoff summary format

- After code changes and validation, include a short summary of changed files in your final response.
- Use plain text (non-clickable) project-relative file references only.
- For each relevant change block, include the starting line number using the `path:line` format (for example `lib/ui/widgets/device/device_form_widget.dart:890`).
- Do not use markdown file links for handoff file references.
- Keep this summary concise and focused on user-impacting or logic-impacting edits.
