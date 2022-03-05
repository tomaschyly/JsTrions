import 'package:js_trions/config.dart';
import 'package:js_trions/model/GoogleTranslateParameters.dart';
import 'package:js_trions/model/GoogleTranslateResponse.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class GoogleTranslateDataTask extends DataTask<GoogleTranslateParameters, GoogleTranslateResponse> {
  /// HttpPostDataTask initialization
  GoogleTranslateDataTask({
    required GoogleTranslateParameters data,
  }) : super(
    method: '',
    options: HTTPTaskOptions(
      type: HTTPType.Post,
      url: kGoogleTranslateUrl,
    ),
    data: data,
    processResult: (json) => GoogleTranslateResponse.fromJson(json),
  );
}
