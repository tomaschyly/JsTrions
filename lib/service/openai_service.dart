import 'package:js_trions/core/app_preferences.dart';
import 'package:js_trions/model/translations_provider.dart';
import 'package:js_trions/ui/widgets/dashboard/dashboard_info_widget.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

OpenAIClient? _openAIClient;

bool get isOpenAIClientInitialized => _openAIClient != null;
List<String> openAIModalIds = [];

/// Initialize OpenAI client
Future<void> initOpenAIClient() async {
  final apiKey = prefsString(kPrefsTranslationsOpenaiApiKey);
  final organization = prefsString(kPrefsTranslationsOpenaiOrganization);

  if (apiKey != null && apiKey.isNotEmpty) {
    _openAIClient = OpenAIClient.withApiKey(
      apiKey,
      organization: organization,
    );

    final models = await _openAIClient!.models.list();

    openAIModalIds = models.data.map((e) => e.id).toList();
  } else {
    _openAIClient = null;
  }
}

/// Create list of [ListDialogOption] for available OpenAI models
Future<List<ListDialogOption<String>>> getOpenAIModelsAsOptions() async {
  if (_openAIClient == null) {
    return [];
  }

  final models = await _openAIClient!.models.list();

  return models.data.map((e) => ListDialogOption<String>(text: '${e.id} - ${e.ownedBy}', value: e.id)).toList();
}

/// Provide info for Dashboard, if enabled
void getOpenAIDashboardInfo(List<DashboardInfoPayload> info) {
  if (TranslationsProvider.values[prefsInt(kPrefsTranslationsProvider)!] == TranslationsProvider.openai) {
    final theModelId = prefsString(kPrefsTranslationsOpenaiSelectedModel) ?? tt('common.model.invalid');
    bool isDanger = false;

    String text = tt('dashboard.info.openAI.text').parameters({
      r'$model': theModelId,
    });

    if (isOpenAIClientInitialized && !openAIModalIds.contains(theModelId)) {
      text = tt('dashboard.info.openAI.text.invalidModel').parameters({
        r'$model': theModelId,
      });
      isDanger = true;
    }

    info.add(DashboardInfoPayload(
      title: tt('dashboard.info.openAI.title'),
      text: text,
      isDanger: isDanger,
      actionSettingsText: tt('dashboard.info.openAI.actionSettingsText'),
    ));
  }
}

/// Use OpenAI to translate text
Future<String?> openAITranslateText({
  required String text,
  required String sourceLanguage,
  required String targetLanguage,
  String? context,
  String? modelId,
}) async {
  final theModelId = modelId ?? prefsString(kPrefsTranslationsOpenaiSelectedModel);

  if (isOpenAIClientInitialized && openAIModalIds.contains(theModelId)) {
    try {
      String userQuery = 'Translate text from $sourceLanguage to $targetLanguage: $text';

      final res = await _openAIClient!.chat.completions.create(
        ChatCompletionCreateRequest(
          model: theModelId!,
          messages: [
            ChatMessage.system(
              'You are a helpful assistant that translates text for users. Respond only with translated text, do not add anything extra.',
            ),
            ChatMessage.user(userQuery),
            if (context != null && context.isNotEmpty)
              ChatMessage.user(
                'Context for this translations is: $context',
              ),
          ],
        ),
      );

      return res.choices.first.message.content;
    } catch (e, t) {
      debugPrint('TCH_e $e');
      debugPrintStack(stackTrace: t);
    }
  }

  return null;
}
