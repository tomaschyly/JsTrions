# JT-131 — Button UI review

Scope: `ButtonWidget` and `IconButtonWidget` across the app, checked for hover animation and hover style.
Extended to other tappable widgets and text fields. Package tweaks go to local `../tch_common_widgets` during development
(`pubspec.yaml` uses `path`) and are released as `tch_common_widgets` `0.42.2`.

> **Mouse cursor — verified OK everywhere, no per-case check needed.**
> Nothing in `lib/` overrides `mouseCursor`. Both widgets default to `SystemMouseCursors.click` while
> interactive and fall back to `SystemMouseCursors.basic` when `onTap` is null or while loading
> (`button_widget.dart:478`, `icon_button_widget.dart:297`). Applies to the switch toggle and selection
> form field too, since they build on `IconButtonWidget`.

## Theme styles

Base styles, all in `lib/core/app_theme.dart`:

| Style | Line | Renders as | Hover |
| --- | --- | --- | --- |
| `kButtonStyle` | `app_theme.dart:83` | outlined | `kButtonHoverStyle` |
| `kButtonDangerStyle` | `app_theme.dart:97` | filled, red | none — empty `CommonButtonHoverStyle()` |
| `kListItemButtonStyle` | `app_theme.dart:104` | text-only | shares `kButtonHoverStyle` |
| `kIconButtonStyle` | `app_theme.dart:116` | outlined | none — empty `IconButtonHoverStyle()` |
| `kAppBarIconButtonStyle` | `app_theme.dart:128` | icon-only | none — `hoverStyle` null, inherits the empty icon-button one |

Derived styles that inherit hover from the base ones: confirm-dialog footer (`app_theme.dart:148`),
list-dialog option and selected option (`app_theme.dart:174`), list-dialog footer (`app_theme.dart:178`),
switch-toggle icon button (`app_theme.dart:196`).

## Issues to resolve [DONE]

- [x] **Icon buttons have no hover feedback at all.** `kIconButtonHoverStyle` is empty (`app_theme.dart:112`),
      and the app-bar style inherits it. Covers every icon-button case below.
      Fixed with `kIconButtonHoverStyle` (hover background + border), app-bar style now sets it explicitly.
- [x] **Danger button has no hover feedback.** `CommonButtonHoverStyle()` at `app_theme.dart:101` is a no-op.
- [x] **Filled buttons probably unreadable on hover.** `kButtonHoverStyle` sets
      `backgroundColor: kColorPrimaryLightHover` (#606060) but no `filledTextStyle`, so filled buttons keep
      `kColorPrimaryLight` (#404040) text — dark grey on dark grey. Check case 3 first.
      Fixed with `kButtonFilledStyle` (light hover text), also used by list-dialog selected option and footer Yes.
- [x] **Decide: border on hover for text-only buttons.** The widget does `borderColor = hoverStyle.borderColor ?? color`
      (`button_widget.dart:187`) and `kButtonHoverStyle` sets `borderColor: kColorTextPrimary`, so a full border
      appears on hover for text-only buttons and list items. Intentional or not?
      Decided: no outline on hover, border blends into the background (`kButtonTextOnlyStyle`), list items included (`kListItemButtonStyle`).
- [x] **Hover fade darkened intermediate frames.** `tch_common_widgets` animated from `Colors.transparent` (transparent black),
      fixed in `button_widget.dart` (local `version/0.42.1`) by fading from a transparent hover color. `IconButtonHoverStyle` gained
      `backgroundColor` + `borderColor` with the same fade (icon-only variant supports hover background too).
- [x] **Unset hover styles the package supports:** `SwitchToggleWidgetStyle.hoverStyle` and
      `SelectionFormFieldStyle.hoverStyle` are never configured.
      Switch toggle needs none: its `SwitchToggleWidgetHoverStyle` only changes text, and the inherited `kIconButtonHoverStyle`
      keeps silver text readable. Selection field now fades in `kColorPrimaryLightHover` fill (`kSelectionFormFieldStyle`).

## Visual checklist — `ButtonWidget` [DONE]

- [x] 1. **Outlined, default** — About screen, the Website / Repository / Contact / Privacy stack
      (`lib/ui/screens/AboutScreen.dart:292`)
- [x] 2. **Outlined, wrap content** — Project Detail, Import / Export translations actions
      (`lib/ui/data_widgets/project_detail_data_widget.dart:309`)
- [x] 3. **Filled** — Dashboard, **Add project** when no projects exist
      (`lib/ui/data_widgets/dashboard_projects_data_widget.dart:54`); same style on Project Detail **Confirm Access**
      (macOS file access request, `lib/ui/data_widgets/project_detail_data_widget.dart:172`)
- [x] 4. **Text-only, desktop app bar** — Projects screen app bar, Add / Edit project
      (`lib/ui/screens/ProjectsScreen.dart:122`)
- [x] 5. **Text-only with danger icon** — Projects screen app bar, Delete project
      (`lib/ui/screens/ProjectsScreen.dart:180`)
- [x] 6. **List item, text-only** — Dashboard recent projects, and the Projects list
      (`lib/ui/data_widgets/dashboard_projects_data_widget.dart:82`, `lib/ui/screens/ProjectsScreen.dart:519`)
- [x] 7. **List item, filled (selected)** — Projects list on desktop, currently selected project
      (`lib/ui/screens/ProjectsScreen.dart:519`)
- [x] 8. **Danger, filled** — Settings, the Reset data action
      (`lib/ui/screens/settings_screen.dart:236`)
- [x] 9. **Confirm-dialog footer, incl. danger Yes** — trigger via Settings Reset
      (`lib/ui/screens/settings_screen.dart:307`, style at `lib/core/app_theme.dart:148`)
- [x] 10. **List-dialog options, text-only + filled selected** — Settings, the app language picker
      (`lib/ui/screens/settings_screen.dart:246`, style at `lib/core/app_theme.dart:174`)

## Visual checklist — `IconButtonWidget` [DONE]

- [x] 11. **Outlined, default** — About screen social links (LinkedIn / X / GitHub)
      (`lib/ui/screens/AboutScreen.dart:316`); same style on the folder pickers in Edit Project
      (`lib/ui/dialogs/EditProjectDialog.dart:159`) and the save actions in Settings OpenAI
      (`lib/ui/screens/settings_screen.dart:507`)
- [x] 12. **Filled, custom icon color** — Project Detail floating bottom actions (add key, analyze code, scroll up)
      (`lib/ui/data_widgets/project_detail_data_widget.dart:539`)
- [x] 13. **Icon-only, plain** — Project Detail, clear-search button inside the search field
      (`lib/ui/data_widgets/project_detail_data_widget.dart:225`)
- [x] 14. **Icon-only, danger via `color`** — Ignore-directories chips in Edit Project, and the delete action on
      programming-language chips
      (`lib/ui/widgets/ProjectIgnoreDirectoriesWidget.dart:183`,
      `lib/ui/data_widgets/manage_programming_languages_data_widget.dart:225`)
- [x] 15. **Icon-only, danger via `iconColor`** — Project Detail translations table, delete-key row action
      (`lib/ui/data_widgets/project_detail_data_widget.dart:1641`)
- [x] 16. **Icon-only, state-driven color** — Project Detail translations table, add/edit and ignore/unignore row
      actions that switch between success and danger
      (`lib/ui/data_widgets/project_detail_data_widget.dart:1632`,
      `lib/ui/data_widgets/project_detail_data_widget.dart:1648`)
      Note: the row itself already has its own hover (`kColorPrimaryLightHover`, `project_detail_data_widget.dart:1626`),
      so the icon hover style must read well on top of it.
      Fixed with `kIconButtonRowActionStyle`, hover background `kColorPrimaryLight` (darker than the hovered row), used by all
      three row actions.
- [x] 17. **App bar** — drawer/back leading icon and app bar actions on any screen
      (`lib/ui/screenStates/AppResponsiveScreenState.dart:137`, `lib/ui/screenStates/AppResponsiveScreenState.dart:169`)
      `kAppBarIconButtonStyle` uses `kIconButtonHoverStyle`, background only since icon-only has no border.
      Text button actions (`option.button`) are covered by cases 4 and 5.
- [x] 18. **Switch toggle** — Project Detail "code only keys" toggle, and Feedback dialog
      (`lib/ui/data_widgets/project_detail_data_widget.dart:292`, `lib/ui/dialogs/FeedbackDialog.dart:126`,
      style at `lib/core/app_theme.dart:195`)
      Inherits `kIconButtonHoverStyle` through `kIconButtonStyle`, no change needed. Selection form field (Settings language,
      translations provider, OpenAI model) checked along with it (`lib/ui/screens/settings_screen.dart:246`).
- [x] 19. **Loading state** — Settings, OpenAI models loading spinner button; and Project Detail analyze-code
      action while running
      (`lib/ui/screens/settings_screen.dart:532`, `lib/ui/data_widgets/project_detail_data_widget.dart:546`)
      Verified in package: `isInteractive = onTap != null && !(isLoading && ignoreInteractionsWhenLoading)` gates hover and cursor,
      `ignoreInteractionsWhenLoading` defaults to true and is not overridden. Analyze-code buttons no longer null `onTap` while loading.
- [x] 20. **Disabled state** — clear-search with empty input, any action with `onTap: null`; confirm no hover
      reaction and the basic cursor
      (`lib/ui/data_widgets/project_detail_data_widget.dart:225`)
      Verified in package: `onTap: null` makes `isInteractive` false, so hover style is skipped and cursor is basic.

## Tappable widgets [DONE]

All use plain `InkWell` without a hover style, so they fall back to the default `ThemeData.hoverColor`
(about 4 % black), which is barely visible on the dark background.

- [x] 21. **Chip** — shared `ChipWidget`, one fix covers all radio-like chips; selected chips have `onTap: null`, so no hover
      (`lib/ui/widgets/ChipWidget.dart:57`). Check in Settings analysis on init and source of translations
      (`lib/ui/screens/settings_screen.dart:718`), Project Detail language and source chips
      (`lib/ui/data_widgets/project_detail_data_widget.dart:1478`), Edit Project translations JSON format
      (`lib/ui/widgets/ProjectTranslationsJsonFormatFieldWidget.dart:139`)
      Stateful now, `InkWell.onHover` fades `kColorPrimaryLightHover` background from its transparent variant with button
      animation duration/curve, border stays `kColorTextPrimary`; default `InkWell` hover overlay disabled. Chips with inner
      icon buttons (ignore dirs, languages, manage programming languages) have no chip `onTap`, so no double hover.
      Also covers Edit Project programming languages multi-select chips
      (`lib/ui/data_widgets/ProjectProgrammingLanguagesFieldDataWidget.dart:265`).
- [x] 22. **Drawer items** — background `kColorPrimary`, selected `kColorPrimaryLight` and not tappable; always visible on desktop
      (`lib/ui/screenStates/AppResponsiveScreenState.dart:207`)
      Extracted `_DrawerOptionWidget`, `AnimatedContainer` below transparent `Material` animates `kColorPrimary` →
      `kColorPrimaryLightHover` with button duration/curve, so `InkWell` splash stays visible; selected has no hover.
- [x] 23. **Toggle container header** — full-width expand/collapse header, Project Detail actions and Edit Project advanced
      (`lib/ui/widgets/ToggleContainerWidget.dart:75`, `lib/ui/data_widgets/project_detail_data_widget.dart:258`,
      `lib/ui/dialogs/EditProjectDialog.dart:213`)
      Header `AnimatedContainer` below transparent `Material` fades `kColorPrimaryLightHover` from its transparent variant with
      button duration/curve, same structure as drawer items so splash stays visible.
      Header background and `InkWell` use inner radius (container radius minus 1px border), all corners closed, top only open.

Skipped: notification toast (`lib/ui/notifications/notification_toast_widget.dart:52`), background depends on message type.

## Text fields [DONE]

`TextFormFieldWidget` has no hover support in `tch_common_widgets` `0.42.1` (date picker and selection field do).

- [x] **Package: add `TextFormFieldHoverStyle`** to `TextFormFieldStyle` in `../tch_common_widgets`
      (`lib/src/ui/form/text_form_field_widget.dart`), animated like other hover styles, faded from a transparent color.
      `fillColor` is animated by the widget (`TweenAnimationBuilder`, `TextFormFieldStyle.animationDuration` / `animationCurve`,
      defaults `kThemeAnimationDuration` + `Curves.easeOut` like buttons) as opacity fade blended over base fill; built-in
      `InputDecoration.hoverColor` is disabled because its fade is hardcoded to 15ms. Skipped when disabled.
      `borderColor` replaces only the enabled border while hovered, focused/error/disabled borders stay, Flutter animates
      the border change. `MouseRegion` is added only when the hover style sets something.
- [x] **Decide: what hover changes** — fill only (like selection field) or border too; must not clash with focused,
      error, or disabled states.
      Decided: fill only (`kColorPrimaryLightHover`), matches selection field; border stays `kColorTextPrimary`.
- [x] **App: configure hover** in `kTextFormFieldStyle` (`lib/core/app_theme.dart`).
      Set `TextFormFieldHoverStyle(fillColor: kColorPrimaryLightHover)`, animated like buttons.
- [x] **Verify: selection field** builds its input from `kTextFormFieldStyle` behind `IgnorePointer`; text field hover must
      not double up with `kSelectionFormFieldStyle` hover (`lib/ui/screens/settings_screen.dart:246`).
- [x] 24. **Single-line field** — Project Detail search, Projects search
      (`lib/ui/data_widgets/project_detail_data_widget.dart:215`, `lib/ui/screens/ProjectsScreen.dart:237`)
- [x] 25. **Field with inline action** — Project Detail search with clear-search icon button, both hovers together
      (`lib/ui/data_widgets/project_detail_data_widget.dart:215`)
- [x] 26. **Dialog fields** — Edit Project, Feedback including multi-line message
      (`lib/ui/dialogs/EditProjectDialog.dart:111`, `lib/ui/dialogs/FeedbackDialog.dart:74`)
- [x] 27. **List-dialog filter** — Settings OpenAI model selection with filter
      (`lib/ui/screens/settings_screen.dart:548`)
- [x] 28. **Focused and error states** — focused field and failed validation while hovered, e.g. Feedback dialog

## Package release

- [ ] Release `tch_common_widgets` `0.42.2` with all package tweaks.
- [ ] Switch `pubspec.yaml` back from local `path` to `tch_common_widgets: ^0.42.2`.
