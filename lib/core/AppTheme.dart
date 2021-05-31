import 'package:js_trions/core/AppPreferences.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

const kColorGold = const Color(0xFFffd700);
const kColorGoldDarker = const Color(0xFFe6c300);
const kColorRed = const Color(0xFFe60000);
const kColorShadow = const Color(0x60000000);
const kColorSilver = const Color(0xFFdddddd);
const kColorSilverDarker = const Color(0xFFcccccc);
const kColorSilverLighter = const Color(0xFFf2f2f2);

const kFontFamily = 'Kalam';

const kText = const TextStyle(color: Colors.black, fontSize: 16);
const kTextHeadline = const TextStyle(color: Colors.black, fontSize: 20);

/// If fancy font enabled, add it to TextStyle
TextStyle fancyText(TextStyle textStyle, {bool force = false}) =>
    force || prefsInt(PREFS_FANCY_FONT) == 1 ? textStyle.copyWith(fontFamily: kFontFamily) : textStyle;

/// Customize CommonTheme for the app
Widget appThemeBuilder(BuildContext context, Widget child) {
  return CommonTheme(
    child: child,
    fontFamily: prefsInt(PREFS_FANCY_FONT) == 1 ? kFontFamily : null,
  );
}
