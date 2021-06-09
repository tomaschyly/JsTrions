import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/SembastResult.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class DeleteProgrammingLanguageDataTask extends DataTask<ProgrammingLanguage, SembastResult> {
  /// DeleteProgrammingLanguageDataTask initialization
  DeleteProgrammingLanguageDataTask({
    required ProgrammingLanguage data,
  }) : super(
          method: ProgrammingLanguage.STORE,
          options: SembastTaskOptions(
            type: SembastType.Delete,
          ),
          data: data,
          processResult: (json) => SembastResult.fromJson(json),
          reFetchMethods: [ProgrammingLanguage.STORE],
        );
}
