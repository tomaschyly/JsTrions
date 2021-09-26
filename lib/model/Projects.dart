import 'package:js_trions/model/Project.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class Projects extends DataModel {
  static const String STORE = 'project';

  late List<Project> projects;

  /// Projects initialization from JSON map
  Projects.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(json['list']);

    projects = list.map((Map<String, dynamic> item) => Project.fromJson(item)).toList();
  }

  /// Convert the object into JSON map
  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'list': projects.map((Project record) => record.toJson()).toList(),
    };

    return json;
  }
}
