import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:js_trions/App.dart';
import 'package:js_trions/core/app_preferences.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

const double kLeftPanelWidth = kDrawerWidth;

const kColorPrimary = const Color(0xFF1a1a1a);
const kColorPrimaryLight = const Color(0xFF404040);
const kColorPrimaryDark = const Color(0xFF000000);
const kColorSecondary = kColorGold;
const kColorSecondaryLight = kColorGoldLight;
const kColorSecondaryDark = kColorGoldDarker;

const kColorTextPrimary = kColorSilver;
const kColorTextSecondary = Colors.black;

const kColorSuccess = const Color(0xFF43a047);
const kColorDanger = kColorRed;
const kColorWarning = const Color(0xFFfb8c00);
const kColorWarningDark = const Color(0xFFc25e00);

const kColorGold = const Color(0xFFffd700);
const kColorGoldLight = const Color(0xFFffff52);
const kColorGoldDarker = const Color(0xFFc7a600);
const kColorRed = const Color(0xFFe60000);
const kColorShadow = const Color(0x60000000);
const kColorSilver = const Color(0xFFdddddd);
const kColorSilverDarker = const Color(0xFFcccccc);
const kColorSilverLighter = const Color(0xFFf2f2f2);

/// Hover colors (lighter variants for dark theme)
const kColorPrimaryLightHover = const Color(0xFF606060); // lighter than kColorPrimaryLight (0xFF404040)

const kFontFamily = 'Kalam';

const kText = const TextStyle(color: kColorTextPrimary, fontSize: 16);
const kTextBold = const TextStyle(color: kColorTextPrimary, fontSize: 16, fontWeight: FontWeight.bold);
const kTextHeadline = const TextStyle(color: kColorTextPrimary, fontSize: 20);
const kTextSuccess = const TextStyle(color: kColorSuccess, fontSize: 16);
const kTextDanger = const TextStyle(color: kColorDanger, fontSize: 16);
const kTextWarning = const TextStyle(color: kColorWarning, fontSize: 16);

/// If fancy font enabled, add it to TextStyle
TextStyle fancyText(TextStyle textStyle, {bool force = false}) =>
    force || prefsInt(PREFS_FANCY_FONT) == 1 ? textStyle.copyWith(fontFamily: kFontFamily) : textStyle;

const kButtonHeight = kMinInteractiveSizeNotTouch + kCommonVerticalMarginHalf;

/// Shorthand to get AppTheme from context
AppTheme getAppTheme(BuildContext context) => CommonTheme.of<AppTheme>(context)!;

extension AppThemeExtension on BuildContext {
  /// Shorthand to get AppTheme from context
  AppTheme get appTheme => getAppTheme(this);
}

/// Customize CommonTheme for the app
Widget appThemeBuilder(BuildContext context, Widget child) {
  final AppDataStateSnapshot snapshot = AppDataState.of(context)!;

  BorderRadius platformBorderRadius = const BorderRadius.all(const Radius.circular(8));
  MainAxisAlignment dialogsMainAxisAlignment = MainAxisAlignment.start;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    platformBorderRadius = BorderRadius.circular(0);
  }

  if ([
    ResponsiveScreen.ExtraLargeDesktop,
    ResponsiveScreen.LargeDesktop,
    ResponsiveScreen.SmallDesktop,
  ].contains(snapshot.responsiveScreen)) {
    dialogsMainAxisAlignment = MainAxisAlignment.center;
  }

  final kButtonStyle = CommonButtonStyle(
    height: kButtonHeight,
    textStyle: const TextStyle(color: kColorTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
    filledTextStyle: const TextStyle(color: kColorPrimaryLight, fontSize: 16, fontWeight: FontWeight.bold),
    disabledTextStyle: const TextStyle(color: kColorPrimaryLight, fontSize: 16, fontWeight: FontWeight.bold),
    color: kColorTextPrimary,
    borderRadius: platformBorderRadius,
    preffixIconWidth: kIconSizeNotTouch,
    preffixIconHeight: kIconSizeNotTouch,
    loadingIconWidth: kIconSizeNotTouch,
    loadingIconHeight: kIconSizeNotTouch,
  );

  final kButtonDangerStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.Filled,
    filledTextStyle: kButtonStyle.filledTextStyle.copyWith(
      color: kColorTextPrimary,
    ),
    color: kColorRed,
  );

  final kListItemButtonStyle = kButtonStyle.copyWith(
    fullWidthMobileOnly: false,
    variant: ButtonVariant.TextOnly,
    alignment: Alignment.centerLeft,
  );

  final kIconButtonStyle = IconButtonStyle(
    width: kButtonHeight,
    height: kButtonHeight,
    iconWidth: kIconSizeNotTouch,
    iconHeight: kIconSizeNotTouch,
    loadingIconWidth: kIconSizeNotTouch,
    loadingIconHeight: kIconSizeNotTouch,
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

  final kDialogContainerStyle = DialogContainerStyle(
    mainAxisAlignment: dialogsMainAxisAlignment,
    backgroundColor: kColorPrimaryLight,
    borderRadius: platformBorderRadius,
  );

  final kConfirmDialogStyle = ConfirmDialogStyle(
    dialogContainerStyle: kDialogContainerStyle,
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
      dangerColor: kColorDanger,
    ),
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
            vertical: prefsInt(PREFS_FANCY_FONT) == 1 ? 8 : 8,
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

  final kListDialogStyle = ListDialogStyle(
    dialogContainerStyle: kDialogContainerStyle,
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
        iconColor: kColorWarning,
        loadingIconWidth: kIconSizeNotTouch,
        loadingIconHeight: kIconSizeNotTouch,
      ),
    ),
    filterStyle: kTextFormFieldStyle,
  );

  final kEmailFormFieldStyle = kTextFormFieldStyle.copyWith(
    keyboardType: TextInputType.emailAddress,
    validations: [
      FormFieldValidation(
        validator: validateEmail,
        errorText: tt('validation.required'),
      ),
    ],
  );

  final kSelectionFormFieldStyle = SelectionFormFieldStyle(
    inputStyle: kTextFormFieldStyle,
  );

  final kSwitchToggleWidgetStyle = SwitchToggleWidgetStyle(
    iconButtonStyle: kIconButtonStyle.copyWith(
      width: 104,
      iconRestricted: false,
    ),
    useText: true,
    textStyle: kButtonStyle.textStyle,
    onText: tt('toggle.on'),
    offText: tt('toggle.off'),
  );

  final kPreferencesSwitchStyle = PreferencesSwitchStyle(
    layout: PreferencesSwitchLayout.Vertical,
    labelStyle: kTextBold,
    descriptionStyle: kText,
    useSwitchToggleWidget: true,
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
      switchToggleWidgetStyle: kSwitchToggleWidgetStyle,
      preferencesSwitchStyle: kPreferencesSwitchStyle,
    ),
    emailFormFieldStyle: kEmailFormFieldStyle,
    tooltipStyle: TooltipStyle(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: platformBorderRadius,
      ),
    ),
  );
}

class AppTheme extends CommonTheme {
  final CommonButtonStyle buttonDangerStyle;
  final CommonButtonStyle listItemButtonStyle;
  final IconButtonStyle appBarIconButtonStyle;
  final TextFormFieldStyle emailFormFieldStyle;

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
    required this.emailFormFieldStyle,
    required TooltipStyle tooltipStyle,
  }) : super(
          child: CommonTheme(
            child: child,
            fontFamily: fontFamily,
            buttonsStyle: buttonsStyle,
            dialogsStyle: dialogsStyle,
            formStyle: formStyle,
            tooltipStyle: tooltipStyle,
          ),
          fontFamily: fontFamily,
          buttonsStyle: buttonsStyle,
          dialogsStyle: dialogsStyle,
          formStyle: formStyle,
          tooltipStyle: tooltipStyle,
        );
}
