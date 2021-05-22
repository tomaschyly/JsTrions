import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class ProjectsScreen extends AbstractResposiveScreen {
  static const String ROUTE = "/projects";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends AppResponsiveScreenState<ProjectsScreen> {
  @override
  AppScreenStateOptions get options => AppScreenStateOptions.basic(
        screenName: ProjectsScreen.ROUTE,
        title: tt('projects.screen.title'),
      );

  @override
  Widget extraLargeDesktopScreen(BuildContext context) => _BodyWidget();

  @override
  Widget largeDesktopScreen(BuildContext context) => _BodyWidget();

  @override
  Widget largePhoneScreen(BuildContext context) => _BodyWidget();

  @override
  Widget smallDesktopScreen(BuildContext context) => _BodyWidget();

  @override
  Widget smallPhoneScreen(BuildContext context) => _BodyWidget();

  @override
  Widget tabletScreen(BuildContext context) => _BodyWidget();
}

abstract class _AbstractBodyWidget extends AbstractStatefulWidget {}

abstract class _AbstractBodyWidgetState<T extends _AbstractBodyWidget> extends AbstractStatefulWidgetState<T> {
  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Wip: projects'),
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
