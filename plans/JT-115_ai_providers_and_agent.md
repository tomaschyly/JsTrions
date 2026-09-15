# JT-115 — AI providers, local LLM and Agent
Started: 2026-09-14

Scope: move JsTrions AI from the single-provider `openai_dart ^1.4.0` to a multi-provider setup (OpenAI, Claude, Gemini, …)
while keeping current AI translations working, investigate subscription / CLI based access and local LLMs,
then expand project AI with an Agent dialog for more actions than single-text translation.

## Meeting focus

Label legend:
- `**[DECISION]**` — needs a product or architecture choice before implementation can be finalized.
- `**[VERIFY]**` — needs review or validation, but likely does not need a product decision.
- `**[BLOCKER]**` — blocks dependent implementation work.

Current focus:
- [ ] **[DECISION]** **[BLOCKER]** Pick the multi-provider package (Phase 1) — blocks Phase 2 and Phase 5
- [ ] **[DECISION]** Provider settings model: one active provider vs. per-feature provider (translate vs. Agent) (Phase 2)
- [ ] **[DECISION]** Offer subscription / CLI access at all, and in which builds (Phase 3)
- [ ] **[DECISION]** Agent actions for the first release and whether the Agent may write files (Phase 5)
- [ ] **[VERIFY]** API key storage — keep in prefs or move to secure storage (Phase 2)

## Current state

| Area | Location | Notes |
| --- | --- | --- |
| Provider enum | `lib/model/translations_provider.dart:1` | `none`, `google`, `openai` |
| OpenAI client + translate | `lib/service/openai_service.dart:14`, `lib/service/openai_service.dart:70` | global client, Chat Completions, model list cached in `openAIModalIds` |
| Client init on start | `lib/app.dart:84` | `initOpenAIClient()` |
| Prefs | `lib/core/app_preferences.dart:15` | API key, organization, selected model (default `gpt-5.4-mini`) stored as plain prefs |
| Settings UI | `lib/ui/screens/settings_screen.dart:366`, `lib/ui/screens/settings_screen.dart:410` | provider picker, `_TranslationsOpenAIWidget` |
| Dashboard info | `lib/ui/screens/dashboard_screen.dart:52` | `getOpenAIDashboardInfo` |
| Translate flow | `lib/ui/dialogs/edit_project_translation_dialog.dart:313` | `_aiTranslate`, Google Translate fallback |
| Chat stub | `lib/ui/dialogs/edit_project_translation_dialog.dart:404`, `lib/ui/dialogs/openai_chat_dialog.dart:1` | unfinished `OpenAIChatDialog`, button commented out |
| Code analysis | `lib/ui/data_widgets/project_detail_data_widget.dart:1300` | per-language `RegExp` from `project.translationKeys` finds keys in code |
| Key context | `assets/translations/metadata.json` | `TranslationKeyMetadata` descriptions usable as translation context |

## Constraints

- Dependency rule: only versions public for 30+ days, verify release dates on pub.dev and note the choice here.
- Services stay functional and stateless-style in `lib/service/`, no OOP service classes with internal state.
- All user-facing text through `tt(...)`, new keys scoped to their context, no translation file edits unless asked.
- Distribution sandboxes limit what is possible: MSIX (Microsoft Store) and Snap confinement may block spawning
  external CLIs or reaching `localhost`; macOS sandbox entitlements too.
- Existing users must keep their OpenAI settings after upgrade (prefs migration, no silent reset).

### Phase 1 — Multi-provider package investigation

- [ ] List candidates with latest eligible (30+ days) version, release date, publisher, maintenance activity:
      `dartantic_ai`, per-provider SDKs from davidmiguel.com (`openai_dart`, `anthropic_sdk_dart`, `googleai_dart`,
      `ollama_dart`, `mistralai_dart`), `llm_dart`, `dart_agent_core`, `mcp_llm`, `langchain`
- [ ] Compare on: providers (OpenAI, Anthropic, Gemini, Ollama, OpenAI-compatible / OpenRouter), model listing,
      streaming, tool calling / agent loop, structured output, cancellation, desktop + web support, dependency footprint
- [ ] Check which SDKs the frameworks use internally (version conflicts with direct SDK usage)
- [ ] Spike: translate one text with 2 providers using the top candidate in a scratch branch
- [ ] **[DECISION]** **[BLOCKER]** Choose package or "per-provider SDKs + own thin abstraction", record reasoning here

### Phase 2 — Refactor to multi-provider, keep current AI translations

- [ ] Update `pubspec.yaml` to the chosen package(s), remove `openai_dart` if replaced
- [ ] Extend `TranslationsProvider` enum (e.g. `anthropic`, `gemini`, `ollama`) keeping `none`/`google`/`openai` indexes stable
      (stored as `index` in prefs)
- [ ] **[DECISION]** Provider settings model: one active AI provider vs. separate provider for translate and Agent
- [ ] Generic AI service in `lib/service/` (init client per provider, list models, translate text), replacing
      `openai_service.dart` while keeping the same call sites working
- [ ] Prefs per provider (API key, selected model, base URL where relevant), migrate existing OpenAI prefs
- [ ] **[VERIFY]** API key storage: plain prefs vs. secure storage (e.g. `flutter_secure_storage`) on all platforms
- [ ] Settings screen: provider-specific settings widget generalized from `_TranslationsOpenAIWidget`, get-API-key links per provider
- [ ] Dashboard info generalized from `getOpenAIDashboardInfo` (invalid model / missing key warnings per provider)
- [ ] `_aiTranslate` uses the generic service, keep Google Translate fallback and HTML unescape behavior
- [ ] Improve translate prompt: include key metadata description as context, placeholders (`$label`, `{language}`) must be preserved
- [ ] Provider icons (currently `images/icons8-chatgpt.svg` vs. `images/icons8-ai.svg`)
- [ ] Regression check: translate with OpenAI as before, with fallback, with missing / invalid key and invalid model

### Phase 3 — Subscription and CLI access investigation

Known state (2026-09-14, re-verify before deciding):
- Claude Pro/Max: subscription OAuth tokens are only allowed in Claude Code and claude.ai (terms 2026-02-20, enforced
  since 2026-04-04), third-party apps must use API keys
- ChatGPT Plus/Pro: "Sign in with ChatGPT" (Codex OAuth) is used by third-party harnesses (OpenCode, Cline, pi) and
  publicly tolerated by OpenAI, but not a documented public API and not guaranteed by terms
- Gemini: Google account login rules for third-party apps not verified yet

- [ ] Re-verify current terms for OpenAI, Anthropic and Google subscription use in third-party apps
- [ ] ChatGPT sign-in: document the OAuth flow, endpoint, model restrictions, rate limits, token refresh; check for a Dart implementation
- [ ] CLI bridge: evaluate calling the user's logged-in `codex exec` / `claude -p` / `gemini` CLI (detection, JSON output,
      streaming, cancellation, errors when not logged in)
- [ ] **[VERIFY]** CLI bridge terms: whether spawning the user's own official CLI from a distributed app is allowed per vendor
- [ ] **[VERIFY]** Platform limits: process spawning in MSIX, Snap strict confinement, macOS sandbox
- [ ] Cheap no-subscription alternatives: Gemini API free tier, OpenRouter
- [ ] **[DECISION]** Offer subscription / CLI access, in which builds (e.g. direct download only), or drop it; record reasoning

### Phase 4 — Local LLM investigation

- [ ] Ollama: model listing and chat via chosen package or OpenAI-compatible endpoint, default `http://localhost:11434`
- [ ] Other local runtimes via OpenAI-compatible endpoint: LM Studio, llama.cpp server
- [ ] Translation quality check on a few small models against a real project (e.g. JsTrions `en.json` → `sk.json`)
- [ ] Tool calling support of local models for Agent mode (which models are usable)
- [ ] **[VERIFY]** `localhost` access in MSIX (loopback restrictions), Snap and macOS sandbox
- [ ] UX: "Ollama not running" / "no models pulled" states in Settings and Dashboard info
- [ ] Decide whether local LLM is a separate provider or generic "OpenAI-compatible (custom base URL)" provider

### Phase 5 — Agent dialog

- [ ] **[DECISION]** First-release action set and whether the Agent may write files, candidates:
  - [ ] Free chat about the project translations
  - [ ] Suggest translation / alternatives for a key (replaces the unfinished chat in `_chatWithAI`)
  - [ ] Translate missing keys for whole project with context (key descriptions, existing translations as glossary)
  - [ ] Review existing translations (consistency, placeholders, tone)
  - [ ] Prepare / explain `RegExp` for finding translation keys in code per programming language
  - [ ] Suggest key names and descriptions for new texts
- [ ] Agent tools design (read-only first): list languages, get translations for key, list missing keys, search keys,
      read key metadata, sample code files for `RegExp` testing, test `RegExp` against sample files
- [ ] Mutation tools behind explicit user confirmation (propose changes → review diff → apply via existing
      `_saveTranslationsToAssets` flow)
- [ ] Rework `lib/ui/dialogs/openai_chat_dialog.dart` into a provider-neutral Agent dialog (message list, streaming,
      stop/cancel, tool call visibility, enlarge state pref)
- [ ] Entry points: Project Detail (project-wide actions), Edit Project Translation dialog (per key), Edit Project dialog (`RegExp` helper)
- [ ] Batch translation: chunking, progress, interruption, cost / token estimate before start
- [ ] Conversation state lifetime (per dialog vs. persisted per project)
- [ ] Error handling: rate limits, context length, invalid tool arguments, provider without tool calling

### Phase 6 — Validation and release

- [ ] `dart format` + `flutter analyze` on changed files
- [ ] Manual test matrix: providers × Windows / macOS / Linux, MSIX and Snap builds
- [ ] Translation keys added by user for new UI (`settings.*`, `dashboard.info.*`, Agent dialog scope)
- [ ] Update `metadata.json` / app description texts mentioning "Google Translate or OpenAI models"
