import 'package:js_trions/model/Project.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class ProjectQuery extends DataModel {
  int? id;
  String? name;

  /// ProjectQuery initialization from JSON map
  ProjectQuery.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json[Project.COL_ID];
    name = json[Project.COL_NAME];
  }

  /// Convert to JSON map
  @override
  Map<String, dynamic> toJson() {
    final json = Map<String, dynamic>();

    if (name != null) {
      json['${Project.COL_NAME} LIKE'] = name;
    }

    return json;
  }
}
