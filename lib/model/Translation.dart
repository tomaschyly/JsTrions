import 'package:tch_appliable_core/tch_appliable_core.dart';

class Translation extends DataModel {
  late String language;
  late dynamic value;

  /// Translation initialization from JSON map
  Translation.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    language = json['language'];
    value = json['value'];
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'language': language,
      'value': value,
    };
  }
}
