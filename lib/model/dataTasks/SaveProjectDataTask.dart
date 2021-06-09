import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/SembastResult.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class SaveProjectDataTask extends DataTask<Project, SembastResult> {
  /// SaveProjectDataTask initialization
  SaveProjectDataTask({
    required Project data,
  }) : super(
          method: Project.STORE,
          options: SembastTaskOptions(
            type: SembastType.Save,
          ),
          data: data,
          processResult: (json) => SembastResult.fromJson(json),
          reFetchMethods: [Project.STORE],
        );
}
