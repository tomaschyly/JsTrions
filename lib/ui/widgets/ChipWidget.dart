import 'package:js_trions/core/app_theme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ChipWidget extends AbstractStatefulWidget {
  final ChipVariant variant;
  final String text;
  final Widget suffixIcon;
  final GestureTapCallback? onTap;

  /// ChipWidget initialization
  const ChipWidget({super.key, this.variant = ChipVariant.bothPadded, required this.text, required this.suffixIcon, this.onTap});

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ChipWidgetState();
}

class _ChipWidgetState extends AbstractStatefulWidgetState<ChipWidget> {
  bool _isHovered = false;

  /// Widget parameters changed
  @override
  void didUpdateWidget(covariant ChipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // InkWell without onTap does not report hover exit, so stale hover would remain once chip becomes tappable again
    if (widget.onTap == null) {
      _isHovered = false;
    }
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final animationDuration = commonTheme.buttonsStyle.buttonStyle.animationDuration;
    final animationCurve = commonTheme.buttonsStyle.buttonStyle.animationCurve;

    Widget chip = AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      height: kButtonHeight,
      padding: widget.variant == ChipVariant.bothPadded
          ? const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf)
          : const EdgeInsets.only(left: kCommonHorizontalMarginHalf),
      decoration: BoxDecoration(
        // Transparent variant of hover color, so hover animation only fades opacity
        color: _isHovered ? kColorPrimaryLightHover : kColorPrimaryLightHover.withValues(alpha: 0),
        border: Border.all(width: 1, color: kColorTextPrimary),
        borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.text, style: fancyText(kText)),
          CommonSpaceHHalf(),
          widget.suffixIcon,
        ],
      ),
    );

    if (widget.onTap != null) {
      chip = ClipRRect(
        borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius ?? BorderRadius.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            // Hover is drawn by chip background, default InkWell hover overlay would double it
            hoverColor: Colors.transparent,
            onHover: _setHoverState,
            onTap: widget.onTap,
            child: chip,
          ),
        ),
      );
    }

    return chip;
  }

  /// Update hover state and rebuild only when value changes
  void _setHoverState(bool isHovered) {
    if (_isHovered == isHovered) {
      return;
    }

    setStateNotDisposed(() {
      _isHovered = isHovered;
    });
  }
}

enum ChipVariant { leftPadded, bothPadded }
