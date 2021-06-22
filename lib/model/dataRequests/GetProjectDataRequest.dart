import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/Projects.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_appliable_core/utils/List.dart';

class GetProjectDataRequest extends DataRequest<Project> {
  /// GetProjectDataRequest initialization
  GetProjectDataRequest({
    required int projectId,
  }) : super(
          source: MainDataProviderSource.Sembast,
          method: Project.STORE,
          processResult: (json) {
            final projects = Projects.fromJson(json);

            return projects.projects.firstWhereOrNull((project) => project.id == projectId);
          },
        );
}
