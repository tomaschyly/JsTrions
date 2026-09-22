# JT-140 — Branding theme (topinambur yellow + system/dark/light)
Started: 2026-09-22

Scope: retire the `#ffd700` gold for the topinambur yellow `#F2B705` already settled on TChApps and
tomas-chyly, and give JsTrions a light theme alongside the existing dark one, defaulting to the system
scheme with a system/dark/light choice in Settings.

Inherited decisions come from two finished plans and are not re-argued here:
- `/Users/tomaschyly/Documents/Development/React-GCP/TChApps/plans/archive/TCA-58-branding-theme.md`
- `/Users/tomaschyly/Documents/Development/Wordpress/tomas-chyly/plans/archive/TCV3-49-branding-theme.md`

The irony worth stating once: those two plans took **JsTrions' own palette** as the source of their dark
neutrals. This plan brings the result back home — JsTrions keeps the dark look it already has, gains the
new accent, and gains the light scheme the web projects built around it.

## Meeting focus

Label legend:
- `**[DECISION]**` — needs a product or architecture choice before implementation can be finalized.
- `**[VERIFY]**` — needs review or validation, but likely does not need a product decision.
- `**[BLOCKER]**` — blocks dependent implementation work.

Current focus:
- [ ] **[VERIFY]** Phase 5 — the desktop title bar (`setBrightness`) and the toast/notification colors in light

Everything else this plan opened has been decided (Tomas, 2026-09-22); see **Settled**.

## Current state

| Area | Location | Notes |
| --- | --- | --- |
| Palette | `lib/core/app_theme.dart:11` | 16 `const kColor*`, all dark-only; `kColorGold = #ffd700` is the accent being retired |
| Text styles | `lib/core/app_theme.dart:45` | 6 `const kText*`, all hardcoding `kColorTextPrimary` (`#dddddd`) |
| Fancy font | `lib/core/app_theme.dart:50` | `fancyText(...)` wraps every style; 56 call sites across `lib/` |
| Theme builder | `lib/core/app_theme.dart:64` | `appThemeBuilder` already takes `AppDataStateSnapshot`, used only for `responsiveScreen` |
| `ThemeData` | `lib/app.dart:96` | one light-slot `ThemeData` holding dark values; no `darkTheme`, no `darkThemePrefsKey` |
| Snapshot | `lib/app.dart:149` | `AppDataStateSnapshot` is empty; `isDarkMode` / `isOSDarkMode` come from the abstract base |
| Prefs | `lib/core/app_preferences.dart` | no dark-mode key; `clearAllAppPrefs()` enumerates every key by hand |
| Color call sites | 15 files, ~46 `kColor*` references | heaviest: `project_detail_data_widget.dart` (9), `app.dart` (9), `AppResponsiveScreenState.dart` (7), `notification_toast_widget.dart` (7), `ProjectsScreen.dart` (6) |
| Accent call sites | `lib/app.dart:103`, `ProjectsScreen.dart:370`, `CategoryHeaderWidget.dart:31`, `project_detail_data_widget.dart:457`, `link_text_widget.dart:92` | `link_text_widget` is the one place the accent is **text** today |
| SVG tinting | `AppResponsiveScreenState.dart:33,45,57,69` | `const ColorFilter.mode(kColorTextPrimary, ...)` — const, so it cannot follow the scheme as written |
| Settings UI | `lib/ui/screens/settings_screen.dart:270` | `_GeneralWidget` holds language + fancy font; the scheme selector belongs beside them |
| Fancy font apply | `settings_screen.dart:281` | pushes a fresh stack to re-apply; `// AppState.instance.invalidate();` above it is commented out because it does not rebuild `CoreApp` |

### What the framework already gives us

`tch_appliable_core` 0.39 has the whole mechanism; nothing needs to be hand-rolled:

- `CoreApp.darkThemePrefsKey` — points at an int pref holding a `DarkMode` index
  (`core_app.dart:129`).
- `enum DarkMode { automatic, enabled, disabled }` (`core_app.dart:681`) — `automatic` is exactly the
  "system" option, and a **missing** pref value also resolves to `automatic`.
- `CoreApp.darkTheme` — picked whenever the resolved mode is dark, falling back to `theme` when null.
- `didChangePlatformBrightness()` → `determineOSThemeMode()` (`core_app.dart:304`) — the OS listener is
  already wired, so `automatic` follows a live system change with no work from us.
- `snapshot.isDarkMode` / `snapshot.isOSDarkMode` on `AbstractAppDataStateSnapshot`.

`timoty-flutter` is the reference implementation of all of the above on the same core version:
`lib/app.dart:278` (`darkThemePrefsKey`), `lib/core/app_theme.dart:175` (`isDarkMode(context)`),
`lib/ui/screens/account/dark_mode_screen.dart:91` (save + invalidate), and
`lib/ui/widgets/dark_mode_list_items_widget.dart` (the three-option picker).

## Constraints

- **Theme and styles only.** No layout, markup, behaviour or architecture changes beyond what the scheme
  switch requires. The one new piece of UI is the scheme selector itself.
- All user-facing text through `tt(...)`, keys scoped to `settings.screen.*` like the neighbouring
  settings; no translation file edits unless asked.
- Dark must come out of this looking the same as it does today, apart from the accent swap. The light
  scheme is the new surface; the dark one is being preserved.
- No new dependency. The core package covers the preference, the persistence and the OS listener.
- Follow the dependency rule if any `tch_*` bump is needed — user's own packages are exempt from the
  30-day wait, everything else is not.

---

### Phase 1 — Palette and the token layer

- [ ] 1.1 Split `app_theme.dart`'s colors into a **raw palette** layer (`_kPalette*`-style literals, named
      after the color) and a **semantic** layer (`kColorBackground`, `kColorSurface`, `kColorBorder`,
      `kColorTextPrimary`, `kColorAccent`, `kColorDanger`, …). Each literal is written once; only the
      semantic resolvers branch on the scheme. Same split TCV3-49 used, expressed in Dart.
- [ ] 1.2 Accent: `kColorAccent = Color(0xFFF2B705)` replaces `kColorGold`. Its light/dark variants
      replace `kColorGoldLight` / `kColorGoldDarker`, and the accent tints `rgba(242,183,5,0.12)` / `0.22`
      from TCV3-49 come across as `kColorAccent.withValues(alpha: 0.12 / 0.22)`.
- [ ] 1.3 Dark neutrals stay as they are, renamed into the semantic layer: `#1a1a1a` background
      (`kColorPrimary`), `#2b2b2b` raised, `#333333` hover, `#404040` border/surface (`kColorPrimaryLight`),
      `#dddddd` / `#f2f2f2` text (`kColorSilver` / `kColorSilverLighter`).
- [ ] 1.4 Light neutrals come from the **tomas-chyly set** — `#f5f5f5` background, `#ffffff` surface,
      `#DDDDDD` border, `#1a1a1a` text, `rgba(0,0,0,0.6)` muted (Tomas, 2026-09-22). Start there and refine
      only if the 6.2 visual pass shows a problem; JsTrions' dense table UI carries far more borders per
      screen than a marketing site, so `#DDDDDD` is the value most likely to need a second look.
- [ ] 1.5 Destructive stays `#e60000` (`kColorRed`), confirmed as the shared destructive on TCA-58. Success
      `#43a047` and warning `#fb8c00` stay as they are — TCA-58 declined to export them to the web projects,
      which says nothing against keeping them here.
- [ ] 1.6 Check every semantic pair for contrast before any widget work, and record the numbers in
      **Settled**. The accent is 9.6:1 on `#1a1a1a` and 1.8:1 on white — measured on TCA-58 and the reason
      for 2.4 below.
- [ ] 1.7 Delete `kColorGold*` outright. One branding yellow at a time; no fallback const kept around.

### Phase 2 — Making the theme scheme-aware

Approach chosen (Tomas, 2026-09-22): **Timoty-style context helpers.** Raw palette consts stay consts; the
semantic layer becomes functions of `BuildContext`, and the text styles get dark-mode twins. It is the
pattern already proven on the same core version, and it keeps the diff inside `app_theme.dart` plus the
call sites that actually paint.

- [ ] 2.1 Add `bool isDarkMode(BuildContext context) => getAppDataStateSnapshot(context).isDarkMode;` to
      `app_theme.dart`, mirroring `timoty-flutter/lib/core/app_theme.dart:175`. Add the matching
      `BuildContext` extension getter next to the existing `AppThemeExtension.appTheme`.
- [ ] 2.2 Turn the semantic colors into `Color kColorX(BuildContext context)` functions. The raw palette
      entries stay `const` so `const` widgets that do not need the scheme keep it.
- [ ] 2.3 Add the dark text styles as `kDMText`, `kDMTextBold`, `kDMTextHeadline` following Timoty's naming,
      and repoint `kText*` at the light values. `fancyText(...)` keeps its signature; a
      `fancyText(context, style)`-shaped overload or a `themedText(context)` helper is decided when 2.5 shows
      how the 56 call sites actually read.
- [ ] 2.4 **Take the yellow off text, links get the underline treatment** (Tomas, 2026-09-22). Same solution
      as tomas-chyly and TChApps: the label reads as normal text and the accent carries on the underline
      alone. `link_text_widget.dart:92` currently lerps `kColorSecondary` → `kColorSecondaryLight` as the
      link's own color on hover; the label moves to the text token and that lerp moves onto
      `decorationColor`, keeping the existing hover animation intact. Holds in **both** schemes, not just
      light.
- [ ] 2.5 Walk `appThemeBuilder` top to bottom and thread `context` through every style it builds — buttons,
      icon buttons, dialogs, form fields, the selection field, the switch toggle, the tooltip. The hover
      styles are the subtle part: `kColorPrimaryLightHover` is "one step lighter than the surface" in dark and
      has to become "one step darker" in light.
- [ ] 2.6 `ThemeData` in `lib/app.dart:96` splits into `theme` (light) and `darkTheme` (dark, the current
      values). `splashColor`, `shadowColor` and the `colorScheme` pair get per-scheme values, and both gain an
      explicit `brightness`.
- [ ] 2.7 The initialization UI (`lib/app.dart:50`) paints `kColorPrimaryLight` before any of this exists —
      it runs before the first frame the theme can react to. Decide whether it reads the OS brightness
      directly (`PlatformDispatcher.instance.platformBrightness`) or stays dark on purpose, like the
      `.fixed-background` decision on TCV3-49.
- [ ] 2.8 The Kalam fancy font **stays as it is, scheme-independent** (Tomas, 2026-09-22). Whether to keep,
      drop or replace it is a separate call Tomas makes another time, so this plan does not touch it and does
      not give light mode a heavier weight. If it reads as spidery on `#f5f5f5` during 6.2, that is an
      observation to record here, not something to fix in JT-140.

### Phase 3 — The preference

- [ ] 3.1 Add `const String kPrefsDarkMode = 'prefs_dark_mode';` to `lib/core/app_preferences.dart`, placed
      with the other general prefs, and `kPrefsDarkMode: DarkMode.automatic.index` to `intPrefs`.
- [ ] 3.2 Add the key to `clearAllAppPrefs()`'s `prefsRemoveInt` block — that function enumerates by hand and
      will silently skip a key that is not listed.
- [ ] 3.3 Pass `darkThemePrefsKey: kPrefsDarkMode` to `CoreApp` in `lib/app.dart`, beside `snapshot:`.
- [ ] 3.4 Re-apply the scheme with the **stack push**, not `invalidate()`. `CoreApp` resolves `DarkMode`
      inside its own `buildContent` and so needs a rebuild, but `AppState.instance.invalidate()` does not
      produce one here — already tried and abandoned, which is why it sits commented out at
      `settings_screen.dart:283` with `pushNamedNewStack(...)` in its place (Tomas, 2026-09-22). The scheme
      selector reuses that exact fancy-font pattern: save the pref, wait `kThemeAnimationDuration`, push a
      fresh stack to `SettingsScreen.ROUTE` with `router-no-animation`.
- [ ] 3.5 Do **not** add `invalidateApp` to `AppDataStateSnapshot`. Timoty wires it
      (`timoty-flutter/lib/app.dart:285`) because it works there; carrying a field into JsTrions that resolves
      to a no-op would be worse than not having it.
- [ ] 3.6 Consequence to check in 6.x: the push discards the navigation stack, so the scheme can only be
      changed from Settings and the user lands back on Settings afterwards. That matches the fancy font
      toggle and is acceptable; it is the reason the selector does not go in the app bar.

### Phase 4 — Settings UI

- [ ] 4.1 Add the scheme selector to `_GeneralWidget` in `settings_screen.dart`, next to language and fancy
      font, wrapped in `SettingWidget` like its neighbours.
- [ ] 4.2 **System first and default**, then Dark, then Light — the order used by the switcher on TChApps,
      tomas-chyly and Timoty Web. `DarkMode.automatic` / `.enabled` / `.disabled` map onto the three.
- [ ] 4.3 Use the established selection pattern from the closest neighbour rather than porting Timoty's
      bottom sheet — the language setting already picks from a list here, and JsTrions is desktop-first where
      a bottom sheet is the wrong primitive. Check `SelectionFormFieldStyle` / `ListDialogStyle` usage in
      `_GeneralWidget` first.
- [ ] 4.4 Translation keys scoped to the screen: `settings.screen.theme.label`, `.system`, `.dark`,
      `.light`, plus a description line if the neighbours carry one. Keys are added to the files only if
      Tomas asks; otherwise `tt(...)` calls go in and the files stay untouched.
- [ ] 4.5 Save on selection, then re-apply with the 3.4 stack push, and show the
      `settings.screen.generic.success` message the fancy font toggle already shows.

### Phase 5 — Repoint the call sites

Roughly 46 `kColor*` references across 15 files. Mechanical once Phase 2 is fixed, and the bulk of the diff.

- [ ] 5.1 `lib/ui/screenStates/AppResponsiveScreenState.dart` — the drawer, the app bar and the four
      `const ColorFilter.mode(kColorTextPrimary, ...)` SVG tints. The `const` has to go for the icons to
      follow the scheme.
- [ ] 5.2 `lib/ui/data_widgets/project_detail_data_widget.dart` — the heaviest file, and the one with the
      odd/even row striping at `:1628` that uses `kColorWarning` / `kColorWarningDark` as row fills. Striping
      contrast is scheme-sensitive and needs looking at, not just repointing.
- [ ] 5.3 `lib/ui/notifications/notification_toast_widget.dart` — the success/danger/warning toast
      backgrounds, over whatever `bot_toast` paints behind them.
- [ ] 5.4 `ProjectsScreen.dart`, `ProjectDetailScreen.dart`, `CategoryHeaderWidget.dart`, `ChipWidget.dart`,
      `ToggleContainerWidget.dart`, `ProjectIgnoreDirectoriesWidget.dart`, `ProjectLanguagesFieldWidget.dart`,
      `dashboard_info_widget.dart`, `InfoDialog.dart`, `manage_programming_languages_data_widget.dart`.
- [ ] 5.5 The `Colors.*` and raw `Color(0x...)` literals outside the theme file —
      `edit_project_translation_dialog.dart`, `openai_chat_dialog.dart`, `FeedbackDialog.dart`,
      `EditProjectDialog.dart`. Each is either a token that was never extracted or a deliberate
      scheme-independent color; decide per case and note the deliberate ones.
- [ ] 5.6 `lib/service/desktop_service.dart` — `setBrightness(Brightness.dark)` is hardcoded and drives the
      native window chrome on macOS. It has to follow the resolved scheme, including a live change.

### Phase 6 — Verification and handoff

- [ ] 6.1 `dart format` on the changed files, then `flutter analyze` on them, clean.
- [ ] 6.2 Walk every screen in System / Dark / Light on macOS: Dashboard, Projects, Project Detail (tables,
      striping, chips, search), Settings, About, and the dialogs — Edit Project, Edit Project Translation,
      OpenAI chat, Feedback, Info, and the confirm dialog. Both the phone/tablet `_BodyWidget` and the
      desktop `_BodyDesktopWidget` layouts.
- [ ] 6.3 Check each notification toast variant and each button variant — filled, outlined, text-only,
      danger, list item, row action, app bar — in both schemes, hovered and not. JT-131 did this work for
      dark; light must not undo it.
- [ ] 6.4 Confirm the preference survives a restart, that System follows a live OS change without a restart,
      and that Dark and Light ignore the OS.
- [ ] 6.5 **[VERIFY]** Linux and Windows: the platform border radius branch, the native title bar, and
      whether 5.6's brightness call has any effect there.
- [ ] 6.6 Handoff summary of changed files with `path:line` references, per `AGENTS.md`.

---

## Settled

- **The branding yellow is topinambur `#F2B705`.** Called on TCA-58 (Tomas, 2026-09-21), carried through
  TCV3-49, inherited here. `#ffd700` is retired and not kept as a fallback.
- **The yellow is never text, in either scheme** (Tomas, 2026-09-22). It lives on fills, borders, backgrounds,
  underlines and hover tints; text over it is black or white by contrast. Measured on TCA-58: 9.6:1 on
  `#1a1a1a`, 1.8:1 on white.
- **Links carry the accent on the underline, exactly as on tomas-chyly and TChApps** (Tomas, 2026-09-22).
  The label is normal text in both schemes. This is the one deliberate change to how dark looks today.
- **The scheme change re-applies with a navigation stack push, not `invalidate()`** (Tomas, 2026-09-22).
  `AppState.instance.invalidate()` does not rebuild `CoreApp` in this app; it was tried during the fancy
  font work, did not work, and was not worth chasing further. `settings_screen.dart:283` is the record of
  that, and the scheme selector follows the same pattern rather than re-opening the question.
- **The destructive red is `#e60000`,** shared across all three projects.
- **System is the default and comes first** in the selector, as on TChApps, tomas-chyly and Timoty Web.
- **Scheme-aware colors are `BuildContext` functions, not tokens on `AppTheme`** (Tomas, 2026-09-22). Timoty
  proves the pattern on this exact core version; `AppTheme` keeps doing what it does, which is holding
  `tch_common_widgets` style objects rather than a design system.
- **No new dependency and no hand-rolled theme service.** `tch_appliable_core` already carries the
  `DarkMode` enum, the pref plumbing, the `theme`/`darkTheme` switch and the OS brightness listener.
- **Dark is preserved, not redesigned.** JT-131 settled the hover and button work on dark surfaces; this plan
  swaps the accent and adds a light twin, and any change to dark beyond the accent is a bug in this work.
- **No version bump in this plan** (Tomas, 2026-09-22). The bump to `1.6.6+32` already landed in `ca98071`,
  and JT-140 branches off it as `feature/JT-140-Update-theme-for-new-topinumbur`. Which release carries this
  work is settled outside the plan, when it is settled.
- **Light neutrals start as the tomas-chyly values** and are refined only if the visual pass demands it.
- **Kalam is out of scope.** It stays exactly as it is in both schemes; its future is a separate decision.

## Noted, not in scope

- `app_theme.dart:184` has a `prefsInt(kPrefsFancyFont) == 1 ? 8 : 8` ternary — both branches are `8`.
  Pre-existing, harmless, left alone unless Tomas asks.
- `app_theme.dart:82` carries a bare `//TODO` with no owner, against the `// TODO(name)` convention.
