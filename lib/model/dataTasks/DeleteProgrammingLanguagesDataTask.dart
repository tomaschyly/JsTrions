import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguageQuery.dart';
import 'package:js_trions/model/SembastResult.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class DeleteProgrammingLanguagesDataTask extends DataTask<ProgrammingLanguageQuery, SembastResult> {
  /// DeleteProgrammingLanguagesDataTask initialization
  DeleteProgrammingLanguagesDataTask({
    required ProgrammingLanguageQuery data,
  }) : super(
          method: ProgrammingLanguage.STORE,
          options: SembastTaskOptions(
            type: SembastType.DeleteWhere,
          ),
          data: data,
          processResult: (json) => SembastResult.fromJson(json),
          reFetchMethods: [ProgrammingLanguage.STORE],
        );
}
