import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class ProgrammingLanguageQuery extends DataModel {
  String? name;

  /// ProgrammingLanguageQuery initialization from JSON map
  ProgrammingLanguageQuery.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    name = json[ProgrammingLanguage.COL_NAME];
  }

  /// Convert to JSON map
  @override
  Map<String, dynamic> toJson() {
    final json = Map<String, dynamic>();

    if (name != null) {
      json['${ProgrammingLanguage.COL_NAME} LIKE'] = name;
    }

    return json;
  }
}
