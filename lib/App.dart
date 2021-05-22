import 'dart:io';

import 'package:js_trions/core/Router.dart' as AppRouter;
import 'package:js_trions/images/TomasChyly.dart';
import 'package:js_trions/ui/DashboardScreen.dart';
import 'package:js_trions/utils/AppTheme.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

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
            backgroundColor: Theme.of(context).backgroundColor,
            body: Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.PrimaryMargin),
                  child: Container(
                    width: 295,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        tomasChylyImage,
                        Container(height: AppDimens.PrimaryVerticalMargin),
                        Text(
                          'JsTrions\nby Tomáš Chylý',
                          // style: AppStyles.TextHeadline.copyWith(fontFamily: 'CaveHand'), //TODO theme
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
      onGenerateRoute: AppRouter.onGenerateRoute,
      theme: ThemeData(
          //TODO
          ),
      snapshot: AppDataStateSnapshot(),
      translatorOptions: TranslatorOptions(
        languages: ['en', 'sk'],
        supportedLocales: [const Locale('en'), const Locale('sk')],
      ),
      mainDataProviderOptions: MainDataProviderOptions(
        sembastOptions: SembastOptions(databasePath: () async {
          if (Platform.isAndroid || Platform.isIOS) {
            return join((await getDatabasesPath()), 'default.db');
          } else {
            var directory = await getApplicationSupportDirectory();

            await directory.create(recursive: true);

            return join(directory.path, 'default.db');
          }
        }),
      ),
    );
  }
}

class AppDataStateSnapshot extends AbstractAppDataStateSnapshot {
  /// AppDataState initialization
  AppDataStateSnapshot();
}
