import 'package:tch_appliable_core/tch_appliable_core.dart';

class DataTaskParameters extends DataModel {
  final Map<String, dynamic> _data;

  /// DataTaskParameters initialization from JSON map
  DataTaskParameters.fromJson(Map<String, dynamic> json)
      : _data = json,
        super.fromJson(json);

  /// Convert the object into JSON map
  @override
  Map<String, dynamic> toJson() => _data;
}
