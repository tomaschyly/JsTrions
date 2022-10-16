import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/App.dart';
import 'package:js_trions/core/AppPreferences.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/ProgrammingLanguageQuery.dart';
import 'package:js_trions/model/ProjectQuery.dart';
import 'package:js_trions/model/dataTasks/DeleteProgrammingLanguagesDataTask.dart';
import 'package:js_trions/model/dataTasks/DeleteProjectsDataTask.dart';
import 'package:js_trions/ui/dataWidgets/ManageProgrammingLanguagesDataWidget.dart';
import 'package:js_trions/ui/dataWidgets/ProjectDetailDataWidget.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:js_trions/ui/widgets/CategoryHeaderWidget.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
import 'package:js_trions/ui/widgets/SettingWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class SettingsScreen extends AbstractResposiveScreen {
  static const String ROUTE = "/settings";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends AppResponsiveScreenState<SettingsScreen> {
  @override
  AbstractScreenStateOptions options = AppScreenStateOptions.main(
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
                child: _GeneralWidget(
                  language: _language,
                ),
              ),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: _TranslationsWidget(),
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
                        child: _GeneralWidget(
                          language: _language,
                        ),
                      ),
                    ),
                  ),
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
                    });
                  } else {
                    Future.delayed(kThemeAnimationDuration).then((value) {
                      _languageKey.currentState!.setValue(language);
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
    }
  }
}

class _TranslationsWidget extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
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
              PreferencesSwitchWidget(
                label: tt('settings.screen.translations.no_html_entities'),
                prefsKey: PREFS_TRANSLATIONS_NO_HTML,
                descriptionOn: tt('settings.screen.translations.no_html_entities.on'),
                descriptionOff: tt('settings.screen.translations.no_html_entities.off'),
              ),
              CommonSpaceVDouble(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectsWidget extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
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
