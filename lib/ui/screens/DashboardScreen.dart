import 'package:js_trions/service/InfoService.dart';
import 'package:js_trions/ui/dataWidgets/DashboardProjectsDataWidget.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class DashboardScreen extends AbstractResponsiveScreen {
  static const String ROUTE = "/dashboard";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends AppResponsiveScreenState<DashboardScreen> {
  @override
  AbstractScreenOptions options = AppScreenStateOptions.main(
    screenName: DashboardScreen.ROUTE,
    title: tt('dashboard.screen.title'),
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

  /// Run initializations of screen on first build only
  @protected
  firstBuildOnly(BuildContext context) {
    super.firstBuildOnly(context);

    determineInfo(context);
  }
}

abstract class _AbstractBodyWidget extends AbstractStatefulWidget {}

abstract class _AbstractBodyWidgetState<T extends _AbstractBodyWidget> extends AbstractStatefulWidgetState<T> {
  final ScrollController _scrollController = ScrollController();

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
          padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSpaceV(),
              DashboardProjectsDataWidget(),
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
                        child: DashboardProjectsDataWidget(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
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
