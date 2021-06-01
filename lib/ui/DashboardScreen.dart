import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class DashboardScreen extends AbstractResposiveScreen {
  static const String ROUTE = "/dashboard";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends AppResponsiveScreenState<DashboardScreen> {
  @override
  AbstractScreenStateOptions options = AppScreenStateOptions.main(
    screenName: DashboardScreen.ROUTE,
    title: tt('dashboard.screen.title'),
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
        child: Text('Wip: dashboard'),
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
