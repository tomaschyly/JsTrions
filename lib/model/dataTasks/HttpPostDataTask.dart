import 'package:js_trions/model/ApiResponse.dart';
import 'package:js_trions/model/DataTaskParameters.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class HttpPostDataTask extends DataTask<DataTaskParameters, ApiResponse> {
  /// HttpPostDataTask initialization
  HttpPostDataTask({
    required String url,
    required Map<String, dynamic> parameters,
  }) : super(
          method: '',
          options: HTTPTaskOptions(
            type: HTTPType.Post,
            url: url,
          ),
          data: DataTaskParameters.fromJson(parameters),
          processResult: (json) => ApiResponse.fromJson(json),
        );
}
