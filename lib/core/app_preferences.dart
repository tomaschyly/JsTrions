import 'package:js_trions/model/translations_provider.dart';
import 'package:js_trions/ui/dataWidgets/ProjectDetailDataWidget.dart';

const String PREFS_LANGUAGE = "prefs_language";
const String PREFS_FANCY_FONT = 'prefs_fancy_font';
const String PREFS_PROJECTS_SOURCE = 'prefs_projects_source';
const String PREFS_PROJECTS_ANALYSIS = 'prefs_projects_analysis';
const String PREFS_PROJECTS_CODE_ONLY = 'prefs_projects_code_only';
const String PREFS_PROJECTS_BEAUTIFY_JSON = 'prefs_projects_beautify_json';
const String PREFS_PROJECTS_EDIT_TRANSLATION_DIALOG_ENLARGED = 'prefs_projects_edit_translation_dialog_enlarged';
const String PREFS_WELCOME = 'prefs_welcome';
const String PREFS_TRANSLATIONS_PROVIDER = 'prefs_translations_provider';
const String PREFS_TRANSLATIONS_OPENAI_API_KEY = 'prefs_translations_openai_api_key';
const String PREFS_TRANSLATIONS_NO_HTML = 'prefs_translations_no_html';

/// Int values, it is for init, defaults and in memory storage
final Map<String, int> intPrefs = {
  PREFS_FANCY_FONT: 1,
  PREFS_PROJECTS_SOURCE: SourceOfTranslations.All.index,
  PREFS_PROJECTS_ANALYSIS: ProjectAnalysisOnInit.Always.index,
  PREFS_PROJECTS_BEAUTIFY_JSON: 1,
  PREFS_PROJECTS_CODE_ONLY: 1,
  PREFS_TRANSLATIONS_PROVIDER: TranslationsProvider.google.index,
  PREFS_TRANSLATIONS_NO_HTML: 1,
};
