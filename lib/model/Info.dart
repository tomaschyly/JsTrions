import 'dart:convert';

import 'package:js_trions/model/Translation.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class Info extends DataModel {
  bool isWelcome = false;
  String? uid;
  late InfoType type;
  late String headline;
  List<Translation>? headlineTranslations;
  String? fullImage;
  String? image;
  String? text;
  List<Translation>? textTranslations;
  String? app;
  String? version;
  int? from;
  int? to;
  bool enabled = false;
  String? url;
  Map<String, dynamic>? payload;
  late int updated;
  late int created;

  /// Info for welcome initialization
  Info.welcome() : super.fromJson({}) {
    isWelcome = true;
    type = InfoType.None;
    headline = tt('info.welcome.headline');
    text = tt('info.welcome.text');

    final now = DateTime.now();

    updated = now.millisecondsSinceEpoch;
    created = now.millisecondsSinceEpoch;
  }

  /// Info initialization from JSON map
  Info.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    uid = json['uid'];
    type = InfoType.values[json['type']];

    headline = json['headline'];
    if (json['headlineTranslations'] != null) {
      final List<Map<String, dynamic>> translations = List<Map<String, dynamic>>.from(json['headlineTranslations']);

      headlineTranslations = translations.map((translation) => Translation.fromJson(translation)).toList();
    }

    fullImage = json['fullImage'];
    image = json['image'];

    text = json['text'];
    if (json['textTranslations'] != null) {
      final List<Map<String, dynamic>> translations = List<Map<String, dynamic>>.from(json['textTranslations']);

      textTranslations = translations.map((translation) => Translation.fromJson(translation)).toList();
    }

    app = json['app'];
    version = json['version'];
    from = json['from'];
    to = json['to'];
    enabled = json['enabled'] ?? false;
    url = json['url'];

    if (json['payload'] != null && json['payload'].isNotEmpty) {
      payload = jsonDecode(json['payload']);
    }

    updated = json['updated'];
    created = json['created'];
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    throw Exception('Info toJson not implemented');
  }

  /// Get Headline by language
  String translatedHeadline(String language) {
    String headline = this.headline;

    final theHeadlineTranslations = headlineTranslations;
    if (theHeadlineTranslations != null) {
      for (Translation translation in theHeadlineTranslations) {
        if (translation.language == language) {
          headline = translation.value as String;

          break;
        }
      }
    }

    return headline;
  }

  /// Get Text by language
  String? translatedText(String language) {
    String? text = this.text;

    final theTextTranslations = textTranslations;
    if (theTextTranslations != null) {
      for (Translation translation in theTextTranslations) {
        if (translation.language == language) {
          text = translation.value as String;

          break;
        }
      }
    }

    return text;
  }
}

enum InfoType {
  None,
  TextOnly,
  ImageText,
  FullImageOnly,
}
