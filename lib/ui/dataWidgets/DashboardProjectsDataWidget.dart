import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/Projects.dart';
import 'package:js_trions/model/dataRequests/GetProjectsDataRequest.dart';
import 'package:js_trions/model/providers/ProjectProvider.dart';
import 'package:js_trions/ui/dialogs/EditProjectDialog.dart';
import 'package:js_trions/ui/screens/ProjectsScreen.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_appliable_core/utils/Text.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class DashboardProjectsDataWidget extends AbstractDataWidget {
  /// DashboardProjectsDataWidget initialization
  DashboardProjectsDataWidget()
      : super(
          dataRequests: [
            GetProjectsDataRequest(),
          ],
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _DashboardProjectsDataWidgetState();
}

class _DashboardProjectsDataWidgetState extends AbstractDataWidgetState<DashboardProjectsDataWidget> {
  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ValueListenableBuilder(
      valueListenable: dataSource!.results,
      builder: (BuildContext context, List<DataRequest> dataRequests, Widget? child) {
        final dataRequest = dataRequests.first as GetProjectsDataRequest;

        final Projects? projects = dataRequest.result;

        if (projects == null || projects.projects.isEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: Text(
                  tt('dashboard.screen.projects.empty'),
                  style: fancyText(kText),
                ),
              ),
              CommonSpaceV(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: ButtonWidget(
                  style: commonTheme.buttonsStyle.buttonStyle.copyWith(
                    variant: ButtonVariant.Filled,
                    widthWrapContent: true,
                  ),
                  text: tt('dashboard.screen.projects.add'),
                  onTap: () {
                    EditProjectDialog.show(context);
                  },
                ),
              ),
            ],
          );
        }

        final recentProjects = projects.projects.where((project) => project.lastSeen > 0).toList();

        sortProjectsByLastSeen(recentProjects);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
              child: Text(
                tt('dashboard.screen.recent_projects'),
                style: fancyText(kTextHeadline),
              ),
            ),
            CommonSpaceV(),
            if (recentProjects.isNotEmpty)
              ...recentProjects.take(5).map((project) {
                return ButtonWidget(
                  style: commonTheme.listItemButtonStyle,
                  text: '${project.name} - ${millisToDefault(project.lastSeen)}',
                  onTap: () {
                    pushNamedNewStack(context, ProjectsScreen.ROUTE, arguments: <String, String>{
                      'router-no-animation': '1',
                      Project.COL_ID: project.id!.toString(),
                    });
                  },
                );
              }).toList()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: Text(
                  tt('dashboard.screen.recent_projects.empty'),
                  style: fancyText(kText),
                ),
              ),
          ],
        );
      },
    );
  }
}
