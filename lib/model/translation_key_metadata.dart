import 'package:tch_appliable_core/tch_appliable_core.dart';

class TranslationKeyMetadata {
  String key;
  String description;

  /// TranslationKeyMetadata initialization
  TranslationKeyMetadata({
    required this.key,
    this.description = '',
  });

  /// TranslationKeyMetadata initialization from JSON map
  /// Init may fail and return null instead
  static TranslationKeyMetadata? fromJson(String key, dynamic value) {
    try {
      final theValue = value as Map<String, dynamic>;

      final description = theValue['description'] as String? ?? '';

      return TranslationKeyMetadata(
        key: key,
        description: description,
      );
    } catch (e, t) {
      debugPrint('TCH_e $e\n$t');
      return null;
    }
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      if (description.isNotEmpty) 'description': description,
    };
  }

  /// Convert to String
  @override
  String toString() {
    return 'TranslationKeyMetadata${toJson()}';
  }
}
