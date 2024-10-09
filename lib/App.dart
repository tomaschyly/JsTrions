import 'dart:io';

import 'package:js_trions/config.dart';
import 'package:js_trions/core/app_preferences.dart' as AppPreferences;
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/core/AppRouter.dart' as AppRouter;
import 'package:js_trions/images/TomasChyly.dart';
import 'package:js_trions/service/ProgrammingLanguageService.dart';
import 'package:js_trions/ui/screens/DashboardScreen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sqflite/sqflite.dart' as SQLite;
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';
import 'package:window_manager/window_manager.dart';

class App extends AbstractStatefulWidget {
  /// Create state for widget
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends AbstractStatefulWidgetState<App> {
  static AppState get instance => _instance;

  static late AppState _instance;

  /// State initialization
  @override
  void initState() {
    _instance = this;

    super.initState();
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return CoreApp(
      title: 'JsTrions',
      initializationUi: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: kColorPrimaryLight,
            body: Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(kCommonPrimaryMargin),
                  child: Container(
                    width: 295,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        tomasChylyImage,
                        Container(height: kCommonVerticalMargin),
                        Text(
                          'JsTrions\nby Tomáš Chylý',
                          style: fancyText(kTextHeadline, force: true),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      initializationMinDurationInMilliseconds: 1200,
      initialScreenRoute: DashboardScreen.ROUTE,
      initialScreenRouteArguments: <String, String>{'router-no-animation': '1'},
      onAppInitStart: (BuildContext context) async {
        if (Platform.isWindows || Platform.isLinux) {
          await windowManager.ensureInitialized();

          if (!(await windowManager.isMaximized()) && !(await windowManager.isFullScreen())) {
            windowManager.center();
          }

          windowManager.show();
        }
      },
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: appThemeBuilder,
      theme: ThemeData(
        primaryColor: kColorPrimary,
        primaryColorLight: kColorPrimaryLight,
        primaryColorDark: kColorPrimaryDark,
        appBarTheme: AppBarTheme(
          color: kColorPrimary,
        ),
        splashColor: kColorSecondary,
        shadowColor: kColorShadow,
        colorScheme: ThemeData().colorScheme.copyWith(
          surface: kColorPrimaryLight,
          secondary: kColorSecondary,
        ),
      ),
      snapshot: AppDataStateSnapshot(),
      translatorOptions: TranslatorOptions(
        languages: ['en', 'sk'],
        supportedLocales: [const Locale('en'), const Locale('sk')],
        getInitialLanguage: (BuildContext context) async => prefsString(AppPreferences.PREFS_LANGUAGE),
      ),
      preferencesOptions: PreferencesOptions(
        intPrefs: AppPreferences.intPrefs,
      ),
      mainDataProviderOptions: MainDataProviderOptions(
        httpClientOptions: HTTPClientOptions(
          hostUrl: kHostUrl,
        ),
        sembastOptions: SembastOptions(
          databasePath: () async {
            if (Platform.isAndroid || Platform.isIOS) {
              return join((await SQLite.getDatabasesPath()), 'default.db');
            } else {
              final directory = await getApplicationSupportDirectory();

              await directory.create(recursive: true);

              return join(directory.path, 'default.db');
            }
          },
          version: 1,
          onVersionChanged: _dbMigrate,
        ),
      ),
    );
  }

  /// Migrate db when version changes
  Future<void> _dbMigrate(Database db, int oldVersion, int newVersion) async {
    await updateDBForProgrammingLanguage(db, oldVersion, newVersion);
  }
}

class AppDataStateSnapshot extends AbstractAppDataStateSnapshot {
  /// AppDataState initialization
  AppDataStateSnapshot();
}
