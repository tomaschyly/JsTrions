import 'dart:math';

import 'package:flutter_svg/svg.dart';
import 'package:js_trions/core/app_theme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ToggleContainerWidget extends AbstractStatefulWidget {
  final String title;
  final Widget content;
  final bool borderLess;

  /// ToggleContainerWidget initialization
  const ToggleContainerWidget({super.key, required this.title, required this.content, this.borderLess = false});

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ToggleContainerWidgetState();
}

class _ToggleContainerWidgetState extends AbstractStatefulWidgetState<ToggleContainerWidget> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isOpen = false;
  bool _isHovered = false;

  /// State initialization
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, upperBound: 0.5, duration: kThemeAnimationDuration);
  }

  /// Dispose of resource manually
  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    // Header is inset by 1px container border, so its radius is reduced to follow inner border curve
    final borderRadius = commonTheme.buttonsStyle.buttonStyle.borderRadius ?? BorderRadius.zero;
    final headerRadius = Radius.circular(max(0, borderRadius.topLeft.x - 1));
    final headerBorderRadius = _isOpen ? BorderRadius.vertical(top: headerRadius) : BorderRadius.all(headerRadius);

    return ClipRRect(
      borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius ?? BorderRadius.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius,
          border: Border.all(width: 1, color: widget.borderLess ? Colors.transparent : (commonTheme.buttonsStyle.buttonStyle.color ?? Colors.transparent)),
        ),
        child: AnimatedSize(
          duration: kThemeAnimationDuration,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Background is below Material, so InkWell splash stays visible above hover color
              AnimatedContainer(
                duration: commonTheme.buttonsStyle.buttonStyle.animationDuration,
                curve: commonTheme.buttonsStyle.buttonStyle.animationCurve,
                decoration: BoxDecoration(
                  // Transparent variant of hover color, so hover animation only fades opacity
                  color: _isHovered ? kColorPrimaryLightHover : kColorPrimaryLightHover.withValues(alpha: 0),
                  borderRadius: headerBorderRadius,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    borderRadius: headerBorderRadius,
                    // Hover is drawn by animated background, default InkWell hover overlay would double it
                    hoverColor: Colors.transparent,
                    onHover: _setHoverState,
                    child: Container(
                      height: commonTheme.buttonsStyle.iconButtonStyle.height,
                      padding: const EdgeInsets.only(left: kCommonHorizontalMarginHalf),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.title, style: fancyText(kTextBold)),
                          CommonSpaceH(),
                          const Spacer(),
                          SizedBox(
                            width: commonTheme.buttonsStyle.iconButtonStyle.width,
                            height: commonTheme.buttonsStyle.iconButtonStyle.height,
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (BuildContext context, Widget? child) {
                                  return Transform.rotate(angle: _animationController.value * 2 * pi, child: child);
                                },
                                child: SvgPicture.asset(
                                  // _isOpen ? 'images/chevron-up.svg' : 'images/chevron-down.svg',
                                  'images/chevron-down.svg',
                                  width: commonTheme.buttonsStyle.iconButtonStyle.iconWidth,
                                  height: commonTheme.buttonsStyle.iconButtonStyle.iconHeight,
                                  colorFilter: ColorFilter.mode(commonTheme.buttonsStyle.iconButtonStyle.color ?? Colors.transparent, BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      setStateNotDisposed(() {
                        _isOpen = !_isOpen;

                        if (_isOpen) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
                      });
                    },
                  ),
                ),
              ),
              if (_isOpen) ...[CommonSpaceV(), widget.content],
            ],
          ),
        ),
      ),
    );
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
