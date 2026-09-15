import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class GetProgrammingLanguagesDataRequest extends DataRequest<ProgrammingLanguages> {
  /// GetProgrammingLanguagesDataRequest initialization
  GetProgrammingLanguagesDataRequest()
      : super(
          source: MainDataProviderSource.sembast,
          method: ProgrammingLanguages.STORE,
          processResult: (json) => ProgrammingLanguages.fromJson(json),
        );
}
