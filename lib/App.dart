import 'package:js_trions/core/Router.dart' as AppRouter;
import 'package:js_trions/ui/DashboardScreen.dart';
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
                child: Text('WIP'), //TODO UI
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
    );
  }
}

class AppDataStateSnapshot extends AbstractAppDataStateSnapshot {
  /// AppDataState initialization
  AppDataStateSnapshot();
}
