import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/app.dart';
import 'package:js_trions/config.dart';
import 'package:js_trions/core/app_preferences.dart';
import 'package:js_trions/core/app_theme.dart';
import 'package:js_trions/model/ProgrammingLanguageQuery.dart';
import 'package:js_trions/model/ProjectQuery.dart';
import 'package:js_trions/model/dataTasks/DeleteProgrammingLanguagesDataTask.dart';
import 'package:js_trions/model/dataTasks/DeleteProjectsDataTask.dart';
import 'package:js_trions/model/translations_provider.dart';
import 'package:js_trions/service/openai_service.dart';
import 'package:js_trions/ui/data_widgets/manage_programming_languages_data_widget.dart';
import 'package:js_trions/ui/data_widgets/project_detail_data_widget.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:js_trions/ui/widgets/CategoryHeaderWidget.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
import 'package:js_trions/ui/widgets/settings/setting_widget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_appliable_core/utils/form.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends AbstractResponsiveScreen {
  static const String ROUTE = "/settings";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends AppResponsiveScreenState<SettingsScreen> {
  @override
  AbstractScreenOptions options = AppScreenStateOptions.main(
    screenName: SettingsScreen.ROUTE,
    title: tt('settings.screen.title'),
  );

  @override
  Widget extraLargeDesktopScreen(BuildContext context) => _BodyDesktopWidget();

  @override
  Widget largeDesktopScreen(BuildContext context) => _BodyDesktopWidget();

  @override
  Widget largePhoneScreen(BuildContext context) => _BodyWidget();

  @override
  Widget smallDesktopScreen(BuildContext context) => _BodyDesktopWidget();

  @override
  Widget smallPhoneScreen(BuildContext context) => _BodyWidget();

  @override
  Widget tabletScreen(BuildContext context) => _BodyWidget();
}

abstract class _AbstractBodyWidget extends AbstractStatefulWidget {}

abstract class _AbstractBodyWidgetState<T extends _AbstractBodyWidget> extends AbstractStatefulWidgetState<T> {
  final ScrollController _scrollController = ScrollController();
  late String _language;

  /// State initialization
  @override
  void initState() {
    super.initState();

    _language = Translator.instance!.currentLanguage;
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          width: double.infinity,
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSpaceV(),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: _TranslationsWidget(),
              ),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: _GeneralWidget(
                  language: _language,
                ),
              ),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: _ProjectsWidget(),
              ),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: _ProgrammingLanguagesWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyWidget extends _AbstractBodyWidget {
  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends _AbstractBodyWidgetState<_BodyWidget> {}

class _BodyDesktopWidget extends _AbstractBodyWidget {
  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyDesktopWidgetState();
}

class _BodyDesktopWidgetState extends _AbstractBodyWidgetState<_BodyDesktopWidget> {
  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          width: double.infinity,
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSpaceV(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: kPhoneStopBreakpoint,
                        padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                        child: _TranslationsWidget(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: kPhoneStopBreakpoint,
                        padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                        child: _GeneralWidget(
                          language: _language,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: kPhoneStopBreakpoint,
                        padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                        child: _ProjectsWidget(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: kPhoneStopBreakpoint,
                        padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                        child: _ProgrammingLanguagesWidget(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralWidget extends StatelessWidget {
  final String language;

  final _languageKey = GlobalKey<SelectionFormFieldWidgetState>();

  /// GeneralWidget initialization
  _GeneralWidget({
    required this.language,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHeaderWidget(
          text: tt('settings.screen.category.general'),
          doubleMargin: true,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ButtonWidget(
                style: commonTheme.buttonDangerStyle,
                text: tt('settings.screen.reset'),
                onTap: () {
                  _clearData(context);
                },
              ),
              CommonSpaceV(),
              Text(tt('settings.screen.reset.description'), style: fancyText(kText)),
              CommonSpaceVDouble(),
              SelectionFormFieldWidget<String>(
                key: _languageKey,
                label: tt('settings.screen.language'),
                selectionTitle: tt('settings.screen.language.selection'),
                clearText: tt('settings.screen.language.selection.cancel'),
                initialValue: language,
                options: <ListDialogOption<String>>[
                  ListDialogOption(
                    text: 'English',
                    value: 'en',
                  ),
                  ListDialogOption(
                    text: 'Slovenčina',
                    value: 'sk',
                  ),
                ],
                onChange: (String? newValue) {
                  if (newValue != null) {
                    Translator.instance!.changeLanguage(newValue);

                    prefsSetString(PREFS_LANGUAGE, Translator.instance!.currentLanguage);

                    Translator.instance!.initTranslations(context).then((value) {
                      AppState.instance.invalidate();

                      pushNamedNewStack(context, SettingsScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});

                      displayScreenMessage(
                        ScreenMessage(
                          message: tt('settings.screen.generic.success'),
                          type: ScreenMessageType.success,
                        ),
                        appTheme: commonTheme,
                      );
                    });
                  }
                },
              ),
              CommonSpaceV(),
              Text(
                tt('settings.screen.language.description'),
                style: fancyText(kText),
              ),
              CommonSpaceVDouble(),
              PreferencesSwitchWidget(
                label: tt('settings.screen.font'),
                prefsKey: PREFS_FANCY_FONT,
                descriptionOn: tt('settings.screen.font.on'),
                descriptionOff: tt('settings.screen.font.off'),
                onChange: (bool value) {
                  Future.delayed(kThemeAnimationDuration).then((value) {
                    AppState.instance.invalidate();

                    pushNamedNewStack(context, SettingsScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});

                    displayScreenMessage(
                      ScreenMessage(
                        message: tt('settings.screen.generic.success'),
                        type: ScreenMessageType.success,
                      ),
                      appTheme: commonTheme,
                    );
                  });
                },
              ),
              CommonSpaceVDouble(),
            ],
          ),
        ),
      ],
    );
  }

  /// Clear all app data from DB after user confirms
  Future<void> _clearData(BuildContext context) async {
    final appTheme = context.appTheme;

    final confirmed = await ConfirmDialog.show(
      context,
      isDanger: true,
      title: tt('dialog.confirm.title'),
      text: tt('settings.screen.reset.confirm'),
      noText: tt('dialog.no'),
      yesText: tt('dialog.yes'),
    );

    if (confirmed == true) {
      await MainDataProvider.instance!.executeDataTask(
        DeleteProgrammingLanguagesDataTask(
          data: ProgrammingLanguageQuery.fromJson({}),
        ),
      );

      await MainDataProvider.instance!.executeDataTask(
        DeleteProjectsDataTask(
          data: ProjectQuery.fromJson({}),
        ),
      );

      displayScreenMessage(
        ScreenMessage(
          message: tt('settings.screen.reset.success'),
          type: ScreenMessageType.success,
        ),
        appTheme: appTheme,
      );
    }
  }
}

class _TranslationsWidget extends StatelessWidget {
  final _translationsProviderKey = GlobalKey<SelectionFormFieldWidgetState>();

  /// TranslationsWidget initialization
  _TranslationsWidget();

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final provider = TranslationsProvider.values[prefsInt(PREFS_TRANSLATIONS_PROVIDER)!];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHeaderWidget(
          text: tt('settings.screen.category.translations'),
          doubleMargin: true,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectionFormFieldWidget<TranslationsProvider>(
                key: _translationsProviderKey,
                label: tt('settings.screen.translationProvider'),
                selectionTitle: tt('settings.screen.translationProvider.selection'),
                clearText: tt('settings.screen.translationProvider.selection.cancel'),
                initialValue: provider,
                options: <ListDialogOption<TranslationsProvider>>[
                  ListDialogOption(
                    text: tt('common.googleTranslate'),
                    value: TranslationsProvider.google,
                  ),
                  ListDialogOption(
                    text: tt('common.openai'),
                    value: TranslationsProvider.openai,
                  ),
                ],
                onChange: (TranslationsProvider? newValue) {
                  if (newValue != null) {
                    prefsSetInt(PREFS_TRANSLATIONS_PROVIDER, newValue.index);

                    displayScreenMessage(
                      ScreenMessage(
                        message: tt('settings.screen.translationProvider.success'),
                        type: ScreenMessageType.success,
                      ),
                      appTheme: appTheme,
                    );
                  } else {
                    _translationsProviderKey.currentState?.setValue(provider);
                  }
                },
              ),
              CommonSpaceV(),
              Text(
                tt('settings.screen.translationProvider.description'),
                style: fancyText(kText),
              ),
              CommonSpaceVDouble(),
              AnimatedSize(
                duration: kThemeAnimationDuration,
                alignment: Alignment.topCenter,
                child: provider == TranslationsProvider.openai
                    ? _TranslationsOpenAIWidget()
                    : const SizedBox(
                        width: double.infinity,
                      ),
              ),
              PreferencesSwitchWidget(
                label: tt('settings.screen.translations.no_html_entities'),
                prefsKey: PREFS_TRANSLATIONS_NO_HTML,
                descriptionOn: tt('settings.screen.translations.no_html_entities.on'),
                descriptionOff: tt('settings.screen.translations.no_html_entities.off'),
                onChange: (bool value) {
                  displayScreenMessage(
                    ScreenMessage(
                      message: tt('settings.screen.generic.success'),
                      type: ScreenMessageType.success,
                    ),
                    appTheme: appTheme,
                  );
                },
              ),
              CommonSpaceVDouble(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TranslationsOpenAIWidget extends AbstractStatefulWidget {
  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _TranslationsOpenAIWidgetState();
}

class _TranslationsOpenAIWidgetState extends AbstractStatefulWidgetState<_TranslationsOpenAIWidget> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _organizationController = TextEditingController();
  final _apiKeyFocus = FocusNode();
  final _organizationFocus = FocusNode();
  late String _apiKeyDesc1;
  late String _apiKeyDescLink;
  bool _obscureApiKey = true;
  bool _openAIModelsLoading = true;
  List<ListDialogOption<String>> _openAIModelsAsOptions = [];
  final _selectModelKey = GlobalKey<SelectionFormFieldWidgetState>();

  /// State initialization
  @override
  void initState() {
    super.initState();

    final String apiKeyDesc = tt('settings.screen.openAIApiKey.description');

    List<String> processing = apiKeyDesc.split(RegExp(r'<a>|</a>')).where((part) => part.isNotEmpty).toList();

    _apiKeyDesc1 = processing[0];
    _apiKeyDescLink = processing[1];

    _apiKeyController.text = prefsString(PREFS_TRANSLATIONS_OPENAI_API_KEY) ?? '';
    _organizationController.text = prefsString(PREFS_TRANSLATIONS_OPENAI_ORGANIZATION) ?? '';

    _updateOpenAIModelsAsOptions();
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _apiKeyController.dispose();
    _organizationController.dispose();
    _apiKeyFocus.dispose();
    _organizationFocus.dispose();

    super.dispose();
  }

  /// Build content from widgets
  @override
  Widget buildContent(BuildContext context) {
    final appTheme = context.appTheme;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SettingWidget(
                  label: null,
                  content: TextFormFieldWidget(
                    controller: _apiKeyController,
                    focusNode: _apiKeyFocus,
                    nextFocus: _organizationFocus,
                    label: tt('settings.screen.openAIApiKey'),
                    textInputAction: TextInputAction.next,
                    obscureText: _obscureApiKey,
                    validations: [
                      FormFieldValidation(
                        validator: validateRequired,
                        errorText: tt('validation.required'),
                      ),
                    ],
                  ),
                  description: null,
                  trailing: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: _apiKeyDesc1,
                        style: fancyText(kText),
                      ),
                      TextSpan(
                        text: _apiKeyDescLink,
                        style: fancyText(kTextBold.copyWith(
                          color: kColorSecondary,
                          decoration: TextDecoration.underline,
                          decorationColor: kColorSecondary,
                        )),
                        recognizer: TapGestureRecognizer()..onTap = () => launchUrlString(kOpenAIGetApKey),
                      ),
                    ]),
                  ),
                ),
              ),
              CommonSpaceH(),
              IconButtonWidget(
                svgAssetPath: _obscureApiKey ? 'images/icons8-eye.svg' : 'images/icons8-invisible.svg',
                onTap: () => setStateNotDisposed(() => _obscureApiKey = !_obscureApiKey),
              ),
              CommonSpaceH(),
              IconButtonWidget(
                svgAssetPath: 'images/save.svg',
                onTap: () => _save(context),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SettingWidget(
                  label: null,
                  content: TextFormFieldWidget(
                    controller: _organizationController,
                    focusNode: _organizationFocus,
                    label: tt('settings.screen.openAI.organization'),
                    onFieldSubmitted: (_) => _save(context),
                  ),
                  description: tt('settings.screen.openAI.organization.description'),
                ),
              ),
              CommonSpaceH(),
              IconButtonWidget(
                svgAssetPath: 'images/save.svg',
                onTap: () => _save(context),
              ),
            ],
          ),
          if (_openAIModelsLoading) ...[
            IconButtonWidget(
              style: appTheme.buttonsStyle.iconButtonStyle.copyWith(
                variant: IconButtonVariant.IconOnly,
              ),
              svgAssetPath: '',
              isLoading: true,
            ),
            CommonSpaceV(),
            Text(
              tt('settings.screen.openAI.selectModel.description'),
              style: fancyText(kText),
            ),
            CommonSpaceVDouble(),
          ] else if (_openAIModelsAsOptions.isNotEmpty) ...[
            SelectionFormFieldWidget<String>(
              key: _selectModelKey,
              label: tt('settings.screen.openAI.selectModel'),
              selectionTitle: tt('settings.screen.openAI.selectModel.selection'),
              clearText: tt('settings.screen.openAI.selectModel.selection.cancel'),
              initialValue: prefsString(PREFS_TRANSLATIONS_OPENAI_SELECTED_MODEL),
              options: _openAIModelsAsOptions,
              hasFilter: true,
              filterText: tt('settings.screen.openAI.selectModel.filter'),
              onChange: (String? newValue) {
                if (newValue != null) {
                  prefsSetString(PREFS_TRANSLATIONS_OPENAI_SELECTED_MODEL, newValue);
                } else {
                  _selectModelKey.currentState?.setValue(prefsString(PREFS_TRANSLATIONS_OPENAI_SELECTED_MODEL));
                }
              },
            ),
            CommonSpaceV(),
            Text(
              tt('settings.screen.openAI.selectModel.description'),
              style: fancyText(kText),
            ),
            CommonSpaceVDouble(),
          ],
          PreferencesSwitchWidget(
            label: tt('settings.screen.translations.fallback'),
            prefsKey: PREFS_TRANSLATIONS_FALLBACK,
            descriptionOn: tt('settings.screen.translations.fallback.on'),
            descriptionOff: tt('settings.screen.translations.fallback.off'),
            onChange: (bool value) {
              displayScreenMessage(
                ScreenMessage(
                  message: tt('settings.screen.generic.success'),
                  type: ScreenMessageType.success,
                ),
                appTheme: appTheme,
              );
            },
          ),
          CommonSpaceVDouble(),
        ],
      ),
    );
  }

  /// Update OpenAI models options
  Future<void> _updateOpenAIModelsAsOptions() async {
    final options = await getOpenAIModelsAsOptions();

    options.sort((a, b) => a.text.compareTo(b.text));

    setStateNotDisposed(() {
      _openAIModelsLoading = false;
      _openAIModelsAsOptions = options;
    });
  }

  /// Save OpenAI preferences
  Future<void> _save(BuildContext context) async {
    clearFocus(context);

    final appTheme = context.appTheme;

    if (_formKey.currentState!.validate()) {
      prefsSetString(PREFS_TRANSLATIONS_OPENAI_API_KEY, _apiKeyController.text);
      prefsSetString(PREFS_TRANSLATIONS_OPENAI_ORGANIZATION, _organizationController.text);

      await initOpenAIClient();

      _updateOpenAIModelsAsOptions();

      displayScreenMessage(
        ScreenMessage(
          message: tt('settings.screen.openAI.success'),
          type: ScreenMessageType.success,
        ),
        appTheme: appTheme,
      );
    }
  }
}

class _ProjectsWidget extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHeaderWidget(
          text: tt('settings.screen.category.projects'),
          doubleMargin: true,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingWidget(
                label: tt('settings.screen.analysis.label'),
                content: Wrap(
                  spacing: kCommonHorizontalMarginHalf,
                  runSpacing: kCommonVerticalMarginHalf,
                  children: [
                    _ProjectAnalysisOnInitChipWidget(
                      analysisOnInit: ProjectAnalysisOnInit.Always,
                    ),
                    _ProjectAnalysisOnInitChipWidget(
                      analysisOnInit: ProjectAnalysisOnInit.Never,
                    ),
                    _ProjectAnalysisOnInitChipWidget(
                      analysisOnInit: ProjectAnalysisOnInit.CodeVisibleOnly,
                    ),
                  ],
                ),
                description: tt('settings.screen.analysis.description'),
              ),
              PreferencesSwitchWidget(
                label: tt('settings.screen.code_only'),
                prefsKey: PREFS_PROJECTS_CODE_ONLY,
                descriptionOn: tt('settings.screen.code_only.on'),
                descriptionOff: tt('settings.screen.code_only.off'),
                onChange: (bool value) {
                  displayScreenMessage(
                    ScreenMessage(
                      message: tt('settings.screen.generic.success'),
                      type: ScreenMessageType.success,
                    ),
                    appTheme: appTheme,
                  );
                },
              ),
              CommonSpaceVDouble(),
              SettingWidget(
                label: tt('settings.screen.source.label'),
                content: Wrap(
                  spacing: kCommonHorizontalMarginHalf,
                  runSpacing: kCommonVerticalMarginHalf,
                  children: [
                    _SourceOfTranslationsChipWidget(
                      source: SourceOfTranslations.All,
                    ),
                    _SourceOfTranslationsChipWidget(
                      source: SourceOfTranslations.Assets,
                    ),
                    _SourceOfTranslationsChipWidget(
                      source: SourceOfTranslations.Code,
                    ),
                  ],
                ),
                description: tt('settings.screen.source.description'),
              ),
              PreferencesSwitchWidget(
                label: tt('settings.screen.beautify_json'),
                prefsKey: PREFS_PROJECTS_BEAUTIFY_JSON,
                descriptionOn: tt('settings.screen.beautify_json.on'),
                descriptionOff: tt('settings.screen.beautify_json.off'),
                onChange: (bool value) {
                  displayScreenMessage(
                    ScreenMessage(
                      message: tt('settings.screen.generic.success'),
                      type: ScreenMessageType.success,
                    ),
                    appTheme: appTheme,
                  );
                },
              ),
              CommonSpaceVDouble(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectAnalysisOnInitChipWidget extends StatelessWidget {
  final ProjectAnalysisOnInit analysisOnInit;

  /// ProjectAnalysisOnInitChipWidget initialization
  _ProjectAnalysisOnInitChipWidget({
    required this.analysisOnInit,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final selected = analysisOnInit.index == prefsInt(PREFS_PROJECTS_ANALYSIS);

    String text = '';

    switch (analysisOnInit) {
      case ProjectAnalysisOnInit.Always:
        text = tt('settings.screen.analysis.always');
        break;
      case ProjectAnalysisOnInit.Never:
        text = tt('settings.screen.analysis.never');
        break;
      case ProjectAnalysisOnInit.CodeVisibleOnly:
        text = tt('settings.screen.analysis.code');
        break;
    }

    return ChipWidget(
      text: text,
      suffixIcon: SvgPicture.asset(
        selected ? 'images/circle-full.svg' : 'images/circle-empty.svg',
        width: commonTheme.buttonsStyle.iconButtonStyle.iconWidth,
        height: commonTheme.buttonsStyle.iconButtonStyle.iconHeight,
        color: commonTheme.buttonsStyle.iconButtonStyle.color,
      ),
      onTap: selected
          ? null
          : () {
              prefsSetInt(PREFS_PROJECTS_ANALYSIS, analysisOnInit.index);

              AppState.instance.invalidate();

              displayScreenMessage(
                ScreenMessage(
                  message: tt('settings.screen.generic.success'),
                  type: ScreenMessageType.success,
                ),
                appTheme: commonTheme,
              );
            },
    );
  }
}

class _SourceOfTranslationsChipWidget extends StatelessWidget {
  final SourceOfTranslations source;

  /// SourceOfTranslationsChipWidget initialization
  _SourceOfTranslationsChipWidget({
    required this.source,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final selected = source.index == prefsInt(PREFS_PROJECTS_SOURCE);

    String text = '';

    switch (source) {
      case SourceOfTranslations.All:
        text = tt('project_detail.actions.source.all');
        break;
      case SourceOfTranslations.Assets:
        text = tt('project_detail.actions.source.assets');
        break;
      case SourceOfTranslations.Code:
        text = tt('project_detail.actions.source.code');
        break;
      case SourceOfTranslations.IgnoredKeys:
        text = tt('project_detail.actions.source.ignored_keys');
        break;
    }

    return ChipWidget(
      text: text,
      suffixIcon: SvgPicture.asset(
        selected ? 'images/circle-full.svg' : 'images/circle-empty.svg',
        width: commonTheme.buttonsStyle.iconButtonStyle.iconWidth,
        height: commonTheme.buttonsStyle.iconButtonStyle.iconHeight,
        color: commonTheme.buttonsStyle.iconButtonStyle.color,
      ),
      onTap: selected
          ? null
          : () {
              prefsSetInt(PREFS_PROJECTS_SOURCE, source.index);

              AppState.instance.invalidate();

              displayScreenMessage(
                ScreenMessage(
                  message: tt('settings.screen.generic.success'),
                  type: ScreenMessageType.success,
                ),
                appTheme: commonTheme,
              );
            },
    );
  }
}

class _ProgrammingLanguagesWidget extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHeaderWidget(
          text: tt('settings.screen.category.programming_languages'),
          doubleMargin: true,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ManageProgrammingLanguagesDataWidget(),
              CommonSpaceVDouble(),
            ],
          ),
        ),
      ],
    );
  }
}
