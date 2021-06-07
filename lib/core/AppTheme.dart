import 'package:js_trions/core/AppPreferences.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

const kColorPrimary = const Color(0xFF1a1a1a);
const kColorPrimaryLight = const Color(0xFF404040);
const kColorPrimaryDark = const Color(0xFF000000);
const kColorSecondary = kColorGold;
const kColorSecondaryLight = kColorGoldLight;
const kColorSecondaryDark = kColorGoldDarker;

const kColorTextPrimary = kColorSilver;
const kColorTextSecondary = Colors.black;

const kColorGold = const Color(0xFFffd700);
const kColorGoldLight = const Color(0xFFffff52);
const kColorGoldDarker = const Color(0xFFc7a600);
const kColorRed = const Color(0xFFe60000);
const kColorShadow = const Color(0x60000000);
const kColorSilver = const Color(0xFFdddddd);
const kColorSilverDarker = const Color(0xFFcccccc);
const kColorSilverLighter = const Color(0xFFf2f2f2);

const kFontFamily = 'Kalam';

const kText = const TextStyle(color: kColorTextPrimary, fontSize: 16);
const kTextHeadline = const TextStyle(color: kColorTextPrimary, fontSize: 20);

/// If fancy font enabled, add it to TextStyle
TextStyle fancyText(TextStyle textStyle, {bool force = false}) =>
    force || prefsInt(PREFS_FANCY_FONT) == 1 ? textStyle.copyWith(fontFamily: kFontFamily) : textStyle;

const kButtonStyle = CommonButtonStyle(
  //TODO
);

final kButtonDangerStyle = kButtonStyle.copyWith(
  variant: ButtonVariant.Filled,
  color: kColorRed,
);

const kIconButtonStyle = IconButtonStyle(
  width: kMinInteractiveSizeNotTouch + kCommonHorizontalMarginHalf,
  height: kMinInteractiveSizeNotTouch + kCommonVerticalMarginHalf,
  iconWidth: kIconSizeNotTouch,
  iconHeight: kIconSizeNotTouch,
  color: kColorTextPrimary,
);

const kAppBarIconButtonStyle = const IconButtonStyle(
  variant: IconButtonVariant.IconOnly,
  color: kColorTextPrimary,
);

/// Customize CommonTheme for the app
Widget appThemeBuilder(BuildContext context, Widget child) {
  return CommonTheme(
    child: child,
    fontFamily: prefsInt(PREFS_FANCY_FONT) == 1 ? kFontFamily : null,
    buttonsStyle: ButtonsStyle(
      buttonStyle: kButtonStyle,
      iconButtonStyle: kIconButtonStyle,
    ),
  );
}
