import 'package:flutter/services.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/GoogleTranslateParameters.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataTasks/GoogleTranslateDataTask.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class EditProjectTranslationDialog extends AbstractStatefulWidget {
  final Project project;
  final Translation translation;

  /// EditProjectTranslationDialog initialization
  EditProjectTranslationDialog({
    required this.project,
    required this.translation,
  });

  /// Show the dialog as a popup
  static Future<Translation?> show(
    BuildContext context, {
    required Project project,
    required Translation translation,
  }) {
    return showDialog<Translation>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: EditProjectTranslationDialog(
            project: project,
            translation: translation,
          ),
        );
      },
    );
  }

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _EditProjectTranslationDialogState();
}

class _EditProjectTranslationDialogState extends AbstractStatefulWidgetState<EditProjectTranslationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final Map<int, TextEditingController> _fieldsControllers = Map();

  /// State initialization
  @override
  void initState() {
    super.initState();

    _keyController.text = widget.translation.key ?? '';

    for (int i = 0; i < widget.translation.languages.length; i++) {
      _fieldsControllers[i] = TextEditingController()..text = widget.translation.translations[i];
    }
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _keyController.dispose();

    _fieldsControllers.forEach((key, controller) {
      controller.dispose();
    });

    super.dispose();
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final theKey = widget.translation.key;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.center,
        child: DialogContainer(
          style: commonTheme.dialogsStyle.listDialogStyle.dialogContainerStyle.copyWith(
            dialogWidth: 992,
          ),
          content: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogHeader(
                    style: commonTheme.dialogsStyle.listDialogStyle.dialogHeaderStyle,
                    title: tt('edit_project_translation.title'),
                  ),
                  CommonSpaceVHalf(),
                  if (theKey != null)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            theKey,
                            style: fancyText(kTextBold),
                          ),
                        ),
                        CommonSpaceHHalf(),
                        IconButtonWidget(
                          style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                            variant: IconButtonVariant.IconOnly,
                          ),
                          svgAssetPath: 'images/clipboard.svg',
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: theKey));
                          },
                        ),
                        Container(width: kButtonHeight + kCommonHorizontalMargin),
                      ],
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: TextFormFieldWidget(
                            controller: _keyController,
                            label: tt('edit_project_translation.field.key'),
                            validations: [
                              FormFieldValidation(
                                validator: validateRequired,
                                errorText: tt('validation.required'),
                              ),
                            ],
                          ),
                        ),
                        Container(width: kButtonHeight + kCommonHorizontalMargin),
                      ],
                    ),
                  CommonSpaceV(),
                  for (int i = 0; i < widget.translation.languages.length; i++)
                    _TranslationField(
                      language: widget.translation.languages[i],
                      controller: _fieldsControllers[i]!,
                      onGoogleTranslate: _googleTranslate,
                    ),
                  Text(
                    tt('edit_project_translation.google_translate.hint'),
                    style: fancyText(kText),
                  ),
                  CommonSpaceVHalf(),
                ],
              ),
            ),
          ],
          dialogFooter: DialogFooter(
            style: commonTheme.dialogsStyle.listDialogStyle.dialogFooterStyle,
            noText: tt('dialog.cancel'),
            yesText: tt('edit_project_translation.submit'),
            noOnTap: () {
              Navigator.of(context).pop();
            },
            yesOnTap: () => _process(context),
          ),
        ),
      ),
    );
  }

  /// Process translations and send back
  void _process(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final List<String> languages = [];
      final List<String> translations = [];

      for (int i = 0; i < widget.translation.languages.length; i++) {
        languages.add(widget.translation.languages[i]);
        translations.add(_fieldsControllers[i]!.text);
      }

      popNotDisposed(
        context,
        mounted,
        Translation(
          key: _keyController.text,
          languages: languages,
          translations: translations,
        ),
      );
    }
  }

  /// Use GoogleTranslate to translate from source to all other languages
  Future<void> _googleTranslate(BuildContext context, String language, String query) async {
    if (language.isEmpty || query.isEmpty) {
      return;
    }

    for (int i = 0; i < widget.translation.languages.length; i++) {
      String translationLanguage = widget.translation.languages[i];
      TextEditingController controller = _fieldsControllers[i]!;

      if (translationLanguage != language) {
        GoogleTranslateDataTask dataTask = await MainDataProvider.instance!.executeDataTask(GoogleTranslateDataTask(
          data: GoogleTranslateParameters(
            queries: [query],
            sourceLanguage: language,
            targetLanguage: translationLanguage,
          ),
        ));

        final theResult = dataTask.result;

        if (theResult != null) {
          setStateNotDisposed(() {
            controller.text = theResult.translations.first.translatedText;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              tt('edit_project_translation.google_translate.fail'),
              style: fancyText(kTextDanger),
              textAlign: TextAlign.center,
            ),
          ));

          break;
        }
      }
    }
  }
}

class Translation {
  final String? key;
  final List<String> languages;
  final List<String> translations;

  /// Translation initialization
  Translation({
    required this.key,
    required this.languages,
    required this.translations,
  });
}

class _TranslationField extends StatelessWidget {
  final String language;
  final TextEditingController controller;
  final Future<void> Function(BuildContext context, String language, String query) onGoogleTranslate;

  /// TranslationField initialization
  _TranslationField({
    required this.language,
    required this.controller,
    required this.onGoogleTranslate,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormFieldWidget(
                controller: controller,
                label: language,
                lines: 3,
                validations: [
                  FormFieldValidation(
                    validator: validateRequired,
                    errorText: tt('validation.required'),
                  ),
                ],
              ),
            ),
            CommonSpaceH(),
            IconButtonWidget(
              svgAssetPath: 'images/language.svg',
              onTap: () => onGoogleTranslate(context, language, controller.text),
            ),
          ],
        ),
        CommonSpaceV(),
      ],
    );
  }
}
