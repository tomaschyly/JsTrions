import 'package:tch_appliable_core/tch_appliable_core.dart';

class ApiResponse extends DataModel {
  String? error;
  String? success;

  /// ApiResponse initialization from JSON map
  ApiResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    error = json['error'];
    success = json['success'];
  }

  /// Convert the object into JSON map
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'error': error,
      'success': success,
    };
  }
}
