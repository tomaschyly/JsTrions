import 'package:tch_appliable_core/tch_appliable_core.dart';

class ProgrammingLanguage extends DataModel {
  static const String STORE = 'programming_language';
  static const String COL_ID = 'id';
  static const String COL_NAME = 'name';
  static const String COL_EXTENSION = 'ext';

  int? id;
  late String name;
  late String extension;

  /// ProgrammingLanguage initialization from JSON map
  ProgrammingLanguage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json[COL_ID];
    name = json[COL_NAME];
    extension = json[COL_EXTENSION];
  }

  /// Covert the object into JSON map
  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      COL_NAME: name,
      COL_EXTENSION: extension,
    };

    if (id != null) {
      json[COL_ID] = id;
    }

    return json;
  }
}
