import 'package:js_trions/model/GoogleTranslateParameters.dart';
import 'package:js_trions/model/dataTasks/GoogleTranslateDataTask.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

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

    return theResult?.translations.first.translatedText;
  } catch (e, t) {
    debugPrint('TCH_e $e');
    debugPrintStack(stackTrace: t);
  }

  return null;
}
