import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:js_trions/core/app_preferences.dart';
import 'package:js_trions/core/app_theme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/translation_key_metadata.dart';
import 'package:js_trions/model/translations_provider.dart';
import 'package:js_trions/service/ProjectService.dart';
import 'package:js_trions/service/google_translate_service.dart';
import 'package:js_trions/service/openai_service.dart';
import 'package:js_trions/ui/dialogs/openai_chat_dialog.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
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
  final _descriptionController = TextEditingController();
  final _descriptionFocusNode = FocusNode();
  final Map<int, TextEditingController> _fieldsControllers = Map();
  final Map<int, FocusNode> _fieldsFocusNodes = Map();
  int _focusedIndex = -1;
  bool _fullScreen = false;
  int _loadingIndex = -1;

  /// State initialization
  @override
  void initState() {
    super.initState();

    _keyController.text = widget.translation.key ?? '';
    _descriptionController.text = widget.translation.translationKeyMetadata?.description ?? '';

    _descriptionFocusNode.addListener(_onDescriptionFocus);

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
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();

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
    final provider = TranslationsProvider.values[prefsInt(PREFS_TRANSLATIONS_PROVIDER)!];

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
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextFormFieldWidget(
                          controller: _descriptionController,
                          focusNode: _descriptionFocusNode,
                          label: tt('edit_project_translation.field.description'),
                          lines: _descriptionFocusNode.hasFocus ? 5 : 3,
                        ),
                      ),
                    ],
                  ),
                  if (provider == TranslationsProvider.openai) ...[
                    CommonSpaceVHalf(),
                    Text(
                      tt('edit_project_translation.field.hint'),
                      style: fancyText(kText),
                    ),
                  ],
                  CommonSpaceV(),
                  for (int i = 0; i < widget.translation.languages.length; i++)
                    _TranslationField(
                      index: i,
                      fullscreen: _fullScreen,
                      isDesktop: isDesktop,
                      isFocused: i == _focusedIndex,
                      language: widget.translation.languages[i],
                      controller: _fieldsControllers[i]!,
                      focusNode: _fieldsFocusNodes[i]!,
                      onAITranslate: _aiTranslate,
                      onChatWithAI: _chatWithAI,
                      provider: provider,
                      loadingIndex: _loadingIndex,
                    ),
                  Text(
                    tt('edit_project_translation.ai_translate.hint'),
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
            yesOnTap: _loadingIndex >= 0 ? null : () => _process(context),
          ),
        ),
      ),
    );
  }

  /// Callback for FocusNode of description
  void _onDescriptionFocus() {
    setStateNotDisposed(() {});
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

      TranslationKeyMetadata? translationKeyMetadata = widget.translation.translationKeyMetadata;

      if (_descriptionController.text.isNotEmpty && translationKeyMetadata == null) {
        translationKeyMetadata = TranslationKeyMetadata(
          key: _keyController.text,
          description: _descriptionController.text,
        );
      } else if (translationKeyMetadata != null) {
        translationKeyMetadata.key = _keyController.text;
        translationKeyMetadata.description = _descriptionController.text;
      }

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
          translationKeyMetadata: translationKeyMetadata,
        ),
      );
    }
  }

  /// Use AI translations provider to translate from source to all other languages
  Future<void> _aiTranslate(BuildContext context, int index, String language, String query) async {
    if (language.isEmpty || query.isEmpty) {
      return;
    }

    final appTheme = context.appTheme;

    setStateNotDisposed(() {
      _loadingIndex = index;
    });

    final bool unescapeHTML = prefsInt(PREFS_TRANSLATIONS_NO_HTML) == 1;
    final unescape = HtmlUnescape();
    final provider = TranslationsProvider.values[prefsInt(PREFS_TRANSLATIONS_PROVIDER)!];
    final fallback = prefsInt(PREFS_TRANSLATIONS_FALLBACK) == 1;

    for (int i = 0; i < widget.translation.languages.length; i++) {
      String translationLanguage = widget.translation.languages[i];
      TextEditingController controller = _fieldsControllers[i]!;

      if (translationLanguage != language) {
        final sourceLanguage = languageCodeOnly(language);
        final targetLanguage = languageCodeOnly(translationLanguage);

        if (sourceLanguage == targetLanguage) {
          setStateNotDisposed(() {
            controller.text = query;
          });

          continue;
        }

        String? result;
        String? message;

        if (provider == TranslationsProvider.openai) {
          result = await openAITranslateText(
            text: query,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            context: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          );

          if (result == null) {
            message = tt('edit_project_translation.openai.fail');
          }
        }

        if (provider == TranslationsProvider.google || (fallback && result == null)) {
          result = await googleTranslateTranslateText(
            query: query,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
          );

          if (result == null) {
            message = tt('edit_project_translation.google_translate.fail');
          }
        }

        if (result != null) {
          final theText = unescapeHTML ? unescape.convert(result) : result;

          setStateNotDisposed(() {
            controller.text = theText;
          });
        } else if (message != null) {
          displayScreenMessage(
            ScreenMessage(
              message: message,
              type: ScreenMessageType.error,
            ),
            appTheme: appTheme,
          );

          break;
        }
      }
    }

    setStateNotDisposed(() {
      _loadingIndex = -1;
    });
  }

  /// Chat with AI to brainstorm best text/translation
  Future<void> _chatWithAI(BuildContext context, int index, String language) async {
    if (language.isEmpty) {
      return;
    }

    final result = await OpenAIChatDialog.show(context);
    print('TCH_dialog result: $result'); //TODO remove
    //TODO
  }
}

class Translation {
  final String? key;
  final List<String> languages;
  final List<String> translations;
  final TranslationKeyMetadata? translationKeyMetadata;

  /// Translation initialization
  Translation({
    required this.key,
    required this.languages,
    required this.translations,
    this.translationKeyMetadata,
  });
}

class _TranslationField extends StatelessWidget {
  final int index;
  final bool fullscreen;
  final bool isDesktop;
  final bool isFocused;
  final String language;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function(BuildContext context, int index, String language, String query) onAITranslate;
  final Future<void> Function(BuildContext context, int index, String language) onChatWithAI;
  final TranslationsProvider provider;
  final int loadingIndex;

  /// TranslationField initialization
  _TranslationField({
    required this.index,
    required this.fullscreen,
    required this.isDesktop,
    required this.isFocused,
    required this.language,
    required this.controller,
    required this.focusNode,
    required this.onAITranslate,
    required this.onChatWithAI,
    required this.provider,
    required this.loadingIndex,
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
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButtonWidget(
                  svgAssetPath: provider == TranslationsProvider.openai ? 'images/icons8-chatgpt.svg' : 'images/icons8-ai.svg',
                  onTap: () => onAITranslate(context, index, language, controller.text),
                  tooltip: tt('edit_project_translation.google_translate.tooltip').parameters({
                    r'$language': language,
                  }),
                  isLoading: loadingIndex == index,
                ),
                /*if (provider == TranslationsProvider.openai) ...[
                  CommonSpaceVHalf(),
                  IconButtonWidget(
                    svgAssetPath: 'images/icons8-messaging.svg',
                    onTap: () => onChatWithAI(context, index, language),
                    tooltip: tt('edit_project_translation.openai_chat.tooltip').parameters({
                      r'$language': language,
                    }),
                  ),
                ],*/
              ],
            ),
          ],
        ),
        CommonSpaceV(),
      ],
    );
  }
}
