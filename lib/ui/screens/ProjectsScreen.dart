import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataRequests/GetProjectsDataRequest.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:path/path.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectsScreen extends AbstractResposiveScreen {
  static const String ROUTE = "/projects";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends AppResponsiveScreenState<ProjectsScreen> {
  @override
  AbstractScreenStateOptions options = AppScreenStateOptions.main(
    screenName: ProjectsScreen.ROUTE,
    title: tt('projects.screen.title'),
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
  Project? _selectedProject;

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Container(
      width: double.infinity,
      child: _ProjectsListWidget(
        selectProject: _selectProject,
        selectedProject: _selectedProject,
      ),
    );
  }

  /// Select Project, on desktop screens show details, on smaller screens navs to details screen
  void _selectProject(Project project) {
    //TODO
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
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonSpaceV(),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: kDrawerWidth,
                  padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                  child: _ProjectsListWidget(
                    selectProject: _selectProject,
                    selectedProject: _selectedProject,
                  ),
                ),
                Container(
                  width: 1,
                  height: double.infinity,
                  color: kColorSecondaryDark,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                    child: Text('WIP: project details'),
                  ),
                ),
              ],
            ),
          ),
          CommonSpaceV(),
        ],
      ),
    );
  }
}

class _ProjectsListWidget extends StatelessWidget {
  final void Function(Project project) selectProject;
  final Project? selectedProject;

  /// ProjectsListWidget initialization
  _ProjectsListWidget({
    required this.selectProject,
    this.selectedProject,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return ListDataWidget<GetProjectsDataRequest, Project>(
      dataRequest: GetProjectsDataRequest(),
      processResult: (GetProjectsDataRequest dataRequest) {
        return dataRequest.result?.projects;
      },
      buildItem: (BuildContext context, int position, Project item) {
        return ButtonWidget(
          style: kListItemButtonStyle,
          text: item.name,
          onTap: item.id == selectedProject?.id
              ? null
              : () {
                  selectProject(item);
                },
        );
      },
      buildLoadingItemWithGlobalKey: (BuildContext context, GlobalKey globalKey) {
        return LoadingItemWidget(
          containerKey: globalKey,
          text: Text(
            tt('list.item.loading'),
            style: fancyText(kText),
          ),
        );
      },
      emptyState: Container(
        width: kPhoneStopBreakpoint,
        padding: const EdgeInsets.all(kCommonPrimaryMargin),
        alignment: Alignment.topCenter,
        child: Text(
          tt('list.empty'),
          style: fancyText(kText),
        ),
      ),
    );
  }
}
