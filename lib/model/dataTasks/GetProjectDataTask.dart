import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/ProjectQuery.dart';
import 'package:js_trions/model/Projects.dart';
import 'package:collection/collection.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class GetProjectDataTask extends DataTask<ProjectQuery, Project> {
  /// GetProjectDataTask initialization
  GetProjectDataTask({
    required ProjectQuery data,
  }) : super(
          method: Project.STORE,
          options: SembastTaskOptions(
            type: SembastType.query,
          ),
          data: data,
          processResult: (json) {
            final projects = Projects.fromJson(json);

            return projects.projects.firstWhereOrNull((project) => project.id == data.id);
          },
        );
}
