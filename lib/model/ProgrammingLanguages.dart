import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class ProgrammingLanguages extends DataModel {
  static const String STORE = 'programming_language';

  late List<ProgrammingLanguage> programmingLanguages;

  /// ProgrammingLanguages initialization from JSON map
  ProgrammingLanguages.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(json['list']);

    programmingLanguages = list.map((Map<String, dynamic> item) => ProgrammingLanguage.fromJson(item)).toList();
  }

  /// Convert the object into JSON map
  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'list': programmingLanguages.map((ProgrammingLanguage record) => record.toJson()).toList(),
    };

    return json;
  }
}
