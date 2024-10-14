import 'package:js_trions/core/app_theme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ChipWidget extends StatelessWidget {
  final ChipVariant variant;
  final String text;
  final Widget suffixIcon;
  final GestureTapCallback? onTap;

  /// ChipWidget initialization
  ChipWidget({
    this.variant = ChipVariant.BothPadded,
    required this.text,
    required this.suffixIcon,
    this.onTap,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    Widget chip = Container(
      height: kButtonHeight,
      padding: variant == ChipVariant.BothPadded
          ? const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf)
          : const EdgeInsets.only(left: kCommonHorizontalMarginHalf),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: kColorTextPrimary,
        ),
        borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: fancyText(kText),
          ),
          CommonSpaceHHalf(),
          suffixIcon,
        ],
      ),
    );

    if (onTap != null) {
      chip = ClipRRect(
        borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius ?? BorderRadius.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            child: chip,
            onTap: onTap,
          ),
        ),
      );
    }

    return chip;
  }
}

enum ChipVariant {
  LeftPadded,
  BothPadded,
}
