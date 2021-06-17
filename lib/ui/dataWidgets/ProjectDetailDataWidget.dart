import 'dart:io';

import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataRequests/GetProjectDataRequest.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectDetailDataWidget extends AbstractDataWidget {
  final int projectId;

  /// ProjectDetailDataWidget initialization
  ProjectDetailDataWidget({
    required this.projectId,
  }) : super(
          dataRequests: [
            GetProjectDataRequest(projectId: projectId),
          ],
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ProjectDetailDataWidgetState();
}

class _ProjectDetailDataWidgetState extends AbstractDataWidgetState<ProjectDetailDataWidget> {
  int? _projectId;
  bool _projectDirNotFound = false;

  /// Widget parameters changed
  @override
  void didUpdateWidget(covariant ProjectDetailDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.projectId != widget.projectId) {
      _resetForProjects();
    }
  }

  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: dataSource!.results,
      builder: (BuildContext context, List<DataRequest> dataRequests, Widget? child) {
        final projectDataRequest = dataRequests.first as GetProjectDataRequest;

        final theProject = projectDataRequest.result;

        if (theProject == null) {
          return Container();
        }

        _initProject(theProject);

        Widget content;

        if (_projectDirNotFound) {
          content = Text(
            tt('project_detail.directory_not_found').replaceAll(r'$directory', theProject.directory),
            style: fancyText(kTextDanger),
          );
        } else {
          content = Container();
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              theProject.name,
              style: fancyText(kTextHeadline),
            ),
            CommonSpaceV(),
            content,
          ],
        );
      },
    );
  }

  /// New projectId provided, reset and load new Project
  void _resetForProjects() {
    updateDataRequests([
      GetProjectDataRequest(projectId: widget.projectId),
    ]);
  }

  /// Check if Projects exists, init translations from Project based on parameters
  Future<void> _initProject(Project project) async {
    if (project.id != _projectId) {
      _projectId = project.id;

      final directory = Directory(project.directory);

      final exists = await directory.exists();

      setStateNotDisposed(() {
        _projectDirNotFound = !exists;
      });

      //TODO need dir for translations inside project
    }
  }
}
