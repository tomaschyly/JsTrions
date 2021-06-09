import 'package:js_trions/App.dart';
import 'package:js_trions/core/AppPreferences.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/ui/dataWidgets/ManageProgrammingLanguagesDataWidget.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:js_trions/ui/widgets/CategoryHeaderWidget.dart';
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
  late String _language;

  /// State initialization
  @override
  void initState() {
    super.initState();

    _language = Translator.instance!.currentLanguage;
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
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
      child: SingleChildScrollView(
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryHeaderWidget(
          text: tt('settings.screen.category.general'),
          doubleMargin: true,
        ),
        ButtonWidget(
          style: kButtonDangerStyle,
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
    );
  }

  /// TODO
  void _clearData(BuildContext context) {
    //TODO clear data when available
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
        ManageProgrammingLanguagesDataWidget(),
        CommonSpaceVDouble(),
      ],
    );
  }
}
