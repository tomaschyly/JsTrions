import 'package:tch_appliable_core/tch_appliable_core.dart';

class Project extends DataModel {
  static const String STORE = 'project';
  static const String COL_ID = 'id';
  static const String COL_NAME = 'name';
  static const String COL_DIRECTORY = 'directory';
  static const String COL_TRANSLATION_ASSETS = 'translation_assets';
  static const String COL_LANGUAGES = 'languages';
  static const String COL_PROGRAMMING_LANGUAGES = 'programming_languages';
  static const String COL_TRANSLATION_KEYS = 'translation_keys';
  static const String COL_LAST_SEEN = 'last_seen';
  static const String COL_UPDATED = 'updated';
  static const String COL_CREATED = 'created';
  static const String COL_TRANSLATIONS_JSON_FORMAT = 'translations_json_format';
  static const String COL_FORMAT_OBJECT_INSIDE = 'format_object_inside';

  int? id;
  late String name;
  late String directory;
  late String translationAssets;
  late List<String> languages;
  late List<int> programmingLanguages;
  late List<TranslationKey> translationKeys;
  late int lastSeen;
  late int updated;
  late int created;
  TranslationsJsonFormat? translationsJsonFormat;
  String? formatObjectInside;

  /// Project initialization from JSON map
  Project.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json[COL_ID];
    name = json[COL_NAME];
    directory = json[COL_DIRECTORY];
    translationAssets = json[COL_TRANSLATION_ASSETS] ?? '';
    languages = List<String>.from(json[COL_LANGUAGES]);
    programmingLanguages = List<int>.from(json[COL_PROGRAMMING_LANGUAGES]);
    translationKeys = List<TranslationKey>.from(json[COL_TRANSLATION_KEYS].map((key) => TranslationKey.fromJson(key)).toList());
    lastSeen = json[COL_LAST_SEEN] ?? 0;
    updated = json[COL_UPDATED];
    created = json[COL_CREATED];

    final int? theFormat = json[COL_TRANSLATIONS_JSON_FORMAT];
    if (theFormat != null) {
      translationsJsonFormat = TranslationsJsonFormat.values[theFormat];
    }
    formatObjectInside = json[COL_FORMAT_OBJECT_INSIDE];
  }

  /// Covert the object into JSON map
  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      COL_NAME: name,
      COL_DIRECTORY: directory,
      COL_TRANSLATION_ASSETS: translationAssets,
      COL_LANGUAGES: languages,
      COL_PROGRAMMING_LANGUAGES: programmingLanguages,
      COL_TRANSLATION_KEYS: translationKeys.map((key) => key.toJson()).toList(),
      COL_LAST_SEEN: lastSeen,
      COL_UPDATED: updated,
      COL_CREATED: created,
      COL_TRANSLATIONS_JSON_FORMAT: translationsJsonFormat?.index,
      COL_FORMAT_OBJECT_INSIDE: formatObjectInside,
    };

    if (id != null) {
      json[COL_ID] = id;
    }

    return json;
  }
}

class TranslationKey extends DataModel {
  late int programmingLanguage;
  late String key;

  /// TranslationKey initialization from JSON map
  TranslationKey.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    programmingLanguage = json['programmingLanguage'];
    key = json['key'];
  }

  /// Covert the object into JSON map
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'programmingLanguage': programmingLanguage,
      'key': key,
    };
  }
}

enum TranslationsJsonFormat {
  None,
  Simple,
  ObjectInside,
}
