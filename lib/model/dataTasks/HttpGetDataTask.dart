import 'package:js_trions/model/ApiResponse.dart';
import 'package:js_trions/model/DataTaskParameters.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class HttpGetDataTask extends DataTask<DataTaskParameters, ApiResponse> {
  /// HttpGetDataTask initialization
  HttpGetDataTask({
    required String url,
    required Map<String, dynamic> parameters,
  }) : super(
    method: '',
    options: HTTPTaskOptions(
      type: HTTPType.Get,
      url: url,
    ),
    data: DataTaskParameters.fromJson(parameters),
    processResult: (json) => ApiResponse.fromJson(json),
  );
}
