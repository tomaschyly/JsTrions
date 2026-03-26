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

### TODO ownership format

- When adding TODO comments, use the format: `// TODO(name) some text`.
- Prefer `name` from `git config user.name` of the user running the agent.
- If the name is unknown, ask the user once, then remember and reuse it consistently.

### Enum conventions

- When creating enums, add `none` as the first option unless explicitly instructed otherwise.

### Dart dot shorthands (Flutter 3.38+)

- Prefer Dart dot shorthands in new/edited code when the type is inferable (for example `.start` instead of `MainAxisAlignment.start`, `.all(8)` instead of `EdgeInsets.all(8)`).
- Use dot shorthands for named constructors and enum/static values where it improves conciseness and readability.
