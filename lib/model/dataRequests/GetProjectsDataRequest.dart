import 'package:js_trions/model/Projects.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class GetProjectsDataRequest extends DataRequest<Projects> {
  /// GetProjectsDataRequest initialization
  GetProjectsDataRequest()
      : super(
          source: MainDataProviderSource.Sembast,
          method: Projects.STORE,
          processResult: (json) => Projects.fromJson(json),
        );
}
