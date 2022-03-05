import 'package:tch_appliable_core/tch_appliable_core.dart';

class GoogleTranslateResponse extends DataModel {
  List<GoogleTranslateTranslation> translations = [];

  /// GoogleTranslateResponse initialization from JSON map
  GoogleTranslateResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    try {
      Map data = json['data'];
      List<Map> translations = List<Map>.from(data['translations']);

      translations.forEach((translation) {
        this.translations.add(
              GoogleTranslateTranslation(
                translatedText: translation['translatedText'],
                detectedSourceLanguage: translation['detectedSourceLanguage'],
              ),
            );
      });
    } catch (e) {
      debugPrint('TCH_e $e');
    }
  }

  /// Convert the object into JSON map
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'translations': translations,
    };
  }
}

class GoogleTranslateTranslation extends DataModel {
  final String translatedText;
  final String detectedSourceLanguage;

  /// GoogleTranslateTranslation initialization
  GoogleTranslateTranslation({
    required this.translatedText,
    required this.detectedSourceLanguage,
  }) : super.fromJson({
          'translatedText': translatedText,
          'detectedSourceLanguage': detectedSourceLanguage,
        });

  /// Convert the object into JSON map
  @override
  Map<String, dynamic> toJson() => json;
}
