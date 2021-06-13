import 'dart:io';

import 'package:flutter/foundation.dart';
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
const kTextBold = const TextStyle(color: kColorTextPrimary, fontSize: 16, fontWeight: FontWeight.bold);
const kTextHeadline = const TextStyle(color: kColorTextPrimary, fontSize: 20);

/// If fancy font enabled, add it to TextStyle
TextStyle fancyText(TextStyle textStyle, {bool force = false}) =>
    force || prefsInt(PREFS_FANCY_FONT) == 1 ? textStyle.copyWith(fontFamily: kFontFamily) : textStyle;

const kButtonHeight = kMinInteractiveSizeNotTouch + kCommonVerticalMarginHalf;

final kPreferencesSwitchStyle = PreferencesSwitchStyle(
  labelStyle: kTextBold,
  descriptionStyle: kText,
);

/// Customize CommonTheme for the app
Widget appThemeBuilder(BuildContext context, Widget child) {
  BorderRadius platformBorderRadius = const BorderRadius.all(const Radius.circular(8));

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    platformBorderRadius = BorderRadius.circular(0);
  }

  final kButtonStyle = CommonButtonStyle(
    height: kButtonHeight,
    textStyle: const TextStyle(color: kColorTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
    filledTextStyle: const TextStyle(color: kColorPrimaryLight, fontSize: 16, fontWeight: FontWeight.bold),
    disabledTextStyle: const TextStyle(color: kColorPrimaryLight, fontSize: 16, fontWeight: FontWeight.bold),
    color: kColorTextPrimary,
    borderRadius: platformBorderRadius,
  );

  final kButtonDangerStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.Filled,
    filledTextStyle: kButtonStyle.filledTextStyle.copyWith(
      color: kColorTextPrimary,
    ),
    color: kColorRed,
  );

  final kListItemButtonStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.TextOnly,
  );

  final kIconButtonStyle = IconButtonStyle(
    width: kButtonHeight,
    height: kButtonHeight,
    iconWidth: kIconSizeNotTouch,
    iconHeight: kIconSizeNotTouch,
    color: kColorTextPrimary,
    borderRadius: platformBorderRadius,
  );

  final kAppBarIconButtonStyle = IconButtonStyle(
    variant: IconButtonVariant.IconOnly,
    width: kButtonHeight,
    height: kButtonHeight,
    iconWidth: kIconSizeNotTouch,
    iconHeight: kIconSizeNotTouch,
    color: kColorTextPrimary,
    borderRadius: platformBorderRadius,
  );

  final kConfirmDialogStyle = ConfirmDialogStyle(
    backgroundColor: kColorPrimaryLight,
    dialogHeaderStyle: const DialogHeaderStyle(
      textStyle: kTextHeadline,
    ),
    textStyle: kText,
    dialogFooterStyle: DialogFooterStyle(
      buttonStyle: kButtonStyle.copyWith(
        widthWrapContent: true,
        filledTextStyle: kButtonStyle.filledTextStyle.copyWith(
          color: kColorTextPrimary,
        ),
      ),
      dangerColor: kColorRed,
    ),
    borderRadius: platformBorderRadius,
  );

  final kListDialogStyle = ListDialogStyle(
    backgroundColor: kColorPrimaryLight,
    optionStyle: kButtonStyle.copyWith(
      variant: ButtonVariant.TextOnly,
    ),
    selectedOptionStyle: kButtonStyle.copyWith(
      variant: ButtonVariant.Filled,
    ),
    dialogHeaderStyle: const DialogHeaderStyle(
      textStyle: kTextHeadline,
    ),
    dialogFooterStyle: DialogFooterStyle(
      buttonStyle: kButtonStyle.copyWith(
        widthWrapContent: true,
      ),
    ),
    borderRadius: platformBorderRadius,
  );

  final OutlineInputBorder platformInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      width: 1,
    ),
    borderRadius: platformBorderRadius,
  );

  final kTextFormFieldStyle = TextFormFieldStyle(
    inputDecoration: TextFormFieldStyle().inputDecoration.copyWith(
          labelStyle: kTextBold,
          contentPadding: EdgeInsets.symmetric(
            horizontal: kCommonHorizontalMarginHalf,
            vertical: prefsInt(PREFS_FANCY_FONT) == 1 ? 7 : 10,
          ),
          enabledBorder: platformInputBorder,
          disabledBorder: platformInputBorder,
          focusedBorder: platformInputBorder,
          errorBorder: platformInputBorder,
          focusedErrorBorder: platformInputBorder,
        ),
    inputStyle: kText,
    borderColor: kColorTextPrimary,
    focusedBorderColor: kColorTextPrimary,
    textAlign: TextAlign.center,
  );

  final kSelectionFormFieldStyle = SelectionFormFieldStyle(
    inputStyle: kTextFormFieldStyle,
  );

  return AppTheme(
    child: child,
    fontFamily: prefsInt(PREFS_FANCY_FONT) == 1 ? kFontFamily : null,
    buttonsStyle: ButtonsStyle(
      buttonStyle: kButtonStyle,
      iconButtonStyle: kIconButtonStyle,
    ),
    buttonDangerStyle: kButtonDangerStyle,
    listItemButtonStyle: kListItemButtonStyle,
    appBarIconButtonStyle: kAppBarIconButtonStyle,
    dialogsStyle: DialogsStyle(
      confirmDialogStyle: kConfirmDialogStyle,
      listDialogStyle: kListDialogStyle,
    ),
    formStyle: FormStyle(
      textFormFieldStyle: kTextFormFieldStyle,
      selectionFormFieldStyle: kSelectionFormFieldStyle,
      preferencesSwitchStyle: kPreferencesSwitchStyle,
    ),
  );
}

class AppTheme extends CommonTheme {
  final CommonButtonStyle buttonDangerStyle;
  final CommonButtonStyle listItemButtonStyle;
  final IconButtonStyle appBarIconButtonStyle;

  /// AppTheme initialization
  AppTheme({
    required Widget child,
    String? fontFamily,
    required ButtonsStyle buttonsStyle,
    required this.buttonDangerStyle,
    required this.listItemButtonStyle,
    required this.appBarIconButtonStyle,
    required DialogsStyle dialogsStyle,
    required FormStyle formStyle,
  }) : super(
          child: CommonTheme(
            child: child,
            fontFamily: fontFamily,
            buttonsStyle: buttonsStyle,
            dialogsStyle: dialogsStyle,
            formStyle: formStyle,
          ),
          fontFamily: fontFamily,
          buttonsStyle: buttonsStyle,
          dialogsStyle: dialogsStyle,
          formStyle: formStyle,
        );
}
