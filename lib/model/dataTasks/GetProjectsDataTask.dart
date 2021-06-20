import 'package:js_trions/model/ProjectQuery.dart';
import 'package:js_trions/model/Projects.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class GetProjectsDataTask extends DataTask<ProjectQuery, Projects> {
  /// GetProjectsDataTask initialization
  GetProjectsDataTask({
    required ProjectQuery data,
  }) : super(
          method: Projects.STORE,
          options: SembastTaskOptions(
            type: SembastType.Query,
          ),
          data: data,
          processResult: (json) => Projects.fromJson(json),
        );
}
