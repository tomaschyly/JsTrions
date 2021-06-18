import 'package:js_trions/model/Project.dart';
import 'package:js_trions/ui/dataWidgets/ProjectDetailDataWidget.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:supercharged/supercharged.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectDetailScreen extends AbstractResposiveScreen {
  static const String ROUTE = "/projects/project";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends AppResponsiveScreenState<ProjectDetailScreen> {
  @override
  AbstractScreenStateOptions options = AppScreenStateOptions.basic(
    screenName: ProjectDetailScreen.ROUTE,
    title: tt('project_detail.screen.title'),
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
  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final RoutingArguments arguments = RoutingArguments.of(context)!;

    final int projectId = arguments[Project.COL_ID]!.toInt()!;

    return Scrollbar(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSpaceV(),
              ProjectDetailDataWidget(
                projectId: projectId,
              )
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
  /// Run initializations of screen on first build only
  @override
  firstBuildOnly(BuildContext context) {
    super.firstBuildOnly(context);

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      popNotDisposed(context, mounted);
    });
  }
}
