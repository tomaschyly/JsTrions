import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/ProjectQuery.dart';
import 'package:js_trions/model/SembastResult.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class DeleteProjectsDataTask extends DataTask<ProjectQuery, SembastResult> {
  /// DeleteProjectsDataTask initialization
  DeleteProjectsDataTask({
    required ProjectQuery data,
  }) : super(
          method: Project.STORE,
          options: SembastTaskOptions(
            type: SembastType.DeleteWhere,
          ),
          data: data,
          processResult: (json) => SembastResult.fromJson(json),
          reFetchMethods: [Project.STORE],
        );
}
