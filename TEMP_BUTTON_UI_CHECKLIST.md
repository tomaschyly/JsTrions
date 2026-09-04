# Button UI review

Scope: `ButtonWidget` and `IconButtonWidget` across the app, checked for hover animation and hover style.

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

## Issues to resolve

- [ ] **Icon buttons have no hover feedback at all.** `kIconButtonHoverStyle` is empty (`app_theme.dart:112`),
      and the app-bar style inherits it. Covers every icon-button case below.
- [ ] **Danger button has no hover feedback.** `CommonButtonHoverStyle()` at `app_theme.dart:101` is a no-op.
- [ ] **Filled buttons probably unreadable on hover.** `kButtonHoverStyle` sets
      `backgroundColor: kColorPrimaryLightHover` (#606060) but no `filledTextStyle`, so filled buttons keep
      `kColorPrimaryLight` (#404040) text — dark grey on dark grey. Check case 3 first.
- [ ] **Decide: border on hover for text-only buttons.** The widget does `borderColor = hoverStyle.borderColor ?? color`
      (`button_widget.dart:187`) and `kButtonHoverStyle` sets `borderColor: kColorTextPrimary`, so a full border
      appears on hover for text-only buttons and list items. Intentional or not?
- [ ] **Unset hover styles the package supports:** `SwitchToggleWidgetStyle.hoverStyle` and
      `SelectionFormFieldStyle.hoverStyle` are never configured.

## Visual checklist — `ButtonWidget`

- [ ] 1. **Outlined, default** — About screen, the Website / Repository / Contact / Privacy stack
      (`lib/ui/screens/AboutScreen.dart:292`)
- [ ] 2. **Outlined, wrap content** — Project Detail, Import / Export translations actions
      (`lib/ui/data_widgets/project_detail_data_widget.dart:309`)
- [ ] 3. **Filled** — Dashboard, **Add project** when no projects exist
      (`lib/ui/data_widgets/dashboard_projects_data_widget.dart:54`)
- [ ] 4. **Text-only, desktop app bar** — Projects screen app bar, Add / Edit project
      (`lib/ui/screens/ProjectsScreen.dart:122`)
- [ ] 5. **Text-only with danger icon** — Projects screen app bar, Delete project
      (`lib/ui/screens/ProjectsScreen.dart:180`)
- [ ] 6. **List item, text-only** — Dashboard recent projects, and the Projects list
      (`lib/ui/data_widgets/dashboard_projects_data_widget.dart:82`, `lib/ui/screens/ProjectsScreen.dart:519`)
- [ ] 7. **List item, filled (selected)** — Projects list on desktop, currently selected project
      (`lib/ui/screens/ProjectsScreen.dart:519`)
- [ ] 8. **Danger, filled** — Settings, the Reset data action
      (`lib/ui/screens/settings_screen.dart:236`)
- [ ] 9. **Confirm-dialog footer, incl. danger Yes** — trigger via Settings Reset
      (`lib/ui/screens/settings_screen.dart:307`, style at `lib/core/app_theme.dart:148`)
- [ ] 10. **List-dialog options, text-only + filled selected** — Settings, the app language picker
      (`lib/ui/screens/settings_screen.dart:246`, style at `lib/core/app_theme.dart:174`)

## Visual checklist — `IconButtonWidget`

- [ ] 11. **Outlined, default** — About screen social links (LinkedIn / X / GitHub)
      (`lib/ui/screens/AboutScreen.dart:316`); same style on the folder pickers in Edit Project
      (`lib/ui/dialogs/EditProjectDialog.dart:159`) and the save actions in Settings OpenAI
      (`lib/ui/screens/settings_screen.dart:507`)
- [ ] 12. **Filled, custom icon color** — Project Detail floating bottom actions (add key, analyze code, scroll up)
      (`lib/ui/data_widgets/project_detail_data_widget.dart:539`)
- [ ] 13. **Icon-only, plain** — Project Detail, clear-search button inside the search field
      (`lib/ui/data_widgets/project_detail_data_widget.dart:225`)
- [ ] 14. **Icon-only, danger via `color`** — Ignore-directories chips in Edit Project, and the delete action on
      programming-language chips
      (`lib/ui/widgets/ProjectIgnoreDirectoriesWidget.dart:183`,
      `lib/ui/data_widgets/manage_programming_languages_data_widget.dart:225`)
- [ ] 15. **Icon-only, danger via `iconColor`** — Project Detail translations table, delete-key row action
      (`lib/ui/data_widgets/project_detail_data_widget.dart:1641`)
- [ ] 16. **Icon-only, state-driven color** — Project Detail translations table, add/edit and ignore/unignore row
      actions that switch between success and danger
      (`lib/ui/data_widgets/project_detail_data_widget.dart:1632`,
      `lib/ui/data_widgets/project_detail_data_widget.dart:1648`)
      Note: the row itself already has its own hover (`kColorPrimaryLightHover`, `project_detail_data_widget.dart:1626`),
      so the icon hover style must read well on top of it.
- [ ] 17. **App bar** — drawer/back leading icon and app bar actions on any screen
      (`lib/ui/screenStates/AppResponsiveScreenState.dart:137`, `lib/ui/screenStates/AppResponsiveScreenState.dart:169`)
- [ ] 18. **Switch toggle** — Project Detail "code only keys" toggle, and Feedback dialog
      (`lib/ui/data_widgets/project_detail_data_widget.dart:292`, `lib/ui/dialogs/FeedbackDialog.dart:126`,
      style at `lib/core/app_theme.dart:195`)
- [ ] 19. **Loading state** — Settings, OpenAI models loading spinner button; and Project Detail analyze-code
      action while running
      (`lib/ui/screens/settings_screen.dart:532`, `lib/ui/data_widgets/project_detail_data_widget.dart:546`)
- [ ] 20. **Disabled state** — clear-search with empty input, any action with `onTap: null`; confirm no hover
      reaction and the basic cursor
      (`lib/ui/data_widgets/project_detail_data_widget.dart:225`)
