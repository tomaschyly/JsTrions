# JT-131 — Desktop tweaks
Started: 2026-09-15

Scope: desktop-focused follow-up to the JT-131 hover work — keyboard shortcuts and icon button tooltips, with window
state persistence, context menus and drag and drop under consideration. Release target (1.6.6 standalone or folded
into 1.7.0) is decided later.

## Meeting focus

Label legend:
- `**[DECISION]**` — needs a product or architecture choice before implementation can be finalized.
- `**[VERIFY]**` — needs review or validation, but likely does not need a product decision.
- `**[BLOCKER]**` — blocks dependent implementation work.

Current focus:
- [ ] **[DECISION]** Release target: 1.6.6 standalone vs. fold into 1.7.0
- [ ] **[DECISION]** Shortcut set for the first release (Phase 1)
- [ ] **[DECISION]** Do Phase 2 — Remember window size and position
- [ ] **[DECISION]** Do Phase 4 — Context menus
- [ ] **[DECISION]** Do Phase 5 — Drag and drop

## Current state

| Area | Location | Notes |
| --- | --- | --- |
| Keyboard shortcuts | — | no `Shortcuts`, `CallbackShortcuts` or `LogicalKeyboardKey` usage in `lib/` |
| Window init | `lib/service/desktop_service.dart:13` | `initDesktop()` always sets default size `1149×718` and centers, or maximizes / full screen on small displays |
| Prefs | `lib/core/app_preferences.dart` | no window state prefs |
| Tooltip support | `tch_common_widgets` `IconButtonWidget.tooltip`, `ButtonWidget.tooltip` | styled by `tooltipStyle` at `lib/core/app_theme.dart:268` |
| Existing tooltips | `lib/ui/data_widgets/project_detail_data_widget.dart:1641`, `lib/ui/dialogs/edit_project_translation_dialog.dart:148` | 8 of ~36 `IconButtonWidget` usages have a tooltip |
| Project detail search | `lib/ui/data_widgets/project_detail_data_widget.dart:72` | `_searchController`, focus target for a search shortcut |

## Constraints

- Desktop-only behavior must not affect mobile / web builds.
- All user-facing text through `tt(...)`, keys scoped to their context (e.g. `project_detail.*.tooltip`), no translation
  file edits unless asked.
- Dependency rule: only versions public for 30+ days, verify release dates on pub.dev and note the choice here.
- `tch_common_widgets` changes (if any) go to local `../tch_common_widgets` during development and are released as a new version.

### Phase 1 — Keyboard shortcuts

- [ ] Review how dialogs, screens and text fields handle focus to pick the shortcut layer (app-wide `Shortcuts` +
      `Actions` vs. per-screen `CallbackShortcuts`)
- [ ] **[DECISION]** Shortcut set, candidates:
  - [ ] `Ctrl/Cmd+F` — focus search in Project Detail
  - [ ] `Ctrl/Cmd+N` — new project (Projects) / new translation key (Project Detail)
  - [ ] `Ctrl/Cmd+S` — save in Edit Project and Edit Project Translation dialogs
  - [ ] `Esc` — close dialogs (verify current behavior first)
  - [ ] `F5` / `Ctrl/Cmd+R` — refresh project analysis
  - [ ] `Ctrl/Cmd+,` — open Settings
- [ ] Use `Cmd` on macOS and `Ctrl` on Windows / Linux (`SingleActivator` with `meta` / `control`)
- [ ] Ensure shortcuts do not fire while typing where the key combination has text-field meaning
- [ ] Show shortcut hints in related tooltips (e.g. "Save (Ctrl+S)")

### Phase 2 — Remember window size and position

- [ ] **[DECISION]** Do this phase
- [ ] Prefs for window bounds and maximized / full screen state in `lib/core/app_preferences.dart`
- [ ] Save on resize / move / maximize via `WindowListener` (debounced)
- [ ] Restore in `initDesktop()`, fall back to current default sizing when no prefs exist
- [ ] **[VERIFY]** Restored bounds are visible on current displays (disconnected monitor, changed resolution) via `screen_retriever`
- [ ] **[VERIFY]** Behavior on Windows, macOS, Linux (including Snap / MSIX builds)

### Phase 3 — Tooltips on icon buttons

- [ ] Audit all `IconButtonWidget` usages without `tooltip`:
  - [ ] `lib/ui/screenStates/AppResponsiveScreenState.dart` (app bar / drawer)
  - [ ] `lib/ui/screens/AboutScreen.dart`
  - [ ] `lib/ui/screens/settings_screen.dart`
  - [ ] `lib/ui/data_widgets/project_detail_data_widget.dart` (remaining ones)
  - [ ] `lib/ui/data_widgets/manage_programming_languages_data_widget.dart`
  - [ ] `lib/ui/dialogs/EditProjectDialog.dart`
  - [ ] `lib/ui/dialogs/edit_project_translation_dialog.dart` (remaining ones)
  - [ ] `lib/ui/widgets/ProjectIgnoreDirectoriesWidget.dart`
  - [ ] `lib/ui/widgets/ProjectLanguagesFieldWidget.dart`
- [ ] Add `tooltip: tt(...)` with keys scoped to each context, following `*.tooltip` naming used in existing tooltips
- [ ] **[VERIFY]** Tooltip style and delay feel right with the hover animations from the button review

### Phase 4 — Context menus

- [ ] **[DECISION]** Do this phase
- [ ] Right-click menu on translation key rows (`_KeyListItemWidget`): copy key, edit, delete, ignore / unignore
- [ ] Right-click menu on project items (Projects / Dashboard): open, edit, delete
- [ ] Check whether `tch_common_widgets` should provide a styled context menu widget or use Flutter `MenuAnchor` /
      `ContextMenuController` styled via app theme
- [ ] Desktop / mouse only, keep existing row actions unchanged

### Phase 5 — Drag and drop

- [ ] **[DECISION]** Do this phase
- [ ] Candidates: `desktop_drop`, `super_drag_and_drop` — latest eligible (30+ days) version, release date, maintenance,
      platform support, native build impact
- [ ] Drop a folder onto the window to open Edit Project dialog with the directory prefilled
- [ ] Drop target visual state (hover highlight)
- [ ] **[VERIFY]** Works in MSIX, Snap confinement and macOS sandbox

### Phase 6 — Validation and release

- [ ] `dart format` + `flutter analyze` on changed files
- [ ] Manual test on Windows, macOS, Linux
- [ ] Translation keys added by user for new tooltips and menus
- [ ] **[DECISION]** Release as 1.6.6 or with 1.7.0
