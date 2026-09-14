import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:js_trions/app.dart';
import 'package:js_trions/core/app_preferences.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

const double kDrawerWidthOverride = 200;
const double kLeftPanelWidth = 260;

const kColorPrimary = Color(0xFF1a1a1a);
const kColorPrimaryLight = Color(0xFF404040);
const kColorPrimaryDark = Color(0xFF000000);
const kColorSecondary = kColorGold;
const kColorSecondaryLight = kColorGoldLight;
const kColorSecondaryDark = kColorGoldDarker;

const kColorTextPrimary = kColorSilver;
const kColorTextSecondary = Colors.black;

const kColorSuccess = Color(0xFF43a047);
const kColorDanger = kColorRed;
const kColorWarning = Color(0xFFfb8c00);
const kColorWarningDark = Color(0xFFc25e00);

const kColorGold = Color(0xFFffd700);
const kColorGoldLight = Color(0xFFffff52);
const kColorGoldDarker = Color(0xFFc7a600);
const kColorRed = Color(0xFFe60000);
const kColorShadow = Color(0x60000000);
const kColorSilver = Color(0xFFdddddd);
const kColorSilverDarker = Color(0xFFcccccc);
const kColorSilverLighter = Color(0xFFf2f2f2);

/// Hover colors (lighter variants for dark theme)
const kColorPrimaryLightHover = Color(0xFF606060); // lighter than kColorPrimaryLight (0xFF404040)
const kColorRedHover = Color(0xFFb30000); // darker than kColorRed (0xFFe60000)

const kFontFamily = 'Kalam';

const kText = TextStyle(color: kColorTextPrimary, fontSize: 16);
const kTextBold = TextStyle(color: kColorTextPrimary, fontSize: 16, fontWeight: FontWeight.bold);
const kTextHeadline = TextStyle(color: kColorTextPrimary, fontSize: 20);
const kTextSuccess = TextStyle(color: kColorSuccess, fontSize: 16);
const kTextDanger = TextStyle(color: kColorDanger, fontSize: 16);
const kTextWarning = TextStyle(color: kColorWarning, fontSize: 16);

/// If fancy font enabled, add it to TextStyle
TextStyle fancyText(TextStyle textStyle, {bool force = false}) =>
    force || prefsInt(kPrefsFancyFont) == 1 ? textStyle.copyWith(fontFamily: kFontFamily) : textStyle;

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

  BorderRadius platformBorderRadius = const BorderRadius.all(Radius.circular(8));
  MainAxisAlignment dialogsMainAxisAlignment = MainAxisAlignment.start;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    platformBorderRadius = BorderRadius.circular(0);
  }

  if ([ResponsiveScreen.extraLargeDesktop, ResponsiveScreen.largeDesktop, ResponsiveScreen.smallDesktop].contains(snapshot.responsiveScreen)) {
    dialogsMainAxisAlignment = MainAxisAlignment.center;
  }

  final kButtonHoverStyle = CommonButtonHoverStyle(
    backgroundColor: kColorPrimaryLightHover,
    borderColor: kColorTextPrimary,
    //TODO
  );

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
    hoverStyle: kButtonHoverStyle,
  );

  final kButtonFilledStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.filled,
    // Hover background is dark, switch text to light for readability
    // Border blends into background, so hovered filled button stays a solid block unlike outlined one
    hoverStyle: kButtonHoverStyle.copyWith(
      borderColor: kColorPrimaryLightHover,
      filledTextStyle: kButtonStyle.filledTextStyle.copyWith(color: kColorTextPrimary),
    ),
  );

  final kButtonTextOnlyStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.textOnly,
    // Border blends into background, so hovered text-only button is highlighted without outline
    hoverStyle: kButtonHoverStyle.copyWith(borderColor: kColorPrimaryLightHover),
  );

  final kButtonDangerStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.filled,
    filledTextStyle: kButtonStyle.filledTextStyle.copyWith(color: kColorTextPrimary),
    color: kColorRed,
    // Darker red on hover, text is already light so it stays readable
    hoverStyle: CommonButtonHoverStyle(backgroundColor: kColorRedHover, borderColor: kColorRedHover),
  );

  final kListItemButtonStyle = kButtonTextOnlyStyle.copyWith(fullWidthMobileOnly: false, alignment: Alignment.centerLeft, textOverflow: TextOverflow.ellipsis);

  final kIconButtonHoverStyle = IconButtonHoverStyle(backgroundColor: kColorPrimaryLightHover, borderColor: kColorTextPrimary);

  final kIconButtonStyle = IconButtonStyle(
    width: kButtonHeight,
    height: kButtonHeight,
    iconWidth: kIconSizeNotTouch,
    iconHeight: kIconSizeNotTouch,
    loadingIconWidth: kIconSizeNotTouch,
    loadingIconHeight: kIconSizeNotTouch,
    color: kColorTextPrimary,
    borderRadius: platformBorderRadius,
    hoverStyle: kIconButtonHoverStyle,
  );

  final kIconButtonFilledStyle = kIconButtonStyle.copyWith(
    variant: IconButtonVariant.filled,
    iconColor: kColorPrimaryLight,
    // Hover background is dark, switch icon to light for readability and blend border like filled button
    hoverStyle: kIconButtonHoverStyle.copyWith(borderColor: kColorPrimaryLightHover, iconColor: kColorTextPrimary),
  );

  final kIconButtonRowActionStyle = kIconButtonStyle.copyWith(
    variant: IconButtonVariant.iconOnly,
    // Row actions are visible on hovered row which already uses kColorPrimaryLightHover, so hover background is darker to stand out
    hoverStyle: kIconButtonHoverStyle.copyWith(backgroundColor: kColorPrimaryLight),
  );

  final kAppBarIconButtonStyle = IconButtonStyle(
    variant: IconButtonVariant.iconOnly,
    width: kButtonHeight,
    height: kButtonHeight,
    iconWidth: kIconSizeNotTouch,
    iconHeight: kIconSizeNotTouch,
    color: kColorTextPrimary,
    borderRadius: platformBorderRadius,
    // Icon only variant has no border, so only hover background is visible on app bar
    hoverStyle: kIconButtonHoverStyle,
  );

  final kDialogContainerStyle = DialogContainerStyle(
    mainAxisAlignment: dialogsMainAxisAlignment,
    backgroundColor: kColorPrimaryLight,
    borderRadius: platformBorderRadius,
  );

  final kConfirmDialogStyle = ConfirmDialogStyle(
    dialogContainerStyle: kDialogContainerStyle,
    dialogHeaderStyle: const DialogHeaderStyle(textStyle: kTextHeadline),
    textStyle: kText,
    dialogFooterStyle: DialogFooterStyle(
      buttonStyle: kButtonStyle.copyWith(widthWrapContent: true, filledTextStyle: kButtonStyle.filledTextStyle.copyWith(color: kColorTextPrimary)),
      // All app confirm dialogs are danger, so Yes uses danger style including its hover
      yesButtonStyle: kButtonDangerStyle.copyWith(widthWrapContent: true),
      dangerColor: kColorDanger,
    ),
  );

  final OutlineInputBorder platformInputBorder = OutlineInputBorder(borderSide: const BorderSide(width: 1), borderRadius: platformBorderRadius);

  final kTextFormFieldStyle = TextFormFieldStyle(
    inputDecoration: TextFormFieldStyle().inputDecoration.copyWith(
      labelStyle: kTextBold,
      contentPadding: EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf, vertical: prefsInt(kPrefsFancyFont) == 1 ? 8 : 8),
      enabledBorder: platformInputBorder,
      disabledBorder: platformInputBorder,
      focusedBorder: platformInputBorder,
      errorBorder: platformInputBorder,
      focusedErrorBorder: platformInputBorder,
    ),
    inputStyle: kText,
    borderColor: kColorTextPrimary,
    focusedBorderColor: kColorTextPrimary,
    // Filled on hover like selection field and outlined buttons, border already uses kColorTextPrimary
    hoverStyle: const TextFormFieldHoverStyle(fillColor: kColorPrimaryLightHover),
    textAlign: TextAlign.center,
  );

  final kListDialogStyle = ListDialogStyle(
    dialogContainerStyle: kDialogContainerStyle,
    optionStyle: kButtonTextOnlyStyle,
    selectedOptionStyle: kButtonFilledStyle,
    dialogHeaderStyle: const DialogHeaderStyle(textStyle: kTextHeadline),
    dialogFooterStyle: DialogFooterStyle(
      buttonStyle: kButtonStyle.copyWith(
        widthWrapContent: true,
        iconColor: kColorWarning,
        loadingIconWidth: kIconSizeNotTouch,
        loadingIconHeight: kIconSizeNotTouch,
      ),
      // Filled Yes needs light text on dark hover background
      yesButtonStyle: kButtonFilledStyle.copyWith(widthWrapContent: true, iconColor: kColorWarning),
    ),
    filterStyle: kTextFormFieldStyle,
  );

  final kEmailFormFieldStyle = kTextFormFieldStyle.copyWith(
    keyboardType: TextInputType.emailAddress,
    validations: [FormFieldValidation(validator: validateEmail, errorText: tt('validation.required'))],
  );

  final kSelectionFormFieldStyle = SelectionFormFieldStyle(
    // Base fill is transparent variant of hover fill, so hover animation only fades opacity
    inputStyle: kTextFormFieldStyle.copyWith(
      inputDecoration: kTextFormFieldStyle.inputDecoration.copyWith(fillColor: kColorPrimaryLightHover.withValues(alpha: 0)),
    ),
    // Filled on hover like outlined buttons, border already uses kColorTextPrimary
    hoverStyle: SelectionFormFieldHoverStyle(
      inputStyle: kTextFormFieldStyle.copyWith(inputDecoration: kTextFormFieldStyle.inputDecoration.copyWith(fillColor: kColorPrimaryLightHover)),
    ),
  );

  final kSwitchToggleWidgetStyle = SwitchToggleWidgetStyle(
    iconButtonStyle: kIconButtonStyle.copyWith(width: 104, iconRestricted: false),
    useText: true,
    textStyle: kButtonStyle.textStyle,
    onText: tt('toggle.on'),
    offText: tt('toggle.off'),
  );

  final kPreferencesSwitchStyle = PreferencesSwitchStyle(
    layout: PreferencesSwitchLayout.vertical,
    labelStyle: kTextBold,
    descriptionStyle: kText,
    useSwitchToggleWidget: true,
  );

  return AppTheme(
    fontFamily: prefsInt(kPrefsFancyFont) == 1 ? kFontFamily : null,
    buttonsStyle: ButtonsStyle(buttonStyle: kButtonStyle, iconButtonStyle: kIconButtonStyle),
    buttonFilledStyle: kButtonFilledStyle,
    buttonTextOnlyStyle: kButtonTextOnlyStyle,
    buttonDangerStyle: kButtonDangerStyle,
    listItemButtonStyle: kListItemButtonStyle,
    iconButtonFilledStyle: kIconButtonFilledStyle,
    iconButtonRowActionStyle: kIconButtonRowActionStyle,
    appBarIconButtonStyle: kAppBarIconButtonStyle,
    dialogsStyle: DialogsStyle(confirmDialogStyle: kConfirmDialogStyle, listDialogStyle: kListDialogStyle),
    formStyle: FormStyle(
      textFormFieldStyle: kTextFormFieldStyle,
      selectionFormFieldStyle: kSelectionFormFieldStyle,
      switchToggleWidgetStyle: kSwitchToggleWidgetStyle,
      preferencesSwitchStyle: kPreferencesSwitchStyle,
    ),
    emailFormFieldStyle: kEmailFormFieldStyle,
    tooltipStyle: TooltipStyle(
      decoration: BoxDecoration(color: Colors.black, borderRadius: platformBorderRadius),
    ),
    child: child,
  );
}

class AppTheme extends CommonTheme {
  final CommonButtonStyle buttonFilledStyle;
  final CommonButtonStyle buttonTextOnlyStyle;
  final CommonButtonStyle buttonDangerStyle;
  final CommonButtonStyle listItemButtonStyle;
  final IconButtonStyle iconButtonFilledStyle;
  final IconButtonStyle iconButtonRowActionStyle;
  final IconButtonStyle appBarIconButtonStyle;
  final TextFormFieldStyle emailFormFieldStyle;

  /// AppTheme initialization
  AppTheme({
    super.key,
    required Widget child,
    super.fontFamily,
    required super.buttonsStyle,
    required this.buttonFilledStyle,
    required this.buttonTextOnlyStyle,
    required this.buttonDangerStyle,
    required this.listItemButtonStyle,
    required this.iconButtonFilledStyle,
    required this.iconButtonRowActionStyle,
    required this.appBarIconButtonStyle,
    required super.dialogsStyle,
    required super.formStyle,
    required this.emailFormFieldStyle,
    required super.tooltipStyle,
  }) : super(
         child: CommonTheme(
           fontFamily: fontFamily,
           buttonsStyle: buttonsStyle,
           dialogsStyle: dialogsStyle,
           formStyle: formStyle,
           tooltipStyle: tooltipStyle,
           child: child,
         ),
       );
}
