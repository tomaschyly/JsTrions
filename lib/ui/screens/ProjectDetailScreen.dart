import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/providers/ProjectProvider.dart';
import 'package:js_trions/ui/dataWidgets/ProjectDetailDataWidget.dart';
import 'package:js_trions/ui/dialogs/EditProjectDialog.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:supercharged/supercharged.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectDetailScreen extends AbstractResponsiveScreen {
  static const String ROUTE = "/projects/project";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends AppResponsiveScreenState<ProjectDetailScreen> {
  @override
  AbstractScreenOptions options = AppScreenStateOptions.basic(
    screenName: ProjectDetailScreen.ROUTE,
    title: tt('project_detail.screen.title'),
  );

  Project? _project;

  @override
  Widget extraLargeDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget largeDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget largePhoneScreen(BuildContext context) => _BodyWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget smallDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget smallPhoneScreen(BuildContext context) => _BodyWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget tabletScreen(BuildContext context) => _BodyWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  /// On Project is initialized in DataWidget
  void _onDataWidgetProjectInit(Project? project) {
    _project = project;

    setStateNotDisposed(() {
      options.appBarOptions = <AppBarOption>[
        if (project != null) ...[
          AppBarOption(
            onTap: (BuildContext context) {
              EditProjectDialog.show(context, project: _project);
            },
            icon: SvgPicture.asset('images/edit.svg', color: kColorTextPrimary),
          ),
          AppBarOption(
            onTap: (BuildContext context) => deleteProject(context, project: project),
            icon: SvgPicture.asset('images/trash.svg', color: kColorDanger),
          ),
        ]
      ];
    });
  }
}

abstract class _AbstractBodyWidget extends AbstractStatefulWidget {
  final ValueChanged<Project?> onDataWidgetProjectInit;

  /// AbstractBodyWidget initialization
  _AbstractBodyWidget({
    required this.onDataWidgetProjectInit,
  });
}

abstract class _AbstractBodyWidgetState<T extends _AbstractBodyWidget> extends AbstractStatefulWidgetState<T> {
  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final RoutingArguments arguments = RoutingArguments.of(context)!;

    final int projectId = arguments[Project.COL_ID]!.toInt()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonSpaceV(),
          Expanded(
            child: ProjectDetailDataWidget(
              projectId: projectId,
              onProjectChanged: widget.onDataWidgetProjectInit,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyWidget extends _AbstractBodyWidget {
  /// BodyWidget initialization
  _BodyWidget({
    required ValueChanged<Project?> onDataWidgetProjectInit,
  }) : super(
          onDataWidgetProjectInit: onDataWidgetProjectInit,
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends _AbstractBodyWidgetState<_BodyWidget> {}

class _BodyDesktopWidget extends _AbstractBodyWidget {
  /// BodyDesktopWidget initialization
  _BodyDesktopWidget({
    required ValueChanged<Project?> onDataWidgetProjectInit,
  }) : super(
          onDataWidgetProjectInit: onDataWidgetProjectInit,
        );

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
