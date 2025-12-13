import 'package:js_trions/core/app_preferences.dart';
import 'package:js_trions/model/GoogleTranslateParameters.dart';
import 'package:js_trions/model/dataTasks/GoogleTranslateDataTask.dart';
import 'package:js_trions/model/translations_provider.dart';
import 'package:js_trions/ui/widgets/dashboard/dashboard_info_widget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

/// Provide info for Dashboard, if enabled
void getGoogleTranslateDashboardInfo(List<DashboardInfoPayload> info) {
  if (TranslationsProvider.values[prefsInt(PREFS_TRANSLATIONS_PROVIDER)!] == TranslationsProvider.google) {
    info.add(DashboardInfoPayload(
      title: tt('dashboard.info.googleTranslate.title'),
      text: tt('dashboard.info.googleTranslate.text'),
      actionSettingsText: tt('dashboard.info.googleTranslate.actionSettingsText'),
    ));
  }
}

/// Use Google Translate to translate text
Future<String?> googleTranslateTranslateText({
  required String query,
  required String sourceLanguage,
  required String targetLanguage,
}) async {
  try {
    GoogleTranslateDataTask dataTask = await MainDataProvider.instance!.executeDataTask(GoogleTranslateDataTask(
      data: GoogleTranslateParameters(
        queries: [query],
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      ),
    ));

    final theResult = dataTask.result;
    debugPrint('TCH_theResult $theResult');

    return theResult?.translations.first.translatedText;
  } catch (e, t) {
    debugPrint('TCH_e $e');
    debugPrintStack(stackTrace: t);
  }

  return null;
}
