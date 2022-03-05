import 'package:tch_appliable_core/tch_appliable_core.dart';

class GoogleTranslateParameters extends DataModel {
  final List<String> queries;
  final String targetLanguage;

  /// GoogleTranslateParameters initialization with parameters
  GoogleTranslateParameters(this.queries, this.targetLanguage)
      : super.fromJson({
          'q': queries,
          'target': targetLanguage,
        });

  /// Convert the object into JSON map
  @override
  Map<String, dynamic> toJson() => json;
}
