import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:js_trions/core/AppPreferences.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/GoogleTranslateParameters.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataTasks/GoogleTranslateDataTask.dart';
import 'package:js_trions/service/ProjectService.dart';
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
  final Map<int, FocusNode> _fieldsFocusNodes = Map();
  int _focusedIndex = -1;
  bool _fullScreen = false;

  /// State initialization
  @override
  void initState() {
    super.initState();

    _keyController.text = widget.translation.key ?? '';

    for (int i = 0; i < widget.translation.languages.length; i++) {
      _fieldsControllers[i] = TextEditingController()..text = widget.translation.translations[i];

      _fieldsFocusNodes[i] = FocusNode();
      _fieldsFocusNodes[i]!.addListener(_onFocus);
    }

    _fullScreen = prefsInt(PREFS_PROJECTS_EDIT_TRANSLATION_DIALOG_ENLARGED) == 1;
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _keyController.dispose();

    _fieldsControllers.forEach((key, controller) {
      controller.dispose();
    });
    _fieldsFocusNodes.forEach((key, focusNode) {
      focusNode.dispose();
    });

    super.dispose();
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final snapshot = AppDataState.of(context)!;
    final commonTheme = context.commonTheme;

    final isDesktop = [
      ResponsiveScreen.ExtraLargeDesktop,
      ResponsiveScreen.LargeDesktop,
      ResponsiveScreen.SmallDesktop,
      ResponsiveScreen.Tablet,
      ResponsiveScreen.LargePhone,
    ].contains(snapshot.responsiveScreen);

    final theKey = widget.translation.key;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.center,
        child: DialogContainer(
          style: commonTheme.dialogsStyle.listDialogStyle.dialogContainerStyle.copyWith(
            dialogWidth: _fullScreen ? double.infinity : 992,
            stretchContent: _fullScreen,
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
                    trailing: IconButtonWidget(
                      style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                        variant: IconButtonVariant.IconOnly,
                        iconWidth: kButtonHeight,
                        iconHeight: kButtonHeight,
                      ),
                      svgAssetPath: _fullScreen ? 'images/icons8-shrink.svg' : 'images/icons8-enlarge.svg',
                      onTap: () => setStateNotDisposed(() {
                        _fullScreen = !_fullScreen;

                        prefsSetInt(PREFS_PROJECTS_EDIT_TRANSLATION_DIALOG_ENLARGED, _fullScreen ? 1 : 0);
                      }),
                      tooltip: _fullScreen ? tt('edit_project_translation.shrink.tooltip') : tt('edit_project_translation.enlarge.tooltip'),
                    ),
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
                          tooltip: tt('edit_project_translation.copy_key.tooltip').parameters({
                            r'$key': theKey,
                          }),
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
                      fullscreen: _fullScreen,
                      isDesktop: isDesktop,
                      isFocused: i == _focusedIndex,
                      language: widget.translation.languages[i],
                      controller: _fieldsControllers[i]!,
                      focusNode: _fieldsFocusNodes[i]!,
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

  /// Callback for FocusNode, if focused, find index in map and then set focused index
  void _onFocus() {
    _focusedIndex = -1;

    for (int i = 0; i < _fieldsFocusNodes.length; i++) {
      if (_fieldsFocusNodes[i]!.hasFocus) {
        _focusedIndex = i;
        break;
      }
    }

    setStateNotDisposed(() {});
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

    final bool unescapeHTML = prefsInt(PREFS_TRANSLATIONS_NO_HTML) == 1;
    final unescape = HtmlUnescape();

    for (int i = 0; i < widget.translation.languages.length; i++) {
      String translationLanguage = widget.translation.languages[i];
      TextEditingController controller = _fieldsControllers[i]!;

      if (translationLanguage != language) {
        if (languageCodeOnly(language) == languageCodeOnly(translationLanguage)) {
          setStateNotDisposed(() {
            controller.text = query;
          });

          continue;
        }

        GoogleTranslateDataTask dataTask = await MainDataProvider.instance!.executeDataTask(GoogleTranslateDataTask(
          data: GoogleTranslateParameters(
            queries: [query],
            sourceLanguage: languageCodeOnly(language),
            targetLanguage: languageCodeOnly(translationLanguage),
          ),
        ));

        final theResult = dataTask.result;

        if (theResult != null) {
          final theText = unescapeHTML ? unescape.convert(theResult.translations.first.translatedText) : theResult.translations.first.translatedText;

          setStateNotDisposed(() {
            controller.text = theText;
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
  final bool fullscreen;
  final bool isDesktop;
  final bool isFocused;
  final String language;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function(BuildContext context, String language, String query) onGoogleTranslate;

  /// TranslationField initialization
  _TranslationField({
    required this.fullscreen,
    required this.isDesktop,
    required this.isFocused,
    required this.language,
    required this.controller,
    required this.focusNode,
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
                focusNode: focusNode,
                label: language,
                lines: (fullscreen && isDesktop) || isFocused ? 5 : 3,
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
              tooltip: tt('edit_project_translation.google_translate.tooltip').parameters({
                r'$language': language,
              }),
            ),
          ],
        ),
        CommonSpaceV(),
      ],
    );
  }
}
