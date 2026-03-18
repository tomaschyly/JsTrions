import 'package:js_trions/model/translations_provider.dart';
import 'package:js_trions/ui/data_widgets/project_detail_data_widget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

const String kPrefsLanguage = "prefs_language";
const String kPrefsFancyFont = 'prefs_fancy_font';
const String kPrefsProjectsSource = 'prefs_projects_source';
const String kPrefsProjectsAnalysis = 'prefs_projects_analysis';
const String kPrefsProjectsCodeOnly = 'prefs_projects_code_only';
const String kPrefsProjectsBeautifyJson = 'prefs_projects_beautify_json';
const String kPrefsProjectsEditTranslationDialogEnlarged = 'prefs_projects_edit_translation_dialog_enlarged';
const String kPrefsOpenaiChatDialogEnlarged = 'prefs_openai_chat_dialog_enlarged';
const String kPrefsWelcome = 'prefs_welcome';
const String kPrefsTranslationsProvider = 'prefs_translations_provider';
const String kPrefsTranslationsOpenaiApiKey = 'prefs_translations_openai_api_key';
const String kPrefsTranslationsOpenaiOrganization = 'prefs_translations_openai_organization';
const String kPrefsTranslationsOpenaiSelectedModel = 'prefs_translations_openai_selected_model';
const String kPrefsTranslationsFallback = 'prefs_translations_fallback';
const String kPrefsTranslationsNoHtml = 'prefs_translations_no_html';

/// Int values, it is for init, defaults and in memory storage
final Map<String, int> intPrefs = {
  kPrefsFancyFont: 1,
  kPrefsProjectsSource: SourceOfTranslations.All.index,
  kPrefsProjectsAnalysis: ProjectAnalysisOnInit.Always.index,
  kPrefsProjectsBeautifyJson: 1,
  kPrefsProjectsCodeOnly: 1,
  kPrefsTranslationsProvider: TranslationsProvider.google.index,
  kPrefsTranslationsFallback: 1,
  kPrefsTranslationsNoHtml: 1,
};

/// String values, it is for init, defaults and in memory storage
final Map<String, String> stringPrefs = {
  kPrefsTranslationsOpenaiSelectedModel: 'gpt-5.4-mini',
};

/// Clear all application preferences (using all defined keys with correct types)
Future<void> clearAllAppPrefs() async {
  // int / bool-like prefs and enum indices
  await prefsRemoveInt(kPrefsFancyFont);
  await prefsRemoveInt(kPrefsProjectsSource);
  await prefsRemoveInt(kPrefsProjectsAnalysis);
  await prefsRemoveInt(kPrefsProjectsCodeOnly);
  await prefsRemoveInt(kPrefsProjectsBeautifyJson);
  await prefsRemoveInt(kPrefsProjectsEditTranslationDialogEnlarged);
  await prefsRemoveInt(kPrefsOpenaiChatDialogEnlarged);
  await prefsRemoveInt(kPrefsWelcome);
  await prefsRemoveInt(kPrefsTranslationsProvider);
  await prefsRemoveInt(kPrefsTranslationsFallback);
  await prefsRemoveInt(kPrefsTranslationsNoHtml);

  // string prefs
  await prefsRemoveString(kPrefsLanguage);
  await prefsRemoveString(kPrefsTranslationsOpenaiApiKey);
  await prefsRemoveString(kPrefsTranslationsOpenaiOrganization);
  await prefsRemoveString(kPrefsTranslationsOpenaiSelectedModel);

  // reset to defaults using in-memory default maps
  for (final entry in intPrefs.entries) {
    await prefsSetInt(entry.key, entry.value);
  }

  for (final entry in stringPrefs.entries) {
    await prefsSetString(entry.key, entry.value);
  }
}
