import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:js_trions/app.dart';
import 'package:js_trions/core/app_preferences.dart';
import 'package:js_trions/service/desktop_service.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_appliable_core/utils/widget.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

const double kDrawerWidthOverride = 200;
const double kLeftPanelWidth = 260;

/// Raw palette, every color literal of the app lives here once
/// The semantic layer below maps these onto the scheme, so a color is never written out twice
/// Topinambur is the branding accent, named after the plant's yellow flowers, shared with TChApps and tomas-chyly
/// It is a surface color only, it never carries text, it measures 9.6:1 on the dark background but 1.8:1 on white
const kPaletteTopinambur = Color(0xFFF2B705);
const kPaletteTopinamburLight = Color(0xFFFBCD41);
const kPaletteTopinamburDark = Color(0xFFB48804);
const kPaletteRed = Color(0xFFe60000);
const kPaletteRedDark = Color(0xFFb30000);
const kPaletteGreen = Color(0xFF43a047);
const kPaletteOrange = Color(0xFFfb8c00);
const kPaletteOrangeDark = Color(0xFFc25e00);
const kPaletteBlack = Color(0xFF000000);
const kPaletteGraphiteDark = Color(0xFF1a1a1a);
const kPaletteSteel = Color(0xFF404040);
const kPaletteSteelLight = Color(0xFF606060);
const kPaletteSilver = Color(0xFFdddddd);
const kPaletteSmoke = Color(0xFFf5f5f5);
const kPaletteWhite = Color(0xFFffffff);
const kPaletteShade = Color(0x60000000);

/// Semantic colors that do not follow the scheme
/// Status fills and the accent read the same on both backgrounds, only the text over them is picked by contrast
const kColorAccent = kPaletteTopinambur;
const kColorAccentLight = kPaletteTopinamburLight;
const kColorAccentDark = kPaletteTopinamburDark;
const kColorSuccess = kPaletteGreen;
const kColorDanger = kPaletteRed;
const kColorDangerHover = kPaletteRedDark;
const kColorWarning = kPaletteOrange;
const kColorWarningDark = kPaletteOrangeDark;
const kColorShadow = kPaletteShade;

/// Tooltips and the barrier behind dialogs stay dark in both schemes, they are overlays rather than surfaces
const kColorOverlay = kPaletteBlack;

/// Text over a filled status or accent color, picked by contrast rather than by scheme
const kColorTextOnDark = kPaletteSilver;
const kColorTextOnLight = kPaletteBlack;

/// Accent tints for hover fills, shared with tomas-chyly
final kColorAccentTint = kColorAccent.withValues(alpha: 0.12);
final kColorAccentTintStrong = kColorAccent.withValues(alpha: 0.22);

/// Is the dark scheme resolved for this context, by preference or by the OS
bool isDarkMode(BuildContext context) => AppDataState.of(context)!.isDarkMode;

/// Page, app bar and drawer background
Color kColorBackground(BuildContext context) => isDarkMode(context) ? kPaletteGraphiteDark : kPaletteSmoke;

/// Raised surfaces, dialogs, the selected drawer option and even table rows
Color kColorSurface(BuildContext context) => isDarkMode(context) ? kPaletteSteel : kPaletteWhite;

/// Hover fill, one step away from the surface in the direction of the scheme
Color kColorSurfaceHover(BuildContext context) => isDarkMode(context) ? kPaletteSteelLight : kPaletteSilver;

/// Text, icons and the borders that enclose them
Color kColorTextPrimary(BuildContext context) => isDarkMode(context) ? kPaletteSilver : kPaletteGraphiteDark;

/// Text over a filled button or icon button, which is filled with kColorTextPrimary
Color kColorTextOnFill(BuildContext context) => isDarkMode(context) ? kPaletteSteel : kPaletteWhite;

/// Accent carried on a thin mark such as a link underline
/// Light needs the darker shade, plain kColorAccent measures only 1.7:1 on the light background
Color kColorAccentLine(BuildContext context) => isDarkMode(context) ? kColorAccent : kColorAccentDark;

/// Hovered variant of kColorAccentLine
Color kColorAccentLineHover(BuildContext context) => isDarkMode(context) ? kColorAccentLight : kColorAccent;

const kFontFamily = 'Kalam';

/// Light scheme text styles
const kText = TextStyle(color: kPaletteGraphiteDark, fontSize: 16);
const kTextBold = TextStyle(color: kPaletteGraphiteDark, fontSize: 16, fontWeight: FontWeight.bold);
const kTextHeadline = TextStyle(color: kPaletteGraphiteDark, fontSize: 20);

/// Dark scheme twins of the text styles
const kDMText = TextStyle(color: kPaletteSilver, fontSize: 16);
const kDMTextBold = TextStyle(color: kPaletteSilver, fontSize: 16, fontWeight: FontWeight.bold);
const kDMTextHeadline = TextStyle(color: kPaletteSilver, fontSize: 20);

/// Status text styles, their color is the same in both schemes
const kTextSuccess = TextStyle(color: kColorSuccess, fontSize: 16);
const kTextDanger = TextStyle(color: kColorDanger, fontSize: 16);
const kTextWarning = TextStyle(color: kColorWarning, fontSize: 16);

/// Text style of the current scheme
TextStyle kTextOf(BuildContext context) => isDarkMode(context) ? kDMText : kText;

/// Bold text style of the current scheme
TextStyle kTextBoldOf(BuildContext context) => isDarkMode(context) ? kDMTextBold : kTextBold;

/// Headline text style of the current scheme
TextStyle kTextHeadlineOf(BuildContext context) => isDarkMode(context) ? kDMTextHeadline : kTextHeadline;

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

  // Native window chrome follows the resolved scheme, including a live OS change
  addPostFrameCallback((timeStamp) {
    applyDesktopBrightness(snapshot.isDarkMode ? Brightness.dark : Brightness.light);
  });

  final kTextStyle = kTextOf(context);
  final kTextBoldStyle = kTextBoldOf(context);
  final kTextHeadlineStyle = kTextHeadlineOf(context);
  final kTextColor = kColorTextPrimary(context);
  final kFillTextColor = kColorTextOnFill(context);
  final kHoverColor = kColorSurfaceHover(context);

  final kButtonHoverStyle = CommonButtonHoverStyle(backgroundColor: kHoverColor, borderColor: kTextColor);

  final kButtonStyle = CommonButtonStyle(
    height: kButtonHeight,
    textStyle: kTextBoldStyle,
    filledTextStyle: kTextBoldStyle.copyWith(color: kFillTextColor),
    disabledTextStyle: kTextBoldStyle.copyWith(color: kFillTextColor),
    color: kTextColor,
    borderRadius: platformBorderRadius,
    preffixIconWidth: kIconSizeNotTouch,
    preffixIconHeight: kIconSizeNotTouch,
    loadingIconWidth: kIconSizeNotTouch,
    loadingIconHeight: kIconSizeNotTouch,
    hoverStyle: kButtonHoverStyle,
  );

  final kButtonFilledStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.filled,
    // Hover background is the surface hover, switch text to the text color for readability
    // Border blends into background, so hovered filled button stays a solid block unlike outlined one
    hoverStyle: kButtonHoverStyle.copyWith(
      borderColor: kHoverColor,
      filledTextStyle: kButtonStyle.filledTextStyle.copyWith(color: kTextColor),
    ),
  );

  final kButtonTextOnlyStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.textOnly,
    // Border blends into background, so hovered text-only button is highlighted without outline
    hoverStyle: kButtonHoverStyle.copyWith(borderColor: kHoverColor),
  );

  final kButtonDangerStyle = kButtonStyle.copyWith(
    variant: ButtonVariant.filled,
    // Red fill needs light text in both schemes
    filledTextStyle: kButtonStyle.filledTextStyle.copyWith(color: kColorTextOnDark),
    color: kColorDanger,
    // Darker red on hover, text is already light so it stays readable
    hoverStyle: CommonButtonHoverStyle(backgroundColor: kColorDangerHover, borderColor: kColorDangerHover),
  );

  final kListItemButtonStyle = kButtonTextOnlyStyle.copyWith(fullWidthMobileOnly: false, alignment: Alignment.centerLeft, textOverflow: TextOverflow.ellipsis);

  final kIconButtonHoverStyle = IconButtonHoverStyle(backgroundColor: kHoverColor, borderColor: kTextColor);

  final kIconButtonStyle = IconButtonStyle(
    width: kButtonHeight,
    height: kButtonHeight,
    iconWidth: kIconSizeNotTouch,
    iconHeight: kIconSizeNotTouch,
    loadingIconWidth: kIconSizeNotTouch,
    loadingIconHeight: kIconSizeNotTouch,
    color: kTextColor,
    borderRadius: platformBorderRadius,
    hoverStyle: kIconButtonHoverStyle,
  );

  final kIconButtonFilledStyle = kIconButtonStyle.copyWith(
    variant: IconButtonVariant.filled,
    iconColor: kFillTextColor,
    // Hover background is the surface hover, switch icon to the text color for readability and blend border like filled button
    hoverStyle: kIconButtonHoverStyle.copyWith(borderColor: kHoverColor, iconColor: kTextColor),
  );

  final kIconButtonRowActionStyle = kIconButtonStyle.copyWith(
    variant: IconButtonVariant.iconOnly,
    // Row actions are visible on hovered row which already uses the surface hover, so hover background is the surface to stand out
    hoverStyle: kIconButtonHoverStyle.copyWith(backgroundColor: kColorSurface(context)),
  );

  final kAppBarIconButtonStyle = IconButtonStyle(
    variant: IconButtonVariant.iconOnly,
    width: kButtonHeight,
    height: kButtonHeight,
    iconWidth: kIconSizeNotTouch,
    iconHeight: kIconSizeNotTouch,
    color: kTextColor,
    borderRadius: platformBorderRadius,
    // Icon only variant has no border, so only hover background is visible on app bar
    hoverStyle: kIconButtonHoverStyle,
  );

  final kDialogContainerStyle = DialogContainerStyle(
    mainAxisAlignment: dialogsMainAxisAlignment,
    backgroundColor: kColorSurface(context),
    borderRadius: platformBorderRadius,
  );

  final kConfirmDialogStyle = ConfirmDialogStyle(
    dialogContainerStyle: kDialogContainerStyle,
    dialogHeaderStyle: DialogHeaderStyle(textStyle: kTextHeadlineStyle),
    textStyle: kTextStyle,
    dialogFooterStyle: DialogFooterStyle(
      buttonStyle: kButtonStyle.copyWith(widthWrapContent: true, filledTextStyle: kButtonStyle.filledTextStyle.copyWith(color: kTextColor)),
      // All app confirm dialogs are danger, so Yes uses danger style including its hover
      yesButtonStyle: kButtonDangerStyle.copyWith(widthWrapContent: true),
      dangerColor: kColorDanger,
    ),
  );

  final OutlineInputBorder platformInputBorder = OutlineInputBorder(borderSide: const BorderSide(width: 1), borderRadius: platformBorderRadius);

  final kTextFormFieldStyle = TextFormFieldStyle(
    inputDecoration: TextFormFieldStyle().inputDecoration.copyWith(
      labelStyle: kTextBoldStyle,
      contentPadding: EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf, vertical: prefsInt(kPrefsFancyFont) == 1 ? 8 : 8),
      enabledBorder: platformInputBorder,
      disabledBorder: platformInputBorder,
      focusedBorder: platformInputBorder,
      errorBorder: platformInputBorder,
      focusedErrorBorder: platformInputBorder,
    ),
    inputStyle: kTextStyle,
    borderColor: kTextColor,
    focusedBorderColor: kTextColor,
    // Filled on hover like selection field and outlined buttons, border already uses the text color
    hoverStyle: TextFormFieldHoverStyle(fillColor: kHoverColor),
    textAlign: TextAlign.center,
  );

  final kListDialogStyle = ListDialogStyle(
    dialogContainerStyle: kDialogContainerStyle,
    optionStyle: kButtonTextOnlyStyle,
    selectedOptionStyle: kButtonFilledStyle,
    dialogHeaderStyle: DialogHeaderStyle(textStyle: kTextHeadlineStyle),
    dialogFooterStyle: DialogFooterStyle(
      buttonStyle: kButtonStyle.copyWith(
        widthWrapContent: true,
        iconColor: kColorWarning,
        loadingIconWidth: kIconSizeNotTouch,
        loadingIconHeight: kIconSizeNotTouch,
      ),
      // Filled Yes needs the text color on the surface hover background
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
    inputStyle: kTextFormFieldStyle.copyWith(inputDecoration: kTextFormFieldStyle.inputDecoration.copyWith(fillColor: kHoverColor.withValues(alpha: 0))),
    // Filled on hover like outlined buttons, border already uses the text color
    hoverStyle: SelectionFormFieldHoverStyle(
      inputStyle: kTextFormFieldStyle.copyWith(inputDecoration: kTextFormFieldStyle.inputDecoration.copyWith(fillColor: kHoverColor)),
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
    labelStyle: kTextBoldStyle,
    descriptionStyle: kTextStyle,
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
      decoration: BoxDecoration(color: kColorOverlay, borderRadius: platformBorderRadius),
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
