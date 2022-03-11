import 'package:tch_appliable_core/tch_appliable_core.dart';

class GoogleTranslateParameters extends DataModel {
  final List<String> queries;
  final String sourceLanguage;
  final String targetLanguage;

  /// GoogleTranslateParameters initialization with parameters
  GoogleTranslateParameters({
    required this.queries,
    required this.sourceLanguage,
    required this.targetLanguage,
  }) : super.fromJson({
          'q': queries,
          'source': sourceLanguage,
          'target': targetLanguage,
        });

  /// Convert the object into JSON map
  @override
  Map<String, dynamic> toJson() => json;
}
