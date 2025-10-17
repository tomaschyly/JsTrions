/// Special metadata key used in translations metadata files.
const String kMetadataJsTrions = r'$JsTrions';

/// Metadata key used to store translation keys that should be ignored for a project.
const String kMetadataIgnoredTranslationKeys = r'$IgnoredTranslationKeys';

/// List of metadata keys (prefixes) that should be treated as metadata entries in metadata.json
/// Add future metadata keys here so code can ignore them when loading/saving metadata.
const List<String> kMetadataKeys = [kMetadataJsTrions, kMetadataIgnoredTranslationKeys];
