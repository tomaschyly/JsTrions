import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/SembastResult.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class SaveProgrammingLanguageDataTask extends DataTask<ProgrammingLanguage, SembastResult> {
  /// SaveProgrammingLanguageDataTask initialization
  SaveProgrammingLanguageDataTask({
    required ProgrammingLanguage data,
  }) : super(
          method: ProgrammingLanguage.STORE,
          options: SembastTaskOptions(
            type: SembastType.Save,
          ),
          data: data,
          processResult: (json) => SembastResult.fromJson(json),
          reFetchMethods: [ProgrammingLanguage.STORE],
        );
}
