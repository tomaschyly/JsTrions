import 'package:js_trions/ui/dataWidgets/ProjectDetailDataWidget.dart';

const String PREFS_LANGUAGE = "prefs_language";
const String PREFS_FANCY_FONT = 'prefs_fancy_font';
const String PREFS_PROJECTS_SOURCE = 'prefs_projects_source';

/// Int values, it is for init, defaults and in memory storage
final Map<String, int> intPrefs = {
  PREFS_FANCY_FONT: 1,
  PREFS_PROJECTS_SOURCE: SourceOfTranslations.All.index,
};
