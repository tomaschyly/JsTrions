import 'package:js_trions/ui/screens/AboutScreen.dart';
import 'package:js_trions/ui/screens/dashboard_screen.dart';
import 'package:js_trions/ui/screens/ProjectDetailScreen.dart';
import 'package:js_trions/ui/screens/ProjectsScreen.dart';
import 'package:js_trions/ui/screens/settings_screen.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

/// Generate Route with Screen for RoutingArguments from Route name
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final arguments = settings.name?.routingArguments;

  if (arguments != null) {
    switch (arguments.route) {
      case DashboardScreen.ROUTE:
        return createRoute((BuildContext context) => DashboardScreen(), settings);
      case ProjectsScreen.ROUTE:
        return createRoute((BuildContext context) => ProjectsScreen(), settings);
      case ProjectDetailScreen.ROUTE:
        return createRoute((BuildContext context) => ProjectDetailScreen(), settings);
      case SettingsScreen.ROUTE:
        return createRoute((BuildContext context) => SettingsScreen(), settings);
      case AboutScreen.ROUTE:
        return createRoute((BuildContext context) => AboutScreen(), settings);
      default:
        throw Exception('Implement OnGenerateRoute in app');
    }
  }

  throw Exception('Arguments not available');
}
