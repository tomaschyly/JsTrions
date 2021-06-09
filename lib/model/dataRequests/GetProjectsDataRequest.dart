import 'package:js_trions/model/Project.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class GetProjectsDataRequest extends DataRequest<Project> {
  /// GetProjectsDataRequest initialization
  GetProjectsDataRequest()
      : super(
          source: MainDataProviderSource.Sembast,
          method: Project.STORE,
          processResult: (json) => Project.fromJson(json),
        );
}
